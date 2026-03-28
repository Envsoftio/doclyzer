import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateShareAccessEventsTable1730814100000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "share_access_events" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "share_link_id" uuid NOT NULL,
        "outcome" varchar(32) NOT NULL DEFAULT 'accessed',
        "accessed_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_share_access_events" PRIMARY KEY ("id"),
        CONSTRAINT "FK_share_access_events_share_link_id" FOREIGN KEY ("share_link_id")
          REFERENCES "share_links"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_share_access_events_share_link_id" ON "share_access_events" ("share_link_id")`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "share_access_events"`);
  }
}
