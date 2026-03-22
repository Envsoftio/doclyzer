import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateUserSharePoliciesTable1730814000000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "user_share_policies" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "default_expires_in_days" integer,
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_user_share_policies" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_user_share_policies_user_id" UNIQUE ("user_id"),
        CONSTRAINT "FK_user_share_policies_user_id" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "user_share_policies"`);
  }
}
