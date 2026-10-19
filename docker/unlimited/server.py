"""Single-page Unlimited service. Run one process: model access is serialized."""
import contextlib
import io
import os
import tempfile
import threading
from pathlib import Path

import pymupdf
import torch
from fastapi import FastAPI, HTTPException, Request
from starlette.concurrency import run_in_threadpool
from transformers import AutoModel, AutoTokenizer
from adapter import adapt, strip_markers

REVISION = '8249d20b2822a7d8a4c22c8d8c9069b5ac36bda3'
DEVICE = os.environ.get('UNLIMITED_DEVICE', 'cuda')
MODEL = os.environ.get('UNLIMITED_MODEL_PATH', 'baidu/Unlimited-OCR')
LIMIT = 25 * 1024 * 1024
lock = threading.Lock()
app = FastAPI()
model = tokenizer = None

@app.on_event('startup')
def load():
    global model, tokenizer
    kwargs = {} if Path(MODEL).is_dir() else {'revision': REVISION}
    tokenizer = AutoTokenizer.from_pretrained(MODEL, trust_remote_code=True, **kwargs)
    model = AutoModel.from_pretrained(MODEL, trust_remote_code=True, use_safetensors=True,
        torch_dtype=torch.float32 if DEVICE != 'cuda' else torch.bfloat16, **kwargs).eval().to(DEVICE)
    model.generation_config.max_new_tokens = 8192

@app.get('/health')
def health():
    return {'ready': model is not None, 'revision': REVISION, 'mode': 'single-page-gundam'}

def convert(data):
    if not lock.acquire(blocking=False):
        raise HTTPException(503, 'OCR worker busy')
    try:
        with pymupdf.open(stream=data, filetype='pdf') as doc, tempfile.TemporaryDirectory(prefix='unlimited-') as temp:
            if doc.needs_pass or len(doc) != 1:
                raise HTTPException(422, 'Exactly one unlocked PDF page is required')
            page = doc[0]
            if page.rect.width * page.rect.height * (300 / 72) ** 2 > 40_000_000:
                raise HTTPException(422, 'Page dimensions exceed rendering limit')
            image = str(Path(temp) / 'page.png')
            page.get_pixmap(matrix=pymupdf.Matrix(300 / 72, 300 / 72)).save(image)
            # eval_mode returns text without the upstream visualization/eval path.
            # Suppress model output: report contents must never enter service logs.
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()), torch.inference_mode():
                raw = model.infer(tokenizer, prompt='<image>document parsing.', image_file=image,
                    output_path=temp, base_size=1024, image_size=640, crop_mode=True,
                    max_length=8192, no_repeat_ngram_size=35, ngram_window=128,
                    eval_mode=True, save_results=False)
            if not isinstance(raw, str) or not raw.strip():
                raise HTTPException(502, 'Empty OCR output')
            text = strip_markers(raw)
            parsed = adapt(text)
            parsed['rawOcr'] = raw
            # A budget-length response is not evidence of a complete page.
            truncated = len(tokenizer.encode(raw, add_special_tokens=False)) >= 8190
            parsed['extractionIncomplete'] |= truncated
            return {'engine': 'unlimited-ocr', 'adapterVersion': 1, 'modelRevision': REVISION,
                    'text': text, 'parsedJson': parsed,
                    'diagnostics': {'warnings': ['incomplete_output'] if parsed['extractionIncomplete'] else []}}
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(422, 'Page conversion failed') from None
    finally:
        lock.release()

@app.post('/v1/convert/pdf')
async def pdf(request: Request):
    data = bytearray()
    async for chunk in request.stream():
        data.extend(chunk)
        if len(data) > LIMIT:
            raise HTTPException(413, 'PDF exceeds size limit')
    return await run_in_threadpool(convert, bytes(data))
