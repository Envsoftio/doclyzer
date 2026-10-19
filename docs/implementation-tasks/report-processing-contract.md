# Durable report processing: implementation contract

Updated 2026-10-19. Code now spans all six phases. Admission is off by default.
Release is blocked on the deployment/device/capacity checks in the
[operations runbook](report-processing-operations.md). Local tests do not prove
production readiness.

## Compatibility and API

The new upload is `POST /v1/reports/processing/uploads`, multipart `file` and
optional `profileId`, with an account-scoped `Idempotency-Key`. It returns 202
only after durable storage and the report/job/event transaction commit. The body
includes `contractVersion: 2`, report ID, version/state, reuse information and
status URL. `/capabilities` advertises acceptance and events independently.
Snapshot, status, inbox, retry, cancel, acknowledgement and summary-retry routes
live under the same authenticated prefix. SSE is `GET /events`.

With runtime disabled, legacy behavior remains. With runtime enabled, legacy
upload/retry explicitly require an upgraded client; they never return queued
results to a synchronous client. Do not enable runtime on only some API replicas.
New clients use capabilities. During admission-off draining they may attempt the
legacy upload, which explicitly fails rather than bypassing durable admission.
Async keep-file and reassignment are rejected: moving an active content identity
between profiles needs a separately designed transaction. Restore locks quota
and the report; a restored incomplete report requires explicit retry.

| Processing state | Legacy status | Meaning |
| --- | --- | --- |
| queued | queued | Durable acceptance |
| processing | parsing | Current generation executing |
| retry_scheduled | failed_transient | Bounded retry scheduled |
| ready | parsed | Core extraction committed |
| needs_attention | content_not_recognized | Content needs review |
| failed | failed_terminal | Permanent error or exhausted recovery |
| cancelled | unparsed | Work cancelled; deletion is separate |

Manual retry creates a new generation; version remains monotonic. Reviewed/parsed
results cannot be overwritten by retry. Core results gate readiness. Optional
summary has its own status, delivery intent and retry route; summary failure never
reruns parsing. Summary refresh is explicit in mobile detail. Acknowledgement is
separate from viewing; it persists on the report and marks inbox read.

## Admission, identity and storage

Source hash version 1 is SHA-256 of original bytes, before image normalization.
Active claims are unique by account/profile/hash version/hash. Historical hashes
are not backfilled. Active, ready and needs-attention duplicates reuse the report;
failed/cancelled/deleted reports permit a new upload with a new key. No active
“upload anyway” option exists. Idempotency binds account, operation, profile,
original-byte hash and MIME type. A lost-response replay does not need storage.
Mismatches conflict; expired keys return Gone rather than becoming new requests.
Request tombstones survive report purge and cascade on account deletion.

Admission locks account and entitlement while reserving quota. Pending and parsed
reports count; terminal failure/cancellation release pending quota. Existing
uploads do not debit credit balances; no new credit charge/refund was introduced.
Referral completion uses the existing idempotent milestone service.

A storage intent commits before PUT; no DB lock spans PUT. Only a non-expired
pending intent can become referenced. The worker schedules bounded orphan sweeps.
They fence abandoned intents before deletion, never remove referenced objects,
and retain tombstones to retry deletion of late PUTs. Accepted intents whose report
was hard-deleted also become eligible. A DB outage never triggers eager deletion.
B2 is durable; in-memory storage and pg-mem cannot enable runtime. Source retention
follows report/recycle-bin lifecycle; no automatic tombstone pruning is enabled.

## Worker and provider

Independent Nest worker/dispatcher entry points share PostgreSQL, not process
memory. SKIP LOCKED claims commit a token and execution audit before OCR. Heartbeats
renew leases; final writes verify lease, deadline, generation, deletion and review
protection. Results, version, outcome and event commit together. Cancellation
fences workers; unsupported provider cancellation means late output is discarded.
SIGTERM stops claims and aborts tracking; an interrupted lease is recovered after
expiry. Forced process death is covered by the real subprocess integration test.

Docling 1.37.0 receives one verified multipart async POST per submission attempt.
Task ID is persisted before tracking. WebSocket is a hint, with bounded HTTP status
reconciliation. API-key deployments use `X-Api-Key` HTTP requests because the pinned
WebSocket accepts its key only in a URL query. Secrets never enter task URLs.
There is no timeout/5xx format or hostname fallback. Submission uncertainty is
recorded before POST; resubmission is bounded, but duplicate external computation
remains possible. Two missing-task observations permit bounded resubmission;
provider unavailability alone does not clear the task. Validated results are
staged durably and reused after takeover. Partial results are rejected explicitly.
The enabled async path never invokes the synchronous conversion client.

Defaults: 10 MiB upload, 100 pages, 25 million decoded image pixels, one worker
slot (configured maximum four), three attempts, 30-minute absolute deadline,
60-second lease with heartbeat every third of the lease, 30-second provider HTTP
request timeout, 15-second WebSocket tracking window. These are conservative
starting limits, not measured capacity guarantees. Memory is bounded additionally
by container limits. Rate-limit Retry-After guidance is honored within the total
job deadline. Chunking is deferred until profiling demonstrates a need.

## Events, clients and notifications

Events contain identifiers, generation/version and state, never file names or lab
contents. A per-account counter row serializes allocation until commit; an
uncommitted lower cursor cannot be skipped by a committed higher cursor.
Snapshots read reports and cursor in one REPEATABLE READ transaction. Replay checks
retention watermark and reads its page in a consistent transaction. Retention
advances the watermark and deletes a contiguous delivered prefix atomically.

Each API has a dedicated LISTEN connection in addition to its query pool.
NOTIFY is only a hint; two-second server scans recover lost wakeups. Replay pages
are 100 events; catch-up is capped at 10,000 per connection. Slow consumers close,
heartbeats occur every 10 seconds, sessions/restrictions are checked every pump,
and connections renew at five minutes. Normal revocation latency is at most the
two-second scan plus DB query time. Six concurrent streams per account are enforced
in PostgreSQL. Clients use bearer headers, a single app-level stream, monotonic
versions, jittered reconnect and fresh snapshots after every restart/reconnect.
They clear state on account changes. No routine client status polling was added.
Shared-link pages do not open an owner's stream. Proxy configuration is a template;
actual load-balancer flush/drain behavior remains a release test.

Terminal events materialize unique inbox items per report/generation and unique
channel/device intents. Dispatcher leases retry independently of parsing, using
existing email preferences, device tokens, product push preferences and referral
services. Push requires explicit enablement and real FCM configuration; mock
acceptance is not production delivery. Visible messages contain generic wording
and identifiers, with stable Android tag/APNs collapse ID and expiry. Token
ownership/preferences are checked at send time; UNREGISTERED disables the matching
token. Retries honor provider guidance, stop after eight attempts or seven days,
and retain exhausted records. Ambiguous sends may still display duplicates.
Explicit new generations can notify again; stream reconnect cannot notify again.

Mobile foreground/background/cold-start callbacks validate report IDs and fetch
an authorized report before navigation. Provider acceptance, failed sends, opened
and inbox read are distinct records; none proves OS display. Dashboard readiness
survives missed push. Real-device behavior still needs the runbook verification.

## Test evidence (2026-10-19)

Run from `apps/api` after `npm run build`:

- `npm run reports:processing-test`: contract and hashing.
- `npm run reports:processing-postgres-test`: schema up/down/up, claim constraints,
  concurrent commit/rollback and event commit ordering.
- `npm run reports:admission-postgres-test`: duplicate/quota/idempotency races,
  authorization, rollback, storage failure/late PUT, lease fencing, review/deletion,
  retry budgets and deadline recovery.
- `npm run reports:runtime-postgres-test`: full historical migration chain and last
  migration reversal/reapplication in a disposable database; provider checkpoint,
  staging, partial rejection and no POST fallback; snapshot/replay authorization,
  retention reset, unique dispatch, token reassignment, manual retry/cancel,
  SSE session revocation; actual Nest worker SIGKILL/restart/task reuse and SIGTERM.
- `DOCLING_TEST_URL=http://127.0.0.1:5002 npm run reports:docling-async-test`:
  local pinned provider, synthetic text PDF, async status/result and repeat fetch.
  Observed conversion was about three seconds.
- Existing parser/Surya fixture, correction and history suites passed.

PostgreSQL scripts require `REPORT_PROCESSING_TEST_DATABASE_URL` and create/drop
isolated schemas or a disposable database; runtime test needs CREATEDB. They do
not migrate the application database. Fake storage/provider/push fixtures are
explicit test doubles, not production fallback paths.

Web production build and two fragmented-stream parser tests passed. Flutter's
24 tests passed, including stream fragmentation/version/logout and existing
report layout/history/correction tests. Compose configuration validates.
Flutter analysis has only the pre-existing unused catch-stack warning in
`signup_screen.dart:76`; it exits nonzero for that warning. These checks do not cover real push display, production proxy, multi-instance load,
representative load, live provider restart/retention expiry,
backup restore, production storage or measured RPO/RTO. See the runbook gates.

## Local emulator and Docker verification (2026-10-19)

The Android emulator submitted `sterling-accuris-pathology-sample-report-unlocked.pdf`
(6,908,257 bytes, 19 pages) through the v2 API. The initial attempt exposed a
live-schema drift: an earlier applied runtime migration lacked
`provider_submission_count`; the worker exhausted three attempts with safe
`PROVIDER_UNAVAILABLE`. The forward repair migration adds that column and runtime
startup now checks it. The opt-in Compose services also initially exhausted the
768 MiB dispatcher limit while using `ts-node`; compiled entry points resolved it.

The emulator's normal Retry action created generation 2. The worker submitted
one async Docling task, persisted its task ID, and finished in **160 seconds**
while the app was backgrounded. It committed ready/parsed with one execution,
one provider submission, 49 extracted rows, four generation-2 events and one
inbox item. The reopened app showed the ready-for-review banner and readable
results. Its extraction review warned that 18 candidate rows were not extracted;
the result therefore still needs user review. Observed Docling memory was about
2.3 GiB during processing. API/worker/dispatcher readiness remained healthy.

This proves the local >120-second asynchronous path and recovery after closing the
screen/app. It does not prove production capacity, parser completeness, push
notification display, provider restart recovery, or backup restoration. The test
used the configured local B2 account; this verification did not print PDF
contents or include them in documentation.
