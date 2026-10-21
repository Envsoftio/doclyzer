import { ConflictException, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { DataSource } from 'typeorm';
import { appendReportEvent } from './report-event.store';
import type { AdmissionPolicy } from './report-admission.service';
import { reportDeadlineMs } from './report-deadline';

export async function cancelReportProcessing(
  db: DataSource,
  userId: string,
  reportId: string,
  deleted: boolean,
): Promise<void> {
  await db.transaction(async (m) => {
    await m.query(
      'SELECT id FROM report_processing_jobs WHERE report_id=$1 FOR UPDATE',
      [reportId],
    );
    const [r] = await m.query(
      'SELECT * FROM reports WHERE id=$1 AND user_id=$2 FOR UPDATE',
      [reportId, userId],
    );
    if (!r || !r.processing_generation) throw new NotFoundException();
    await m.query(
      `UPDATE report_job_executions SET outcome='cancelled',finished_at=clock_timestamp() WHERE job_id IN(SELECT id FROM report_processing_jobs WHERE report_id=$1) AND outcome='running'`,
      [reportId],
    );
    await m.query(
      `UPDATE report_processing_jobs SET state='cancelled',lease_token=NULL,lease_expires_at=NULL,heartbeat_at=NULL,completed_at=clock_timestamp(),staged_result=NULL
      WHERE report_id=$1 AND state IN ('queued','leased','retry_scheduled')`,
      [reportId],
    );
    await m.query(
      'DELETE FROM report_ocr_page_checkpoints WHERE job_id IN (SELECT id FROM report_processing_jobs WHERE report_id=$1)',
      [reportId],
    );
    await m.query(
      'DELETE FROM report_processing_content_claims WHERE report_id=$1',
      [reportId],
    );
    if (r.processing_state !== 'cancelled' || (deleted && !r.deleted_at)) {
      const [rows] = await m.query(
        `UPDATE reports SET processing_state='cancelled',processing_stage='complete',processing_version=processing_version+1,
        processing_completed_at=clock_timestamp(),processing_retry_at=NULL,
        deleted_at=CASE WHEN $2 THEN clock_timestamp() ELSE deleted_at END,
        purge_after_at=CASE WHEN $2 THEN clock_timestamp()+interval '30 days' ELSE purge_after_at END
        WHERE id=$1 RETURNING processing_version`,
        [reportId, deleted],
      );
      await appendReportEvent(m, userId, {
        schemaVersion: 1,
        reportId,
        profileId: r.profile_id,
        generation: r.processing_generation,
        version: rows[0].processing_version,
        status: 'cancelled',
        stage: 'complete',
      });
    }
  });
}
export async function retryReportProcessing(
  db: DataSource,
  userId: string,
  reportId: string,
  policy: AdmissionPolicy,
): Promise<void> {
  await db.transaction(async (m) => {
    await m.query('SELECT id FROM users WHERE id=$1 FOR NO KEY UPDATE', [
      userId,
    ]);
    await m.query(
      'SELECT id FROM report_processing_jobs WHERE report_id=$1 FOR UPDATE',
      [reportId],
    );
    const [r] = await m.query(
      'SELECT * FROM reports WHERE id=$1 AND user_id=$2 AND deleted_at IS NULL FOR UPDATE',
      [reportId, userId],
    );
    if (!r || !r.processing_generation) throw new NotFoundException();
    if (
      ['queued', 'processing', 'retry_scheduled'].includes(r.processing_state)
    )
      return;
    if (r.status === 'parsed')
      throw new ConflictException({
        code: 'REPORT_ALREADY_PARSED',
        message: 'Completed or reviewed results cannot be reprocessed.',
      });
    const [{ count }] = await m.query(
      'SELECT count(*)::integer AS count FROM report_lab_values WHERE report_id=$1 AND review_version>0',
      [reportId],
    );
    if (count) throw new ConflictException({ code: 'REPORT_HAS_CORRECTIONS' });
    const [entitlement] = await m.query(
      'SELECT plan_id FROM user_entitlements WHERE user_id=$1 FOR UPDATE',
      [userId],
    );
    const [plan] = await m.query(
      'SELECT limits FROM plans WHERE id=$1 FOR SHARE',
      [entitlement?.plan_id],
    );
    const [usage] = await m.query(
      `SELECT count(*)::integer AS count FROM reports WHERE user_id=$1 AND deleted_at IS NULL AND (status='parsed' OR processing_state IN ('queued','processing','retry_scheduled'))`,
      [userId],
    );
    if (!plan || usage.count >= plan.limits.maxReports)
      throw new ConflictException({ code: 'REPORT_LIMIT_EXCEEDED' });
    const [active] = await m.query(
      'SELECT report_id FROM report_processing_content_claims WHERE user_id=$1 AND profile_id=$2 AND source_hash=$3',
      [userId, r.profile_id, r.source_hash],
    );
    if (active)
      throw new ConflictException({
        code: 'REPORT_DUPLICATE_ACTIVE',
        reportId: active.report_id,
      });
    const [rows] = await m.query(
      `UPDATE reports SET processing_generation=processing_generation+1,processing_version=processing_version+1,
      processing_state='queued',status='queued',processing_stage='queued',processing_error_code=NULL,processing_started_at=NULL,
      processing_completed_at=NULL,processing_retry_at=NULL,processing_acknowledged_at=NULL WHERE id=$1 RETURNING *`,
      [reportId],
    );
    const next = rows[0];
    await m.query(
      'INSERT INTO report_processing_content_claims VALUES($1,$2,$3,1,$4)',
      [userId, r.profile_id, r.source_hash, reportId],
    );
    await m.query(
      `INSERT INTO report_processing_jobs(id,report_id,generation,trigger,max_attempts,deadline_at) VALUES($1,$2,$3,'retry',$4,clock_timestamp()+$5*interval '1 millisecond')`,
      [
        randomUUID(),
        reportId,
        next.processing_generation,
        policy.maxAttempts,
        reportDeadlineMs(policy, r.source_page_count),
      ],
    );
    await appendReportEvent(m, userId, {
      schemaVersion: 1,
      reportId,
      profileId: r.profile_id,
      generation: next.processing_generation,
      version: next.processing_version,
      status: 'queued',
      stage: 'queued',
    });
  });
}
