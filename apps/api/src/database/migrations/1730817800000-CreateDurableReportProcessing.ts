import type { MigrationInterface, QueryRunner } from 'typeorm';

/** Additive only: legacy reports are not enrolled in asynchronous processing. */
export class CreateDurableReportProcessing1730817800000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    await q.query(`ALTER TABLE reports
      ADD processing_state varchar(32),
      ADD processing_generation integer NOT NULL DEFAULT 0 CHECK (processing_generation >= 0),
      ADD processing_version bigint NOT NULL DEFAULT 0 CHECK (processing_version >= 0),
      ADD processing_stage varchar(32),
      ADD processing_error_code varchar(64),
      ADD processing_accepted_at timestamptz,
      ADD processing_started_at timestamptz,
      ADD processing_completed_at timestamptz,
      ADD processing_retry_at timestamptz,
      ADD source_hash varchar(64),
      ADD source_hash_version smallint,
      ADD CONSTRAINT report_processing_state_check CHECK (processing_state IS NULL OR processing_state IN
        ('queued','processing','retry_scheduled','ready','needs_attention','failed','cancelled')),
      ADD CONSTRAINT report_source_hash_check CHECK (
        (source_hash IS NULL AND source_hash_version IS NULL) OR
        (source_hash IS NOT NULL AND source_hash_version IS NOT NULL AND
         source_hash ~ '^[0-9a-f]{64}$' AND source_hash_version = 1))`);
    // Ownership tuples allow child records to enforce account/profile scoping.
    await q.query(
      `ALTER TABLE reports ADD CONSTRAINT reports_processing_owner_key UNIQUE (id, user_id, profile_id)`,
    );
    await q.query(`CREATE TABLE report_processing_jobs (
      id uuid PRIMARY KEY,
      report_id uuid NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
      generation integer NOT NULL CHECK (generation > 0),
      trigger varchar(32) NOT NULL CHECK (trigger IN ('initial_upload','retry')),
      state varchar(32) NOT NULL DEFAULT 'queued' CHECK (state IN ('queued','leased','retry_scheduled','succeeded','failed','cancelled')),
      attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
      max_attempts integer NOT NULL CHECK (max_attempts > 0),
      available_at timestamptz NOT NULL DEFAULT now(),
      deadline_at timestamptz NOT NULL,
      lease_token uuid,
      lease_expires_at timestamptz,
      heartbeat_at timestamptz,
      provider_task_id text,
      provider_instance_id text,
      submission_uncertain_at timestamptz,
      error_code varchar(64),
      created_at timestamptz NOT NULL DEFAULT now(),
      completed_at timestamptz,
      UNIQUE (report_id, generation),
      CHECK (deadline_at > created_at),
      CHECK ((state = 'leased' AND lease_token IS NOT NULL AND lease_expires_at IS NOT NULL AND heartbeat_at IS NOT NULL)
        OR (state <> 'leased' AND lease_token IS NULL AND lease_expires_at IS NULL AND heartbeat_at IS NULL))
    )`);
    await q.query(`CREATE UNIQUE INDEX report_processing_one_active_job ON report_processing_jobs(report_id)
      WHERE state IN ('queued','leased','retry_scheduled')`);
    await q.query(`CREATE INDEX report_processing_due_jobs ON report_processing_jobs(available_at, id)
      WHERE state IN ('queued','retry_scheduled')`);
    await q.query(`CREATE INDEX report_processing_expired_leases ON report_processing_jobs(lease_expires_at)
      WHERE state = 'leased'`);
    // No uniqueness is imposed on historical normalized hashes or legacy reports.
    await q.query(`CREATE TABLE report_processing_content_claims (
      user_id uuid NOT NULL,
      profile_id uuid NOT NULL,
      source_hash varchar(64) NOT NULL CHECK (source_hash ~ '^[0-9a-f]{64}$'),
      source_hash_version smallint NOT NULL CHECK (source_hash_version = 1),
      report_id uuid NOT NULL UNIQUE,
      PRIMARY KEY (user_id, profile_id, source_hash_version, source_hash),
      FOREIGN KEY (report_id, user_id, profile_id) REFERENCES reports(id, user_id, profile_id) ON DELETE CASCADE
    )`);
    await q.query(`CREATE TABLE report_upload_requests (
      user_id uuid NOT NULL,
      operation varchar(32) NOT NULL CHECK (operation = 'report_upload_v2'),
      idempotency_key varchar(128) NOT NULL,
      request_hash varchar(64) NOT NULL CHECK (request_hash ~ '^[0-9a-f]{64}$'),
      profile_id uuid NOT NULL,
      report_id uuid NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now(),
      expires_at timestamptz NOT NULL CHECK (expires_at > created_at),
      PRIMARY KEY (user_id, operation, idempotency_key),
      FOREIGN KEY (report_id, user_id, profile_id) REFERENCES reports(id, user_id, profile_id) ON DELETE CASCADE
    )`);
    await q.query(
      `CREATE INDEX report_upload_requests_expiry ON report_upload_requests(expires_at)`,
    );
    // Transactional account counter, not a sequence: lock is held until commit.
    await q.query(`CREATE TABLE report_event_cursors (
      user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
      last_cursor bigint NOT NULL DEFAULT 0 CHECK (last_cursor >= 0),
      retained_after bigint NOT NULL DEFAULT 0 CHECK (retained_after >= 0 AND retained_after <= last_cursor)
    )`);
    await q.query(`CREATE TABLE report_processing_events (
      user_id uuid NOT NULL,
      cursor bigint NOT NULL CHECK (cursor > 0),
      report_id uuid NOT NULL,
      profile_id uuid NOT NULL,
      generation integer NOT NULL CHECK (generation > 0),
      version bigint NOT NULL CHECK (version > 0),
      status varchar(32) NOT NULL CHECK (status IN ('queued','processing','retry_scheduled','ready','needs_attention','failed','cancelled')),
      stage varchar(32) NOT NULL CHECK (stage IN ('queued','extracting','normalizing','complete')),
      schema_version smallint NOT NULL DEFAULT 1 CHECK (schema_version = 1),
      created_at timestamptz NOT NULL DEFAULT now(),
      PRIMARY KEY (user_id, cursor),
      UNIQUE (report_id, version),
      FOREIGN KEY (report_id, user_id, profile_id) REFERENCES reports(id, user_id, profile_id) ON DELETE CASCADE
    )`);
  }

  async down(q: QueryRunner): Promise<void> {
    for (const table of [
      'report_processing_events',
      'report_event_cursors',
      'report_upload_requests',
      'report_processing_content_claims',
      'report_processing_jobs',
    ]) {
      await q.query(`DROP TABLE ${table}`);
    }
    await q.query(`ALTER TABLE reports DROP CONSTRAINT reports_processing_owner_key,
      DROP CONSTRAINT report_processing_state_check, DROP CONSTRAINT report_source_hash_check,
      DROP processing_state, DROP processing_generation, DROP processing_version, DROP processing_stage,
      DROP processing_error_code, DROP processing_accepted_at, DROP processing_started_at,
      DROP processing_completed_at, DROP processing_retry_at, DROP source_hash, DROP source_hash_version`);
  }
}
