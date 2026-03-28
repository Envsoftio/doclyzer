import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreatePromoCodeAuditEvents1730815000000 implements MigrationInterface {
  name = 'CreatePromoCodeAuditEvents1730815000000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "promo_code_audit_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "actor_user_id" uuid NOT NULL,
        "promo_code_id" uuid NOT NULL,
        "action" character varying(64) NOT NULL,
        "target" character varying(128) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "correlation_id" character varying(128) NOT NULL,
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_promo_code_audit_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_promo_code_audit_events_actor_user"
          FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
        CONSTRAINT "FK_promo_code_audit_events_promo_code"
          FOREIGN KEY ("promo_code_id") REFERENCES "promo_codes"("id") ON DELETE CASCADE ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_promo_code_audit_events_promo_created_at"
      ON "promo_code_audit_events" ("promo_code_id", "created_at")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_promo_code_audit_events_promo_created_at"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "promo_code_audit_events"`);
  }
}
