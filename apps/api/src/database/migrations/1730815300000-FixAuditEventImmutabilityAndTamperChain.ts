import type { MigrationInterface, QueryRunner } from 'typeorm';

export class FixAuditEventImmutabilityAndTamperChain1730815300000 implements MigrationInterface {
  name = 'FixAuditEventImmutabilityAndTamperChain1730815300000';

  async up(queryRunner: QueryRunner): Promise<void> {
    // H1: Audit records must survive user deletion.
    // Change actor_user_id FK from ON DELETE CASCADE to ON DELETE SET NULL
    // so that deleting a superadmin user does not wipe their audit trail.
    await queryRunner.query(`
      ALTER TABLE "superadmin_action_audit_events"
      DROP CONSTRAINT "FK_superadmin_action_audit_actor_user"
    `);
    await queryRunner.query(`
      ALTER TABLE "superadmin_action_audit_events"
      ALTER COLUMN "actor_user_id" DROP NOT NULL
    `);
    await queryRunner.query(`
      ALTER TABLE "superadmin_action_audit_events"
      ADD CONSTRAINT "FK_superadmin_action_audit_actor_user"
      FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE SET NULL
    `);

    // H2: Enforce uniqueness on tamper_sequence so concurrent inserts are caught
    // at the DB level if the advisory-lock serialisation ever fails.
    await queryRunner.query(`
      CREATE UNIQUE INDEX "UQ_superadmin_action_audit_tamper_sequence"
      ON "superadmin_action_audit_events" ("tamper_sequence")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP INDEX "public"."UQ_superadmin_action_audit_tamper_sequence"
    `);
    await queryRunner.query(`
      ALTER TABLE "superadmin_action_audit_events"
      DROP CONSTRAINT "FK_superadmin_action_audit_actor_user"
    `);
    await queryRunner.query(`
      ALTER TABLE "superadmin_action_audit_events"
      ALTER COLUMN "actor_user_id" SET NOT NULL
    `);
    await queryRunner.query(`
      ALTER TABLE "superadmin_action_audit_events"
      ADD CONSTRAINT "FK_superadmin_action_audit_actor_user"
      FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE CASCADE
    `);
  }
}
