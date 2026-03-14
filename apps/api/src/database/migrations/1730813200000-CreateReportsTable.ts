import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportsTable1730813200000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "reports" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "profile_id" uuid NOT NULL,
        "original_file_name" varchar(512) NOT NULL,
        "content_type" varchar(128) NOT NULL,
        "size_bytes" integer NOT NULL,
        "original_file_storage_key" varchar(1024) NOT NULL,
        "status" varchar(32) NOT NULL DEFAULT 'queued',
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_reports" PRIMARY KEY ("id"),
        CONSTRAINT "FK_reports_user" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_reports_profile" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_reports_user_id" ON "reports" ("user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_reports_profile_id" ON "reports" ("profile_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_reports_created_at" ON "reports" ("created_at")`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "reports"`);
  }
}
