import { Client } from 'pg';
import { extractAutoImageLabRows } from '../src/modules/reports/geometry/image-auto-parser';
import {
  loadObservationRules,
  normalizeObservation,
} from '../src/modules/reports/observation-normalizer';
import type { PaddlePageOutput } from '../src/modules/reports/paddle-ocr.client';

// Repairs only blank OCR metadata. Names, results, reviewed rows, and existing
// metadata must agree with the saved report before any write is attempted.
async function main() {
  const reportId = process.argv[2];
  const apply = process.argv[3] === '--apply';
  if (!/^[0-9a-f]{8}-[0-9a-f-]{27,}$/.test(reportId ?? ''))
    throw new Error('Usage: ts-node backfill-image-metadata.ts REPORT_UUID [--apply]');
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();
  try {
    await client.query('BEGIN');
    const report = (
      await client.query(
        `SELECT content_type,status,processing_state,structured_report
         FROM reports WHERE id=$1 AND deleted_at IS NULL FOR UPDATE`,
        [reportId],
      )
    ).rows[0];
    if (
      !report ||
      !['image/jpeg', 'image/png'].includes(report.content_type) ||
      report.status !== 'parsed' ||
      report.processing_state !== 'ready'
    )
      throw new Error('Report is not a ready parsed image');
    const shadow = (
      await client.query(
        'SELECT raw_output FROM report_vl_shadows WHERE report_id=$1',
        [reportId],
      )
    ).rows[0];
    const page = shadow?.raw_output?.[0]?.geometry?.paddlePage as
      | PaddlePageOutput['parsedJson']['paddlePage']
      | undefined;
    if (!page) throw new Error('Stored OCR page is unavailable');
    const recovered = extractAutoImageLabRows(page);
    const saved = (
      await client.query(
        `SELECT id,sort_order,parameter_name,value,unit,reference_range,
                review_version,extraction_source,canonical_test_id
         FROM report_lab_values WHERE report_id=$1 ORDER BY sort_order FOR UPDATE`,
        [reportId],
      )
    ).rows;
    const tests = (report.structured_report?.sections ?? []).flatMap(
      (section: { tests?: Array<Record<string, unknown>> }) => section.tests ?? [],
    ) as Array<Record<string, unknown>>;
    if (
      !recovered.length ||
      recovered.length !== saved.length ||
      tests.length !== saved.length ||
      saved.some(
        (row, index) =>
          row.sort_order !== index ||
          row.review_version !== 0 ||
          row.extraction_source !== 'paddleocr_geometry' ||
          row.parameter_name !== recovered[index].parameterName ||
          row.value !== recovered[index].value ||
          tests[index].parameterName !== row.parameter_name ||
          tests[index].value !== row.value ||
          (row.unit && row.unit !== recovered[index].unit) ||
          (row.reference_range &&
            row.reference_range !== recovered[index].referenceRange),
      )
    )
      throw new Error('Saved rows do not match the OCR evidence');
    const rules = await loadObservationRules(async (sql) =>
      (await client.query(sql)).rows,
    );
    let changed = 0;
    for (let index = 0; index < saved.length; index++) {
      const old = saved[index];
      const evidence = recovered[index];
      const unit = old.unit || evidence.unit;
      const range = old.reference_range || evidence.referenceRange;
      if (unit === old.unit && range === old.reference_range) continue;
      const normalized = normalizeObservation(
        { parameterName: old.parameter_name, value: old.value, unit },
        rules,
      );
      if (normalized.canonicalTestId !== old.canonical_test_id)
        throw new Error('Observation identity changed during backfill');
      tests[index].unit = unit;
      tests[index].referenceRange = range;
      if (apply) {
        await client.query(
          `UPDATE report_lab_values
           SET unit=$2,original_unit=$2,reference_range=$3,
               normalized_unit=$4,normalized_numeric_value=$5,review_state=$6
           WHERE id=$1 AND review_version=0`,
          [
            old.id,
            unit,
            range,
            normalized.normalizedUnit,
            normalized.normalizedNumericValue,
            normalized.reviewState,
          ],
        );
      }
      changed++;
    }
    if (apply && changed) {
      await client.query(
        'UPDATE reports SET structured_report=$2::jsonb,updated_at=clock_timestamp() WHERE id=$1',
        [reportId, JSON.stringify(report.structured_report)],
      );
    }
    await client.query(apply ? 'COMMIT' : 'ROLLBACK');
    console.log(`${apply ? 'Updated' : 'Would update'} ${changed} of ${saved.length} rows`);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    await client.end();
  }
}

void main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
