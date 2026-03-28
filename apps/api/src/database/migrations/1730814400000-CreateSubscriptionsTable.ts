import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateSubscriptionsTable1730814400000
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add razorpay_plan_id column to plans table
    await queryRunner.query(
      `ALTER TABLE "plans" ADD COLUMN "razorpay_plan_id" varchar NULL`,
    );

    // Create subscriptions table
    await queryRunner.query(`
      CREATE TABLE "subscriptions" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "plan_id" uuid NOT NULL,
        "status" varchar(32) NOT NULL DEFAULT 'created',
        "razorpay_subscription_id" varchar NOT NULL,
        "razorpay_payment_id" varchar NULL,
        "razorpay_signature" varchar NULL,
        "current_period_start" timestamptz NULL,
        "current_period_end" timestamptz NULL,
        "metadata" jsonb NULL,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "PK_subscriptions" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_subscriptions_razorpay_subscription_id" UNIQUE ("razorpay_subscription_id"),
        CONSTRAINT "FK_subscriptions_user_id" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_subscriptions_plan_id" FOREIGN KEY ("plan_id") REFERENCES "plans"("id") ON DELETE NO ACTION
      )
    `);

    // Seed paid plan row
    await queryRunner.query(`
      INSERT INTO "plans" ("name", "tier", "limits", "price_info", "is_active", "razorpay_plan_id")
      VALUES (
        'Pro Monthly',
        'paid',
        '{"maxProfiles": 5, "maxReports": 100, "maxShareLinks": 10, "aiChatEnabled": true}',
        '{"monthlyInr": 299, "monthlyUsd": 4.99}',
        true,
        '${process.env.RAZORPAY_PLAN_ID_PRO || 'plan_placeholder'}'
      )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Remove seeded paid plan
    await queryRunner.query(
      `DELETE FROM "plans" WHERE "name" = 'Pro Monthly' AND "tier" = 'paid'`,
    );

    // Drop subscriptions table
    await queryRunner.query(`DROP TABLE IF EXISTS "subscriptions"`);

    // Remove razorpay_plan_id column from plans
    await queryRunner.query(
      `ALTER TABLE "plans" DROP COLUMN IF EXISTS "razorpay_plan_id"`,
    );
  }
}
