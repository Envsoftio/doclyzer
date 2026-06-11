import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddPromoParityFieldsAndLifecycleEvents1730816900000
  implements MigrationInterface
{
  name = 'AddPromoParityFieldsAndLifecycleEvents1730816900000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "promo_codes"
      ADD COLUMN "max_discount_amount" numeric(10,2)
    `);

    await queryRunner.query(`
      CREATE TABLE "promo_lifecycle_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "promo_code_id" uuid,
        "user_id" uuid,
        "promo_code" character varying(64),
        "product_type" character varying(32),
        "product_ref_id" uuid,
        "order_id" uuid,
        "event_type" character varying(32) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "invalid_reason_code" character varying(64),
        "discount_amount" numeric(10,2),
        "final_amount" numeric(10,2),
        "currency" character varying(10),
        "idempotency_key" character varying(128),
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_promo_lifecycle_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_promo_lifecycle_events_promo_code"
          FOREIGN KEY ("promo_code_id") REFERENCES "promo_codes"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_promo_lifecycle_events_user"
          FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_promo_lifecycle_events_order"
          FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_promo_lifecycle_events_promo_created_at"
      ON "promo_lifecycle_events" ("promo_code_id", "created_at")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_promo_lifecycle_events_user_id"
      ON "promo_lifecycle_events" ("user_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_promo_lifecycle_events_order_id"
      ON "promo_lifecycle_events" ("order_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_promo_lifecycle_events_type_created_at"
      ON "promo_lifecycle_events" ("event_type", "created_at")
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "UQ_orders_zero_checkout_key"
      ON "orders" ((metadata ->> 'zeroCheckoutKey'))
      WHERE metadata ? 'zeroCheckoutKey'
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX IF EXISTS "UQ_orders_zero_checkout_key"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_promo_lifecycle_events_type_created_at"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_promo_lifecycle_events_order_id"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_promo_lifecycle_events_user_id"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_promo_lifecycle_events_promo_created_at"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "promo_lifecycle_events"`);
    await queryRunner.query(`
      ALTER TABLE "promo_codes"
      DROP COLUMN "max_discount_amount"
    `);
  }
}
