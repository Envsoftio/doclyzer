import assert from 'node:assert/strict';
import { PDFDocument } from 'pdf-lib';
import { ReportVlShadowService } from '../src/modules/reports/processing/report-vl-shadow.service';
import type { DataSource } from 'typeorm';
import type { ConfigService } from '@nestjs/config';

async function main() {
  const pdf = await PDFDocument.create(); pdf.addPage([600,800]); pdf.addPage([600,800]);
  let saved: unknown[] = [];
  const db = { query: async (_sql:string, values:unknown[]) => { saved = values; return []; } } as unknown as DataSource;
  const config = { get: () => 'false' } as unknown as ConfigService;
  const box = (x:number,y:number,w:number) => [[x,y],[x+w,y],[x+w,y+15],[x,y+15]];
  const words = ['Test','Result','Unit','Glucose','90','mg/dL'];
  const polys = [box(10,20,60),box(210,20,65),box(400,20,40),box(10,50,80),box(210,50,30),box(400,50,60)];
  const output = { text: '', parsedJson: { reviewPages: { '1': { visual: { parsedJson: { paddlePage: {
    page_width:600,page_height:800,dpi:72,native_words:[],paddle:{rec_texts:words,rec_scores:words.map(()=>0.9),rec_polys:polys},
    model_version:'PP-OCRv5_mobile',paddleocr_version:'3.2.0',docling_parse_version:'7.22.3',
  } } } } } } };
  await new ReportVlShadowService(db, config).capture('00000000-0000-4000-8000-000000000001',1,Buffer.from(await pdf.save()),new AbortController().signal,output);
  assert.equal(saved.length,5);
  const candidates = JSON.parse(saved[2] as string);
  assert.equal(candidates.length,1);
  assert.equal(candidates[0].testRaw,'Glucose');
  assert.equal(candidates[0].resultRaw,'90');
  assert.equal(candidates[0].machineEligible,false);
  assert.equal(candidates[0].id,'p0-t1000-r0');
  const raw = JSON.parse(saved[4] as string);
  assert.deepEqual(raw[0].geometry.paddlePage.paddle.rec_texts,words);
  assert.equal(raw[1].geometry, null);
  const statuses = JSON.parse(saved[3] as string);
  assert.deepEqual(statuses.map((page: { status: string }) => page.status), ['parsed', 'parsed']);
  console.log('PASS Paddle evidence persists as review candidate with aligned raw output');
}
void main().catch((error)=>{console.error(error);process.exitCode=1});
