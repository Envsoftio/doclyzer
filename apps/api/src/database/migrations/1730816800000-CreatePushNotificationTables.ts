import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreatePushNotificationTables1730816800000
  implements MigrationInterface
{
  name = 'CreatePushNotificationTables1730816800000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "user_device_tokens" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "token_hash" character varying(64) NOT NULL,
        "provider_token" text NOT NULL,
        "platform" character varying(24) NOT NULL,
        "provider" character varying(32) NOT NULL DEFAULT 'fcm',
        "installation_id" character varying(128),
        "app_version" character varying(64),
        "device_label" character varying(128),
        "preferences" jsonb,
        "active" boolean NOT NULL DEFAULT true,
        "last_seen_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "disabled_at" TIMESTAMP WITH TIME ZONE,
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_user_device_tokens_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_user_device_tokens_user"
          FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION
      )
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "UQ_user_device_tokens_token_hash"
      ON "user_device_tokens" ("token_hash")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_user_device_tokens_user_active"
      ON "user_device_tokens" ("user_id", "active")
    `);

    await queryRunner.query(`
      CREATE TABLE "push_send_audit" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "sender_user_id" uuid,
        "notification_type" character varying(64) NOT NULL,
        "status" character varying(32) NOT NULL,
        "audience_filter" jsonb NOT NULL,
        "title" character varying(120) NOT NULL,
        "body" character varying(280) NOT NULL,
        "dry_run" boolean NOT NULL DEFAULT false,
        "target_count" integer NOT NULL DEFAULT 0,
        "sent_count" integer NOT NULL DEFAULT 0,
        "failed_count" integer NOT NULL DEFAULT 0,
        "skipped_count" integer NOT NULL DEFAULT 0,
        "provider" character varying(64),
        "idempotency_key" character varying(128),
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_push_send_audit_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_push_send_audit_sender"
          FOREIGN KEY ("sender_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION
      )
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "UQ_push_send_audit_idempotency"
      ON "push_send_audit" ("idempotency_key")
      WHERE "idempotency_key" IS NOT NULL
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_push_send_audit_sender_created"
      ON "push_send_audit" ("sender_user_id", "created_at")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_push_send_audit_created_at"
      ON "push_send_audit" ("created_at")
    `);

    await queryRunner.query(`
      CREATE TABLE "push_delivery_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "push_send_audit_id" uuid,
        "user_id" uuid,
        "device_token_id" uuid,
        "notification_type" character varying(64) NOT NULL,
        "recipient_scope" character varying(32) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "provider" character varying(64),
        "provider_message_id" character varying(255),
        "error_code" character varying(96),
        "occurred_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_push_delivery_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_push_delivery_audit"
          FOREIGN KEY ("push_send_audit_id") REFERENCES "push_send_audit"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_push_delivery_user"
          FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_push_delivery_device_token"
          FOREIGN KEY ("device_token_id") REFERENCES "user_device_tokens"("id") ON DELETE SET NULL ON UPDATE NO ACTION
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_push_delivery_audit_outcome"
      ON "push_delivery_events" ("push_send_audit_id", "outcome")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_push_delivery_user_occurred"
      ON "push_delivery_events" ("user_id", "occurred_at")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_push_delivery_occurred_at"
      ON "push_delivery_events" ("occurred_at")
    `);

    await queryRunner.query(`
      CREATE TABLE "push_open_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "push_send_audit_id" uuid,
        "user_id" uuid NOT NULL,
        "device_token_id" uuid,
        "provider_message_id" character varying(255),
        "deep_link" character varying(255),
        "opened_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_push_open_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_push_open_audit"
          FOREIGN KEY ("push_send_audit_id") REFERENCES "push_send_audit"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_push_open_user"
          FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
        CONSTRAINT "FK_push_open_device_token"
          FOREIGN KEY ("device_token_id") REFERENCES "user_device_tokens"("id") ON DELETE SET NULL ON UPDATE NO ACTION
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_push_open_audit_opened"
      ON "push_open_events" ("push_send_audit_id", "opened_at")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_push_open_user_opened"
      ON "push_open_events" ("user_id", "opened_at")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_push_open_user_opened"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_push_open_audit_opened"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "push_open_events"`);

    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_push_delivery_occurred_at"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_push_delivery_user_occurred"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_push_delivery_audit_outcome"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "push_delivery_events"`);

    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_push_send_audit_created_at"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_push_send_audit_sender_created"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "UQ_push_send_audit_idempotency"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "push_send_audit"`);

    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_user_device_tokens_user_active"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "UQ_user_device_tokens_token_hash"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "user_device_tokens"`);
  }
}
