# Report processing operations and release verification

Updated 2026-10-19. Owner roles below require named deployment owners before release.
Defaults are provisional. No production rollout, real push or backup restore was
performed during implementation.

## Deployment and rollback

1. Back up PostgreSQL and verify object-store recovery access. Assign database,
   backend/on-call and mobile release owners; record actual RPO/RTO and workload.
2. Apply the four additive processing migrations with acceptance/runtime off.
   Historical reports have generation zero. Claims constrain new async identities,
   not historical duplicate rows. Do not use TypeORM synchronize for these tables.
3. Deploy compatible web/mobile clients and new API code to every replica. Configure
   durable B2 storage, PostgreSQL, pinned Docling and existing email delivery. Give
   worker and dispatcher only required network/storage/provider access; restrict
   operator routes through existing superadmin authorization. Count one extra
   PostgreSQL LISTEN connection per API replica when sizing the pool.
4. Build `apps/api` once, then start independently with `npm run start:report-worker:prod` and
   `npm run start:report-dispatcher:prod` after API build. Set
   `REPORT_ASYNC_RUNTIME_ENABLED=true` and the appropriate process role. The
   opt-in `docker-compose.processing.yml` runs compiled API/worker/dispatcher
   entry points because `ts-node` exceeded the local dispatcher memory limit.
   It is a local deployment template, not a hardened production image. Validate
   it with Compose `config --quiet`.
5. Set API runtime true, admission false. `/v1/health/report-processing` must show
   both roles healthy; stale heartbeats older than 30 seconds fail readiness.
   Verify B2 GET/PUT/delete with a synthetic canary, provider auth and queue drain.
   Configure the SSE location from `docker/nginx/report-sse.conf` for the real
   upstream. Runtime requires PostgreSQL/durable storage/migrations at startup.
6. After the checks below, enable `REPORT_ASYNC_ACCEPTANCE_ENABLED=true` for a
   controlled canary. Enable `REPORT_COMPLETION_PUSH_ENABLED=true` only after
   FCM/APNs/device verification. Missing FCM configuration fails dispatcher startup
   when push is enabled. Never use mock success as readiness evidence.
7. Rollback trigger: any ownership/fencing/data-loss violation, unexplained ready
   results, or sustained missed SLO. Disable acceptance first. Keep runtime,
   migrations and worker/dispatcher running to drain accepted jobs and support
   async clients. Never automatically resume sync parsing for queued reports.
   Do not revert processing migrations or old binaries over accepted jobs.

The v1 upload/retry API is deliberately blocked while runtime is on. Communicate
minimum mobile support before rollout; admission-off is a maintenance/drain state,
not an invitation to route new uploads through the old synchronous path.

## Configuration and retention

`processing-settings.ts` validates integer limits. Relevant defaults:

| Setting | Default |
| --- | --- |
| REPORT_MAX_ATTEMPTS / REPORT_DEADLINE_MS | 3 / 1800000 |
| REPORT_LEASE_MS / REPORT_WORKER_CONCURRENCY | 60000 / 1 |
| REPORT_PROVIDER_REQUEST_MS | 30000 |
| REPORT_MAX_PAGES / REPORT_MAX_IMAGE_PIXELS | 100 / 25000000 |
| REPORT_UPLOAD_DEADLINE_MS | 120000 |
| REPORT_EVENT_RETENTION_MS | 604800000 (7 days) |
| REPORT_NOTIFICATION_EXPIRY_MS | 604800000 (7 days) |
| REPORT_IDEMPOTENCY_RETENTION_MS | 604800000 (replay expiry, not tombstone deletion) |
| REPORT_ORPHAN_RETRY_MS | 3600000 |
| DOCLING_INSTANCE_ID | docling-1.37.0; change when provider identity changes |

Event retention only deletes a contiguous dispatched prefix and advances reset
watermarks in the same transaction. Undispatched events survive the nominal
window. Terminal staged OCR results clear after one day. Source files follow
existing recycle-bin/hard-deletion lifecycle; worker sweeps unreferenced intent
objects. Inbox and execution diagnostics survive with their parent and cascade
on deletion as defined by migrations. Idempotency and orphan tombstones are kept
until account deletion; size them and approve a separate pruning policy before
long-term scale. No cleanup deletes a live job lease. Backup retention also needs
to comply with the product's deletion policy.

## Monitoring and incident response

`GET /v1/admin/report-processing` provides job/delivery counts and oldest times,
process heartbeats, expired leases and orphan counts. Use execution timestamps
for conversion duration and attempts. Current instrumentation is a foundation,
not a complete latency/SSE/OOM dashboard. Do not log source files, lab results,
provider bodies, tokens, credentials or signed storage URLs.

Candidate alerts (must be validated with staging traffic): backend on-call owns
oldest due job >2 minutes, missing process heartbeat >30 seconds, expired leases
>2 lease periods, overdue jobs, delivery backlog >5 minutes and any exhausted
notification; storage owner owns orphan growth across two sweep/retry windows.
Infrastructure failures should be grouped separately from INVALID_CONTENT.
Wire these alerts to the deployment's monitoring system before canary expansion.

| Incident | Procedure |
| --- | --- |
| Queued/stuck work | Check process heartbeat, due time, lease, absolute deadline and attempt audit. Restore DB/storage/provider access; claims reconcile stale work. Never edit report status or lease tokens manually. |
| Worker crash | Restart same code. Wait lease expiry; verify new execution token and old token rejection. Alert if not claimed within two lease periods plus queue delay. |
| Docling restart | Restore same endpoint/identity where applicable. Known tasks reconcile; confirmed missing tasks resubmit within budget. Change instance ID for replacement identity. Do not issue manual duplicate POSTs. |
| Result expired | Check staged result first. Missing unstaged result permits bounded retry; exhausted work is visibly failed. Keep source for user/operator retry. |
| Bad/oversized/partial content | Inspect safe outcome, ask for supported source or review. Do not increase concurrency/timeouts as a substitute for memory/page limits. |
| Optional summary failure | Use report summary-retry; extraction remains ready. Do not retry whole processing. |
| Push/email outage | Inspect delivery intent/error and existing channel audit. Restore provider; backoff and expiry operate independently of report state. A timed-out send is ambiguous; stable collapse IDs reduce but cannot eliminate duplicates. |
| SSE signal outage/replay backlog | Query durable events/watermark; restore LISTEN connectivity. Server scans continue. Clients reset to authorized snapshot on gaps/expiry. Check proxy buffering, 10-second heartbeats and account connection caps. |
| Operator retry/cancel | POST `/v1/admin/report-processing/:id/retry` or `/cancel` with `{ "reason": "incident reference and reason" }` as superadmin. Audit records requested/succeeded/failed. Retry uses normal quota/generation protections and refuses reviewed success. |
| Backup restore | Stop admission and all writers. Restore PostgreSQL plus matching source objects; fence/terminate every pre-restore worker before restart. Provider tasks may be absent or ahead of restored DB. Restart runtime and let durable claims reconcile; verify event cursors/clients reset, source coverage, duplicate ledger safeguards and external delivery ambiguity before admission. Never claim restored DB can undo a push already displayed. |

## Required recorded release exercises

Use synthetic medical-format documents, never real patient data in test logs.
For each exercise record build SHA, environment/config, fixture checksum, timestamps,
observations and named owner. Preserve results as release artifacts.

- **Large conversion:** text and scanned PDFs at supported size/page limits, including
  one actual Docling conversion taking >120 seconds. Submit through the HTTP API,
  leave/close client, restart worker while tracking, then verify readable results,
  a single authoritative generation and no synchronous conversion request. Run
  under contention at one worker slot before adjusting concurrency. Record p50/p95
  acceptance, queue/conversion time, memory and OOMs.
- **Provider contract:** restart pinned Docling during a live task; test missing task,
  response loss, WebSocket disconnect, API-key mode, result download failure and
  actual retention expiry. Immediate repeat-fetch passed locally; retention expiry
  and long-running restart still require evidence.
- **Multi-instance/proxy:** connect through the actual load balancer to two API
  replicas. Confirm immediate frame flush, heartbeat visibility, signal disconnect
  recovery, replica drain, snapshot/subscription race, session revoke and slow
  reader limits. Attempt six streams and confirm the seventh is rejected. Measure
  DB connections and query cost under expected concurrent streams.
- **Clients:** cold start/resume/offline, token refresh, account/profile switch,
  logout while streaming, accept then leave upload, duplicate file and lost 202
  response. Confirm versions never regress and caches do not cross accounts.
- **Real push:** Android and iOS with production-like credentials in foreground,
  background and terminated states; denied permission, offline delivery, rotation,
  logout/reassignment, multiple devices, stale deleted report and superseded
  generation. Tap must authorize/fetch the right report. Correlate provider accepted,
  device-observed display, opened audit and acknowledgement separately.
- **Recovery:** DB disconnect during completion, source outage, process SIGKILL,
  dispatcher crash after provider acceptance, sustained overload and backup restore.
  Check no accepted work remains silently stuck; document external ambiguity.

Candidate targets to measure (not current guarantees): worker takeover within
90 seconds at the default lease under available capacity; foreground event lag
p95 <=3 seconds; upload acceptance p95 <=5 seconds excluding transfer; completion
within the configured 30-minute deadline for each supported document class.
Expected documents/day, peak uploads, concurrent SSE sessions, sustained capacity,
RPO/RTO and production thresholds remain unprovided. Release cannot be signed off
until owners supply and validate them. Local integration results are recorded in
[the implementation contract](report-processing-contract.md).

The local emulator run on 2026-10-19 completed a 19-page, 6.9 MB PDF in 160
seconds with the app backgrounded. It met the >120-second functional exercise;
content review flagged 18 missing candidate rows. Staging contention, production
proxy and device push checks remain open.
