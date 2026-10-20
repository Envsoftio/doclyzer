FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    OMP_NUM_THREADS=2 \
    OPENBLAS_NUM_THREADS=2 \
    MKL_NUM_THREADS=2 \
    PADDLE_PDX_MODEL_SOURCE=bos

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libgl1 libglib2.0-0 libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Keep the VL experiment separate from the PP-OCRv5 mobile service. The latter
# pins PaddleOCR 3.2.0 and cannot load the AI Studio 1.6 pipeline.
RUN pip install --no-cache-dir \
    'paddlepaddle==3.2.1' \
    'paddleocr[doc-parser]==3.6.0' \
    'fastapi==0.115.12' \
    'uvicorn==0.34.2'

COPY docker/paddleocr-vl/benchmark.py /app/benchmark.py
COPY docker/paddleocr-vl/server.py /app/server.py
WORKDIR /app
EXPOSE 5006
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "5006", "--workers", "1", "--no-access-log"]
