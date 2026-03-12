import type { DataSource } from 'typeorm';

function quoteIdentifier(identifier: string): string {
  return `"${identifier.replace(/"/g, '""')}"`;
}

/** Truncate all entity tables; uses tablePath for schema-qualified names (TypeORM). */
export async function clearDatabase(dataSource: DataSource): Promise<void> {
  const tableNames = dataSource.entityMetadatas.map(
    (entityMetadata) => entityMetadata.tablePath,
  );

  if (tableNames.length === 0) {
    return;
  }

  const truncationSql = tableNames
    .map((tableName) => quoteIdentifier(tableName))
    .join(', ');
  await dataSource.query(
    `TRUNCATE TABLE ${truncationSql} RESTART IDENTITY CASCADE`,
  );
}
