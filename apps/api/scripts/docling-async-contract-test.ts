import assert from 'node:assert/strict';
import { PDFDocument, StandardFonts } from 'pdf-lib';
async function main() {
  const base = process.env.DOCLING_TEST_URL;
  if (!base)
    throw new Error(
      'Set DOCLING_TEST_URL to a disposable/staging Docling 1.37.0 instance',
    );
  const pdf = await PDFDocument.create(),
    font = await pdf.embedFont(StandardFonts.Helvetica),
    page = pdf.addPage();
  [
    'SYNTHETIC TEST LAB REPORT',
    'Test                 Result          Reference',
    'Haemoglobin          13.5 g/dL       12 - 16',
    'Platelet Count       250             150 - 450',
  ].forEach((line, i) =>
    page.drawText(line, { x: 40, y: 700 - i * 30, size: 12, font }),
  );
  const form = new FormData();
  form.append(
    'files',
    new Blob([new Uint8Array(await pdf.save())], { type: 'application/pdf' }),
    'synthetic-test.pdf',
  );
  form.append('to_formats', 'md');
  form.append('to_formats', 'json');
  form.append('do_ocr', 'false');
  form.append('include_images', 'false');
  const started = Date.now();
  const submit = await fetch(`${base}/v1/convert/file/async`, {
    method: 'POST',
    body: form,
    signal: AbortSignal.timeout(30000),
  });
  assert.ok(submit.ok, `submission status ${submit.status}`);
  const task = (await submit.json()) as { task_id: string };
  assert.ok(task.task_id);
  let success = false;
  while (Date.now() - started < 300000) {
    const response = await fetch(`${base}/v1/status/poll/${task.task_id}`, {
      signal: AbortSignal.timeout(30000),
    });
    assert.ok(response.ok);
    const status = (await response.json()) as { task_status: string };
    if (status.task_status === 'failure')
      throw new Error('Provider conversion failed');
    if (status.task_status === 'success') {
      success = true;
      break;
    }
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
  assert.ok(success, 'conversion deadline');
  for (let i = 0; i < 2; i++) {
    const response = await fetch(`${base}/v1/result/${task.task_id}`, {
      signal: AbortSignal.timeout(30000),
    });
    assert.ok(response.ok);
    const data = (await response.json()) as {
      status: string;
      document: { md_content: string; json_content: { schema_name: string } };
    };
    assert.equal(data.status, 'success');
    assert.ok(data.document.md_content);
    assert.equal(data.document.json_content.schema_name, 'DoclingDocument');
  }
  console.log(
    `PASS live async Docling submission/status/result schema and immediate repeat retrieval (${Date.now() - started} ms). This is not a >120s load or retention-expiry test.`,
  );
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
