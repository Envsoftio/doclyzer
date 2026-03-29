import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateSuperadminActionAuditTables1730815200000 implements MigrationInterface {
  name = 'CreateSuperadminActionAuditTables1730815200000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "superadmin_action_audit_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "actor_user_id" uuid NOT NULL,
        "action" character varying(64) NOT NULL,
        "target" character varying(128) NOT NULL,
        "sensitive_target" boolean NOT NULL DEFAULT false,
        "outcome" character varying(32) NOT NULL,
        "correlation_id" character varying(128) NOT NULL,
        "metadata" jsonb,
        "tamper_hash" character varying(64) NOT NULL,
        "tamper_prev_hash" character varying(64),
        "tamper_sequence" integer NOT NULL,
        "performed_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_superadmin_action_audit_events_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_superadmin_action_audit_actor"
      ON "superadmin_action_audit_events" ("actor_user_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_superadmin_action_audit_created_at"
      ON "superadmin_action_audit_events" ("created_at")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_superadmin_action_audit_sequence"
      ON "superadmin_action_audit_events" ("tamper_sequence")
    `);
    await queryRunner.query(`
      ALTER TABLE "superadmin_action_audit_events"
      ADD CONSTRAINT "FK_superadmin_action_audit_actor_user"
      FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE CASCADE
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "superadmin_action_audit_events"
      DROP CONSTRAINT "FK_superadmin_action_audit_actor_user"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_superadmin_action_audit_sequence"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_superadmin_action_audit_created_at"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_superadmin_action_audit_actor"
    `);
    await queryRunner.query(`
      DROP TABLE "superadmin_action_audit_events"
    `);
  }
}
