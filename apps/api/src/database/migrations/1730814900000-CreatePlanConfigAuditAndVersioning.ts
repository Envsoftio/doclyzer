import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreatePlanConfigAuditAndVersioning1730814900000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "plans"
      ADD COLUMN "config_version" integer NOT NULL DEFAULT 1
    `);

    await queryRunner.query(`
      CREATE TABLE "plan_config_audit_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "actor_user_id" uuid NOT NULL,
        "plan_id" uuid NOT NULL,
        "action" character varying(64) NOT NULL,
        "target" character varying(128) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "correlation_id" character varying(128) NOT NULL,
        "previous_config_version" integer NOT NULL,
        "new_config_version" integer NOT NULL,
        "error_code" character varying(64),
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_plan_config_audit_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_plan_config_audit_events_actor_user" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
        CONSTRAINT "FK_plan_config_audit_events_plan" FOREIGN KEY ("plan_id") REFERENCES "plans"("id") ON DELETE CASCADE ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_plan_config_audit_events_plan_created_at"
      ON "plan_config_audit_events" ("plan_id", "created_at")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP INDEX IF EXISTS "IDX_plan_config_audit_events_plan_created_at"
    `);
    await queryRunner.query(`
      DROP TABLE IF EXISTS "plan_config_audit_events"
    `);
    await queryRunner.query(`
      ALTER TABLE "plans"
      DROP COLUMN "config_version"
    `);
  }
}
