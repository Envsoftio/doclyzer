# Doclyzer: Blood Test History, Understanding, and Mobile Experience

Status: Draft for product review; implementation has not started under this PRD  
Date: 2026-10-16  
Scope: Consumer product, UX/UI redesign, lab-data reliability, and Flutter mobile delivery

## 1. Product decision

Doclyzer helps people keep their blood-test reports, see how individual results change over time, understand what each test measures, and learn about relevant lifestyle factors and questions to discuss with a clinician.

The product must make the journey from a confusing report to an understandable personal history simple. The current consumer experience requires a structural UX redesign, not a cosmetic refresh. Uploading, finding, understanding, and comparing results must become the primary experience. Account administration, credits, referrals, and operational details must become secondary.

Deliver a consumer web UI optimized for mobile interaction and evolve the existing Flutter app for iOS and Android. Both clients must feel like applications through navigation, state preservation, device integration, and performance—not merely through narrow-screen CSS.

Educational content is not diagnosis or treatment. A disclaimer does not substitute for careful handling of missing context, uncertain extraction, units, reference ranges, or unsupported recommendations.

## 2. Evidence and confidence

This assessment is based on source inspection. It is not evidence of production readiness, extraction accuracy, or successful device testing. No completion percentage is assigned because implementation presence does not establish reliability.

Confidence labels used here:

- **[Certain]** Directly observed in the inspected source or explicitly requested by the product owner.
- **[Likely]** Design recommendation or strong inference requiring validation.
- **[Unverified]** Requires runtime testing, user research, or a specific technical investigation.

| Capability | Finding | Evidence |
| --- | --- | --- |
| Report upload and history | [Certain] API supports PDF/image uploads, profile-scoped history, originals, retries, deletion, and restoration. Runtime reliability is unverified. | [Reports controller](../apps/api/src/modules/reports/reports.controller.ts), [reports service](../apps/api/src/modules/reports/reports.service.ts) |
| Structured extraction | [Certain] Parsing paths produce values, units, dates, and structured report metadata. | [Reports module](../apps/api/src/modules/reports/), [report entity](../apps/api/src/database/entities/report.entity.ts) |
| Graphs | [Certain] API trends and Flutter charts exist. Data comparison and presentation need correction. | [Trend service](../apps/api/src/modules/reports/reports.service.ts), [Flutter chart](../apps/mobile/lib/features/reports/screens/trend_chart_screen.dart) |
| Test education | [Certain] No dedicated test-education catalog or explanation service was found in the inspected consumer/report code. | [API modules](../apps/api/src/modules/), [consumer report screens](../apps/mobile/lib/features/reports/screens/) |
| Personalized explanation | [Certain] Reference-range flags and an optional whole-report summary exist; this does not implement the required test-by-test experience. | [Summary service](../apps/api/src/modules/reports/report-summary/report-summary.service.ts) |
| Lifestyle education | [Certain] No structured, sourced lifestyle-education feature was found in inspected code. | Same inspection scope as test education |
| Sharing | [Certain] Share creation, expiry, revocation, and access-history endpoints exist. | [Sharing controller](../apps/api/src/modules/sharing/sharing.controller.ts) |
| Consumer web | [Certain] Existing web pages primarily serve administration and public sharing. User login redirects to `/admin`. | [Landing page](../apps/web/app/pages/index.vue), [login](../apps/web/app/pages/login/index.vue) |
| Mobile | [Certain] Existing consumer app is Flutter and is the mobile delivery surface for this PRD. | [Flutter entry point](../apps/mobile/lib/main.dart), [web dependencies](../apps/web/package.json) |
| Home UX | [Certain] Flutter home primarily lists destinations and account actions rather than a personal results overview. | [Home screen](../apps/mobile/lib/features/auth/screens/home_screen.dart) |

### Specific defects and gaps to resolve

1. Trends group results by exact parameter name and take the first available unit. Different units can be combined without conversion; aliases can split one test into several histories.
2. Trend parsing uses `parseFloat()`, which can misread formatted values such as `1,200`. Qualified results such as `<5` must not silently become exact measurements.
3. Missing sample dates fall back to upload dates without a distinct date-provenance field in trend points.
4. Flutter charts space points by list index rather than elapsed time, visually hiding unequal intervals.
5. The normalized lab-value entity does not store reference ranges; ranges exist in structured report metadata. Reliable observation-level provenance and comparison require a clearer model.
6. No dedicated user correction endpoint/workflow was found for extracted observations. Viewing parsed text is not an adequate verification experience.
7. Consumer web login expects top-level tokens, whereas the controller returns the standard response envelope. It also routes consumers into administration and uses development-oriented success copy.
8. The optional summary service delegates to an external HTTP summarizer. Its presence does not establish a reviewed educational system or that the provider is configured and working.
9. The profile model has date of birth but lacks some potentially relevant interpretation context. Missing context must remain explicit; it must not be inferred from names or unrelated fields.

## 3. Users, jobs, and outcomes

Primary users are people tracking their own blood tests and people organizing reports for family members. A secondary recipient is a clinician viewing a deliberately shared report or history.

| User job | Required outcome |
| --- | --- |
| “Keep this report somewhere I can find it.” | Upload to the correct profile and retrieve the original later. |
| “What does this test mean?” | Find a short, understandable definition directly from the result. |
| “What does my value mean?” | See a supported comparison to the source lab range, with uncertainty and limitations. |
| “Has it changed?” | Compare compatible observations over actual collection dates. |
| “What can I learn or do next?” | Access reviewed lifestyle education and questions for a clinician without receiving an unsupported treatment instruction. |
| “Show my doctor.” | Share an intentional scope with expiry and revocation controls. |

## 4. Scope and non-goals

### Required release scope

- Consumer authentication, session restoration, and account recovery.
- Personal/family profiles with visible ownership throughout the report journey.
- PDF/image upload, extraction progress, uncertainty review, and correction.
- Searchable report history and access to originals.
- Test detail combining current result, range, history, and education.
- Reliable charts with unit/name normalization and date provenance.
- A reviewed initial education catalog; unsupported tests remain viewable with an honest education-unavailable state.
- Sharing and essential account/privacy controls.
- A complete consumer design system and mobile interaction model.
- Browser delivery plus Flutter iOS/Android implementation and device validation.

### Non-goals for this release

- Diagnosis, treatment selection, medication changes, supplement dosing, or guaranteed improvement plans.
- A fabricated overall health score or automatic claims that every out-of-range result is dangerous.
- Autonomous emergency triage based on extracted results.
- A general medical chatbot before the structured experience is reliable.
- Expansion of referrals, promotions, or admin analytics ahead of the core consumer journey.
- A full admin redesign. Preserve working administrative capabilities and isolate consumer navigation from them.
- A forced replacement of the existing Flutter app before the redesigned mobile experience reaches parity.

## 5. UX and information architecture

### Persistent navigation

| Destination | Primary content | Primary action |
| --- | --- | --- |
| Home | Active profile, latest report, results outside the lab range, followed tests, processing/review reminders | Add report |
| Reports | Searchable history grouped by collection date, report status, original files | Add report |
| Trends | Search/select a test, latest comparable result, graph, history list | Open test detail |
| You | Family profiles, sharing management, account, billing, notifications, privacy | Manage the selected setting |

Mobile uses four persistent bottom tabs. Upload is an action, not a fifth empty destination. Desktop adapts the same information architecture to a navigation rail and wider detail layouts. The active profile is visible on Home, Reports, Trends, and upload confirmation.

### Journey A: first report

1. Sign up/sign in using plain-language forms and actionable errors.
2. Create or select a profile with the minimum information necessary to store a report.
3. Choose camera, photos, or a document file through the appropriate platform picker.
4. Confirm the selected profile and file before upload.
5. See upload progress, then processing status. Allow safe navigation away and return.
6. Review extracted collection date, test names, values, units, and ranges alongside the source. Highlight uncertainty without inventing confidence percentages.
7. Save confirmations/corrections and open the report summary.
8. Tap a test to understand it and see its history.

No report: show one clear invitation to add a report and a brief explanation of what happens next. Do not present fabricated personal results. Any optional demonstration must be explicitly labeled as sample data and kept separate from the account.

### Journey B: returning user

Open Home → see the active profile and latest report → open a changed or followed test → inspect its history and explanation. Routine tasks must not require visiting account settings or navigating through a long menu.

### Journey C: test detail

Order information by the user's questions:

1. Test name, understandable expanded name, latest value and unit.
2. Collection date, lab reference range, and a textual comparison state.
3. History chart and accessible observation list.
4. “What this test measures.”
5. “Understanding this result,” including what cannot be concluded.
6. “Lifestyle factors and questions to discuss.”
7. Source report, education sources, and review date.

Use progressive disclosure for longer explanations. Keep raw parsed transcripts, processing attempts, and reassignment under secondary actions. Preserve easy access to the original report.

### Journey D: family profile and sharing

Switch profile → clear/reload profile-dependent state → inspect the intended history → choose what to share → review scope and expiry → invoke native sharing where available. Switching profiles must never briefly display another person's results as if they belong to the newly selected profile.

### Required states

Every primary screen must specify loading, empty, populated, failure, offline, and session-expired behavior. Report flows additionally require uploading, processing, needs-review, ready, duplicate, unsupported-file, parse-failed, and deleted states. Map these product states explicitly to backend states; do not imply a queue or retry capability that has not been implemented.

## 6. Visual and interaction requirements

The following are proposed design requirements, not findings about user preferences:

- Calm, modern presentation with a neutral background, strong typography, and a restrained accent color. Avoid a dense administrative dashboard aesthetic.
- Design tokens for color, spacing, typography, radii, elevation, and motion; shared components for all consumer screens.
- At least 44 × 44 CSS-pixel touch targets, legible body text, and support for enlarged text.
- No horizontal page scrolling at common phone widths. Tables become understandable cards or lists where appropriate.
- Never use color alone to communicate below-range, above-range, within-range, or unknown states.
- Accessible labels, keyboard navigation, visible focus, reduced-motion support, and chart data available as text.
- Keep one dominant action per screen. Use bottom sheets for short choices and full screens for complex editing.
- Preserve tab position, scroll, filters, and safe in-progress input when navigating.
- Respect device safe areas, keyboard overlap, Android back behavior, and iOS navigation conventions.
- Use concise product language: “Add report,” “Your results,” and “Lab reference range.” Avoid “API,” “tokens,” and “parsed transcript” in primary flows.
- Show dates and units clearly. An upward trend is not automatically “better”; a downward trend is not automatically “worse.”

### Design deliverables before broad implementation

Produce an interactive prototype covering onboarding, Home, report list, upload/review, report detail, test detail, profile switching, and sharing. Include real empty/error states and long test names. Review the prototype against the tasks in section 11 before implementing every screen. Visual review alone is insufficient: users must be able to complete the tasks.

## 7. Functional requirements and acceptance criteria

| ID | Requirement | Acceptance criteria |
| --- | --- | --- |
| AUTH-01 | Consumer authentication | Login reads the real API envelope, enters the consumer experience, restores a valid session, handles expiry, and never routes an ordinary user into admin. |
| PROFILE-01 | Profile isolation | API authorization and UI cache isolation prevent cross-user/profile leakage; upload confirms the target profile. |
| REPORT-01 | Upload and recovery | PDF/JPG/PNG flows cover success, duplicate detection, size/type errors, network loss, and parse failure without silently creating duplicate reports on retry. |
| REPORT-02 | Verify extraction | User can inspect and correct values, units, test mapping, dates, and ranges; original extraction and source document remain traceable. Concurrent edits cannot silently overwrite each other. |
| REPORT-03 | History | Users can search reports, identify collection versus upload dates, open originals, and access deletion/restoration without losing context. |
| REPORT-04 | General lab-report ingestion | Parsing is independent of laboratory/vendor and template. Validate digital PDFs, scans and photos across unseen laboratories, reordered/optional columns, quantitative and qualitative results, microscopy, microbiology and multi-page reports. Preserve unsupported content and expose uncertainty; never silently treat partial extraction as complete. One sample report is a regression fixture, not an accuracy acceptance set. |
| DATA-01 | Test identity | Approved aliases resolve to a canonical analyte; Hb and HbA1c never merge; uncertain mappings require review. |
| DATA-02 | Comparable measurements | Only validated, compatible units are converted/combined; original value/unit is preserved. Unknown or incompatible units remain separate with an explanation. |
| DATA-03 | Numeric semantics | Preserve exact numbers, qualifiers, qualitative results, and raw text. Locale-sensitive formatting must be parsed explicitly or flagged for review. |
| DATA-04 | Date semantics | Collection date and upload timestamp are distinct. Unknown collection dates are labeled and excluded from date-based claims until resolved. |
| TREND-01 | Honest graphs | Use actual date spacing and observation provenance. Support zero, one, and multiple observations, same-day observations, differing ranges, and non-chartable values. |
| TREND-02 | Range presentation | Present the range relevant to each observation; do not imply that the newest lab range applied historically. Provide an accessible list and links to source reports. |
| EDU-01 | Test definition | Supported tests have plain-language definitions, sources, content version, and review date. Unsupported tests do not receive fabricated explanations. |
| EDU-02 | Result explanation | Comparison uses a trustworthy source range and compatible units. Missing/ambiguous data produces an explicit unknown state. Range comparison is not presented as a diagnosis. |
| EDU-03 | Lifestyle education | Reviewed content explains relevant general factors and limitations; no automatic prescription, medication change, dosage, or promise of improvement. |
| SHARE-01 | Intentional sharing | User sees the selected scope and expiry before sharing; revoked/expired links stop granting access; private pages are not indexed. |
| UX-01 | Core navigation | Four persistent destinations, visible active profile, predictable back behavior, retained navigation state, and no settings detour for routine report tasks. |
| NATIVE-01 | Mobile integration | Camera/file selection, native sharing, secure session restoration, deep links, lifecycle, keyboard, and back handling work on both target platforms. |
| PRIVACY-01 | Sensitive data handling | No report values/files or session secrets in analytics, error telemetry, or ordinary logs. Logout clears sensitive client state and temporary files according to the defined retention policy. |

## 8. Education model and Hb example

Use a reviewed content catalog as the initial source of educational text. Content should include canonical test identity, aliases, definition, contextual factors, limits of interpretation, general lifestyle education, clinician-discussion prompts, sources, version, and reviewer/review date. Define an accountable qualified reviewer before publishing result-specific educational content.

Keep deterministic comparison separate from explanatory text. If AI is added, constrain it to verified observations and approved content, validate its output, retain provenance, and provide a fallback when unavailable. Do not let AI invent reference ranges or fill missing patient context.

Illustrative presentation—not a universal medical rule:

> **Hemoglobin (Hb): 11 g/dL**  
> Collection date: taken from the confirmed report.  
> Lab reference range: shown exactly as verified from this report.  
> Comparison: “Below this lab's reference range” only if the verified range supports that statement.  
> What it measures: Hemoglobin is a protein in red blood cells that carries oxygen.  
> Understanding your result: A single result does not establish why it is outside the range. Relevant context and other results may be needed.  
> Next: View previous results, read reviewed educational information, or prepare questions for a clinician.

Do not translate this example into “You have iron deficiency” or “Take iron.” Hemoglobin testing alone does not establish the cause of an abnormal result. See [MedlinePlus: Hemoglobin Test](https://medlineplus.gov/lab-tests/hemoglobin-test/), consulted during the source assessment.

## 9. Data and technical direction

### Observation model

Define a normalized observation contract with: report/profile identity, canonical test identity and original test label, raw result, parsed numeric value when valid, comparison qualifier, original and normalized units, source reference range, collection date and date provenance, extraction source, review state, and correction provenance. Preserve source observations when deriving normalized values. Use deterministic fixtures to verify conversion, parsing, and alias rules.

Unknown values are first-class states. A qualitative result must remain visible even if it cannot be plotted. Corrections must invalidate affected summaries, comparisons, and caches. Reprocessing must not silently overwrite confirmed user corrections.

### Report parser generalization

The pipeline must separate document reading, layout/row reconstruction, observation extraction, validation and normalization. Do not encode the sample laboratory's column positions, test names or expected results. Recognize semantic headers and retain raw labels, values, units, reference ranges and page provenance. Ambiguous historical result columns, locale-sensitive numbers, merged cells and unsupported narrative results require fallback or review rather than guessed associations.

Release evaluation must use independently annotated reports from multiple laboratories and reserve unseen templates for validation. Score observation completeness and extra rows separately from value/unit accuracy; also score ranges, dates, patient association and source-page linkage. Include hematology, chemistry, thyroid/hormone, urine/microscopy, microbiology and narrative reports, plus rotated/degraded scans and photographs. Synthetic layout tests supplement this corpus; they do not establish real-world OCR accuracy. The user correction/review workflow in REPORT-02 remains required.

### Application architecture

[Likely] Retain NestJS and PostgreSQL, reuse verified report/profile/sharing APIs, and retain the Nuxt admin/public surfaces. Build a dedicated Vue consumer web client and evolve the existing Flutter consumer app for native delivery. Share API contracts, product requirements, content, and design tokens where practical; do not require a shared UI codebase. The web client's package location and UI component library are implementation decisions to settle in the first milestone.

The Flutter consumer client must use the API directly and must not depend on Nuxt server routes running inside the device. Maintain explicit API contracts and platform adapters for secure storage, file/camera acquisition, sharing, notifications, and lifecycle behavior.

Native session secrets require a reviewed platform-secure storage approach; browser sessions require an explicit cookie/token design and CSRF/XSS considerations. Do not carry the current experimental localStorage implementation into the release by default.

Define allowed origins, HTTPS API endpoints, deep-link behavior, and session expiry before device integration. Bundle required UI assets so the app shell opens without a network request. Initial offline behavior may be an explicit offline state; offline access to personal results is not required until secure storage and retention are designed.

### Migration

- Preserve existing users, profiles, report IDs, originals, and sharing behavior.
- Add/backfill new observation fields without inventing missing data. Unresolved historical observations remain reviewable.
- Evolve Flutter as the supported mobile client throughout delivery; do not introduce a parallel mobile client.
- Keep web and Flutter requirements aligned, while allowing platform-specific implementation where necessary.
- Validate billing, notifications, privacy controls, and account recovery parity before switching existing users. Decide platform-specific payment/push integration before distribution.
- Use additive migrations and a reversible rollout. Do not delete old clients or data as part of the initial redesign.

## 10. Course of action

| Milestone | Work | Exit evidence |
| --- | --- | --- |
| 1. Baseline and UX design | Exercise current auth/upload/history; inventory API contracts and Flutter capabilities; establish anonymized/synthetic report fixtures; prototype core journeys and design system. | Reproducible baseline, agreed contracts, and task-tested prototype including error states. |
| 2. Reliable observations | Implement canonical identity, numeric/qualifier handling, unit compatibility, date provenance, correction history, and honest trends. | Regression fixtures cover edge cases; existing reports remain accessible; incompatible observations cannot silently share a trend. |
| 3. Consumer vertical slice | Implement login/profile selection → upload → review → report history → test detail using the real API and approved visual system. | End-to-end browser flow with real backend responses, no placeholder personal results, and tested profile isolation. |
| 4. Education and usable trends | Publish reviewed initial catalog, contextual range comparison, source links, lifestyle education, and accessible charts. | Every supported test has reviewed content; unknown/unsupported data fails honestly; reviewer signs off content. |
| 5. Native delivery | Implement the redesigned consumer experience in Flutter; integrate secure session handling, file/camera acquisition, sharing, lifecycle, notifications, and device navigation. | Core flows pass on iOS and Android, including offline startup and interrupted uploads. |
| 6. Migration and release | Validate feature parity, accessibility, usability, performance, telemetry, and staged rollout/rollback. | Release checklist satisfied; existing-user migration exercised; no unresolved critical data, privacy, or journey defects. |

Milestone 1 prototype work and baseline investigation can proceed together. Production graph/explanation work must depend on the corrected data contract. Cosmetic changes alone do not satisfy any milestone.

## 11. Validation and release gates

### Usability targets

These are proposed targets, not measured current performance. Run a formative test with at least five representative users, including a family-profile user and a person unfamiliar with lab terminology.

- At least four of five can find their latest report and open an explanation for a named test without coaching.
- At least four of five can add a report to the intended profile and understand whether it is processing, awaiting review, or ready.
- At least four of five can compare two results and identify their units and dates without misreading an unknown range as normal.
- At least four of five can share the intended scope and later revoke access.
- No participant should mistake sample data for personal results or an educational explanation for a confirmed diagnosis; any such observation triggers copy/interaction revision.

### Engineering and content gates

- Automated coverage for login response envelopes, profile authorization, aliases, incompatible units, formatted/qualified numbers, missing dates/ranges, corrections, and share revocation.
- Golden extraction fixtures for representative supported report formats, with expected values and uncertainty states. Record measured accuracy; do not advertise unsupported accuracy percentages.
- End-to-end core journey tests against the API, including failures and session expiry.
- Manual device checks for camera permissions, file picker cancellation, keyboard, safe areas, back navigation, large text, slow network, interruption, and restart.
- No horizontal page overflow at 320, 375, and 430 CSS-pixel widths; desktop layouts remain usable.
- Proposed performance budget: on an agreed mid-range device, locally bundled shell visible within two seconds of cold launch; show progress promptly for network/processing work. Record device/network conditions and measured results.
- Accessible chart alternatives and text labels; verify primary flows with a screen reader and keyboard.
- Education sources/review dates present; qualified content review complete before publishing supported explanations.
- Existing account/report data preserved; migration rollback exercised; critical privacy and authorization defects resolved.

Track report-upload completion, review completion, time to first usable report, ability to retrieve a result, and usability task success. Analytics must use approved non-sensitive events and must not contain test names, results, report contents, or personal health context.

## 12. Decisions to resolve during milestone 1

These decisions do not block documenting or prototyping the core journeys:

- Initial release platforms and distribution sequence: browser, Android, and iOS prioritization.
- Initial education catalog and supported report formats, selected from representative user reports rather than assumptions.
- Named content reviewer, review cadence, and process for withdrawing outdated content.
- Consumer package location and component framework; validate navigation and accessibility before committing.
- Optional profile context needed for education, with purpose and consent defined; avoid unnecessary data collection.
- Whether secure offline report access belongs in a later release.
- Existing billing/push parity and distribution requirements for the replacement client.

## 13. Definition of done

A user can upload a blood-test report to the correct profile, verify uncertain extraction, find it later, view comparable results over time, and understand a supported test through reviewed educational content. The consumer web UI and tested Flutter iOS/Android builds provide the same core journey with appropriate platform-native interactions. Unknown data stays explicit, existing records remain intact, and the core journey passes usability testing.

Delivering attractive screenshots, an admin-style dashboard, an unverified AI summary, or a web page placed inside a native shell does not meet this definition.
