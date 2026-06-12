import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReferralFoundation1730817000000 implements MigrationInterface {
  name = 'CreateReferralFoundation1730817000000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "user_referral_profiles" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "referral_code" character varying(32) NOT NULL,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_user_referral_profiles_id" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_user_referral_profiles_user_id" UNIQUE ("user_id"),
        CONSTRAINT "FK_user_referral_profiles_user_id"
          FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE UNIQUE INDEX "UQ_user_referral_profiles_referral_code_upper"
      ON "user_referral_profiles" (UPPER("referral_code"))
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_user_referral_profiles_referral_code_lookup"
      ON "user_referral_profiles" ("referral_code")
    `);

    await queryRunner.query(`
      CREATE TABLE "referral_logs" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "referrer_user_id" uuid NOT NULL,
        "invitee_user_id" uuid NOT NULL,
        "referrer_profile_id" uuid NOT NULL,
        "applied_referral_code" character varying(32) NOT NULL,
        "review_status" character varying(32) NOT NULL DEFAULT 'pending',
        "invitee_bonus_status" character varying(32) NOT NULL DEFAULT 'pending',
        "milestone_a_status" character varying(32) NOT NULL DEFAULT 'pending',
        "milestone_b_status" character varying(32) NOT NULL DEFAULT 'pending',
        "invitee_bonus_released_at" TIMESTAMP WITH TIME ZONE,
        "milestone_a_released_at" TIMESTAMP WITH TIME ZONE,
        "milestone_b_released_at" TIMESTAMP WITH TIME ZONE,
        "blocked_reason_code" character varying(64),
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_referral_logs_id" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_referral_logs_invitee_user_id" UNIQUE ("invitee_user_id"),
        CONSTRAINT "FK_referral_logs_referrer_user_id"
          FOREIGN KEY ("referrer_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
        CONSTRAINT "FK_referral_logs_invitee_user_id"
          FOREIGN KEY ("invitee_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
        CONSTRAINT "FK_referral_logs_referrer_profile_id"
          FOREIGN KEY ("referrer_profile_id") REFERENCES "user_referral_profiles"("id") ON DELETE CASCADE ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_referral_logs_referrer_user_id"
      ON "referral_logs" ("referrer_user_id")
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_referral_logs_invitee_user_id"
      ON "referral_logs" ("invitee_user_id")
    `);

    await queryRunner.query(`
      CREATE TABLE "referral_reward_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "referral_log_id" uuid NOT NULL,
        "beneficiary_user_id" uuid NOT NULL,
        "reward_type" character varying(32) NOT NULL,
        "status" character varying(32) NOT NULL DEFAULT 'pending',
        "credit_amount" numeric(10,2) NOT NULL,
        "idempotency_key" character varying(128),
        "reason_code" character varying(64),
        "metadata" jsonb,
        "resolved_at" TIMESTAMP WITH TIME ZONE,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_referral_reward_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_referral_reward_events_referral_log_id"
          FOREIGN KEY ("referral_log_id") REFERENCES "referral_logs"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
        CONSTRAINT "FK_referral_reward_events_beneficiary_user_id"
          FOREIGN KEY ("beneficiary_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE UNIQUE INDEX "UQ_referral_reward_events_idempotency_key"
      ON "referral_reward_events" ("idempotency_key")
      WHERE "idempotency_key" IS NOT NULL
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_referral_reward_events_status"
      ON "referral_reward_events" ("status")
    `);

    await queryRunner.query(`
      CREATE TABLE "referral_audit_events" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "referral_log_id" uuid,
        "reward_event_id" uuid,
        "actor_user_id" uuid,
        "event_type" character varying(64) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "reason_code" character varying(64),
        "metadata" jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_referral_audit_events_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_referral_audit_events_referral_log_id"
          FOREIGN KEY ("referral_log_id") REFERENCES "referral_logs"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_referral_audit_events_reward_event_id"
          FOREIGN KEY ("reward_event_id") REFERENCES "referral_reward_events"("id") ON DELETE SET NULL ON UPDATE NO ACTION,
        CONSTRAINT "FK_referral_audit_events_actor_user_id"
          FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_referral_audit_events_created_at"
      ON "referral_audit_events" ("created_at")
    `);

    await queryRunner.query(`
      CREATE TABLE "referral_policy_configs" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "config_key" character varying(64) NOT NULL,
        "invitee_bonus_credits" numeric(10,2) NOT NULL,
        "milestone_a_credits" numeric(10,2) NOT NULL,
        "milestone_b_tiers" jsonb NOT NULL,
        "monthly_reward_cap" numeric(10,2) NOT NULL,
        "zero_amount_order_eligible" boolean NOT NULL DEFAULT false,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_referral_policy_configs_id" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_referral_policy_configs_config_key" UNIQUE ("config_key")
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "referral_policy_configs"`);
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_referral_audit_events_created_at"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "referral_audit_events"`);
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_referral_reward_events_status"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "UQ_referral_reward_events_idempotency_key"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "referral_reward_events"`);
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_referral_logs_invitee_user_id"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_referral_logs_referrer_user_id"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "referral_logs"`);
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_user_referral_profiles_referral_code_lookup"`,
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "UQ_user_referral_profiles_referral_code_upper"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "user_referral_profiles"`);
  }
}
