import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateGiftVouchers1730817100000 implements MigrationInterface {
  name = 'CreateGiftVouchers1730817100000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "gift_vouchers" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "code_hash" character varying(64) NOT NULL,
        "code_mask" character varying(24) NOT NULL,
        "credit_amount" numeric(10,2) NOT NULL,
        "status" character varying(32) NOT NULL DEFAULT 'active',
        "expires_at" TIMESTAMP WITH TIME ZONE,
        "created_by_user_id" uuid,
        "redeemed_by_user_id" uuid,
        "redeemed_at" TIMESTAMP WITH TIME ZONE,
        "voided_by_user_id" uuid,
        "voided_at" TIMESTAMP WITH TIME ZONE,
        "void_reason" character varying(240),
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_gift_vouchers_id" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_gift_vouchers_code_hash" UNIQUE ("code_hash"),
        CONSTRAINT "FK_gift_vouchers_created_by_user_id"
          FOREIGN KEY ("created_by_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_gift_vouchers_redeemed_by_user_id"
          FOREIGN KEY ("redeemed_by_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_gift_vouchers_voided_by_user_id"
          FOREIGN KEY ("voided_by_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_gift_vouchers_status"
      ON "gift_vouchers" ("status")
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_gift_vouchers_expires_at"
      ON "gift_vouchers" ("expires_at")
    `);

    await queryRunner.query(`
      CREATE TABLE "gift_voucher_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "gift_voucher_id" uuid NOT NULL,
        "actor_user_id" uuid,
        "event_type" character varying(64) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_gift_voucher_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_gift_voucher_events_gift_voucher_id"
          FOREIGN KEY ("gift_voucher_id") REFERENCES "gift_vouchers"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
        CONSTRAINT "FK_gift_voucher_events_actor_user_id"
          FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_gift_voucher_events_voucher_created_at"
      ON "gift_voucher_events" ("gift_voucher_id", "created_at")
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_gift_voucher_events_type_created_at"
      ON "gift_voucher_events" ("event_type", "created_at")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_gift_voucher_events_type_created_at"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_gift_voucher_events_voucher_created_at"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "gift_voucher_events"`);
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_gift_vouchers_expires_at"`,
    );
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_gift_vouchers_status"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "gift_vouchers"`);
  }
}
