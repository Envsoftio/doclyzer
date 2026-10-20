import { strict as assert } from 'node:assert';
import { readFileSync } from 'node:fs';
import { parseVlTablePage } from '../src/modules/reports/geometry/vl-table';

const page = (html: string) => ({ width: 1000, height: 1200, parsing_res_list: [
  { block_label: 'table', block_bbox: [10, 20, 900, 800], block_content: html },
] });
const header = '<tr><td>Test Name</td><td>Obtained Value</td><td>Unit</td><td>Bio. Ref. Intervals (Age/Gender specific)</td></tr>';
const rows = parseVlTablePage(page(`<table>${header}<tr><td>WBC</td><td>12.8</td><td>10^3/uL</td><td>4-11</td></tr><tr><td>RBC</td><td></td><td></td><td>4-5</td></tr></table>`), 0);
assert.equal(rows.length, 2);
assert.equal(rows[0].resultRaw, '12.8');
assert.equal(rows[0].rangeRaw, '4-11');
assert.equal(rows[1].resultRaw, null);
assert(rows[1].reviewReasons.includes('missing_result'));
assert(rows.every((r) => r.machineEligible === false && r.status === 'needs_review'));
assert.equal(parseVlTablePage(page(`<table><tr><td>Test Name</td><td>Current Result</td><td>Prior Result</td></tr><tr><td>WBC</td><td>12.8</td><td>10.2</td></tr></table>`), 0).length, 0);
assert.equal(parseVlTablePage(page(`<table>${header}<tr><td colspan="2">WBC</td><td>12.8</td></tr></table>`), 0).length, 0);
const sample = process.env.REPORT_VL_PRIVATE_SAMPLE;
if (sample) {
  const real = parseVlTablePage(JSON.parse(readFileSync(sample, 'utf8')), 0);
  assert.equal(real.length, 20, 'Private sample must expose 20 review rows');
  assert(real.every((r) => r.tableBox.length === 4 && r.pageWidth > 0));
}
console.log('PaddleOCR-VL table contract passed');
