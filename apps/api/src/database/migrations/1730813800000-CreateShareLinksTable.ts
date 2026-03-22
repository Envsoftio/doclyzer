import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateShareLinksTable1730813800000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "share_links" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "profile_id" uuid NOT NULL,
        "token" varchar(64) NOT NULL,
        "scope" varchar(32) NOT NULL DEFAULT 'all',
        "is_active" boolean NOT NULL DEFAULT true,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_share_links" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_share_links_token" UNIQUE ("token"),
        CONSTRAINT "FK_share_links_user_id" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_share_links_profile_id" FOREIGN KEY ("profile_id")
          REFERENCES "profiles"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_share_links_profile_id" ON "share_links" ("profile_id")`
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_share_links_user_id" ON "share_links" ("user_id")`
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "share_links"`);
  }
}
