import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateEmailAdminTables1730815900000
  implements MigrationInterface
{
  name = 'CreateEmailAdminTables1730815900000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "email_queue_items" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "email_type" character varying(64) NOT NULL,
        "recipient_scope" character varying(64) NOT NULL,
        "status" character varying(32) NOT NULL,
        "scheduled_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "processed_at" TIMESTAMP WITH TIME ZONE,
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_email_queue_items_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_email_queue_status"
      ON "email_queue_items" ("status")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_email_queue_scheduled_at"
      ON "email_queue_items" ("scheduled_at")
    `);
    await queryRunner.query(`
      CREATE TABLE "email_delivery_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "email_type" character varying(64) NOT NULL,
        "recipient_scope" character varying(64) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "provider" character varying(64),
        "provider_message_id" character varying(128),
        "occurred_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_email_delivery_events_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_email_delivery_outcome"
      ON "email_delivery_events" ("outcome")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_email_delivery_type"
      ON "email_delivery_events" ("email_type")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_email_delivery_occurred_at"
      ON "email_delivery_events" ("occurred_at")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP INDEX "public"."IDX_email_delivery_occurred_at"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_email_delivery_type"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_email_delivery_outcome"
    `);
    await queryRunner.query(`
      DROP TABLE "email_delivery_events"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_email_queue_scheduled_at"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_email_queue_status"
    `);
    await queryRunner.query(`
      DROP TABLE "email_queue_items"
    `);
  }
}
