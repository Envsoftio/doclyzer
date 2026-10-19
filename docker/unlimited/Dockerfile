FROM python:3.12-slim
ENV PYTHONUNBUFFERED=1 HF_HOME=/cache/huggingface
WORKDIR /app
COPY docker/unlimited/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY docker/unlimited/adapter.py docker/unlimited/server.py ./
EXPOSE 5004
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "5004", "--workers", "1", "--no-access-log"]
