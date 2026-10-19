Unlimited OCR replacement
=========================

Role: native Docling -> page validation -> Unlimited single-page OCR -> shared
lab parser -> native/visual reconciliation -> publish or review. ColPali is not
part of ingestion. Surya is removed from runtime wiring and Compose; its old
Docker implementation remains as historical trial material only.

Service contract: POST /v1/convert/pdf, raw application/pdf, one unlocked page,
maximum 25 MiB / 40 megapixels at 300 DPI. Response includes engine=unlimited-ocr,
adapterVersion=1, text, parsedJson and diagnostics. The client rejects a different
service contract, preventing a leftover Surya instance from masquerading as the
replacement. Default port is 5004 (old Surya used 5003).

The pinned model revision is 8249d20b2822a7d8a4c22c8d8c9069b5ac36bda3.
The service uses Transformers infer(), base_size=1024, image_size=640,
crop_mode=True, 8192 generated tokens, one worker and one active request.
A busy service returns 503. Over-budget/incomplete output is held for review.
Generated coordinates are never evaluated. No report is sent to Hugging Face;
initial startup downloads public weights/code, then inference runs locally.
Request temp files are deleted after inference. Raw OCR stays in the document
artifact, not logs. Source regions are recorded when available; absent regions
are not invented. HTTP cancellation stops client waiting; model generation may
continue until its token bound and the service remains busy meanwhile.

NVIDIA deployment (recipe supplied; not validated on NVIDIA hardware here):
  docker compose -f docker-compose.yml -f docker-compose.unlimited.yml up -d --build unlimited
  Set UNLIMITED_OCR_BASE_URL=http://unlimited:5004 for API AND report-worker when
  using the processing overlay. API is configured by the Unlimited overlay;
  the worker uses UNLIMITED_OCR_BASE_URL from the environment/.env.
  Rebuild API production output and restart its workers after source deployment.
  The model requires NVIDIA drivers / NVIDIA Container Toolkit. Size VRAM and
  job deadlines from target-hardware measurements, not this Mac trial.

Apple Silicon development:
  Docker cannot expose Apple's Metal GPU. Run this service natively, using the
  already validated Mac-patched model directory and a Python environment with
  torch, transformers and requirements installed. The official model is CUDA
  specific; setting DEVICE=mps alone does not patch it.
  UNLIMITED_MODEL_PATH=/absolute/path/to/model_local UNLIMITED_DEVICE=mps \
    python -m uvicorn server:app --host 0.0.0.0 --port 5004 --workers 1 --no-access-log
  Run from docker/unlimited. Containers default to host.docker.internal:5004.
  Keep the service on a trusted internal network: it has no public authentication.
  On Linux without the GPU overlay, provide a reachable backend URL explicitly.

Configuration:
  UNLIMITED_OCR_ENABLED=true
  UNLIMITED_OCR_BASE_URL=http://127.0.0.1:5004 (host API)
  UNLIMITED_OCR_TIMEOUT_MS=610000
  Changing model/adapter semantics requires bumping unlimited-v1 checkpoint key.
  Disabling/unavailable OCR holds unresolved pages for review; it does not silently
  accept the native partial extraction.

Checks:
  python -m unittest discover -s docker/unlimited -p 'test_*.py'
  cd apps/api && npm run reports:test && npm run reports:processing-test

Known limitations:
  No cross-page table-header inference. Unmapped/continued tables require review.
  Exact reconciliation deliberately rejects some harmless name/method/range
  formatting differences as well as genuine conflicts. It is not clinical proof.
  Raw primary tuple recovery does not establish complete patient metadata,
  reference-range, interpretation, source-region or database-import accuracy.
  Existing Surya containers are not automatically stopped by a source change;
  remove those services during deployment after the replacement is healthy.
