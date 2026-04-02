import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddGinIndexToDeliveryEventMetadata1730816100000
  implements MigrationInterface
{
  name = 'AddGinIndexToDeliveryEventMetadata1730816100000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE INDEX "IDX_email_delivery_metadata_gin" ON "email_delivery_events" USING GIN ("metadata")',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'DROP INDEX "public"."IDX_email_delivery_metadata_gin"',
    );
  }
}
