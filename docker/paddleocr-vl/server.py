"""Bounded local PaddleOCR-VL page service. Raw result content is never logged."""
import json
import os
import subprocess
import sys
import tempfile
import threading
from pathlib import Path
from urllib.parse import urlparse

from fastapi import FastAPI, Header, HTTPException, Request
from PIL import Image
from starlette.concurrency import run_in_threadpool


MAX_BYTES = 10 * 1024 * 1024
MAX_PIXELS = 25_000_000
DEADLINE = int(os.environ.get('LAB_VL_PAGE_TIMEOUT_SEC', '60'))
API_KEY = os.environ.get('LAB_VL_API_KEY', '')
LOCK = threading.Lock()
app = FastAPI()


def authorized(key):
    if not API_KEY:
        raise HTTPException(503, 'Service key not configured')
    if key != API_KEY:
        raise HTTPException(403, 'Forbidden')


def file_type(data):
    if data.startswith(b'%PDF-'):
        import pypdfium2 as pdfium
        try:
            pdf = pdfium.PdfDocument(data)
            if len(pdf) != 1:
                raise HTTPException(422, 'Exactly one PDF page is required')
            page = pdf[0]
            width, height = page.get_size()
            if width * height * (300 / 72) ** 2 > MAX_PIXELS:
                raise HTTPException(422, 'Page render exceeds pixel limit')
            return '.pdf'
        except HTTPException:
            raise
        except Exception:
            raise HTTPException(422, 'Unreadable PDF') from None
    try:
        with Image.open(__import__('io').BytesIO(data)) as image:
            if image.format not in ('JPEG', 'PNG'):
                raise ValueError()
            if image.width * image.height > MAX_PIXELS:
                raise HTTPException(422, 'Image exceeds pixel limit')
            return '.jpg' if image.format == 'JPEG' else '.png'
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(422, 'Expected PDF, JPEG or PNG') from None


def page_worker(data, suffix):
    from paddleocr import PaddleOCRVL
    backend = os.environ.get('LAB_VL_BACKEND', 'llama-cpp-server')
    url = os.environ.get('LAB_VL_SERVER_URL', '')
    parsed = urlparse(url)
    if backend != 'llama-cpp-server' or parsed.scheme != 'http' or parsed.hostname not in ('vl-llama', 'host.docker.internal', '127.0.0.1', 'localhost'):
        raise RuntimeError('Local llama.cpp backend required')
    with tempfile.TemporaryDirectory(prefix='lab-vl-') as temp:
        source = Path(temp) / ('page' + suffix)
        source.write_bytes(data)
        output = Path(temp) / 'output'
        output.mkdir()
        pipeline = PaddleOCRVL(
            pipeline_version='v1.6', device='cpu', cpu_threads=2,
            layout_detection_model_dir=os.environ['LAB_VL_LAYOUT_DIR'],
            use_doc_orientation_classify=False,
            use_doc_unwarping=False,
            use_layout_detection=True,
            vl_rec_backend=backend,
            vl_rec_server_url=url,
            vl_rec_api_key=os.environ.get('LAB_VL_BACKEND_API_KEY') or None,
        )
        results = pipeline.predict(str(source))
        if len(results) != 1:
            raise RuntimeError('Unexpected VL page count')
        results[0].save_to_json(save_path=str(output))
        files = list(output.glob('*_res.json'))
        if len(files) != 1:
            raise RuntimeError('Missing VL result')
        return json.loads(files[0].read_text())


def supervised(data, suffix):
    with tempfile.TemporaryDirectory(prefix='lab-vl-supervisor-') as temp:
        result = Path(temp) / 'result.json'
        try:
            subprocess.run(
                [sys.executable, '/app/server.py', '--page-worker', suffix, str(result)],
                input=data, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                timeout=DEADLINE, check=True,
            )
        except subprocess.TimeoutExpired:
            raise HTTPException(504, 'VL page timed out') from None
        except subprocess.CalledProcessError:
            raise HTTPException(502, 'VL page failed') from None
        if not result.is_file() or result.stat().st_size > 5 * 1024 * 1024:
            raise HTTPException(502, 'VL result exceeds limit')
        return json.loads(result.read_text())


@app.get('/health')
def health():
    layout = Path(os.environ.get('LAB_VL_LAYOUT_DIR', ''))
    return {'ready': bool(API_KEY) and layout.is_dir() and
            (layout / 'inference.pdiparams').is_file() and
            bool(os.environ.get('LAB_VL_SERVER_URL')),
            'model': 'PaddleOCR-VL-1.6', 'backend': 'llama-cpp-server'}


@app.post('/v1/parse/page')
async def parse_page(request: Request, x_api_key: str | None = Header(default=None)):
    authorized(x_api_key)
    chunks = []
    size = 0
    async for chunk in request.stream():
        size += len(chunk)
        if size > MAX_BYTES:
            raise HTTPException(413, 'Page exceeds byte limit')
        chunks.append(chunk)
    if not size:
        raise HTTPException(413, 'Empty page')
    data = b''.join(chunks)
    suffix = file_type(data)
    if not LOCK.acquire(blocking=False):
        raise HTTPException(503, 'VL worker busy')
    try:
        return await run_in_threadpool(supervised, data, suffix)
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(502, 'VL page failed') from None
    finally:
        LOCK.release()


if __name__ == '__main__' and sys.argv[1:2] == ['--page-worker']:
    Path(sys.argv[3]).write_text(json.dumps(page_worker(sys.stdin.buffer.read(), sys.argv[2])))
