/** Compare locally saved Docling responses with independently verified observations.
 * npm run reports:benchmark -- expected.json response1.json response2.json
 * Expected JSON: [{parameterName, value, unit, referenceRange?}].
 * No network calls. No report contents are printed; only aggregate metrics.
 */
import { readFileSync } from 'node:fs';
import { OpenDataLoaderJsonParser } from '../src/modules/reports/opendataloader-json-parser';

interface ExpectedRow {
  parameterName: string;
  value: string;
  unit: string | null;
  referenceRange?: string | null;
}
const [expectedPath, ...responsePaths] = process.argv.slice(2);
if (!expectedPath || !responsePaths.length) {
  throw new Error(
    'Usage: reports:benchmark -- expected.json response.json [response.json ...]',
  );
}
const expected: unknown = JSON.parse(readFileSync(expectedPath, 'utf8'));
if (
  !Array.isArray(expected) ||
  !expected.length ||
  !expected.every(
    (row: ExpectedRow) =>
      row &&
      typeof row.parameterName === 'string' &&
      typeof row.value === 'string' &&
      (typeof row.unit === 'string' || row.unit === null),
  )
) {
  throw new Error(
    'Expected a nonempty array of verified {parameterName,value,unit} observations.',
  );
}
const gold = expected as ExpectedRow[];
const key = (row: ExpectedRow) =>
  JSON.stringify([
    row.parameterName.trim(),
    row.value.trim(),
    (row.unit ?? '').trim(),
  ]);
const parser = new OpenDataLoaderJsonParser();
for (const [index, path] of responsePaths.entries()) {
  const response = JSON.parse(readFileSync(path, 'utf8')) as {
    status?: string;
    document?: { json_content?: unknown };
    schema_name?: string;
  };
  if (response.status && response.status !== 'success') {
    console.log(
      JSON.stringify({
        input: index + 1,
        status: response.status,
        expected: gold.length,
        matched: 0,
      }),
    );
    continue;
  }
  const doc = response.document?.json_content ?? response;
  const parsed = parser.parseWithDiagnostics(doc);
  const actual = parsed.extractedLabValues.map((r) => ({
    ...r,
    unit: r.unit ?? null,
  }));
  const available = [...actual];
  let matched = 0;
  let rangesChecked = 0;
  let rangesMatched = 0;
  for (const row of gold) {
    const i = available.findIndex((candidate) => key(candidate) === key(row));
    if (Object.hasOwn(row, 'referenceRange')) rangesChecked++;
    if (i < 0) continue;
    matched++;
    const candidate = available.splice(i, 1)[0];
    if (
      Object.hasOwn(row, 'referenceRange') &&
      (candidate.referenceRange ?? '').trim() ===
        (row.referenceRange ?? '').trim()
    )
      rangesMatched++;
  }
  console.log(
    JSON.stringify({
      input: index + 1,
      expected: gold.length,
      extracted: actual.length,
      matchedNameValueUnit: matched,
      unmatchedExpected: gold.length - matched,
      unmatchedActual: available.length,
      rangesChecked,
      rangesMatched,
    }),
  );
}
