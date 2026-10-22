import type { MigrationInterface, QueryRunner } from 'typeorm';

export class SeedStarterPlan1730818700000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    // Keep the existing Pro row (and its subscriptions) while using the
    // customer-facing plan name consistently.
    await queryRunner.query(`
      UPDATE "plans" SET "name" = 'Pro', "updated_at" = now()
      WHERE "name" = 'Pro Monthly' AND "tier" = 'paid'
        AND NOT EXISTS (SELECT 1 FROM "plans" WHERE "name" = 'Pro')
    `);

    // Starter remains unavailable for purchase until a real payment provider
    // plan and price are configured. Its limits are editable in admin now.
    await queryRunner.query(`
      INSERT INTO "plans" ("name", "tier", "limits", "price_info", "razorpay_plan_id", "is_active")
      SELECT 'Starter', 'paid',
        '{"maxProfiles": 2, "maxReports": 25, "maxShareLinks": 3, "aiChatEnabled": false}'::jsonb,
        NULL, NULL, false
      WHERE NOT EXISTS (SELECT 1 FROM "plans" WHERE "name" = 'Starter')
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DELETE FROM "plans" WHERE "name" = 'Starter'
        AND NOT EXISTS (
          SELECT 1 FROM "user_entitlements" WHERE "plan_id" = "plans"."id"
        )
        AND NOT EXISTS (
          SELECT 1 FROM "subscriptions" WHERE "plan_id" = "plans"."id"
        )
    `);
    await queryRunner.query(`
      UPDATE "plans" SET "name" = 'Pro Monthly', "updated_at" = now()
      WHERE "name" = 'Pro' AND "tier" = 'paid'
    `);
  }
}
