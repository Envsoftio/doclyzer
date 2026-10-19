import test from 'node:test'
import assert from 'node:assert/strict'
import { ReportSseParser } from '../app/utils/reportSse.ts'
test('fragmented UTF-8, CRLF, multiline data, heartbeats and duplicate IDs', () => {
  const parser = new ReportSseParser(), decoder = new TextDecoder(), frames = []
  const bytes = new TextEncoder().encode(': heartbeat\r\n\r\nid: 9\r\nevent: report.status_changed\r\ndata: {"name":"é",\r\ndata: "version":"9"}\r\n\r\nid: 9\nevent: report.status_changed\ndata: {}\n\n')
  for (const byte of bytes) frames.push(...parser.push(decoder.decode(Uint8Array.of(byte), { stream: true })))
  assert.equal(frames.length, 2)
  assert.equal(frames[0].id, '9')
  assert.deepEqual(JSON.parse(frames[0].data), { name: 'é', version: '9' })
  assert.equal(frames[1].id, '9')
})
test('bounds incomplete frames', () => assert.throws(() => new ReportSseParser().push('x'.repeat(1024 * 1024 + 1))))
