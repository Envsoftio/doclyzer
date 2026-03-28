import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateCreditPacksAndOrders1730814300000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    // Create credit_packs table
    await queryRunner.query(`
      CREATE TABLE "credit_packs" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "name" varchar(255) NOT NULL,
        "credits" integer NOT NULL,
        "price_inr" numeric(10,2) NOT NULL,
        "price_usd" numeric(10,2) NOT NULL,
        "is_active" boolean NOT NULL DEFAULT true,
        "sort_order" integer NOT NULL DEFAULT 0,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_credit_packs" PRIMARY KEY ("id")
      )
    `);

    // Create orders table
    await queryRunner.query(`
      CREATE TABLE "orders" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "credit_pack_id" uuid NOT NULL,
        "amount" numeric(10,2) NOT NULL,
        "currency" varchar(10) NOT NULL,
        "status" varchar(32) NOT NULL DEFAULT 'pending',
        "razorpay_order_id" varchar(255) NOT NULL,
        "razorpay_payment_id" varchar(255),
        "razorpay_signature" varchar(512),
        "credited" boolean NOT NULL DEFAULT false,
        "metadata" jsonb,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_orders" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_orders_razorpay_order_id" UNIQUE ("razorpay_order_id"),
        CONSTRAINT "FK_orders_user_id" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_orders_credit_pack_id" FOREIGN KEY ("credit_pack_id")
          REFERENCES "credit_packs"("id")
      )
    `);

    await queryRunner.query(
      `CREATE INDEX "IDX_orders_user_id" ON "orders" ("user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_orders_razorpay_order_id" ON "orders" ("razorpay_order_id")`,
    );

    // Seed default credit packs
    await queryRunner.query(`
      INSERT INTO "credit_packs" ("name", "credits", "price_inr", "price_usd", "is_active", "sort_order")
      VALUES
        ('Small Pack', 5, 99, 2.99, true, 1),
        ('Medium Pack', 15, 249, 6.99, true, 2),
        ('Large Pack', 50, 699, 19.99, true, 3)
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "orders"`);
    await queryRunner.query(`DROP TABLE "credit_packs"`);
  }
}
