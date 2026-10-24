import { strict as assert } from 'node:assert';
import { gunzipSync } from 'node:zlib';
import {
  createDataExportArchive,
  exportCsv,
} from '../src/modules/account/data-export-archive';

const csv = exportCsv([
  ['test', 'value'],
  ['Hemoglobin', '13.2'],
  ['a,b', '"quoted"'],
]);
assert(csv.toString('utf8').includes('"a,b","""quoted"""'));

const archive = gunzipSync(
  createDataExportArchive([
    { path: 'account.json', data: Buffer.from('{"id":"one"}') },
    { path: 'results.csv', data: csv },
  ]),
);
let offset = 0;
for (const [expectedPath, expectedData] of [
  ['account.json', Buffer.from('{"id":"one"}')] as const,
  ['results.csv', csv] as const,
]) {
  const header = archive.subarray(offset, offset + 512);
  assert.equal(header.toString('utf8', 0, 100).split('\0')[0], expectedPath);
  const size = parseInt(header.toString('ascii', 124, 136).trim(), 8);
  assert.equal(size, expectedData.length);
  assert.deepEqual(archive.subarray(offset + 512, offset + 512 + size), expectedData);
  offset += 512 + Math.ceil(size / 512) * 512;
}
assert.throws(() => createDataExportArchive([{ path: '../secret', data: Buffer.from('x') }]));
console.log('Data export archive contract passed');
