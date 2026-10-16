"""Internal, bounded PDF OCR endpoint. Run one worker; model service is separate."""
import asyncio
import json
import os
import tempfile
from pathlib import Path

import pypdfium2 as pdfium
from fastapi import FastAPI, HTTPException, Request
from adapter import adapt

app = FastAPI(docs_url=None, redoc_url=None)
lock = asyncio.Lock()
MAX_BYTES = 25 * 1024 * 1024
MAX_PAGES = int(os.getenv('SURYA_MAX_PAGES', '50'))
TIMEOUT = int(os.getenv('SURYA_JOB_TIMEOUT_SECONDS', '600'))


@app.get('/health')
async def health():
    return {'status': 'ok'}


@app.post('/v1/convert/pdf')
async def convert(request: Request):
    if lock.locked():
        raise HTTPException(503, 'OCR worker busy')
    async with lock:
        with tempfile.TemporaryDirectory(prefix='report-ocr-') as folder:
            path = Path(folder) / 'report.pdf'
            size = 0
            with path.open('wb') as out:
                async for chunk in request.stream():
                    size += len(chunk)
                    if size > MAX_BYTES:
                        raise HTTPException(413, 'PDF too large')
                    out.write(chunk)
            try:
                with pdfium.PdfDocument(str(path)) as doc:
                    page_count = len(doc)
                    if not 0 < page_count <= MAX_PAGES:
                        raise HTTPException(413, 'PDF page limit exceeded')
            except HTTPException:
                raise
            except Exception:
                raise HTTPException(422, 'Invalid or encrypted PDF') from None
            # Require a separately supervised model server: terminating this job
            # cannot leave an auto-spawned model process running or leak a document.
            if not os.getenv('SURYA_INFERENCE_URL'):
                raise HTTPException(503, 'Model endpoint not configured')
            process = await asyncio.create_subprocess_exec(
                'surya_ocr', str(path), '--output_dir', str(Path(folder) / 'out'),
                stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL,
            )
            try:
                await asyncio.wait_for(process.wait(), timeout=TIMEOUT)
                if process.returncode:
                    raise HTTPException(502, 'OCR conversion failed')
                raw = json.loads((Path(folder) / 'out/report/results.json').read_text())
                if len(next(iter(raw.values()))) != page_count:
                    raise ValueError('Incomplete page output')
                return adapt(raw)
            except asyncio.TimeoutError:
                raise HTTPException(504, 'OCR timed out') from None
            except (ValueError, KeyError, TypeError, OSError):
                raise HTTPException(502, 'Invalid OCR output') from None
            finally:
                if process.returncode is None:
                    process.kill()
                    await process.wait()
