---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-02b-vision', 'step-02c-executive-summary', 'step-03-success', 'step-04-journeys', 'step-01b-continue', 'step-05-domain', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish', 'step-12-complete']
inputDocuments: ['product-brief-doclyzer-2026-03-01.md']
workflowType: 'prd'
classification:
  projectType: mobile_app
  domain: healthcare
  complexity: high
  projectContext: greenfield
---

# Product Requirements Document - doclyzer

**Author:** Vishnu
**Date:** 2026-03-01

---

## Executive Summary

**Doclyzer** is a product of **Envsoft Solutions LLP**. It is the one place for patients and carers to store, organise, and understand medical reports: one app for reports, trends, and AI summary; one link so the doctor sees full history—no app required for them.

**Who it's for:** People who accumulate PDF reports (labs, imaging, discharge notes), want to see trends (e.g. Hb over time), get a short AI summary, and hand off a clear history to any clinician. Primary: chronic self-managers and family carers; secondary: one-off users and share-link recipients (doctors, family).

**Job-to-be-done:** "Bring everything to the visit." Full history = selected reports + trends + summary in one view for the recipient. Product works even if the user never shares—timeline and trends are the base value.

**Boundary:** Doclyzer is not a diagnostic tool, not a replacement for a doctor or lab, and not an EHR. It is the patient's own organiser and handoff layer. Patient-controlled handoff to any clinician; complements (does not replace) clinic EHR.

**Free vs paid:** Free tier gives limited use; paid (credits + optional subscription) is for "everything in one place, shareable, with trends and AI," with a clear upgrade moment when they hit the cap or want to share.

### Free vs Paid Tier Matrix

| Limit / Feature | Free | Paid |
|-----------------|------|------|
| **Patient profiles** | 1 per account | Multiple |
| **Reports / files** | ~5 total (configurable) | Higher cap or credits |
| **Share links** | 1 per account | Higher cap |
| **Timeline, lab trends, charts** | Yes | Yes |
| **Basic per-report summary** | Yes | Yes |
| **AI chat / lifestyle suggestions** | No | Yes |
| **Profile create/edit/switch** | Create 1, edit; no switch (only 1) | Create/edit/switch multiple |

### What Makes This Special

- **Recipient-first share:** The share link is built for whoever opens it (doctor/family): readable, scannable, print-friendly—so "I sent the link" turns into "they actually used it."
- **Monetization as product design:** Credits (pay per report) and optional subscription from day one, built for irregular use.
- **Data and AI you control:** Parsing and AI run in your stack; data stays with you; one architecture for India, EU, US.
- **Trust by design:** Every AI output is clearly "informational only" and "talk to your doctor"; compliance and disclaimers are a product differentiator.

**Investor one-liner (short):** *Scattered reports → one link, one trend view.*

---

## Project Classification

| Dimension | Value |
|----------|--------|
| **Project type** | Mobile app (primary: Flutter iOS/Android), with web (share page, landing) and SaaS (credits, subscription) |
| **Domain** | Healthcare (medical reports, PHI, patient/carer use) |
| **Complexity** | High (PHI, disclaimers, multi-region, compliance) |
| **Project context** | Greenfield |

---

## Success Criteria

### User Success

- **Activation:** User has uploaded ≥2 reports and/or created at least one share link (per account).
- **Value moment:** (1) First share link opened by a recipient (e.g. doctor), or (2) first time user sees a trend chart (e.g. Hb over time). Either counts as "product worked."
- **Lifestyle/insight (paid):** User saw an AI lifestyle/natural-healing suggestion and (optionally) marked it helpful.
- **Retention:** 7-day and 30-day retention of activated users; goal = return to view/add reports or use share again.

### Business Success

- **North-star (share-as-wedge):** Share links opened by recipient (e.g. within 7 days of creation). Leading indicator: share links created per MAU.
- **Growth:** New signups; share-link recipients who sign up (viral loop).
- **Revenue:** Conversion from Free to paid (credit packs and/or subscription); ARPU by region (India vs US/EU); one-time pack uptake; promo redemptions tracked.
- **Trust:** Consent and data-handling compliance (e.g. GDPR where applicable); no major privacy or security incidents.

### Technical Success

- **Parse reliability:** Majority of supported report types (lab, common imaging) parse successfully; clear failure handling and "Keep file anyway" when parse fails.
- **Availability:** Backend and share page available for normal use; no unplanned data loss.
- **Compliance:** No PHI in logs or analytics; disclaimers and consent flows in place for AI output and data use.

### Measurable Outcomes

| Outcome | Target (example) | How measured |
|--------|------------------|---------------|
| Share links opened within 7d | % of created links opened | Share token + first view event |
| Activated users (2+ reports or 1+ share) | % of signups within 30d | Account-level events |
| 30-day retention (activated) | e.g. ≥25% | Return within 30d of activation |
| Free → paid conversion | % of activated users | Subscription or one-time purchase |
| Share → signup (recipient) | % of unique link viewers who sign up | Attribution from share token |

Leading indicators: reports uploaded per user, share links created per MAU, AI suggestion impressions and helpful votes (when in scope).

---

## Product Scope

### MVP – Minimum Viable Product

- Auth and account; patient profiles (create, assign reports, switch).
- Upload and parse (PDF, Docling or agreed stack); upload/parse status and "Keep file anyway" on failure.
- Per-profile timeline; lab as chartable time series; imaging as dated list with findings.
- Basic per-report summary (no chat/lifestyle in Free).
- One share link per account (Free); share page (web) with reports, summaries, charts; expiry and revoke.
- Credits and recharge (credit packs + subscription from day one); Razorpay (India + international); promo codes at checkout.
- Plan table and promo CRUD in superadmin; analytics (signups, active users, credit/subscription revenue, promo impact).
- **Object storage:** Backblaze B2 (S3-compatible) for report PDFs, profile avatars, and other user-uploaded files; private buckets with signed or scoped URLs for access.
- Flutter app (mobile); NestJS backend; separate share web app.

**MVP success:** User can sign up, create a profile, upload ≥2 reports, see timeline and a simple trend, create one share link and open it in a browser with correct data. Share link opened by recipient within 7d as north-star signal. No critical security/privacy incidents; disclaimers and consent in place.

### Growth (Post-MVP)

- Full AI: chat with reports, lifestyle/natural-healing suggestions (paid); "marked helpful" and basic analytics.
- Export PDF pack; reminders ("retest in 3 months"); "compare with prior" UI.
- More share links and higher caps per plan; optional EU hosting / GDPR-focused rollout.

### Vision (Future)

- B2B / clinic dashboard; doctors invite patients into a connected workflow.
- Offline / cache; FHIR or lab integration where it adds value; additional report formats and regions.

---

## User Journeys

### 1. Primary User – Success Path (Chronic Self-Manager)

**Opening:** Priya has diabetes and gets lab PDFs every few months. They live in email and folders; she can't see how HbA1c or fasting sugar have changed over time. Before a new specialist visit she digs for PDFs and hopes the doctor gets the picture.

**Rising action:** She signs up for Doclyzer, creates a profile ("Me"), and uploads two lab PDFs. The app shows "Uploading…" then "Reading report…"; within a minute she sees both reports on a timeline with a short summary. She taps a parameter and sees a simple trend (e.g. Hb over time). She creates a share link for "Me's reports," copies it, and sends it to the doctor's office before the visit.

**Climax:** The doctor opens the link in the browser, sees her timeline, numbers, and trend on one page, and uses it in the consultation. Priya feels she "brought everything in one place" without printing or forwarding PDFs.

**Resolution:** She keeps adding reports after each test; the trend and one share link become her default way to prepare for visits. She hits the free cap, sees the upgrade moment, and buys a credit pack so she can keep going.

**Reveals:** Auth, profiles, upload + parse + status, timeline, lab trends, basic summary, share flow (create → copy/send), share page (recipient view), credits/recharge and upgrade path.

### 2. Primary User – Edge Case (Parse Failure, Wrong Profile)

**Opening:** Raj uploads a scan report PDF. The parser doesn't recognise the layout and fails.

**Rising action:** He sees "We couldn't read this format. Your file is saved." with **Retry** and **Keep file anyway**. He taps **Keep file anyway** and gets an unparsed card with "View PDF" so the file isn't lost. Later he uploads a lab report but realises he chose "Dad" instead of "Me"; he can't move reports between profiles in MVP, so he knows to pick the right profile next time (or we note "move report" as a future improvement).

**Climax:** He still has the scan on his timeline (as PDF-only) and his lab in the right profile; he can create a share link for "Me" that only includes the correct reports.

**Resolution:** He learns that some PDFs stay "view only" and that profile choice at upload matters. No dead-end; recovery is clear.

**Reveals:** Parse-failure messaging, Retry and Keep file anyway, unparsed card, profile assignment at upload, share scope (per profile).

### 3. Secondary User – Family Carer

**Opening:** Anitha manages reports for herself, her mother, and her father. She used to keep printouts and PDFs in folders per person and would mix them up before appointments.

**Rising action:** She creates profiles "Me," "Mom," "Dad" in Doclyzer. She uploads each person's reports and assigns them to the right profile. She switches profile to see each timeline and, for her mom's labs, a trend. Before her dad's cardiology visit she creates a share link for "Dad's reports," sends the link to the family, and the doctor opens it.

**Climax:** At the visit, the doctor has already seen the trend and history via the link. Anitha feels in control and no longer carries stacks of paper.

**Resolution:** She keeps adding reports per profile and uses one share link per visit per person. She considers subscription for the family (more reports, more share links).

**Reveals:** Multi-profile (create, assign, switch), per-profile timeline and trends, per-profile share link, subscription as family option.

### 4. Share Recipient – Doctor (No App)

**Opening:** Dr. Kumar receives a message from a patient: "My reports are here: [link]." He's used to getting PDFs in email or WhatsApp; often they're out of order or missing.

**Rising action:** He opens the link in his browser. A clean page loads with the patient's name (or "Patient's reports"), timeline of reports, key results, and a simple trend (e.g. Hb). No login, no app. He reads, prints if needed, and closes the tab.

**Climax:** He has a single, up-to-date view of the patient's history and uses it in the consultation. The patient's "one link" actually gets used.

**Resolution:** He may receive more links from other patients over time. If he ever signs up (e.g. for his own family), that's a viral loop; for this journey he is non-logged-in recipient only.

**Reveals:** Share page (web, no app), doctor-friendly layout, print-friendly, no login, correct scope (profile/reports chosen by sender).

### 5. Superadmin – Plan and Promo Management

**Opening:** Ops needs to add a launch promo ("LAUNCH20") and tweak the free-tier report cap for a campaign.

**Rising action:** They log in to the superadmin dashboard (strong auth), open the plan table, and edit the free tier (e.g. report cap 5 → 3 for the test). They add a new promo code: LAUNCH20, 20% off credit packs, validity 30 days, cap 500 redemptions. They save and see the code in the list.

**Climax:** Users start applying LAUNCH20 at checkout; redemptions and revenue impact show in promo analytics. No code deploy was needed.

**Resolution:** They use the same surface to edit limits, add/deactivate promos, and monitor signups, active users, and revenue. No PHI on the dashboard; actions are audited.

**Reveals:** Superadmin auth, plan table (limits, caps, pricing), promo CRUD, redemption and revenue analytics, audit and no-PHI policy.

### Journey Requirements Summary

| Journey | Capabilities |
|--------|---------------|
| Primary – success | Auth, profiles, upload, parse, status, timeline, lab trends, basic summary, share (create/copy), share page, credits/upgrade |
| Primary – edge | Parse failure + Retry/Keep file, unparsed card, profile choice at upload, share scope |
| Family carer | Multi-profile, assign at upload, switch profile, per-profile share, subscription option |
| Share recipient | Share page (web, no app), doctor view, print, no login |
| Superadmin | Admin auth, plan table, promo CRUD, analytics, audit, no PHI |

## Domain-Specific Requirements

### Compliance & Regulatory

- Healthcare baseline: HIPAA-aligned PHI safeguards, GDPR/DPDP consent + deletion/portability handling, and explicit role separation between medical-data handling and billing systems.
- Regulatory-positioning control: keep product claims strictly informational (non-diagnostic, non-treatment) to avoid unintended medical-device classification scope creep.
- Policy-by-region controls: legal/disclaimer text, consent gates, retention defaults, and user-rights workflows must be configurable by jurisdiction (India/US/EU).
- Audit readiness: maintain immutable logs for access, sharing, consent changes, and admin actions sufficient for compliance reviews and incident investigations.

### Technical Constraints

- PHI-safe architecture: zero PHI in analytics/crash telemetry/logs; enforce structured redaction at SDK, API gateway, and worker levels.
- Data protection: encryption in transit and at rest, scoped secrets management, short-lived credentials, and strict RBAC/ABAC for patient profiles and documents.
- Share security controls: signed scoped tokens, expiry and revoke, optional passcode, rate limiting, bot-abuse detection, and anti-enumeration defenses.
- Safety guardrails for AI/parsing: confidence thresholds, unsupported-format detection, safe fallback ("view PDF"), and deterministic error states.
- Reliability minimums: background processing with retries/backoff, dead-letter handling, and idempotent upload/parse/payment webhooks.

### Integration Requirements

- Parser/LLM isolation: run in controlled network zones with explicit ingress/egress rules; no outbound PHI leakage paths.
- Payments boundary: Razorpay integration must never carry report-level health content; use minimal metadata and separate audit trail.
- Identity and admin controls: strong auth (MFA for superadmin), session hardening, and privileged action approvals where necessary.
- Future interoperability path: define extension points for FHIR/EHR integrations without constraining MVP delivery.

### Risk Mitigations

- Mis-parse risk: expose parse status + confidence, offer Retry and Keep-file-anyway, and provide clear user messaging for recoverable failures.
- Clinical misinterpretation risk: prominently display "informational only" language near AI output; require source-linked summaries where possible.
- Wrong-profile assignment risk: confirmation checkpoints at upload and safe reassignment flow with audit trace.
- Share leakage risk: default-expiring links, quick revoke UX, access-attempt monitoring, and anomaly alerts.
- Compliance drift risk: scheduled compliance reviews per release train and mandatory legal/privacy sign-off for high-impact changes.
- Operational risk: incident response playbooks for PHI exposure, parser outage, and payment-webhook mismatch; run tabletop pre-mortems before launch.

### Implementation Priorities (Cross-Functional Synthesis)

- **P0 (MVP gate):** PHI-safe observability, share-link security, legal disclaimers/consent baseline, parse failure recovery, audit logs.
- **P1:** region-policy toggles, stronger admin governance, AI provenance/citation enhancements, automated compliance checks in CI.
- **P2:** interoperability expansion (FHIR/EHR), advanced risk scoring, deeper security automation.

## Mobile App Specific Requirements

### Project-Type Overview

Doclyzer is a Flutter-first mobile healthcare app for patients and carers, centered on profile-scoped report management, structured parsing feedback, trends, and share-link handoff. The mobile experience must optimize trust, low-friction uploads, and deterministic recovery under real-world network variability.

### Technical Architecture Considerations

- Modular Flutter architecture with bounded domains: `auth`, `profiles`, `reports`, `timeline/charts`, `sharing`, `billing`, `settings`.
- Async-first backend contract for parsing lifecycle with explicit states: `uploading`, `queued`, `parsing`, `parsed`, `unparsed`, `failed_transient`, `failed_terminal`.
- Idempotent mobile actions for upload, retry, and payment callbacks; prevent duplicate report entries under poor connectivity.
- Strong session and credential security: secure storage, refresh-token rotation, short token TTLs for privileged flows, forced re-auth for high-risk actions.
- PHI-safe telemetry pipeline with enforceable schema-level redaction and CI checks preventing prohibited fields in analytics/crash events.

### Platform Requirements

- Flutter parity across iOS/Android for critical journeys; platform-specific divergence only when policy or UX norms require it.
- Performance targets on mid-tier Android:
  - app cold start target,
  - timeline first render target,
  - report upload responsiveness target.
- Accessibility baseline across both platforms (dynamic text, contrast, screen reader labels for key flows).
- Release strategy with phased rollout and rollback controls for parsing/upload/billing regressions.

### Device Permissions and Capabilities

- Minimum required permissions: file/document access; optional camera only when capture flow is used.
- Just-in-time permission prompts with pre-permission rationale and graceful fallback UI.
- Clipboard/share-sheet integration for link distribution with anti-leak UX cues (e.g., warning on public channels).
- Explicit prohibition of unnecessary permissions (location, contacts, microphone) in MVP.

### Offline and Connectivity Strategy

- Online-first MVP with resilient UX for intermittent networks:
  - queued retries for transient failures,
  - resumable upload where feasible,
  - user-visible job status with deterministic outcomes.
- Local persistence of pending actions and draft metadata to survive app restarts.
- Conflict handling policy for stale profile context or duplicated uploads after reconnect.

### Push Strategy

- PHI-safe push taxonomy:
  - parse complete,
  - action required,
  - billing/credit events,
  - security events (new device/session).
- Notification copy must be generic and privacy-preserving, with deep-link routing to authenticated in-app context.
- Granular user controls per notification category and jurisdiction-aware consent behavior.

### Store Compliance

- Medical disclaimer consistency across onboarding, AI output surfaces, and app store metadata.
- Data safety/privacy nutrition labels aligned with actual SDK/event behavior and reviewed per release.
- Region-aware legal links and consent text versioning (terms/privacy/refund) with audit trail of accepted versions.

### Implementation Considerations

- Prioritize first-value funnel reliability: signup → profile selection → upload → parsed insight/timeline.
- Enforce “active profile clarity” at all times to reduce wrong-profile uploads and shares.
- Build failure recovery as core UX:
  - Retry,
  - Keep file anyway,
  - clear terminal-state messaging.
- Add release guardrails:
  - contract tests for parsing status transitions,
  - E2E for upload/share critical paths,
  - synthetic monitoring for share-link rendering.

### Object Storage (Backblaze B2)

User-uploaded files (medical report PDFs, profile pictures, and any other binary assets) must be stored in durable, scalable object storage rather than local disk. **Backblaze B2** is the designated object store for MVP.

**Requirements:**

- **Backblaze B2** (S3-compatible API): one or more buckets for production file storage.
- **Asset types:** (1) Report PDFs (per profile, linked from report records); (2) profile/account avatars; (3) any future uploads (e.g. export packs, attachments).
- **Access model:** Buckets are private; the API generates short-lived signed URLs (or application-served streams) for reading. No public bucket listing. Write via application credentials only.
- **Naming and structure:** Predictable key structure (e.g. `reports/{userId}/{profileId}/{reportId}.pdf`, `avatars/{userId}.{ext}`) to support cleanup, data export, and account closure.
- **Environment:** B2 key ID, application key, bucket name(s), and endpoint configured via environment; no credentials in code or repo.
- **Resilience:** Upload flow stores file to B2 first, then creates/updates DB record; on DB failure, orphan files can be reconciled via lifecycle or admin job. Deletion (account closure, report delete) must remove both DB record and B2 object where applicable.
- **Compliance:** Same PHI and retention expectations as the rest of the system; B2 region and terms chosen to align with data-residency and backup requirements.

**Out of scope for MVP:** Cross-region replication, custom CDN, or multi-provider failover; single B2 bucket (or one per asset type) is sufficient.

### Failure Modes and Mitigations (Step-7 Addendum)

- Duplicate uploads from retry storms:
  - mitigation: client-generated idempotency key + server dedupe hash.
- Wrong-profile operations:
  - mitigation: sticky profile context + confirmation on high-impact actions.
- Silent parse failures:
  - mitigation: explicit terminal states and timeout escalation messaging.
- PHI leakage via logs/notifications:
  - mitigation: denylist/allowlist enforcement at SDK boundary and CI policy checks.
- Payment/report state drift:
  - mitigation: webhook idempotency and reconciliation jobs with admin alerts.

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Trust-first problem-solving MVP with monetization validation from day one.  
**Resource Requirements:** 1 mobile engineer, 1 backend engineer, 1 frontend/web engineer (share/admin), 1 QA, part-time PM/UX, part-time DevOps/SRE.

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
- Chronic self-manager: upload reports, see timeline/trends, share with doctor.
- Family carer: create/switch profiles and manage per-profile reports.
- Share recipient: open link in browser without app/login.
- Superadmin: manage plans/promos and view core revenue/usage analytics.

**Must-Have Capabilities:**
- Auth/account + multi-profile support.
- PDF upload, parse orchestration, deterministic status states, Retry/Keep-file-anyway recovery.
- Per-profile timeline + core lab trend visualization.
- Share links with revoke/expiry and secure token scope.
- Credits/recharge + subscription baseline + promo code application.
- PHI-safe observability, audit trails, legal/disclaimer enforcement.
- Admin plan table + promo CRUD + baseline operational analytics.

### Post-MVP Features

**Phase 2 (Post-MVP):**
- Rich AI assistant/chat and personalized lifestyle suggestions.
- Exportable doctor-ready report packs and compare-with-prior views.
- Notification expansion and stronger family collaboration flows.
- Better parsing coverage for long-tail report formats.

**Phase 3 (Expansion):**
- FHIR/EHR integrations and interoperability.
- Region-specific hosting/compliance expansions (deeper EU posture).
- B2B clinic workflows and white-label/enterprise capabilities.
- Advanced risk scoring and predictive insights.

### Risk Mitigation Strategy

**Technical Risks:** parsing reliability, wrong-profile actions, share security, webhook state drift.  
Mitigation: idempotency, explicit state machine, profile-safety confirmations, secure share controls, reconciliation jobs.

**Market Risks:** users may not retain after first upload/share.  
Mitigation: optimize first-value funnel, measure activation/retention, sharpen recipient experience for viral loop.

**Resource Risks:** scope overload in regulated domain.  
Mitigation: strict MVP boundaries, defer advanced AI/features to Phase 2, keep compliance/security P0.

## Functional Requirements

### Account & Identity Management

- FR1: Visitors can create a Doclyzer account.
- FR2: Registered users can sign in and sign out securely.
- FR3: Users can recover account access when credentials are lost.
- FR4: Users can view and update basic account information.
- FR5: Users can view and accept current legal and policy documents within the product context.

### Patient Profile Management

- FR6: Account holders can create patient profiles; free tier allows one profile per account; paid tier allows multiple profiles.
- FR7: Account holders can edit profile details for each patient profile.
- FR8: Account holders can switch active profile context at any time.
- FR9: Users can assign each uploaded report to a specific patient profile.
- FR10: Users can delete a patient profile with confirmation and clear impact visibility.

### Report Ingestion & Processing

- FR11: Users can upload supported medical report files to an active profile.
- FR12: Users can see report processing status from submission to final state.
- FR13: Users can retry report processing when processing fails.
- FR14: Users can keep an uploaded report as file-only when parsing is unsuccessful.
- FR15: Users can view original report files regardless of parse outcome.
- FR16: The system can detect and handle duplicate report submissions with explicit user choice.
- FR50: Users can view a complete history of report processing attempts and outcomes per report.
- FR61: Users can correct report-to-profile assignment after upload with explicit confirmation.

### Health Data Organization & Insight

- FR17: Users can view a timeline of reports scoped to the active profile.
- FR18: Users can view structured lab values when extraction is available.
- FR19: Users can view trend charts for chartable lab parameters over time.
- FR20: Users can view report-level summaries for uploaded reports.
- FR21: Users can view profile-level consolidated health history from available reports.

### Sharing & Recipient Experience

- FR22: Users can create share links for selected profile data.
- FR23: Users can configure share-link validity controls, including expiry and revocation.
- FR24: Users can distribute share links via copy/share actions.
- FR25: Recipients with a valid share link can view shared content in a browser without account creation.
- FR26: Recipients can access a readable, doctor-friendly shared view including timeline and key trends.
- FR52: Users can define default share-link policies for newly created share links.
- FR57: The system can detect and flag suspicious activity across both account and sharing surfaces for administrative review.
- FR59: Users can view a history of share-link access events for links they created, including timestamp, link identifier, and outcome state.

### Monetization & Billing

- FR27: Users can view current credit balance and entitlement status.
- FR28: Users can purchase credit packs through supported payment flows.
- FR29: Users can subscribe to supported paid plans.
- FR30: Users can apply valid promo codes during eligible checkout flows.
- FR31: The system can enforce free-tier and paid-tier usage limits consistently.
- FR47: Users can see the outcome of billing actions and entitlement updates in pending, failed, and reconciled states.
- FR51: Users can view current plan/credit entitlements and the latest entitlement change reason.

### Notifications, Communication & Support

- FR32: Users can receive product notifications for relevant account, report, and billing events.
- FR33: Users can control notification preferences by category.
- FR34: Users can receive clear in-app messaging for success, failure, and recovery states during critical flows.
- FR60: Users can manage account communication preferences for security and compliance notices.
- FR65: The system can provide user-facing status updates for major service incidents affecting core workflows.
- FR68: Users can initiate in-product support requests tied to failed critical actions, including related action identifiers for triage.
- FR77: The system provides an email pipeline for sending transactional and product emails (e.g. password reset, notifications, security/compliance notices) with delivery status and tracking.

### Consent, Privacy & Governance

- FR40: The system can enforce explicit informational-only medical disclaimers at the point of AI-derived interpretation and before share publication where relevant.
- FR41: Users can exercise account-level data rights workflows, including deletion-related actions.
- FR42: The system can enforce PHI-safe product telemetry and operational event handling policies.
- FR44: Users can grant and withdraw consent for data processing features that require explicit consent.
- FR45: Users can view which consent choices are currently active for their account.
- FR46: The system can enforce profile isolation across all user-facing views and share outputs unless explicitly authorized by the account holder.
- FR48: The system can maintain acceptance records for legal/policy versions tied to user actions.
- FR54: Users can request an export of their account data, including user-submitted data and available derived account artifacts, in a portable format.
- FR62: Users can request account closure and receive clear visibility into resulting data-access changes.
- FR67: Users can view and acknowledge critical compliance or security notices that affect account use.

### Session & Access Control

- FR55: Users can view and manage active sessions/devices associated with their account.
- FR56: Users can immediately revoke account access from selected active sessions/devices.
- FR70: Users can view when protective restrictions are applied to their account and what actions are limited.
- FR71: Users can view a clear rationale and next steps when account restrictions are applied.

### Delegation & Multi-Profile Safety

- FR63: Users can designate trusted delegates for profile management with explicit scope controls.
- FR66: Users can revoke delegated profile-management access at any time.
- FR72: Users can define delegation expiration conditions when granting delegated access.

### Superadmin Operations & Incident Response

- FR35: Superadmins can manage plan definitions, limits, and pricing configuration.
- FR36: Superadmins can create, edit, activate, and deactivate promo codes.
- FR37: Superadmins can view promo redemption and revenue impact data.
- FR38: Superadmins can view core product metrics for signups, usage, and monetization.
- FR39: Superadmin actions are recorded with auditable change history.
- FR43: The system can provide access and sharing activity records needed for compliance and incident investigation.
- FR49: Superadmins can perform emergency containment actions, including reversible actions where applicable, with mandatory audit notes.
- FR53: Superadmins can retrieve auditable records for access, sharing, consent, and policy acceptance events.
- FR58: Superadmins can suspend and restore risky share links and affected accounts with auditable justification.
- FR64: Superadmins can enforce temporary protective restrictions during active security investigations.
- FR69: Superadmins can place accounts in restricted review mode without deleting user data.
- FR73: Superadmins can document resolution outcomes for restricted accounts with audit traceability.
- FR76: Superadmins can execute time-bound override actions with mandatory reason capture and expiration.
- FR78: Superadmins can view email queue status, delivery analytics (sent, failed, bounced by type), and email sending history via an admin panel.
- FR79: Superadmins can send admin-level emails (e.g. announcements, support, incident notifications) through the admin panel with mandatory audit and recipient controls.

### FR Governance Note

Any new feature introduced after this point must map to an existing FR or add a new FR before planning and implementation.

## Non-Functional Requirements

### Performance

- NFR1: Core authenticated screens load usable content within 2 seconds under normal mobile network conditions.
- NFR2: Report upload initiation feedback appears within 1 second of user action.
- NFR3: Timeline interactions (scroll/filter/open report) respond within 300 ms for typical profile data volumes.
- NFR4: Share-link web view renders primary summary content within 2 seconds on modern mobile browsers.

### Security & Privacy

- NFR5: All data in transit is protected with TLS.
- NFR6: Sensitive stored data is encrypted at rest using approved key-management practices.
- NFR7: PHI is excluded from analytics, crash telemetry, and operational logs.
- NFR8: Access to profile-scoped data is enforced by account and authorization context across all surfaces.
- NFR9: Security-relevant admin and user actions are auditable and tamper-evident.

### Reliability & Availability

- NFR10: Critical user workflows (auth, upload, timeline view, share view, entitlement check) achieve 99.9% monthly availability target.
- NFR11: Background processing failures use retry/backoff with deterministic terminal states.
- NFR12: User-facing error states provide recovery paths for all critical workflows.
- NFR13: Backup and restore procedures support recovery point and recovery time targets appropriate for healthcare data handling.

### Scalability

- NFR14: System supports 10x growth from initial launch load without architecture redesign of core workflows.
- NFR15: Peak-time traffic spikes are handled without loss of data consistency for uploads, entitlements, or share access.
- NFR16: Asynchronous processing capacity can be increased horizontally for parse and AI workloads.

### Accessibility

- NFR17: Mobile and share-web interfaces conform to WCAG 2.1 AA criteria for applicable components.
- NFR18: Critical flows are operable with screen readers and scalable text settings.
- NFR19: Color and contrast choices meet accessibility thresholds for health-information readability.

### Integration & Interoperability

- NFR20: External integrations (payment, parser/AI services) use versioned contracts with explicit error semantics.
- NFR21: Integration failures degrade gracefully without corrupting user-visible state.
- NFR22: Integration latency and failure rates are continuously monitored with alert thresholds.

### Compliance & Governance

- NFR23: Legal/policy version acceptance is retained for audit and dispute handling.
- NFR24: Consent-state changes are traceable with timestamped records.
- NFR25: Region-aware compliance controls can be configured without requiring core product redesign.

### Operational Observability

- NFR26: Production systems emit structured, searchable operational events for critical flows.
- NFR27: Alerting exists for security incidents, entitlement drift, and parser/processing failures.
- NFR28: Incident response procedures define severity tiers, notification paths, and restoration expectations.
