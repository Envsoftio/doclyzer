import type { MigrationInterface, QueryRunner } from 'typeorm';

export class MigrateToBetterAuth1730814600000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD COLUMN "email_verified" boolean NOT NULL DEFAULT false
    `);

    await queryRunner.query(`
      ALTER TABLE "users"
      ALTER COLUMN "password_hash" DROP NOT NULL
    `);

    await queryRunner.query(`
      UPDATE "users"
      SET "display_name" = split_part("email", '@', 1)
      WHERE "display_name" IS NULL
    `);

    await queryRunner.query(`
      CREATE TABLE "accounts" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "provider_id" varchar(255) NOT NULL,
        "account_id" varchar(255) NOT NULL,
        "access_token" text,
        "refresh_token" text,
        "id_token" text,
        "access_token_expires_at" TIMESTAMPTZ,
        "refresh_token_expires_at" TIMESTAMPTZ,
        "scope" text,
        "password_hash" varchar(255),
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_accounts" PRIMARY KEY ("id"),
        CONSTRAINT "FK_accounts_user_id" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    await queryRunner.query(
      `CREATE INDEX "IDX_accounts_user_id" ON "accounts" ("user_id")`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "UQ_accounts_provider_account" ON "accounts" ("provider_id", "account_id")`,
    );

    await queryRunner.query(`
      INSERT INTO "accounts" (
        "id",
        "user_id",
        "provider_id",
        "account_id",
        "password_hash",
        "created_at",
        "updated_at"
      )
      SELECT
        gen_random_uuid(),
        "id",
        'credential',
        "id",
        "password_hash",
        now(),
        now()
      FROM "users"
    `);

    await queryRunner.query(`
      CREATE TABLE "verifications" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "identifier" varchar(255) NOT NULL,
        "value" varchar(255) NOT NULL,
        "expires_at" TIMESTAMPTZ NOT NULL,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_verifications" PRIMARY KEY ("id")
      )
    `);

    await queryRunner.query(
      `CREATE INDEX "IDX_verifications_identifier" ON "verifications" ("identifier")`,
    );

    // Explicitly invalidate existing sessions; Better Auth cannot migrate tokens safely.
    await queryRunner.query(`DELETE FROM "sessions"`);

    await queryRunner.query(`
      ALTER TABLE "sessions"
      ADD COLUMN "token" varchar(255)
    `);
    await queryRunner.query(`
      ALTER TABLE "sessions"
      ADD COLUMN "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now()
    `);
    await queryRunner.query(`
      ALTER TABLE "sessions"
      DROP COLUMN "refresh_token_hash"
    `);
    await queryRunner.query(`
      ALTER TABLE "sessions"
      ALTER COLUMN "token" SET NOT NULL
    `);

    await queryRunner.query(
      `CREATE UNIQUE INDEX "UQ_sessions_token" ON "sessions" ("token")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_sessions_user_id" ON "sessions" ("user_id")`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "IDX_sessions_user_id"`);
    await queryRunner.query(`DROP INDEX "UQ_sessions_token"`);

    await queryRunner.query(`
      ALTER TABLE "sessions"
      ADD COLUMN "refresh_token_hash" varchar(255)
    `);
    await queryRunner.query(`
      UPDATE "sessions" SET "refresh_token_hash" = ''
      WHERE "refresh_token_hash" IS NULL
    `);
    await queryRunner.query(`
      ALTER TABLE "sessions"
      ALTER COLUMN "refresh_token_hash" SET NOT NULL
    `);
    await queryRunner.query(`
      ALTER TABLE "sessions"
      DROP COLUMN "token"
    `);
    await queryRunner.query(`
      ALTER TABLE "sessions"
      DROP COLUMN "updated_at"
    `);

    await queryRunner.query(`DROP INDEX "IDX_verifications_identifier"`);
    await queryRunner.query(`DROP TABLE "verifications"`);

    await queryRunner.query(`DROP INDEX "UQ_accounts_provider_account"`);
    await queryRunner.query(`DROP INDEX "IDX_accounts_user_id"`);
    await queryRunner.query(`DROP TABLE "accounts"`);

    await queryRunner.query(`
      ALTER TABLE "users"
      DROP COLUMN "email_verified"
    `);
    await queryRunner.query(`
      ALTER TABLE "users"
      ALTER COLUMN "password_hash" SET NOT NULL
    `);
  }
}
