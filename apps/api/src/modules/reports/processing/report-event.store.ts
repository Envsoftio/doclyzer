import type { EntityManager } from 'typeorm';
import type { ReportStatusEventV1 } from './report-processing.contract';

/**
 * Call after changing the report in the SAME transaction. Do no external I/O
 * after this call: the account counter serializes event publication until commit.
 * All event producers must use this allocator, never nextval()/MAX(cursor).
 */
export async function appendReportEvent(
  manager: EntityManager,
  userId: string,
  event: ReportStatusEventV1,
): Promise<string> {
  if (!manager.queryRunner?.isTransactionActive) {
    throw new Error('Report events require an active transaction');
  }
  const rows: { last_cursor: string }[] = await manager.query(
    `INSERT INTO report_event_cursors(user_id, last_cursor) VALUES ($1, 1)
     ON CONFLICT (user_id) DO UPDATE
     SET last_cursor = report_event_cursors.last_cursor + 1
     RETURNING last_cursor`,
    [userId],
  );
  const cursor = rows[0].last_cursor;
  // INSERT ... SELECT rejects events not matching committed-in-this-transaction
  // state. A caller must roll back on error, including a failed invariant.
  const inserted: { cursor: string }[] = await manager.query(
    `INSERT INTO report_processing_events
       (user_id, cursor, report_id, profile_id, generation, version, status, stage, schema_version)
     SELECT user_id, $2, id, profile_id, processing_generation, processing_version,
       processing_state, processing_stage, $9
     FROM reports WHERE user_id = $1 AND id = $3 AND profile_id = $4
       AND processing_generation = $5 AND processing_version = $6
       AND processing_state = $7 AND processing_stage = $8
     RETURNING cursor`,
    [
      userId,
      cursor,
      event.reportId,
      event.profileId,
      event.generation,
      event.version,
      event.status,
      event.stage,
      event.schemaVersion,
    ],
  );
  if (inserted.length !== 1) {
    throw new Error('Report event does not match authoritative report state');
  }
  return cursor;
}
