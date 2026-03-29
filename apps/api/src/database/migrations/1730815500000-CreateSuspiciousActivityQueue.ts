import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateSuspiciousActivityQueue1730815500000
  implements MigrationInterface
{
  name = 'CreateSuspiciousActivityQueue1730815500000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "suspicious_activity_queue_items" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "target_type" character varying(64) NOT NULL,
        "target_id" character varying(128) NOT NULL,
        "signal_type" character varying(64) NOT NULL,
        "rule_code" character varying(64) NOT NULL,
        "severity" character varying(16) NOT NULL,
        "status" character varying(16) NOT NULL,
        "confidence_score" integer NOT NULL,
        "detection_summary" character varying(256),
        "detection_count" integer NOT NULL DEFAULT 1,
        "first_detected_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "last_detected_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "suggested_containment" jsonb,
        "dedupe_key" character varying(128) NOT NULL,
        "idempotency_key" character varying(128),
        "metadata" jsonb,
        "reviewed_at" TIMESTAMP WITH TIME ZONE,
        "resolved_at" TIMESTAMP WITH TIME ZONE,
        "resolution_notes" character varying(256),
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_suspicious_activity_queue_items_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_suspicious_queue_status"
      ON "suspicious_activity_queue_items" ("status")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_suspicious_queue_severity"
      ON "suspicious_activity_queue_items" ("severity")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_suspicious_queue_target"
      ON "suspicious_activity_queue_items" ("target_type", "target_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_suspicious_queue_rule"
      ON "suspicious_activity_queue_items" ("rule_code")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_suspicious_queue_last_detected"
      ON "suspicious_activity_queue_items" ("last_detected_at")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_suspicious_queue_dedupe"
      ON "suspicious_activity_queue_items" ("dedupe_key")
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "UQ_suspicious_queue_idempotency"
      ON "suspicious_activity_queue_items" ("idempotency_key")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP INDEX "public"."UQ_suspicious_queue_idempotency"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_suspicious_queue_dedupe"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_suspicious_queue_last_detected"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_suspicious_queue_rule"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_suspicious_queue_target"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_suspicious_queue_severity"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_suspicious_queue_status"
    `);
    await queryRunner.query(`
      DROP TABLE "suspicious_activity_queue_items"
    `);
  }
}
