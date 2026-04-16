import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddIdempotencyKeyToEmailQueue1730816000000 implements MigrationInterface {
  name = 'AddIdempotencyKeyToEmailQueue1730816000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE "email_queue_items" ADD "idempotency_key" character varying(128)',
    );
    await queryRunner.query(
      'CREATE UNIQUE INDEX "UQ_email_queue_idempotency" ON "email_queue_items" ("idempotency_key")',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX "public"."UQ_email_queue_idempotency"');
    await queryRunner.query(
      'ALTER TABLE "email_queue_items" DROP COLUMN "idempotency_key"',
    );
  }
}
