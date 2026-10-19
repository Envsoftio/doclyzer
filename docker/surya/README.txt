Surya OCR integration
====================

Routing
- Background jobs durably checkpoint native Docling conversion first (OCR off).
  Complete native pages retain embedded text. Unresolved pages are copied into
  one-page PDFs and tried with Surya, RapidOCR, then Tesseract via Docling.
- OCR pages keep one complete reading only when every row is corroborated by
  another engine on test names, raw values, units, reference ranges and dates.
  Different engines may corroborate different rows; cells are never mixed.
  Tesseract breaks ties;
  disagreement or missing rows blocks publication, without user correction.
- Retry scope is a full page, preserving table headers/context. Cell crops and
  mixed-cell reconstruction are not implemented. Completed engine/page outputs and native conversion are durably staged and
  reused after worker restarts. Job attempts
  and deadlines bound the work. Agreement is not proof of digit-level accuracy.
- Logs REPORT_OCR_PAGE_STARTED / ATTEMPT / ACCEPTED and CASCADE_COMPLETE contain
  page numbers, engine names and counts, not medical text.
- The synchronous path also uses the cascade when native extraction fails.
- Docling needs the fixed `tesseract-table` preset from docker-compose.yml
  (Tesseract CLI, English, page segmentation mode 6, and a bounded wrapper
  that removes long straight table rules from a temporary raster). Requests never switch
  payload schemas after an engine error. Other deployments must register this
  preset before enabling the cascade.
- The CPU model uses one inference slot and four threads by default; set
  SURYA_MODEL_THREADS on the model service to tune for available CPU capacity.
- Surya is enabled by default. Set SURYA_OCR_ENABLED=false to roll back.
- Surya 0.22.1 uses a separate, local llama.cpp model server. The model revision
  and llama.cpp revision are pinned in start_model.py and Dockerfile.

Docker
  docker compose up -d --build surya surya-model
  docker compose up -d api

The first model start downloads roughly 1.4 GB of weights into surya_cache.
The supplied image runs inference on CPU; Apple Silicon users get faster
inference by running llama-server natively with Metal. The application HTTP
endpoint is bound to localhost; the model endpoint has no published port.
Only expose either service on a trusted internal network.

The worker processes one report at a time, rejects busy requests with 503,
limits input to 25 MB / 50 pages, and terminates jobs after 600 seconds.
The API timeout is 610 seconds; proxy/request timeouts must accommodate this.
A busy or unavailable worker falls back to Docling. /health is process liveness,
not a guarantee that weights have downloaded or the model is ready.
Temporary PDFs and OCR output are deleted after each request. Report content
is not written to this service's logs. Run uvicorn with one worker.

Native development (Python 3.12)
  python3.12 -m venv .venv
  .venv/bin/pip install -r docker/surya/requirements.txt
  brew install llama.cpp
  .venv/bin/python docker/surya/start_model.py

In another terminal, from docker/surya, with the venv bin directory on PATH:
  SURYA_INFERENCE_BACKEND=llamacpp \
  SURYA_INFERENCE_URL=http://127.0.0.1:8080/v1 \
  SURYA_INFERENCE_PARALLEL=2 \
  uvicorn server:app --host 127.0.0.1 --port 5003 --workers 1 --no-access-log

Tests
  python -m unittest discover -s docker/surya -p 'test_*.py'
  cd apps/api && npm run reports:test

Accuracy boundaries
The adapter maps semantic headers (Test/Investigation/Analyte/Component,
Result/Observed Value, Unit/UOM and reference-range variants) in varying orders.
Unit, flag and range columns are optional; title rows and repeated headers are
supported. It recovers same-page detached tables and explicitly labelled result
paragraphs. Qualitative observations, microscopy intervals, titers and graded
positives remain non-scalar values, without inferred abnormality.
Unknown populated results and ambiguous historical columns trigger fallback;
no laboratory names or analyte-specific expected values are encoded.
Interpretation sections and merged result cells are not patient observations.
A High/Low token misplaced in an empty flag/unit pair is corrected with a warning.

This is broader layout support, not universal report support. Multi-level merged
headers, locale-specific numeric notation, unknown languages/headers and complex
microbiology/narrative results can still exhaust automatic fallback. Unresolved extraction is withheld rather
than requiring user correction.
Validate unseen laboratories and report categories before accuracy claims.

The original 11-page digital report benchmark is private and is not committed.
Saved Surya output produces 53 observations: 51 exact name/value/unit matches;
two names differ in punctuation/spelling. Dates, reference ranges and narrative
text are not comprehensively scored. This sample does not establish accuracy
on blurry scans or photographs. Do not describe its score as overall accuracy.

Licensing
Surya code is Apache-2.0. Model weights have separate modified AI Pubs Open
RAIL-M terms; the publisher states free use for research/personal use and
startups below its $5M funding/revenue threshold. Check the applicable model
terms before commercial rollout: https://github.com/datalab-to/surya#commercial-usage
