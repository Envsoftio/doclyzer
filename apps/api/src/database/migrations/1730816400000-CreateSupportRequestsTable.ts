import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateSupportRequestsTable1730816400000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "support_requests" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "action_type" varchar(64) NOT NULL,
        "correlation_id" varchar(128) NOT NULL,
        "client_action_id" varchar(128),
        "error_code" varchar(64),
        "error_message" text,
        "entity_ids" jsonb,
        "metadata" jsonb,
        "user_message" text,
        "status" varchar(24) NOT NULL DEFAULT 'open',
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_support_requests" PRIMARY KEY ("id"),
        CONSTRAINT "FK_support_requests_user" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_support_requests_user_id" ON "support_requests" ("user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_support_requests_created_at" ON "support_requests" ("created_at")`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "support_requests"`);
  }
}
