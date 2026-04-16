import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddRestrictionReviewMode1730815600000 implements MigrationInterface {
  name = 'AddRestrictionReviewMode1730815600000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "restrictions" ADD "restricted_review_mode" boolean NOT NULL DEFAULT false`,
    );
    await queryRunner.query(
      `ALTER TABLE "restrictions" ADD "restricted_until" TIMESTAMPTZ`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "restrictions" DROP COLUMN "restricted_until"`,
    );
    await queryRunner.query(
      `ALTER TABLE "restrictions" DROP COLUMN "restricted_review_mode"`,
    );
  }
}
