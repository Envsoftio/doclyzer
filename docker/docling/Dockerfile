FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    curl \
    tesseract-ocr \
    tesseract-ocr-eng \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip && \
    pip install "docling-serve==1.37.0" "docling-slim==2.140.0" "docling-core==2.102.0" "docling-parse==7.22.3" "docling-ibm-models==4.0.3" "docling-jobkit==3.8.2" "onnxruntime==1.31.0"

COPY docker/docling/tesseract-table.py /usr/local/bin/tesseract-table
RUN chmod +x /usr/local/bin/tesseract-table

EXPOSE 5002
