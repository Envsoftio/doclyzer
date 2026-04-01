import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateCaseResolutionDocumentsTable1730815800000
  implements MigrationInterface
{
  name = 'CreateCaseResolutionDocumentsTable1730815800000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "case_resolution_documents" (
        "id"                   UUID          NOT NULL DEFAULT uuid_generate_v4(),
        "target_user_id"       UUID          NOT NULL,
        "author_user_id"       UUID,
        "summary"              TEXT          NOT NULL,
        "root_cause"           TEXT          NOT NULL,
        "user_impact"          TEXT          NOT NULL,
        "actions_taken"        TEXT          NOT NULL,
        "outcome"              VARCHAR(32)   NOT NULL,
        "audit_correlation_id" VARCHAR(128),
        "prior_document_id"    UUID,
        "version"              INTEGER       NOT NULL DEFAULT 1,
        "created_at"           TIMESTAMPTZ   NOT NULL DEFAULT now(),
        CONSTRAINT "PK_case_resolution_documents" PRIMARY KEY ("id"),
        CONSTRAINT "FK_case_resolution_documents_target_user" FOREIGN KEY ("target_user_id")
          REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_case_resolution_documents_author_user" FOREIGN KEY ("author_user_id")
          REFERENCES "users"("id") ON DELETE SET NULL
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_case_resolution_documents_target_user_id" ON "case_resolution_documents" ("target_user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_case_resolution_documents_created_at" ON "case_resolution_documents" ("created_at")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX "IDX_case_resolution_documents_created_at"`,
    );
    await queryRunner.query(
      `DROP INDEX "IDX_case_resolution_documents_target_user_id"`,
    );
    await queryRunner.query(`DROP TABLE "case_resolution_documents"`);
  }
}
