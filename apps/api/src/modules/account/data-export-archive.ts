import { gzipSync } from 'node:zlib';

export interface ExportEntry {
  path: string;
  data: Buffer;
}

function octal(header: Buffer, offset: number, width: number, value: number) {
  const text = value.toString(8).padStart(width - 1, '0');
  header.write(`${text}\0`, offset, width, 'ascii');
}

/** Standard ustar archive, compressed with gzip; no third-party archive runtime. */
export function createDataExportArchive(entries: ExportEntry[]): Buffer {
  const blocks: Buffer[] = [];
  for (const entry of entries) {
    const name = Buffer.from(entry.path, 'utf8');
    if (name.length > 100 || entry.path.startsWith('/') || entry.path.includes('..')) {
      throw new Error('Invalid export path');
    }
    const header = Buffer.alloc(512);
    name.copy(header, 0);
    octal(header, 100, 8, 0o600);
    octal(header, 108, 8, 0);
    octal(header, 116, 8, 0);
    octal(header, 124, 12, entry.data.length);
    octal(header, 136, 12, Math.floor(Date.now() / 1000));
    header.fill(32, 148, 156);
    header.write('0', 156, 1, 'ascii');
    header.write('ustar\0', 257, 6, 'ascii');
    header.write('00', 263, 2, 'ascii');
    const checksum = header.reduce((sum, value) => sum + value, 0);
    octal(header, 148, 8, checksum);
    blocks.push(header, entry.data);
    const remainder = entry.data.length % 512;
    if (remainder) blocks.push(Buffer.alloc(512 - remainder));
  }
  blocks.push(Buffer.alloc(1024));
  return gzipSync(Buffer.concat(blocks));
}

export function exportCsv(rows: Array<Array<unknown>>): Buffer {
  const encoded = rows
    .map((row) =>
      row
        .map((value) => `"${String(value ?? '').replaceAll('"', '""')}"`)
        .join(','),
    )
    .join('\r\n');
  return Buffer.from(`\uFEFF${encoded}\r\n`, 'utf8');
}
