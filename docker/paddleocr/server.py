"""CPU-only, one-page evidence service. Never logs or publishes report content."""
import contextlib
import io
import json
import os
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

import fitz
from PIL import Image
from fastapi import FastAPI, Header, HTTPException, Request
from starlette.concurrency import run_in_threadpool

MAX_BYTES = 10 * 1024 * 1024
MAX_PIXELS = 25_000_000
DPI = int(os.environ.get('LAB_OCR_DPI', '300'))
API_KEY = os.environ.get('LAB_OCR_API_KEY', '')
LOCK = threading.Lock()
app = FastAPI()
_ocr = None


def authorized(key):
    if not API_KEY:
        raise HTTPException(503, 'Service key not configured')
    if key != API_KEY:
        raise HTTPException(403, 'Forbidden')


def get_ocr():
    global _ocr
    if _ocr is None:
        det = Path(os.environ['PADDLEOCR_DET_DIR'])
        rec = Path(os.environ['PADDLEOCR_REC_DIR'])
        if not det.is_dir() or not rec.is_dir():
            raise RuntimeError('Local OCR models missing')
        from paddleocr import PaddleOCR
        _ocr = PaddleOCR(
            text_detection_model_name='PP-OCRv5_mobile_det',
            text_detection_model_dir=str(det),
            text_recognition_model_name='PP-OCRv5_mobile_rec',
            text_recognition_model_dir=str(rec),
            use_doc_orientation_classify=False,
            use_doc_unwarping=False,
            use_textline_orientation=False,
            text_recognition_batch_size=1,
            device='cpu',
        )
    return _ocr


def native_words(path, height):
    """docling-parse 7.22.3 public v7 word-cell API, without table models."""
    from docling_core.types.doc.page import TextCellUnit
    from docling_parse.pdf_parser import ContentConfig, ContentLevel, DecodeConfig, DoclingPdfParser
    parser = DoclingPdfParser(loglevel='fatal')
    doc = parser.load(
        path_or_stream=str(path),
        decode_config=DecodeConfig(do_sanitization=True, keep_glyphs=False),
        content_config=ContentConfig(
            char_cells_content_level=ContentLevel.COMPUTE,
            word_cells_content_level=ContentLevel.COMPUTE_AND_MATERIALIZE,
            line_cells_content_level=ContentLevel.SKIP,
            shapes_content_level=ContentLevel.SKIP,
            bitmaps_content_level=ContentLevel.SKIP,
        ),
    )
    page = doc.get_page(1)
    output = []
    for word in page.iterate_cells(unit_type=TextCellUnit.WORD):
        box = word.rect.to_bounding_box().to_top_left_origin(height)
        output.append({'text': word.text, 'bbox': [box.l, box.t, box.r, box.b], 'coord_origin': 'TOPLEFT'})
    return output


def read_one_page(data):
    with fitz.open(stream=data, filetype='pdf') as doc:
        if doc.needs_pass or len(doc) != 1:
            raise HTTPException(422, 'Exactly one unlocked PDF page is required')
        page = doc[0]
        width, height = page.rect.width, page.rect.height
        if width * height * (DPI / 72) ** 2 > MAX_PIXELS:
            raise HTTPException(422, 'Page render exceeds pixel limit')
        with tempfile.TemporaryDirectory(prefix='lab-ocr-') as temp:
            pdf_path = Path(temp) / 'page.pdf'
            image_path = Path(temp) / 'page.png'
            pdf_path.write_bytes(data)
            try:
                native = native_words(pdf_path, height)
                native_error = False
            except Exception:
                native = []
                native_error = True
            page.get_pixmap(matrix=fitz.Matrix(DPI / 72, DPI / 72), alpha=False).save(image_path)
            # .json is already JSON-serializable in PaddleOCR 3.2.0.
            results = get_ocr().predict(str(image_path), text_rec_score_thresh=0.0)
            if len(results) != 1:
                raise HTTPException(502, 'Unexpected OCR page count')
            payload = results[0].json.get('res', results[0].json)
            texts = payload.get('rec_texts', [])
            scores = payload.get('rec_scores', [])
            polygons = payload.get('rec_polys', [])
            if not (len(texts) == len(scores) == len(polygons)):
                raise HTTPException(502, 'OCR arrays are not aligned')
            return {'page_width': width, 'page_height': height, 'dpi': DPI,
                    'native_error': native_error,
                    'native_words': native, 'paddle': {'rec_texts': texts,
                    'rec_scores': scores, 'rec_polys': polygons},
                    'model_version': 'PP-OCRv5_mobile_det+PP-OCRv5_mobile_rec',
                    'paddleocr_version': '3.2.0', 'docling_parse_version': '7.22.3'}


def read_one_image(data):
    with Image.open(io.BytesIO(data)) as image:
        if image.format not in ('JPEG', 'PNG') or image.width * image.height > MAX_PIXELS:
            raise HTTPException(422, 'Expected JPEG or PNG within pixel limit')
        width, height = image.size
        with tempfile.TemporaryDirectory(prefix='lab-image-') as temp:
            image_path = Path(temp) / ('image.jpg' if image.format == 'JPEG' else 'image.png')
            image_path.write_bytes(data)
            results = get_ocr().predict(str(image_path), text_rec_score_thresh=0.0)
            if len(results) != 1:
                raise HTTPException(502, 'Unexpected OCR image count')
            payload = results[0].json.get('res', results[0].json)
            texts = payload.get('rec_texts', [])
            scores = payload.get('rec_scores', [])
            polygons = payload.get('rec_polys', [])
            if not (len(texts) == len(scores) == len(polygons)):
                raise HTTPException(502, 'OCR arrays are not aligned')
            return {'page_width': width, 'page_height': height, 'dpi': 72,
                    'native_error': False, 'native_words': [],
                    'paddle': {'rec_texts': texts, 'rec_scores': scores, 'rec_polys': polygons},
                    'model_version': 'PP-OCRv5_mobile_det+PP-OCRv5_mobile_rec',
                    'paddleocr_version': '3.2.0', 'docling_parse_version': '7.22.3'}


@app.get('/health')
def health():
    return {'ready': bool(API_KEY) and Path(os.environ.get('PADDLEOCR_DET_DIR', '')).is_dir() and
            Path(os.environ.get('PADDLEOCR_REC_DIR', '')).is_dir(),
            'model': 'PP-OCRv5_mobile_det+PP-OCRv5_mobile_rec'}


@app.post('/v1/extract/page')
async def extract_page(request: Request, x_api_key: str | None = Header(default=None)):
    authorized(x_api_key)
    data = await request.body()
    if not data or len(data) > MAX_BYTES:
        raise HTTPException(413, 'Page exceeds limit')
    content_type = request.headers.get('content-type', '').split(';')[0].lower()
    if content_type not in ('application/pdf', 'image/jpeg', 'image/png'):
        raise HTTPException(415, 'Expected PDF, JPEG or PNG')
    if content_type == 'application/pdf':
        with fitz.open(stream=data, filetype='pdf') as doc:
            if doc.needs_pass or len(doc) != 1:
                raise HTTPException(422, 'Exactly one unlocked PDF page is required')
            page = doc[0]
            if page.rect.width * page.rect.height * (DPI / 72) ** 2 > MAX_PIXELS:
                raise HTTPException(422, 'Page render exceeds pixel limit')
    else:
        with Image.open(io.BytesIO(data)) as image:
            if image.format != ('JPEG' if content_type == 'image/jpeg' else 'PNG') or image.width * image.height > MAX_PIXELS:
                raise HTTPException(422, 'Invalid image or pixel limit exceeded')
    if not LOCK.acquire(blocking=False):
        raise HTTPException(503, 'OCR worker busy')
    try:
        return await run_in_threadpool(run_supervised, data, content_type)
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(502, 'Page extraction failed') from None
    finally:
        LOCK.release()


def run_supervised(data, content_type='application/pdf'):
    """A timed-out native call cannot outlive its supervised child process."""
    with tempfile.TemporaryDirectory(prefix='lab-page-') as temp:
        result_path = Path(temp) / 'result.json'
        try:
            subprocess.run([sys.executable, '/app/server.py', '--page-worker', content_type, str(result_path)],
                           input=data, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                           timeout=int(os.environ.get('LAB_OCR_PAGE_TIMEOUT_SEC', '30')), check=True)
        except subprocess.TimeoutExpired:
            raise HTTPException(504, 'Page extraction timed out') from None
        except subprocess.CalledProcessError:
            raise HTTPException(502, 'Page extraction failed') from None
        return json.loads(result_path.read_text())


@app.post('/v1/verify/field')
async def verify_field(request: Request, x_api_key: str | None = Header(default=None)):
    authorized(x_api_key)
    data = await request.body()
    if not data or len(data) > MAX_BYTES:
        raise HTTPException(413, 'Page exceeds limit')
    try:
        rect = [float(x) for x in request.query_params['rect'].split(',')]
        if len(rect) != 4 or rect[2] <= rect[0] or rect[3] <= rect[1]:
            raise ValueError()
    except (KeyError, ValueError):
        raise HTTPException(422, 'Invalid crop rectangle') from None
    with fitz.open(stream=data, filetype='pdf') as doc:
        if doc.needs_pass or len(doc) != 1:
            raise HTTPException(422, 'Exactly one unlocked PDF page is required')
        page = doc[0]
        crop = fitz.Rect(*rect) & page.rect
        if crop.is_empty or crop.width * crop.height * (DPI / 72) ** 2 > 2_000_000:
            raise HTTPException(422, 'Invalid crop size')
        pix = page.get_pixmap(matrix=fitz.Matrix(DPI / 72, DPI / 72), clip=crop, alpha=False)
        try:
            run = await run_in_threadpool(lambda: subprocess.run(
                ['tesseract', 'stdin', 'stdout', '-l', 'eng', '--psm', '7', 'tsv'],
                input=pix.tobytes('png'), stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                timeout=5, check=True))
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
            raise HTTPException(504, 'Verification failed or timed out') from None
        return {'tsv': run.stdout.decode('utf-8', 'replace'),
                'crop_to_original': [72 / DPI, 0, 0, 72 / DPI, crop.x0, crop.y0],
                'engine': 'tesseract', 'crop_rect': list(crop)}


if __name__ == '__main__' and sys.argv[1:2] == ['--page-worker']:
    with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
        data = sys.stdin.buffer.read()
        result = read_one_page(data) if sys.argv[2] == 'application/pdf' else read_one_image(data)
    Path(sys.argv[3]).write_text(json.dumps(result))
