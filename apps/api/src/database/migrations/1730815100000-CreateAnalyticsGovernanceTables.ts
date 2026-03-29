import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateAnalyticsGovernanceTables1730815100000 implements MigrationInterface {
  name = 'CreateAnalyticsGovernanceTables1730815100000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "analytics_taxonomy_fields" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "event_name" character varying(128) NOT NULL,
        "field_name" character varying(128) NOT NULL,
        "classification" character varying(32) NOT NULL,
        "allow_list" boolean NOT NULL DEFAULT false,
        "notes" text,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_analytics_taxonomy_fields_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "IDX_analytics_taxonomy_event_field"
      ON "analytics_taxonomy_fields" ("event_name", "field_name")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_analytics_taxonomy_event"
      ON "analytics_taxonomy_fields" ("event_name")
    `);

    await queryRunner.query(`
      CREATE TABLE "analytics_governance_reviews" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "event_name" character varying(128) NOT NULL,
        "field_name" character varying(128) NOT NULL,
        "classification" character varying(32) NOT NULL,
        "status" character varying(32) NOT NULL DEFAULT 'pending',
        "details" text,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_analytics_governance_reviews_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_analytics_governance_reviews_event_field"
      ON "analytics_governance_reviews" ("event_name", "field_name")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_analytics_governance_reviews_event"
      ON "analytics_governance_reviews" ("event_name")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP INDEX "public"."IDX_analytics_governance_reviews_event"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_analytics_governance_reviews_event_field"
    `);
    await queryRunner.query(`
      DROP TABLE "analytics_governance_reviews"
    `);

    await queryRunner.query(`
      DROP INDEX "public"."IDX_analytics_taxonomy_event"
    `);
    await queryRunner.query(`
      DROP INDEX "public"."IDX_analytics_taxonomy_event_field"
    `);
    await queryRunner.query(`
      DROP TABLE "analytics_taxonomy_fields"
    `);
  }
}
