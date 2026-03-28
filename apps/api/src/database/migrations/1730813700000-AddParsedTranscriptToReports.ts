import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddParsedTranscriptToReports1730813700000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "reports" ADD COLUMN "parsed_transcript" text NULL`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "reports" DROP COLUMN "parsed_transcript"`,
    );
  }
}
