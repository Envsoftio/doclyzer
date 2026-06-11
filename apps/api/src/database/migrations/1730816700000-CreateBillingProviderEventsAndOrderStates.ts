import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateBillingProviderEventsAndOrderStates1730816700000 implements MigrationInterface {
  name = 'CreateBillingProviderEventsAndOrderStates1730816700000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "billing_provider_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "provider" character varying(32) NOT NULL,
        "provider_event_id" character varying(255),
        "idempotency_key" character varying(128) NOT NULL,
        "event_type" character varying(64) NOT NULL,
        "order_id" uuid,
        "razorpay_order_id" character varying(255),
        "razorpay_payment_id" character varying(255),
        "outcome" character varying(32) NOT NULL DEFAULT 'received',
        "error_code" character varying(64),
        "metadata" jsonb,
        "received_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_billing_provider_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_billing_provider_events_order"
          FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE UNIQUE INDEX "UQ_billing_provider_events_idempotency"
      ON "billing_provider_events" ("idempotency_key")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_billing_provider_events_order"
      ON "billing_provider_events" ("order_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_billing_provider_events_provider_event"
      ON "billing_provider_events" ("provider", "provider_event_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_billing_provider_events_type_received"
      ON "billing_provider_events" ("event_type", "received_at")
    `);

    await queryRunner.query(`
      UPDATE "orders"
      SET "status" = CASE
        WHEN "status" = 'pending' THEN 'payment_pending'
        WHEN "status" IN ('paid', 'signature_verified') THEN 'client_purchase_confirmed'
        ELSE "status"
      END
    `);
    await queryRunner.query(
      `ALTER TABLE "orders" ALTER COLUMN "status" SET DEFAULT 'payment_pending'`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "orders" ALTER COLUMN "status" SET DEFAULT 'pending'`,
    );
    await queryRunner.query(`
      UPDATE "orders"
      SET "status" = CASE
        WHEN "status" IN ('created', 'payment_pending', 'webhook_pending', 'pending_review') THEN 'pending'
        WHEN "status" IN ('client_purchase_confirmed', 'signature_verified') THEN 'paid'
        ELSE "status"
      END
    `);

    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_billing_provider_events_type_received"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_billing_provider_events_provider_event"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_billing_provider_events_order"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "UQ_billing_provider_events_idempotency"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "billing_provider_events"`);
  }
}
