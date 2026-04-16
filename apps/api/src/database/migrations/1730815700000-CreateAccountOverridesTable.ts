import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateAccountOverridesTable1730815700000 implements MigrationInterface {
  name = 'CreateAccountOverridesTable1730815700000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "account_overrides" (
        "id"                  UUID                NOT NULL DEFAULT uuid_generate_v4(),
        "user_id"             UUID                NOT NULL,
        "overridden_actions"  JSONB               NOT NULL,
        "expires_at"          TIMESTAMPTZ         NOT NULL,
        "is_active"           BOOLEAN             NOT NULL DEFAULT true,
        "reason"              TEXT,
        "created_by_user_id"  UUID,
        "revoked_at"          TIMESTAMPTZ,
        "revoked_by_user_id"  UUID,
        "revoked_reason"      TEXT,
        "created_at"          TIMESTAMPTZ         NOT NULL DEFAULT now(),
        "updated_at"          TIMESTAMPTZ         NOT NULL DEFAULT now(),
        CONSTRAINT "PK_account_overrides" PRIMARY KEY ("id"),
        CONSTRAINT "FK_account_overrides_user" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_account_overrides_user_id" ON "account_overrides" ("user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_account_overrides_user_active" ON "account_overrides" ("user_id", "is_active")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "IDX_account_overrides_user_active"`);
    await queryRunner.query(`DROP INDEX "IDX_account_overrides_user_id"`);
    await queryRunner.query(`DROP TABLE "account_overrides"`);
  }
}
