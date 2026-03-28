import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateSuperadminMfaAndAuditTables1730814800000 implements MigrationInterface {
  name = 'CreateSuperadminMfaAndAuditTables1730814800000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "superadmin_mfa_challenges" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "session_id" character varying(128) NOT NULL,
        "status" character varying(32) NOT NULL,
        "risk_fingerprint" character varying(160) NOT NULL,
        "attempt_count" integer NOT NULL DEFAULT 0,
        "max_attempts" integer NOT NULL DEFAULT 5,
        "locked_until" TIMESTAMP WITH TIME ZONE,
        "last_failure_code" character varying(64),
        "admin_action_token" character varying(255),
        "expires_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "verified_at" TIMESTAMP WITH TIME ZONE,
        "trust_expires_at" TIMESTAMP WITH TIME ZONE,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_superadmin_mfa_challenges_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_superadmin_mfa_user_session"
      ON "superadmin_mfa_challenges" ("user_id", "session_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_superadmin_mfa_expires_at"
      ON "superadmin_mfa_challenges" ("expires_at")
    `);
    await queryRunner.query(`
      ALTER TABLE "superadmin_mfa_challenges"
      ADD CONSTRAINT "FK_superadmin_mfa_user"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE
    `);

    await queryRunner.query(`
      CREATE TABLE "superadmin_auth_audit_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "actor_user_id" uuid NOT NULL,
        "action" character varying(64) NOT NULL,
        "target" character varying(64) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "correlation_id" character varying(128) NOT NULL,
        "challenge_id" character varying(255),
        "error_code" character varying(64),
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_superadmin_auth_audit_events_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_superadmin_audit_actor"
      ON "superadmin_auth_audit_events" ("actor_user_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_superadmin_audit_created_at"
      ON "superadmin_auth_audit_events" ("created_at")
    `);
    await queryRunner.query(`
      ALTER TABLE "superadmin_auth_audit_events"
      ADD CONSTRAINT "FK_superadmin_audit_actor_user"
      FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE CASCADE
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "superadmin_auth_audit_events"
      DROP CONSTRAINT "FK_superadmin_audit_actor_user"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_superadmin_audit_created_at"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_superadmin_audit_actor"
    `);
    await queryRunner.query(`
      DROP TABLE "superadmin_auth_audit_events"
    `);

    await queryRunner.query(`
      ALTER TABLE "superadmin_mfa_challenges"
      DROP CONSTRAINT "FK_superadmin_mfa_user"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_superadmin_mfa_expires_at"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_superadmin_mfa_user_session"
    `);
    await queryRunner.query(`
      DROP TABLE "superadmin_mfa_challenges"
    `);
  }
}
