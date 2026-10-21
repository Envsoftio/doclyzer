import { randomUUID } from 'node:crypto';
import { DataSource, type EntityManager } from 'typeorm';
import { appendReportEvent } from './report-event.store';
import {
  legacyReportStatus,
  type ProcessingState,
} from './report-processing.contract';

export interface ReportJobLease {
  jobId: string;
  reportId: string;
  generation: number;
  token: string;
  attempt: number;
  executionId: string;
}
export type ProcessingErrorCode =
  | 'SOURCE_UNAVAILABLE'
  | 'PROVIDER_UNAVAILABLE'
  | 'INVALID_CONTENT'
  | 'PROCESSING_DEADLINE'
  | 'ATTEMPTS_EXHAUSTED'
  | 'WORKER_INTERRUPTED';
export class ReportLeaseLostError extends Error {
  constructor() {
    super('Report processing lease is no longer current');
  }
}
interface JobRow {
  id: string;
  report_id: string;
  generation: number;
  attempt_count: number;
  max_attempts: number;
  lease_token: string | null;
  deadline_expired: boolean;
}
interface ReportRow {
  id: string;
  user_id: string;
  profile_id: string;
  processing_generation: number;
  processing_version: string;
  processing_state: ProcessingState;
  deleted_at: Date | null;
}

/** SQL queue primitives. Transactions never include OCR or other network work. */
export class ReportJobStore {
  constructor(
    private readonly db: DataSource,
    private readonly leaseMs: number,
  ) {
    if (db.options.type !== 'postgres' || db.options.extra?.usePgMem)
      throw new Error('Report jobs require PostgreSQL');
    if (!Number.isSafeInteger(leaseMs) || leaseMs < 1 || leaseMs > 2147483647)
      throw new Error('Invalid lease lifetime');
  }

  /** Also reconciles one expired/deleted/superseded job per invocation. */
  async claim(): Promise<ReportJobLease | null> {
    return this.db.transaction(async (manager) => {
      const [job]: JobRow[] =
        await manager.query(`SELECT j.*,j.deadline_at <= clock_timestamp() AS deadline_expired
        FROM report_processing_jobs j WHERE
          (j.state IN ('queued','retry_scheduled') AND (j.available_at <= clock_timestamp() OR j.deadline_at <= clock_timestamp()))
          OR (j.state='leased' AND j.lease_expires_at <= clock_timestamp())
        ORDER BY j.available_at,j.id LIMIT 1 FOR UPDATE OF j SKIP LOCKED`);
      if (!job) return null;
      const [report]: ReportRow[] = await manager.query(
        'SELECT * FROM reports WHERE id=$1 FOR UPDATE',
        [job.report_id],
      );
      if (job.lease_token)
        await this.endExecution(
          manager,
          job.lease_token,
          'lease_expired',
          'WORKER_INTERRUPTED',
        );
      const obsolete =
        !report ||
        report.deleted_at ||
        report.processing_generation !== job.generation ||
        !['queued', 'processing', 'retry_scheduled'].includes(
          report.processing_state,
        );
      if (
        obsolete ||
        job.deadline_expired ||
        job.attempt_count >= job.max_attempts
      ) {
        const state = obsolete ? 'cancelled' : 'failed';
        const error = obsolete
          ? null
          : job.deadline_expired
            ? 'PROCESSING_DEADLINE'
            : 'ATTEMPTS_EXHAUSTED';
        await this.closeJob(manager, job.id, state, error);
        if (
          report &&
          report.processing_generation === job.generation &&
          ['queued', 'processing', 'retry_scheduled'].includes(
            report.processing_state,
          )
        ) {
          await this.transition(manager, report, state, error);
        }
        return null;
      }
      const token = randomUUID(),
        executionId = randomUUID();
      await manager.query(
        `UPDATE report_processing_jobs SET state='leased',attempt_count=attempt_count+1,
        lease_token=$2,heartbeat_at=clock_timestamp(),lease_expires_at=LEAST(deadline_at,clock_timestamp()+$3*interval '1 millisecond') WHERE id=$1`,
        [job.id, token, this.leaseMs],
      );
      await manager.query(
        `INSERT INTO report_job_executions(id,job_id,attempt_number,lease_token) VALUES ($1,$2,$3,$4)`,
        [executionId, job.id, job.attempt_count + 1, token],
      );
      await this.transition(manager, report, 'processing', null);
      return {
        jobId: job.id,
        reportId: job.report_id,
        generation: job.generation,
        token,
        attempt: job.attempt_count + 1,
        executionId,
      };
    });
  }

  async heartbeat(lease: ReportJobLease): Promise<boolean> {
    const rows = await this.db.query(
      `UPDATE report_processing_jobs j SET heartbeat_at=clock_timestamp(),
      lease_expires_at=LEAST(j.deadline_at,clock_timestamp()+$5*interval '1 millisecond')
      FROM reports r WHERE j.id=$1 AND j.report_id=$2 AND j.generation=$3 AND j.lease_token=$4
        AND j.state='leased' AND j.lease_expires_at > clock_timestamp() AND j.deadline_at > clock_timestamp()
        AND r.id=j.report_id AND r.processing_generation=j.generation AND r.deleted_at IS NULL
        AND r.processing_state='processing' RETURNING j.id`,
      [
        lease.jobId,
        lease.reportId,
        lease.generation,
        lease.token,
        this.leaseMs,
      ],
    );
    // TypeORM returns [rows, affectedCount] for raw UPDATE statements.
    return rows[1] === 1;
  }

  async extendDeadline(
    lease: ReportJobLease,
    budgetMs: number,
  ): Promise<Date> {
    const result = await this.db.query(
      `UPDATE report_processing_jobs j SET
       deadline_at=GREATEST(j.deadline_at,j.created_at+$5*interval '1 millisecond'),
       lease_expires_at=GREATEST(j.lease_expires_at,LEAST(j.created_at+$5*interval '1 millisecond',clock_timestamp()+$6*interval '1 millisecond'))
       FROM reports r WHERE j.id=$1 AND j.report_id=$2 AND j.generation=$3
       AND j.lease_token=$4 AND j.state='leased' AND j.lease_expires_at>clock_timestamp()
       AND j.deadline_at>clock_timestamp() AND r.id=j.report_id
       AND r.processing_generation=j.generation AND r.deleted_at IS NULL
       RETURNING j.deadline_at`,
      [lease.jobId, lease.reportId, lease.generation, lease.token, budgetMs, this.leaseMs],
    );
    if (result[1] !== 1) throw new ReportLeaseLostError();
    return new Date(result[0][0].deadline_at);
  }

  async setStage(lease: ReportJobLease, stage: 'normalizing'): Promise<void> {
    await this.db.transaction(async (manager) => {
      const { report } = await this.lockLease(manager, lease);
      const [rows] = await manager.query(
        'UPDATE reports SET processing_stage=$2,processing_version=processing_version+1 WHERE id=$1 RETURNING processing_version',
        [report.id, stage],
      );
      await appendReportEvent(manager, report.user_id, {
        schemaVersion: 1,
        reportId: report.id,
        profileId: report.profile_id,
        generation: report.processing_generation,
        version: rows[0].processing_version,
        status: 'processing',
        stage,
      });
    });
  }

  async complete(
    lease: ReportJobLease,
    outcome: 'ready' | 'needs_attention',
    persistResults: (manager: EntityManager) => Promise<void>,
  ): Promise<void> {
    await this.db.transaction(async (manager) => {
      const { report } = await this.lockLease(manager, lease);
      const [{ count }] = await manager.query(
        `SELECT count(*)::integer AS count FROM report_lab_values WHERE report_id=$1 AND review_version > 0`,
        [lease.reportId],
      );
      if (count > 0)
        throw new Error('Reviewed report results cannot be replaced');
      // All normalized results must be written through this manager. Failure or
      // lease expiry rolls back the results along with status/events/outcome.
      await persistResults(manager);
      await this.assertUnexpired(manager, lease);
      await this.closeJob(manager, lease.jobId, 'succeeded', null);
      await this.endExecution(
        manager,
        lease.token,
        outcome === 'ready' ? 'succeeded' : 'needs_attention',
        null,
      );
      await this.transition(manager, report, outcome, null);
    });
  }

  async fail(
    lease: ReportJobLease,
    error: ProcessingErrorCode,
    retryDelayMs: number | null,
  ): Promise<void> {
    if (
      retryDelayMs !== null &&
      (!Number.isSafeInteger(retryDelayMs) ||
        retryDelayMs < 1 ||
        retryDelayMs > 2147483647)
    )
      throw new Error('Invalid retry delay');
    await this.db.transaction(async (manager) => {
      const { job, report } = await this.lockLease(manager, lease);
      const [{ eligible }] = await manager.query(
        `SELECT deadline_at > clock_timestamp()+$2*interval '1 millisecond' AS eligible FROM report_processing_jobs WHERE id=$1`,
        [lease.jobId, retryDelayMs ?? 0],
      );
      const retry =
        retryDelayMs !== null &&
        job.attempt_count < job.max_attempts &&
        eligible;
      if (retry) {
        await manager.query(
          `UPDATE report_processing_jobs SET state='retry_scheduled',available_at=clock_timestamp()+$2*interval '1 millisecond',
          lease_token=NULL,lease_expires_at=NULL,heartbeat_at=NULL,error_code=$3 WHERE id=$1`,
          [lease.jobId, retryDelayMs, error],
        );
      } else await this.closeJob(manager, lease.jobId, 'failed', error);
      await this.endExecution(
        manager,
        lease.token,
        retry ? 'retry_scheduled' : 'failed',
        error,
      );
      await this.transition(
        manager,
        report,
        retry ? 'retry_scheduled' : 'failed',
        error,
      );
    });
  }

  private async lockLease(
    manager: EntityManager,
    lease: ReportJobLease,
  ): Promise<{ job: JobRow; report: ReportRow }> {
    const [job]: JobRow[] = await manager.query(
      `SELECT *,deadline_at <= clock_timestamp() AS deadline_expired FROM report_processing_jobs
      WHERE id=$1 AND report_id=$2 AND generation=$3 AND lease_token=$4 AND state='leased'
      AND lease_expires_at > clock_timestamp() AND deadline_at > clock_timestamp() FOR UPDATE`,
      [lease.jobId, lease.reportId, lease.generation, lease.token],
    );
    if (!job) throw new ReportLeaseLostError();
    const [report]: ReportRow[] = await manager.query(
      `SELECT * FROM reports WHERE id=$1 AND processing_generation=$2
      AND processing_state='processing' AND deleted_at IS NULL FOR UPDATE`,
      [lease.reportId, lease.generation],
    );
    if (!report) throw new ReportLeaseLostError();
    await this.assertUnexpired(manager, lease);
    return { job, report };
  }
  private async assertUnexpired(
    manager: EntityManager,
    lease: ReportJobLease,
  ): Promise<void> {
    const [valid] = await manager.query(
      `SELECT id FROM report_processing_jobs WHERE id=$1 AND lease_token=$2
      AND state='leased' AND lease_expires_at > clock_timestamp() AND deadline_at > clock_timestamp()`,
      [lease.jobId, lease.token],
    );
    if (!valid) throw new ReportLeaseLostError();
  }
  private async closeJob(
    manager: EntityManager,
    id: string,
    state: string,
    error: string | null,
  ): Promise<void> {
    await manager.query(
      `UPDATE report_processing_jobs SET state=$2,error_code=$3,completed_at=clock_timestamp(),
      lease_token=NULL,lease_expires_at=NULL,heartbeat_at=NULL WHERE id=$1`,
      [id, state, error],
    );
  }
  private async endExecution(
    manager: EntityManager,
    token: string,
    outcome: string,
    error: string | null,
  ): Promise<void> {
    await manager.query(
      `UPDATE report_job_executions SET outcome=$2,error_code=$3,finished_at=clock_timestamp()
      WHERE lease_token=$1 AND outcome='running'`,
      [token, outcome, error],
    );
  }
  private async transition(
    manager: EntityManager,
    report: ReportRow,
    state: ProcessingState,
    error: string | null,
  ): Promise<void> {
    const terminal = [
      'ready',
      'needs_attention',
      'failed',
      'cancelled',
    ].includes(state);
    const stage = terminal
      ? 'complete'
      : state === 'processing'
        ? 'extracting'
        : 'queued';
    const [updated] = await manager.query(
      `UPDATE reports SET processing_state=$2::varchar,status=$3,processing_stage=$4,
      processing_error_code=$5,processing_version=processing_version+1,
      processing_started_at=CASE WHEN $2::varchar='processing' THEN COALESCE(processing_started_at,clock_timestamp()) ELSE processing_started_at END,
      processing_completed_at=CASE WHEN $6 THEN clock_timestamp() ELSE NULL END,
      processing_retry_at=CASE WHEN $2::varchar='retry_scheduled' THEN
        (SELECT available_at FROM report_processing_jobs WHERE report_id=$1 AND generation=processing_generation) ELSE NULL END
      WHERE id=$1 RETURNING processing_version`,
      [report.id, state, legacyReportStatus[state], stage, error, terminal],
    );
    // Raw UPDATE returns [rows,count].
    const version = updated[0].processing_version as string;
    if (terminal)
      await manager.query(
        'DELETE FROM report_processing_content_claims WHERE report_id=$1',
        [report.id],
      );
    await appendReportEvent(manager, report.user_id, {
      schemaVersion: 1,
      reportId: report.id,
      profileId: report.profile_id,
      generation: report.processing_generation,
      version,
      status: state,
      stage,
    });
  }
}
