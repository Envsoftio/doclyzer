import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreatePromoCodesAndRedemptions1730814500000
  implements MigrationInterface
{
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "promo_codes" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "code" varchar(64) NOT NULL,
        "discount_type" varchar(16) NOT NULL,
        "discount_value" numeric(10,2) NOT NULL,
        "applies_to" varchar(16) NOT NULL,
        "valid_from" TIMESTAMPTZ,
        "valid_until" TIMESTAMPTZ,
        "usage_cap_total" integer,
        "usage_cap_per_user" integer,
        "is_active" boolean NOT NULL DEFAULT true,
        "metadata" jsonb,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_promo_codes" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_promo_codes_code" UNIQUE ("code")
      )
    `);

    await queryRunner.query(`
      CREATE TABLE "promo_redemptions" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "promo_code_id" uuid NOT NULL,
        "user_id" uuid NOT NULL,
        "product_type" varchar(32) NOT NULL,
        "product_ref_id" uuid,
        "order_id" uuid,
        "subscription_id" uuid,
        "discount_amount" numeric(10,2) NOT NULL,
        "currency" varchar(10) NOT NULL,
        "status" varchar(16) NOT NULL DEFAULT 'redeemed',
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_promo_redemptions" PRIMARY KEY ("id"),
        CONSTRAINT "FK_promo_redemptions_promo_code_id" FOREIGN KEY ("promo_code_id")
          REFERENCES "promo_codes"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_promo_redemptions_user_id" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_promo_redemptions_order_id" FOREIGN KEY ("order_id")
          REFERENCES "orders"("id") ON DELETE SET NULL,
        CONSTRAINT "FK_promo_redemptions_subscription_id" FOREIGN KEY ("subscription_id")
          REFERENCES "subscriptions"("id") ON DELETE SET NULL,
        CONSTRAINT "UQ_promo_redemptions_order" UNIQUE ("promo_code_id", "order_id"),
        CONSTRAINT "UQ_promo_redemptions_subscription" UNIQUE ("promo_code_id", "subscription_id")
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_promo_redemptions_promo_code_id"
      ON "promo_redemptions" ("promo_code_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_promo_redemptions_user_id"
      ON "promo_redemptions" ("user_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_promo_redemptions_promo_user"
      ON "promo_redemptions" ("promo_code_id", "user_id")
    `);

    await queryRunner.query(`
      ALTER TABLE "orders"
      ADD COLUMN "promo_code_id" uuid,
      ADD COLUMN "discount_amount" numeric(10,2),
      ADD COLUMN "final_amount" numeric(10,2),
      ADD CONSTRAINT "FK_orders_promo_code_id" FOREIGN KEY ("promo_code_id")
        REFERENCES "promo_codes"("id") ON DELETE SET NULL
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_orders_promo_code_id"
      ON "orders" ("promo_code_id")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "IDX_orders_promo_code_id"`);
    await queryRunner.query(`ALTER TABLE "orders" DROP CONSTRAINT "FK_orders_promo_code_id"`);
    await queryRunner.query(`ALTER TABLE "orders" DROP COLUMN "final_amount"`);
    await queryRunner.query(`ALTER TABLE "orders" DROP COLUMN "discount_amount"`);
    await queryRunner.query(`ALTER TABLE "orders" DROP COLUMN "promo_code_id"`);

    await queryRunner.query(`DROP INDEX "IDX_promo_redemptions_promo_user"`);
    await queryRunner.query(`DROP INDEX "IDX_promo_redemptions_user_id"`);
    await queryRunner.query(`DROP INDEX "IDX_promo_redemptions_promo_code_id"`);
    await queryRunner.query(`DROP TABLE "promo_redemptions"`);
    await queryRunner.query(`DROP TABLE "promo_codes"`);
  }
}
