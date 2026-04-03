import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateServiceIncidentsTable1730816300000
  implements MigrationInterface
{
  name = 'CreateServiceIncidentsTable1730816300000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TYPE "incident_severity" AS ENUM ('major', 'critical')`,
    );
    await queryRunner.query(
      `CREATE TYPE "incident_status" AS ENUM ('active', 'monitoring', 'resolved')`,
    );
    await queryRunner.query(`
      CREATE TABLE "service_incidents" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "severity" "incident_severity" NOT NULL,
        "status" "incident_status" NOT NULL,
        "headline" text NOT NULL,
        "message" text NOT NULL,
        "whats_affected" text NOT NULL,
        "affected_surfaces" text[] NOT NULL,
        "started_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "resolved_at" TIMESTAMP WITH TIME ZONE,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_service_incidents_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_service_incidents_status_updated_at"
      ON "service_incidents" ("status", "updated_at")
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX "IDX_service_incidents_status_updated_at"`,
    );
    await queryRunner.query(`DROP TABLE "service_incidents"`);
    await queryRunner.query(`DROP TYPE "incident_status"`);
    await queryRunner.query(`DROP TYPE "incident_severity"`);
  }
}
