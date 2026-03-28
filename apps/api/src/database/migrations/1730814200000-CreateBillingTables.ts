import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateBillingTables1730814200000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    // Create plans table
    await queryRunner.query(`
      CREATE TABLE "plans" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "name" varchar(255) NOT NULL,
        "tier" varchar(32) NOT NULL,
        "limits" jsonb NOT NULL,
        "price_info" jsonb,
        "is_active" boolean NOT NULL DEFAULT true,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_plans" PRIMARY KEY ("id")
      )
    `);

    // Create user_entitlements table
    await queryRunner.query(`
      CREATE TABLE "user_entitlements" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "plan_id" uuid NOT NULL,
        "credit_balance" numeric(10,2) NOT NULL DEFAULT 0,
        "status" varchar(32) NOT NULL DEFAULT 'active',
        "activated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "expires_at" TIMESTAMPTZ,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_user_entitlements" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_user_entitlements_user_id" UNIQUE ("user_id"),
        CONSTRAINT "FK_user_entitlements_user_id" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_user_entitlements_plan_id" FOREIGN KEY ("plan_id")
          REFERENCES "plans"("id")
      )
    `);

    await queryRunner.query(
      `CREATE INDEX "IDX_user_entitlements_user_id" ON "user_entitlements" ("user_id")`,
    );

    // Seed default free-tier plan
    await queryRunner.query(`
      INSERT INTO "plans" ("name", "tier", "limits", "is_active")
      VALUES (
        'Free',
        'free',
        '{"maxProfiles": 1, "maxReports": 5, "maxShareLinks": 1, "aiChatEnabled": false}',
        true
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "user_entitlements"`);
    await queryRunner.query(`DROP TABLE "plans"`);
  }
}
