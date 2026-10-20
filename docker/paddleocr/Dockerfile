FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    OMP_NUM_THREADS=1 \
    OPENBLAS_NUM_THREADS=1 \
    MKL_NUM_THREADS=1 \
    PADDLEOCR_DET_DIR=/models/PP-OCRv5_mobile_det_infer \
    PADDLEOCR_REC_DIR=/models/PP-OCRv5_mobile_rec_infer

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates tesseract-ocr tesseract-ocr-eng \
    libgl1 libglib2.0-0 libgomp1 \
    && rm -rf /var/lib/apt/lists/*
COPY docker/paddleocr/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Official PP-OCRv5 mobile inference weights are bundled at build time.
# Runtime construction passes these paths explicitly and never downloads models.
RUN mkdir -p /models && \
    curl --fail --location --silent --show-error \
      https://paddle-model-ecology.bj.bcebos.com/paddlex/official_inference_model/paddle3.0.0/PP-OCRv5_mobile_det_infer.tar \
      | tar -x -C /models && \
    curl --fail --location --silent --show-error \
      https://paddle-model-ecology.bj.bcebos.com/paddlex/official_inference_model/paddle3.0.0/PP-OCRv5_mobile_rec_infer.tar \
      | tar -x -C /models && \
    test -d "$PADDLEOCR_DET_DIR" && test -d "$PADDLEOCR_REC_DIR"

COPY docker/paddleocr/server.py /app/server.py
WORKDIR /app
EXPOSE 5005
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "5005", "--workers", "1", "--no-access-log"]
