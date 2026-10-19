import type { MigrationInterface, QueryRunner } from 'typeorm';
export class CompleteReportProcessingRuntime1730818100000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    await q.query('DROP INDEX report_upload_intents_cleanup');
    await q.query(
      'CREATE INDEX report_upload_intents_cleanup ON report_upload_intents(cleanup_after)',
    );
    await q.query(
      `ALTER TABLE reports ADD summary_status varchar(24) NOT NULL DEFAULT 'not_requested', ADD processing_acknowledged_at timestamptz`,
    );
    await q.query(
      `ALTER TABLE report_processing_jobs ADD staged_result jsonb, ADD provider_missing_count integer NOT NULL DEFAULT 0, ADD provider_submission_count integer NOT NULL DEFAULT 0`,
    );
    await q.query(
      `ALTER TABLE report_processing_events ADD dispatched_at timestamptz`,
    );
    await q.query(
      `CREATE INDEX report_events_dispatch ON report_processing_events(created_at) WHERE dispatched_at IS NULL`,
    );
    await q.query(`CREATE TABLE report_inbox (
      id uuid PRIMARY KEY, user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      report_id uuid NOT NULL REFERENCES reports(id) ON DELETE CASCADE, generation integer NOT NULL,
      status varchar(32) NOT NULL, created_at timestamptz NOT NULL DEFAULT now(), read_at timestamptz,
      UNIQUE(report_id,generation))`);
    await q.query(
      `CREATE INDEX report_inbox_user ON report_inbox(user_id,created_at DESC)`,
    );
    await q.query(`CREATE TABLE report_delivery_intents (
      id uuid PRIMARY KEY, inbox_id uuid NOT NULL REFERENCES report_inbox(id) ON DELETE CASCADE,
      channel varchar(16) NOT NULL CHECK(channel IN ('push','email','referral','summary','ops')),
      target varchar(64) NOT NULL, state varchar(16) NOT NULL DEFAULT 'pending',
      attempts integer NOT NULL DEFAULT 0, available_at timestamptz NOT NULL DEFAULT now(),
      expires_at timestamptz NOT NULL, lease_token uuid, lease_until timestamptz,
      provider_message_id text, error_code varchar(64), completed_at timestamptz,
      UNIQUE(inbox_id,channel,target))`);
    await q.query(
      `CREATE INDEX report_deliveries_due ON report_delivery_intents(available_at) WHERE state IN ('pending','sending')`,
    );
    await q.query(
      `CREATE TABLE report_sse_connections (id uuid PRIMARY KEY,user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE, expires_at timestamptz NOT NULL)`,
    );
    await q.query(
      `CREATE INDEX report_sse_user ON report_sse_connections(user_id,expires_at)`,
    );
    await q.query(
      `CREATE TABLE report_operator_actions(id uuid PRIMARY KEY,actor_user_id uuid REFERENCES users(id) ON DELETE SET NULL,report_id uuid REFERENCES reports(id) ON DELETE SET NULL,action varchar(32) NOT NULL,reason varchar(512) NOT NULL,outcome varchar(24) NOT NULL,created_at timestamptz NOT NULL DEFAULT now())`,
    );
    await q.query(
      `CREATE TABLE report_process_health (id varchar(64) PRIMARY KEY,role varchar(24) NOT NULL,heartbeat_at timestamptz NOT NULL)`,
    );
    await q.query(`CREATE FUNCTION signal_report_event() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
      PERFORM pg_notify('report_events', NEW.user_id::text); RETURN NEW; END $$`);
    await q.query(
      `CREATE TRIGGER report_event_signal AFTER INSERT ON report_processing_events FOR EACH ROW EXECUTE FUNCTION signal_report_event()`,
    );
  }
  async down(q: QueryRunner): Promise<void> {
    await q.query('DROP INDEX report_upload_intents_cleanup');
    await q.query(
      "CREATE INDEX report_upload_intents_cleanup ON report_upload_intents(cleanup_after) WHERE state <> 'accepted'",
    );
    await q.query(
      'DROP TRIGGER report_event_signal ON report_processing_events',
    );
    await q.query('DROP FUNCTION signal_report_event()');
    for (const table of [
      'report_operator_actions',
      'report_process_health',
      'report_sse_connections',
      'report_delivery_intents',
      'report_inbox',
    ])
      await q.query(`DROP TABLE ${table}`);
    await q.query('DROP INDEX report_events_dispatch');
    await q.query('ALTER TABLE report_processing_events DROP dispatched_at');
    await q.query(
      'ALTER TABLE report_processing_jobs DROP staged_result,DROP provider_missing_count,DROP provider_submission_count',
    );
    await q.query(
      'ALTER TABLE reports DROP summary_status,DROP processing_acknowledged_at',
    );
  }
}
