# Critical Task: Durable Report Processing, SSE, and Completion Notifications

Created: 2026-10-19
Status: Code implemented across all six phases; local integration verified; production release gates remain open
Priority: Critical

## Implementation progress (2026-10-19)

Implemented: durable admission, fenced standalone worker, pinned asynchronous Docling adapter, transactional events and authenticated SSE, web/Flutter tracking, independent inbox/notification dispatcher, operator controls and deployment/runbook artifacts. Admission remains off by default. The full migration chain, actual worker kill/restart, PostgreSQL races, SSE session revocation, client tests and builds passed locally. A real 19-page emulator upload then completed in 160 seconds with the app backgrounded; see the contract for schema-repair and extraction-review findings.

See [implementation contract and evidence](report-processing-contract.md) and [operations/release runbook](report-processing-operations.md). Checked items represent implemented code or explicit design decisions, not proof of production deployment. Unchecked items require additional integration, infrastructure, load or real-device evidence; all-phase production sign-off is not complete.

## Objective and reliability promise

Let users leave the upload screen after the server accepts their file. Process reports in a separate recoverable worker, show live progress in web and Flutter through SSE, and notify users when results are ready even when the mobile app is closed. Replace synchronous Docling conversion to remove its 120-second response-wait limitation.

Zero failures and guaranteed push display are not achievable promises. The required guarantees are durable acceptance, bounded retries, visible failure states, recoverable event delivery, and no silent loss or duplicate business effects. External outages can delay completion; exhausted recovery must produce an actionable state and operational alert. This task covers known failure classes and requires further failures found during implementation to be added to its test matrix.

## Original baseline and implementation areas

- `apps/api/src/modules/reports/reports.service.ts`: upload currently awaits parsing and summary generation before saving the report; duplicate detection is explicitly best-effort. Preserve extraction, corrections, entitlement, and referral behavior during extraction into a worker.
- `apps/api/src/modules/reports/docling-ocr.client.ts`: calls `/v1/convert/file`, uses a shared request deadline, and switches payload formats following non-success responses. A timeout must not trigger a format fallback or uncontrolled resubmission.
- `apps/api/src/database/entities/report.entity.ts`: already defines queued/parsing and terminal report statuses. Evolve these with an explicit compatibility mapping rather than introducing conflicting state models.
- `apps/api/src/database/entities/report-processing-attempt.entity.ts`: extend or complement the existing attempt audit with durable execution state.
- `apps/api/src/common/notification-pipeline`: existing report completion dispatch queues email; extend delivery without breaking existing consumers.
- `apps/api/src/modules/notifications`: reuse token registration, preferences, delivery audit, and FCM provider foundations.
- `apps/mobile/lib/features/notifications/push_notification_service.dart`: currently registers tokens and tracks opens; add reliable routing and foreground state reconciliation.
- `apps/mobile/lib/features/reports`, web report/dashboard components, API configuration, migrations, and deployment services require coordinated changes.
- `docker/docling/Dockerfile` pins `docling-serve==1.37.0`; `docker-compose.yml` gives Docling a 6 GB memory limit. Verify deployed behavior rather than assuming current upstream documentation matches the pinned version.

Related tasks: [push infrastructure](billing-referral-notification-promo/09-push-notification-infrastructure.md), [mobile notifications](billing-referral-notification-promo/12-mobile-notifications.md). Reuse existing implementations; do not build a second token or preference system.

## Non-negotiable invariants

1. An upload is accepted only after its source file is durable and its report and job transaction has committed.
2. Closing a screen, losing SSE, or closing the app does not cancel accepted work.
3. One active logical processing job exists per report; concurrent identical uploads in the same account/profile reuse active processing.
4. Execution and message delivery are at least once. Database constraints, transaction guards, and idempotent business operations prevent duplicate persisted effects; do not claim end-to-end exactly-once execution.
5. Only the current lease holder and processing generation may commit results. Old workers cannot overwrite retries, reviewed results, or deleted reports.
6. Ready status implies all required results are committed and readable. Optional enrichment has a separate status if it does not gate readiness.
7. Status transitions and their durable events commit atomically. Notification delivery failure never rolls back successful parsing or reruns it.
8. SSE is the foreground update mechanism. No routine client report-status polling loop. Snapshot reconciliation on startup, reconnect gaps, or expired cursors is required.
9. Authorization applies to snapshots, live events, replay, results, and notification navigation. Identifiers are never authorization credentials.
10. A report remains discoverable after missed push notifications. Push provider acceptance is not proof of display or reading.

## Architecture and decisions to close before coding

Use PostgreSQL-backed jobs and a durable event outbox initially, with a separate NestJS worker entry point. Keep HTTP API, processing worker, and notification dispatcher independently restartable. SSE gateways read committed events; cross-instance signals wake delivery but are not the durable source.

- [ ] Confirm database availability, backup/restore objectives, storage durability, expected documents/day, peak uploads, concurrent SSE connections, page counts, and conversion latency distribution.
- [x] Choose cross-instance signaling: PostgreSQL LISTEN/NOTIFY or Redis pub/sub. In either case recover missed wakeups by scanning durable events server-side, including startup/reconnection. Document connection-pool requirements and outage behavior.
- [x] Specify browser SSE authentication: secure same-origin session cookies, or a streaming client supporting authorization headers. Native EventSource cannot attach arbitrary bearer headers. Do not place long-lived credentials in URLs. Define Flutter token refresh and stream restart behavior.
- [ ] Confirm the pinned Docling task/status/result API, task retention, restart behavior, partial-success responses, result consumption semantics, and supported progress transport in an integration test.
- [x] Decide whether summary generation gates readiness. Recommended: core extracted results gate ready; optional summary failure remains separately visible and retryable.
- [ ] Set supported upload/page/resource limits, retry budget, processing deadline, job lease/heartbeat timing, event retention, notification expiry, and recovery SLOs. Record measured rationale, not arbitrary unlimited values.
- [x] Define completed-duplicate, deleted-report restore, review acknowledgement, reprocessing, credit reservation/refund, and notification-per-attempt policies. Active duplicate uploads must never offer “Upload anyway.”
- [x] Define compatible behavior for old mobile clients before changing upload responses; use a versioned contract or enforce a supported minimum version. Do not silently return queued data to clients expecting final results.

## Phase 1 — Contracts, schema, and durable acceptance

- [x] Document states and legal transitions. Distinguish queued, active processing, scheduled retry, successful completion, content needing attention, permanent failure, and deletion/cancellation. Preserve existing API status compatibility explicitly.
- [x] Add processing generation, monotonic report version, stage, safe error code, accepted/start/completion timestamps, and retry eligibility. Keep raw provider errors private.
- [x] Add jobs/attempt fields: report ID, trigger, attempt count, available time, lease token/generation, lease expiry, heartbeat, absolute deadline, provider task ID and provider instance identity where needed, outcome and diagnostics.
- [x] Add indexes and constraints for runnable jobs, active execution, content identity, and idempotency. Use PostgreSQL integration tests for concurrency behavior; an in-memory database is insufficient evidence for locks.
- [x] Hash original accepted file bytes before variable normalization and document the hash algorithm/version. Deduplicate exact bytes, not semantic document similarity or filenames.
- [x] Serialize active content claims by account/profile/hash. Handle two simultaneous requests, an existing report completing during the check, and a competing transaction rolling back. Keep detection scoped to authorized ownership.
- [x] Scope request idempotency by authenticated account and operation; bind keys to request identity. Reject key reuse with different content/profile. Define key expiry and lookup behavior after a lost response.
- [x] Store the file and transactionally create report, job, and queued event. If object storage succeeds but the transaction fails, clean up safely; use an age-bounded orphan sweeper for crash gaps. Never remove an object referenced by an accepted report.
- [x] Return `202` with report ID, current version/status and status URL only after commit. An active duplicate returns the existing report without a new job or credit use. Document response semantics for all other duplicate states.
- [x] Make entitlement reservation, capture/refund, and referral milestones idempotent using existing ledger-safe services. Count accepted pending work consistently against limits so concurrent uploads cannot exceed allowance.

## Phase 2 — Separate worker and result integrity

- [x] Extract parsing into a service callable by the worker; keep HTTP upload and retry endpoints short and durable. Manual retries enqueue work rather than executing parsing inline.
- [x] Claim due jobs atomically (for example row locks with SKIP LOCKED). Commit claims before network/OCR work; do not hold database transactions or row locks for the conversion duration.
- [x] Use renewable leases and fencing tokens. Every final write must verify current ownership, generation, report existence, deletion state, and review protections within its transaction.
- [x] Add bounded concurrency, exponential backoff with jitter, provider rate-limit handling, maximum attempts, and a total deadline. Classify invalid/corrupt/unsupported content separately from transient infrastructure errors.
- [x] Recover expired leases after crashes. A database outage must stop unsafe new claims and prevent unfenced commits; recover from persisted state after connectivity returns.
- [x] Record real stages only. Do not infer percentage completion from time elapsed or simulate progress.
- [x] Persist results, report version/status, attempt outcome, and event atomically. Preserve manually reviewed corrections and prevent partial rows becoming visible as ready.
- [x] Make cancellation/deletion win over completion. Cancel provider work when supported; otherwise discard late output safely and clean up retained artifacts.
- [x] Implement graceful shutdown: stop claiming, finish within grace or release safely, and rely on lease recovery for forced termination.
- [x] Add an automatic stale-job reconciler and audited operator retry/cancel controls. Retry controls use normal claims and invariants, not direct status edits.

## Phase 3 — Asynchronous Docling and large-file recovery

- [x] Submit via the pinned version's `/v1/convert/file/async`; persist the returned task ID before subsequent tracking steps.
- [x] Subscribe to the supported Docling task WebSocket. Reconcile task status after disconnects; bounded backend status checks are permitted for recovery and do not replace client SSE.
- [ ] Retrieve the finished result, validate its schema and completion quality, and durably stage it before final normalization if needed. Confirm whether fetching starts a retention countdown or consumes results.
- [x] Separate submission timeout, tracking connection timeout, result-download timeout, lease lifetime, and total conversion deadline. A disconnected socket is not a failed conversion.
- [x] Remove format fallback on timeout/5xx. Use a verified request schema; validation errors should be diagnosed, not blindly resubmitted with alternate bodies or hostnames.
- [x] Handle the ambiguous submission window: Docling may accept a task before the worker receives/persists its ID. Verify provider idempotency or task lookup support. If unavailable, record uncertainty, bound resubmissions, and acknowledge that duplicate external computation may occur; fencing still prevents duplicate results/charges.
- [x] On provider restart, distinguish temporarily unreachable tasks from confirmed missing tasks. Retry only under a bounded policy and retain the source object until processing/retention policy permits deletion.
- [x] Handle partial-success output explicitly; do not present missing pages/results as a fully successful extraction. Retain page provenance and expose review warnings according to extraction rules.
- [ ] Enforce input size, page, decoded-image, memory, concurrency, and execution limits. Test scanned and text PDFs separately. Increasing wait time does not solve out-of-memory failures.
- [ ] Benchmark representative large files under contention before tuning workers/threads. Do not blindly increase concurrency within the current memory limit.
- [x] Consider page-range chunking only if profiling requires it; preserve page order, cross-page tables, units, references, and provenance, with extraction regression tests. It is not the default timeout fix.
- [x] Verify no synchronous `/v1/convert/file` request remains on the production processing path. Raising MAX_SYNC_WAIT alone does not satisfy this task.

## Phase 4 — Durable events and authenticated SSE

Example wire contract (final endpoint and schema must be versioned):

```text
id: <opaque-durable-cursor>
event: report.status_changed
data: {"schemaVersion":1,"reportId":"...","profileId":"...","attemptId":"...","version":4,"status":"parsed","stage":"complete"}
```

- [x] Persist minimal events in the same transaction as report changes; include no transcript, lab values, filename, or other unnecessary medical data.
- [x] Design a durable replay cursor with commit-order correctness. A plain auto-increment ID can be allocated before another transaction commits: advancing past an uncommitted lower ID can lose an event. Specify and test serialization/publication ordering that prevents this gap.
- [x] Provide one account-scoped stream per client session, with profile-aware payloads. Do not create one socket per report or subscribe shared-link viewers to an owner's private stream.
- [x] Support Last-Event-ID and an explicit persisted-cursor mechanism for new connections. Native automatic reconnect alone does not cover app/browser restart.
- [x] Specify race-free snapshot plus replay handoff. Define which cursor a snapshot represents and how events occurring during snapshot loading are applied.
- [x] On expired/invalid cursors, emit a typed reset instruction; client fetches a fresh authorized snapshot and resumes without looping. Bound replay pages, stream buffers, and catch-up work.
- [x] Recheck account/session/access revocation for long-lived connections and replay. Stop delivery promptly after logout/session expiry or profile access changes; define the maximum revocation latency.
- [x] Add heartbeats, reconnect backoff/jitter, slow-consumer disconnection, per-account connection limits, and multi-tab behavior. Test SSE parsing across fragmented network chunks and multiline data.
- [x] Support multiple API instances without sticky-session dependency. Ensure every relevant gateway can deliver the event; a single competing-consumer queue alone is not broadcast delivery.
- [ ] Disable proxy response buffering and unintended caching; verify compression/flush behavior, HTTP connection capacity, idle timeout, and graceful load-balancer draining through the actual deployed proxy.
- [x] Publish after commit only. Never announce readiness from an in-memory callback before results commit.

## Phase 5 — Web and Flutter UX

- [x] Add app-level connection and report stores with subscription cleanup. Navigation away from upload must not stop tracking.
- [x] Show the queued report as soon as accepted; merge authoritative response versions with SSE updates without regressing state.
- [x] Render queue, processing stages, scheduled retry, ready, and actionable failure states on dashboard/list/detail screens. Show delayed updates/reconnecting when appropriate.
- [x] Apply events idempotently by report version; reconcile version gaps where required. Keep persisted cursors and caches account-scoped and update cursors only after safe application or ensure a fresh snapshot on restart.
- [x] Handle cold launch, resume, offline/online transitions, token refresh, profile switch, logout, and login as another account. Do not keep SSE alive as a mobile background-execution workaround.
- [x] Keep ready-for-review visible until the defined acknowledgement action. Viewing and processing are separate states.
- [x] Distinguish file transfer from processing. This task permits leaving after server acceptance; closing before transfer completes is not guaranteed unless a separately scoped background/resumable upload implementation is added.

## Phase 6 — Completion push and inbox

- [x] Consume the durable completion event independently of parsing. Atomically create a unique inbox item and delivery intents per eligible channel/device, with stable logical notification IDs.
- [x] Reuse existing preferences and token lifecycle. Do not route all push eligibility through email-only preference checks.
- [x] Send a visible FCM notification payload for Android/iOS routing through APNs, with generic wording and minimal identifiers. Do not depend on background Dart execution to display it.
- [x] Authenticate device registration; handle token rotation, stale tokens, account reassignment, logout, and multiple devices. Recheck recipient eligibility before sending.
- [x] Retry transient provider failures with backoff and provider guidance. Disable invalid tokens, expire stale notifications, and retain exhausted delivery failures for operational inspection.
- [x] Treat send-timeout/provider-response loss as ambiguous. Database deduplication cannot guarantee a provider never displays a duplicate; use stable IDs and supported platform replacement/collapse semantics where appropriate without collapsing different reports unintentionally.
- [x] Handle foreground messages, background taps, and terminated-app initial messages. Queue navigation until auth/router initialization; fetch current state and authorize access before opening the report.
- [x] Handle stale notifications for deleted, superseded, or inaccessible reports without exposing data or navigating to an unrelated profile. Validate route types/IDs rather than opening arbitrary payload URLs.
- [x] Prevent repeated completion alerts on tracking reconnect or job redelivery. Define whether an explicit new processing generation merits another notification.
- [x] Show completion in the inbox/dashboard when push permission is denied or delivery fails. Record provider accepted, failed, opened, and read as distinct concepts; never label accepted as confirmed display.
- [ ] Verify real Android/iOS devices with production-like credentials. Mock provider success must not satisfy production readiness or silently mask missing credentials.

## Failure recovery and required test matrix

Every row needs an automated integration/fault-injection test where feasible; device/OS and proxy cases need a recorded reproducible verification procedure.

| Failure or race | Required recovery / assertion |
| --- | --- |
| Upload response lost after commit | Same idempotency key returns existing report; no extra job or charge |
| Same bytes uploaded concurrently | One active content claim and processing job; both clients follow the same report |
| Same key with different file/profile | Explicit conflict; no mutation of original request |
| Storage succeeds, database fails/crashes | No accepted response; unreferenced object eventually removed safely |
| Storage unavailable or accepted object missing | Clear upload failure or actionable processing failure; no false readiness |
| Worker dies before/after claiming | Lease expiry permits recovery; no permanent queued/parsing limbo |
| Old worker completes after lease takeover | Fencing rejects its commit; newer attempt remains authoritative |
| Database disconnects during completion | Transaction rolls back or commit is reconciled; effects are not blindly repeated |
| Docling accepts but task ID response is lost | Submission uncertainty policy bounds duplicate work and protects business effects |
| Conversion exceeds 120 seconds | Async task completes without sync-wait 504; user can navigate away |
| Docling/WebSocket restarts | Reattach/reconcile known task or controlled retry if confirmed lost |
| Result expires or download fails | Recover staged result or retry under budget; never announce incomplete results |
| Corrupt/huge/OOM/partial-result document | Classified outcome, bounded resource use, no endless retries or false success |
| Optional summary fails | Follow documented readiness policy; avoid repeating successful extraction unnecessarily |
| Completion races with deletion/review edits | Deletion/review protection wins; no resurrection or silent correction loss |
| SSE instance or signal channel fails | Reconnect and durable catch-up without missed committed events |
| Event transactions commit out of ID order | Replay does not skip late-committing events |
| Event emitted during snapshot/subscription | Handoff delivers final state without a gap |
| Duplicate/out-of-order events or slow client | No state regression; bounded buffering and recoverable disconnection |
| Cursor expired or retention job races replay | Typed reset and consistent snapshot; no silent truncation |
| Token expiry, logout, access revoked | Stream stops authorized delivery; caches/cursors cannot leak across accounts |
| App closed, offline, or notifications disabled | Backend finishes; inbox/dashboard recovers on return |
| Push accepted but dispatcher crashes | Stable delivery identity; ambiguity handled without claiming exactly-once display |
| Invalid token or provider outage | Cleanup/retry/expiry independent of report success |
| Push tapped after logout/profile change/deletion | Authenticated, authorized routing or safe unavailable state |
| Old mobile client receives new API behavior | Version/compatibility policy prevents broken result navigation |
| Sustained upload and SSE load | Bounded queues/connections/memory, measured latency, visible overload response |
| Backup restoration or deployment rollback | Reconcile jobs/provider tasks/events with restored state; preserve fencing and deduplication |

## Operations, security, and retention

- [ ] Measure upload acceptance latency, queue age/depth, worker lease expiry, attempt counts, conversion duration by pages/type, OOMs, stuck reports, event lag, SSE connection/replay/reset rates, and notification retry/failure rates.
- [x] Correlate report/job/attempt/event IDs without logging files, lab data, secrets, push tokens, or signed storage URLs. Redact provider error bodies.
- [ ] Define alert thresholds and owners for oldest queued job, deadline overruns, repeated provider failures, delivery backlog, and orphan growth. Dashboards must distinguish infrastructure outage from bad documents.
- [x] Add readiness/liveness checks appropriate to each process; a healthy API does not imply healthy workers. Fail production startup/readiness for required missing configuration rather than silently selecting mocks.
- [ ] Apply least privilege to workers, storage, notification credentials, and event consumers. Rate-limit upload, retry, SSE connection, and replay endpoints.
- [ ] Define retention for source files, staged results, events, idempotency records, inbox items, and diagnostics. Deletion must remove or anonymize associated sensitive artifacts while retaining only permitted audit data.
- [ ] Ensure event cleanup respects replay/reset semantics and job cleanup cannot delete live leases. Verify restore procedures and document the actual recovery-point/recovery-time objectives.
- [x] Publish runbooks for stuck jobs, Docling restart, expired results, provider outage, notification ambiguity, replay backlog, safe operator retry, and disaster recovery.

## Delivery order and release gates

1. Contracts, decisions, schema migrations, and concurrency tests.
2. Durable upload acceptance, isolated worker, asynchronous Docling, and crash recovery.
3. Transactional events, replay-safe SSE, and multi-instance/proxy tests.
4. Web/Flutter stores, dashboard UX, lifecycle handling, and client compatibility.
5. Notification dispatcher/inbox, device routing, and real-device tests.
6. Fault-injection suite, capacity measurements, operational runbooks, and staged rollout.

- [x] Use additive migrations first; assess existing duplicate records before enabling unique constraints. Deploy compatible consumers before producing new events/responses.
- [x] Feature-flag new acceptance separately from draining existing jobs. Rolling back must stop new admission safely without stranding already accepted asynchronous reports.
- [x] Prevent old and new processing paths from processing the same accepted report. Do not fall back to synchronous parsing automatically during queue outages.
- [ ] Canary with representative files/users, observe the defined SLOs, then expand. Record rollback triggers and migration compatibility.
- [ ] Set numeric release targets from measured staging load before rollout: maximum recovery time after worker death, foreground event lag, sustained queue capacity, and processing deadline by supported document class.

## Definition of done

Checked behavioral items below have local automated evidence only; the unchecked release items remain mandatory.

- [ ] All critical checklist items above are implemented or explicitly resolved with a documented rationale; unresolved durability/security/recovery requirements block release.
- [ ] A report exceeding the former 120-second wait completes through the deployed asynchronous path while the user leaves the screen/app.
- [x] Duplicate uploads, worker takeover, event replay, and notification redelivery do not duplicate persisted business effects.
- [x] Both clients recover current state after missed events without routine foreground status polling.
- [ ] A closed-app notification opens the correct authorized report; missed push remains recoverable through inbox/dashboard state.
- [x] No accepted report silently remains stuck: it completes, is retried within budget, or reaches an actionable terminal state with diagnostics.
- [ ] Existing parser, correction, entitlement, referral, and report-history checks pass alongside new PostgreSQL concurrency and recovery tests.
- [ ] Test evidence, measured capacity/SLOs, production configuration, compatibility rollout, and recovery runbooks are attached to the implementation PRs.

## Provider references to verify against the pinned deployment

- [Docling asynchronous conversion usage](https://github.com/docling-project/docling-serve/blob/main/docs/usage.md)
- [Docling configuration and synchronous wait limit](https://github.com/docling-project/docling-serve/blob/main/docs/configuration.md)
- [Flutter FCM lifecycle and notification interaction](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages)

These links track upstream documentation. Pin tested contract details in implementation tests; upstream main is not evidence of behavior in the deployed version.

## Privacy and ready-banner regression verification (2026-10-19)

- Tested the supplied 19-page Sterling Accuris PDF with local PDFium text extraction and a fresh local asynchronous Docling conversion (`do_ocr=false`, structured tables enabled). No document contents or identity values were printed or sent to an LLM. Temporary extracted contents remain outside the repository and are removed after verification.
- Patient name, age, sex and collection date agree between both local extraction paths. Fixed Markdown label/value cells, `Sex/Age`, full `Years` units, collection dates with abbreviated months, and adjacent `Lab Id` labels. Lab organization name is extracted locally and merged into the persisted structured report. Lab contact/address fields were not reliably found and are not claimed as verified.
- **Not a complete extraction sign-off:** Docling converted all 19 pages successfully; the structured parser extracted 49 of 67 candidate rows. The remaining 18 require review. This test covers native-text asynchronous conversion and parsing, not a fresh end-to-end upload/worker/SSE/device deployment.
- Raw-PDF summaries and free-text AI fallback now fail closed regardless of their configuration flags. Summary intents are no longer created; old queued intents drain without reading the source PDF. Summary retry returns an explicit privacy-disabled response. Result explanations resolve an exact approved catalog alias, validate numeric result/unit/range fields, omit sample dates and identifiers, and reject unsupported input before transport. This intentionally reduces AI feature availability until a safe structured contract is implemented.
- Ready notifications now have explicit dismiss actions on web/mobile. Opening a readable report acknowledges it without depending on the processing snapshot having arrived. Server acknowledgment is durable, idempotent, owner-scoped, restricted to ready reports and updates only the current generation's inbox item. Refresh alone is not an acknowledgment.
- Added `reports:privacy-test` and `scripts/report-acknowledgement-postgres-test.ts`. The latter uses connection-local temporary PostgreSQL tables to test persisted acknowledgment, repeat reads, ownership, generation scope and queued-state protection. Real-file verification logs only aggregate counts/field presence and uses a transport trap; synthetic fixtures exercise unsafe inputs and ensure zero outbound requests.
- **Emulator follow-up (2026-10-19):** Uploaded the exact bytes of `sterling-accuris-pathology-sample-report-unlocked.pdf` to the local asynchronous API for the signed-in test account and viewed the result on Android emulator `emulator-5554`. The 19-page report finished `needs_attention` / **Extraction incomplete** (49/67 candidate rows mapped), so it must not be presented as fully ready. Fixed the worker result path to retain locally extracted identity fields while withholding incomplete lab-result sections. After retrying that same upload, the emulator showed Patient details with name, age, gender and sample collection labels, and Lab details with a lab name label. Lab address, phone, email and location were absent. The original PDF was left unchanged; temporary QA copies were removed.
- The targeted mobile store tests, parser/OCR tests, privacy transport test, API build and PostgreSQL acknowledgment test passed. A separate synthetic ready fixture was used only for the notification path: the API snapshot returned `ready` with no acknowledgment, and an API acknowledgment persisted, but the banner was not observable in the emulator accessibility tree during this run. The visual dismiss/refresh behavior remains **unverified on emulator** and should not be signed off from the unit/database tests alone.
