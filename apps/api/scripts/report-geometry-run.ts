/** Shadow parser for a private evidence manifest produced by an OCR adapter.
 * stdout is PHI: run only in an approved local environment. */
import { readFileSync, writeFileSync } from 'node:fs';
import {
  parseGeometry,
  type LabTemplate,
} from '../src/modules/reports/geometry/lab-parser';
import type { PageEvidence } from '../src/modules/reports/geometry/evidence';

const [input, output] = process.argv.slice(2);
if (!input || !output)
  throw new Error(
    'Usage: ts-node scripts/report-geometry-run.ts evidence.json review.json',
  );
if (process.env.REPORT_GEOMETRY_SHADOW_ENABLED !== 'true')
  throw new Error(
    'Set REPORT_GEOMETRY_SHADOW_ENABLED=true for local shadow evaluation',
  );
const manifest = JSON.parse(readFileSync(input, 'utf8')) as {
  pages: PageEvidence[];
  expectedPageIds: string[];
  templates?: LabTemplate[];
};
if (!Array.isArray(manifest.pages) || !Array.isArray(manifest.expectedPageIds))
  throw new Error('Expected pages and expectedPageIds arrays');
const result = parseGeometry(
  manifest.pages,
  manifest.expectedPageIds,
  manifest.templates ?? [],
);
writeFileSync(
  output,
  JSON.stringify(
    { schemaVersion: 1, automaticRelease: false, ...result },
    null,
    2,
  ),
  { mode: 0o600 },
);
