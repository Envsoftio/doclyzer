import { isUUID } from 'class-validator';
import { randomUUID } from 'node:crypto';
import {
  BadRequestException,
  ConflictException,
  GoneException,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { DataSource, type EntityManager } from 'typeorm';
import type { FileStorageService } from '../../../common/storage/file-storage.interface';
import {
  ALLOWED_UPLOAD_CONTENT_TYPES,
  MAX_REPORT_SIZE_BYTES,
} from '../reports.types';
import {
  acceptedSourceHash,
  type ProcessingState,
} from './report-processing.contract';
import { appendReportEvent } from './report-event.store';
import { reportSourceStorageKey } from './report-storage-key';

export interface AdmissionPolicy {
  maxAttempts: number;
  processingDeadlineMs: number;
  uploadDeadlineMs: number;
  idempotencyRetentionMs: number;
  cleanupRetryMs: number;
}
export interface ReportAdmissionInput {
  userId: string;
  profileId: string;
  idempotencyKey: string;
  file: { buffer: Buffer; originalname: string; mimetype: string };
}
export interface AcceptedReport {
  reportId: string;
  profileId: string;
  version: string;
  status: ProcessingState;
  reused: boolean;
}

/** Internal v2 admission primitive. Not exposed until the async worker is ready. */
export class ReportAdmissionService {
  constructor(
    private readonly db: DataSource,
    private readonly storage: FileStorageService,
    private readonly policy: AdmissionPolicy,
  ) {
    if (db.options.type !== 'postgres' || db.options.extra?.usePgMem) {
      throw new Error('Durable report admission requires PostgreSQL');
    }
    if (storage.durability !== 'durable') {
      throw new Error(
        'Durable report admission requires persistent object storage',
      );
    }
    for (const key of [
      'maxAttempts',
      'processingDeadlineMs',
      'uploadDeadlineMs',
      'idempotencyRetentionMs',
      'cleanupRetryMs',
    ] as const) {
      const value = policy[key];
      if (!Number.isSafeInteger(value) || value <= 0)
        throw new Error('Admission budgets must be positive integers');
    }
    if (
      policy.maxAttempts > 100 ||
      Object.values(policy).some((value) => value > 2147483647)
    ) {
      throw new Error('Admission budgets exceed supported bounds');
    }
  }

  async accept(input: ReportAdmissionInput): Promise<AcceptedReport> {
    this.validate(input);
    const hash = acceptedSourceHash(input.file.buffer);
    // Include content type: identical bytes interpreted differently are a different request.
    const requestHash = acceptedSourceHash(
      Buffer.from(
        JSON.stringify([
          'report_upload_v2',
          input.profileId,
          hash,
          input.file.mimetype,
        ]),
      ),
    );
    // Lost-response recovery works even when object storage is currently unavailable.
    const replay = await this.db.transaction(async (manager) => {
      await this.lockAccount(manager, input.userId);
      await this.authorizeProfile(manager, input);
      return this.replay(manager, input, requestHash);
    });
    if (replay) return replay;

    const intentId = randomUUID();
    const reportId = randomUUID();
    const key = reportSourceStorageKey(
      input.userId,
      input.profileId,
      reportId,
      input.file.mimetype,
    );
    await this.db.query(
      `INSERT INTO report_upload_intents
      (id,user_id,storage_key,abandon_after,cleanup_after) VALUES
      ($1,$2,$3,clock_timestamp()+$4*interval '1 millisecond',clock_timestamp()+$4*interval '1 millisecond')`,
      [intentId, input.userId, key, this.policy.uploadDeadlineMs],
    );
    // No DB locks during storage I/O. On failure/timeout, keep the intent: the
    // upload may have succeeded despite response loss. The sweeper owns cleanup.
    await this.storage.upload(key, input.file.buffer, input.file.mimetype);
    return this.db.transaction(async (manager) => {
      await this.lockAccount(manager, input.userId);
      await this.authorizeProfile(manager, input);
      const existingRequest = await this.replay(manager, input, requestHash);
      if (existingRequest) return existingRequest;
      const [intent] = await manager.query(
        `SELECT id FROM report_upload_intents
        WHERE id=$1 AND state='pending' AND abandon_after > clock_timestamp() FOR UPDATE`,
        [intentId],
      );
      if (!intent)
        throw new ServiceUnavailableException({
          code: 'REPORT_UPLOAD_EXPIRED',
          message: 'Upload acceptance expired; retry with the same key.',
        });

      // Lock the report too: a terminal transition may release its content claim
      // while this request waits. If it completed, return the completed duplicate.
      const [existing] = await manager.query(
        `SELECT r.* FROM reports r
        WHERE r.user_id=$1 AND r.profile_id=$2 AND r.source_hash=$3 AND r.source_hash_version=1
          AND r.deleted_at IS NULL AND r.processing_state IN ('queued','processing','retry_scheduled','ready','needs_attention')
        ORDER BY r.created_at DESC LIMIT 1 FOR UPDATE OF r`,
        [input.userId, input.profileId, hash],
      );
      if (existing) {
        await this.recordRequest(manager, input, requestHash, existing.id);
        return this.response(existing, true);
      }
      await this.reserveQuota(manager, input.userId);
      const [report] = await manager.query(
        `INSERT INTO reports
        (id,user_id,profile_id,original_file_name,content_type,size_bytes,original_file_storage_key,
         status,source_hash,source_hash_version,processing_state,processing_generation,processing_version,
         processing_stage,processing_accepted_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7,'queued',$8,1,'queued',1,1,'queued',clock_timestamp()) RETURNING *`,
        [
          reportId,
          input.userId,
          input.profileId,
          input.file.originalname,
          input.file.mimetype,
          input.file.buffer.length,
          key,
          hash,
        ],
      );
      await manager.query(
        `INSERT INTO report_processing_content_claims VALUES ($1,$2,$3,1,$4)`,
        [input.userId, input.profileId, hash, reportId],
      );
      await manager.query(
        `INSERT INTO report_processing_jobs
        (id,report_id,generation,trigger,max_attempts,deadline_at) VALUES ($1,$2,1,'initial_upload',$3,clock_timestamp()+$4*interval '1 millisecond')`,
        [
          randomUUID(),
          reportId,
          this.policy.maxAttempts,
          this.policy.processingDeadlineMs,
        ],
      );
      await this.recordRequest(manager, input, requestHash, reportId);
      await manager.query(
        `UPDATE report_upload_intents SET state='accepted' WHERE id=$1`,
        [intentId],
      );
      await appendReportEvent(manager, input.userId, {
        schemaVersion: 1,
        reportId,
        profileId: input.profileId,
        generation: 1,
        version: '1',
        status: 'queued',
        stage: 'queued',
      });
      return this.response(report, false);
    });
  }

  /** Bounded orphan cleanup. Abandoned intents remain tombstones for late PUTs. */
  async sweepOrphans(
    limit = 100,
  ): Promise<{ inspected: number; deleted: number; failed: number }> {
    if (!Number.isInteger(limit) || limit < 1 || limit > 1000)
      throw new Error('Invalid cleanup batch size');
    const intents: { id: string; storage_key: string }[] =
      await this.db.transaction(async (manager) => {
        const rows = await manager.query(
          `SELECT i.id,i.storage_key FROM report_upload_intents i
        WHERE i.cleanup_after <= clock_timestamp()
          AND i.abandon_after <= clock_timestamp()
          AND NOT EXISTS (SELECT 1 FROM reports r WHERE r.original_file_storage_key=i.storage_key)
        ORDER BY i.cleanup_after LIMIT $1 FOR UPDATE OF i SKIP LOCKED`,
          [limit],
        );
        for (const row of rows)
          await manager.query(
            `UPDATE report_upload_intents SET state='abandoned',
        cleanup_attempts=cleanup_attempts+1,cleanup_after=clock_timestamp()+$2*interval '1 millisecond'
        WHERE id=$1`,
            [row.id, this.policy.cleanupRetryMs],
          );
        return rows;
      });
    let deleted = 0,
      failed = 0;
    for (const intent of intents) {
      try {
        await this.storage.delete(intent.storage_key, { allVersions: true });
        await this.db.query(
          `UPDATE report_upload_intents SET last_cleanup_at=clock_timestamp() WHERE id=$1`,
          [intent.id],
        );
        deleted++;
      } catch {
        failed++;
      } // Return failures for operational alerting; never log object/provider contents.
    }
    return { inspected: intents.length, deleted, failed };
  }

  private async lockAccount(
    manager: EntityManager,
    userId: string,
  ): Promise<void> {
    const [user] = await manager.query(
      'SELECT id FROM users WHERE id=$1 AND deletion_requested_at IS NULL FOR NO KEY UPDATE',
      [userId],
    );
    if (!user) throw new NotFoundException();
  }
  private async authorizeProfile(
    manager: EntityManager,
    input: ReportAdmissionInput,
  ): Promise<void> {
    const [profile] = await manager.query(
      'SELECT id FROM profiles WHERE id=$1 AND user_id=$2 FOR SHARE',
      [input.profileId, input.userId],
    );
    if (!profile) throw new NotFoundException();
  }
  private async replay(
    manager: EntityManager,
    input: ReportAdmissionInput,
    hash: string,
  ): Promise<AcceptedReport | null> {
    const [request] = await manager.query(
      `SELECT *,expires_at <= clock_timestamp() AS expired
      FROM report_upload_requests WHERE user_id=$1 AND operation='report_upload_v2' AND idempotency_key=$2`,
      [input.userId, input.idempotencyKey],
    );
    if (!request) return null;
    if (request.request_hash !== hash)
      throw new ConflictException({
        code: 'REPORT_IDEMPOTENCY_CONFLICT',
        message: 'Key already bound to a different upload.',
      });
    // Retain keys as tombstones rather than silently reusing an expired key.
    if (request.expired)
      throw new GoneException({
        code: 'REPORT_IDEMPOTENCY_EXPIRED',
        message:
          'This upload request expired. Select the file again to start a new upload.',
      });
    const [report] = await manager.query(
      'SELECT * FROM reports WHERE id=$1 AND user_id=$2 AND profile_id=$3 AND deleted_at IS NULL',
      [request.report_id, input.userId, input.profileId],
    );
    if (!report)
      throw new GoneException({
        code: 'REPORT_UPLOAD_REMOVED',
        message: 'The accepted report is no longer available.',
      });
    return this.response(report, true);
  }
  private async recordRequest(
    manager: EntityManager,
    input: ReportAdmissionInput,
    hash: string,
    reportId: string,
  ): Promise<void> {
    await manager.query(
      `INSERT INTO report_upload_requests
      (user_id,operation,idempotency_key,request_hash,profile_id,report_id,expires_at)
      VALUES ($1,'report_upload_v2',$2,$3,$4,$5,clock_timestamp()+$6*interval '1 millisecond')`,
      [
        input.userId,
        input.idempotencyKey,
        hash,
        input.profileId,
        reportId,
        this.policy.idempotencyRetentionMs,
      ],
    );
  }
  private async reserveQuota(
    manager: EntityManager,
    userId: string,
  ): Promise<void> {
    // Reuse existing plan/entitlement data. Report uploads currently have no
    // credit debit; the pending report row itself is the quota reservation.
    const [entitlement] = await manager.query(
      `SELECT plan_id FROM user_entitlements WHERE user_id=$1 FOR UPDATE`,
      [userId],
    );
    if (!entitlement)
      throw new ServiceUnavailableException({
        code: 'REPORT_ENTITLEMENT_REQUIRED',
        message: 'Provision account entitlements before accepting uploads.',
      });
    const [plan] = await manager.query(
      `SELECT limits FROM plans WHERE id=$1 FOR SHARE`,
      [entitlement.plan_id],
    );
    const max = plan?.limits?.maxReports;
    if (!Number.isSafeInteger(max) || max < 0)
      throw new ServiceUnavailableException({ code: 'REPORT_PLAN_INVALID' });
    const [usage] = await manager.query(
      `SELECT count(*)::integer AS count FROM reports WHERE user_id=$1 AND deleted_at IS NULL
      AND (status='parsed' OR processing_state IN ('queued','processing','retry_scheduled'))`,
      [userId],
    );
    if (usage.count >= max)
      throw new ConflictException({
        code: 'REPORT_LIMIT_EXCEEDED',
        message: 'Report allowance is fully reserved.',
      });
  }
  private response(
    report: {
      id: string;
      profile_id: string;
      processing_version: string;
      processing_state: ProcessingState;
    },
    reused: boolean,
  ): AcceptedReport {
    return {
      reportId: report.id,
      profileId: report.profile_id,
      version: report.processing_version,
      status: report.processing_state,
      reused,
    };
  }
  private validate(input: ReportAdmissionInput): void {
    if (!isUUID(input.userId) || !isUUID(input.profileId))
      throw new BadRequestException({ code: 'REPORT_OWNER_INVALID' });
    if (!/^[A-Za-z0-9._:-]{1,128}$/.test(input.idempotencyKey ?? ''))
      throw new BadRequestException({ code: 'REPORT_IDEMPOTENCY_KEY_INVALID' });
    if (
      !input.file?.buffer?.length ||
      input.file.buffer.length > MAX_REPORT_SIZE_BYTES
    )
      throw new BadRequestException({ code: 'REPORT_FILE_SIZE_INVALID' });
    if (
      !(ALLOWED_UPLOAD_CONTENT_TYPES as readonly string[]).includes(
        input.file.mimetype,
      )
    )
      throw new BadRequestException({ code: 'REPORT_FILE_TYPE_UNSUPPORTED' });
    if (
      !input.file.originalname?.trim() ||
      input.file.originalname.length > 512
    )
      throw new BadRequestException({ code: 'REPORT_FILE_NAME_INVALID' });
  }
}
