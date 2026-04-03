# Story 7.1: AI informational-only disclaimer enforcement across surfaces

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a platform owner,
I want AI disclaimers enforced wherever AI-derived output appears,
so that safety framing is consistent.

## Acceptance Criteria

1. **Given** AI-derived content is rendered on any surface (mobile app or web share)
   **When** the surface loads
   **Then** an informational-only disclaimer is visible and non-optional.
2. **Given** a report summary is displayed on mobile
   **When** the summary is visible
   **Then** the disclaimer appears immediately adjacent to the summary block.
3. **Given** a report summary is displayed on the web share page
   **When** the share page renders
   **Then** the disclaimer is visible in the same view as the summary content and is not dismissible.
4. **Given** AI-derived content is not present (e.g., no summary)
   **When** the surface loads
   **Then** no AI disclaimer is shown to avoid confusing users.
5. **Given** the disclaimer is visible on any surface
   **When** assistive technology is used
   **Then** the disclaimer text is accessible to screen readers and meets WCAG 2.1 AA readability expectations.

## Tasks / Subtasks

- [x] Inventory AI-derived output surfaces and confirm where summaries or AI content are rendered today (AC: 1)
- [x] Centralize the disclaimer copy to avoid drift between surfaces (AC: 1)
- [x] Mobile: ensure disclaimer is consistently rendered next to AI summary blocks and health-history AI surfaces (AC: 2)
- [x] Web: add a non-dismissible disclaimer to the share page when summaries are present (AC: 3)
- [x] Ensure disclaimer is not shown when AI content is absent (AC: 4)
- [x] Accessibility pass: confirm semantic exposure for screen readers and readable contrast on both mobile and web (AC: 5)

## Dev Notes

- **Existing AI-derived output surfaces (current code):**
  - Mobile report summary: `apps/mobile/lib/features/reports/screens/report_detail_screen.dart`
  - Mobile health history disclaimer already present: `apps/mobile/lib/features/reports/screens/health_history_screen.dart`
  - Web share page renders report summaries with no disclaimer today: `apps/web/app/pages/share/[token].vue`
- **Expected disclaimer copy (consistent across surfaces):**
  - “Informational only — not medical advice. Discuss with your doctor.”
- **Do not add new API fields** for disclaimers; enforce at UI layer only.
- **No PHI in logs or analytics** (already required by project context).
- **Testing policy:** Skip all tests for this story (per project testing policy).

### Project Structure Notes

- Mobile shared UI can live under `apps/mobile/lib/shared/` (consider a small widget like `AiDisclaimerNote` to avoid copy drift).
- Web shared UI can live under `apps/web/app/components/` (create a small `AiDisclaimerNote.vue` if reuse is needed beyond share page).
- Keep Flutter UI Material 3 conventions and the existing text style/spacing patterns in report detail and health history screens.
- In Nuxt, `useHead` already manages meta tags; keep share page semantics minimal and accessible.

### References

- Epic 7 story definition in `/_bmad-output/planning-artifacts/epics.md` (Epic 7 → Story 7.1)
- AI disclaimer UX rules in `/_bmad-output/planning-artifacts/ux-design-specification.md` (AI surfaces: summaries, insights, lifestyle suggestions)
- Accessibility and PHI-safe requirements in `/_bmad-output/planning-artifacts/prd.md`
- Architecture rules and project structure in `/_bmad-output/planning-artifacts/architecture.md`
- Project implementation rules in `/_bmad-output/project-context.md`

## Developer Context

### Technical Requirements

- **Flutter:** Ensure disclaimers are visible near AI summary blocks; use Material 3 text styles and accessible semantics.
- **Nuxt (share page):** Render a disclaimer block when any `report.summary` is present; keep it in the same scroll context as the summary section.
- **Consistency:** Centralize disclaimer copy to avoid drift and guarantee same text across surfaces.
- **No analytics leakage:** Never emit summary content in logs or analytics events.

### Architecture Compliance

- Maintain route isolation and non-indexable share page behavior.
- Keep PHI out of telemetry, logs, and analytics payloads.
- Preserve standardized response envelope and do not change API contracts.

### Library / Framework Requirements

- Use Flutter’s accessibility guidance for semantics and readable UI.
- In Nuxt, use `useHead` for page metadata and keep accessibility semantics in the template.
- Ensure disclaimer readability aligns with WCAG 2.1 AA guidance on accessible content presentation.

### File Structure Requirements

- Mobile:
  - `apps/mobile/lib/features/reports/screens/report_detail_screen.dart`
  - `apps/mobile/lib/features/reports/screens/health_history_screen.dart`
  - Optional shared widget in `apps/mobile/lib/shared/`
- Web:
  - `apps/web/app/pages/share/[token].vue`
  - Optional shared component in `apps/web/app/components/`

### Testing Requirements

- **Skip all tests** for this story (per `Dev Agent Testing Policy`).
- No new test files or spec updates.

## Latest Tech Information

- Flutter accessibility guidance emphasizes using proper semantics for screen reader support and accessible UI in Flutter apps.
  Source: https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
- Nuxt `useHead` supports setting meta tags and head content for pages (including robots meta for share pages).
  Source: https://dev.nuxt.com/docs/4.x/api/composables/use-head
- WCAG 2.1 defines conformance levels (A/AA/AAA); Level AA is the common target for accessible web content.
  Source: https://www.w3.org/2018/06/pressrelease-wcag21

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Implementation Plan

- Confirm current AI-summary and health-history surfaces on mobile and share page.
- Centralize disclaimer copy into shared UI components for mobile and web.
- Render disclaimers only when AI content is present and keep semantics accessible.

### Debug Log References

- Source discovery: `/_bmad-output/planning-artifacts/epics.md`, `architecture.md`, `prd.md`, `ux-design-specification.md`
- Code scan: `apps/mobile` and `apps/web` surfaces for summaries/disclaimers

### Completion Notes List

- Centralized disclaimer copy into `AiDisclaimerNote` on mobile and web.
- Mobile: summary disclaimers now use the shared widget; health history shows the disclaimer only when AI-derived trend data exists.
- Web: share page renders a non-dismissible disclaimer alongside report summaries.
- Accessibility preserved via semantic text and readable contrast; no PHI logged.
- Tests skipped per Dev Agent Testing Policy.

### File List

- `apps/mobile/lib/shared/ai_disclaimer_note.dart`
- `apps/mobile/lib/features/reports/screens/report_detail_screen.dart`
- `apps/mobile/lib/features/reports/screens/health_history_screen.dart`
- `apps/web/app/components/AiDisclaimerNote.vue`
- `apps/web/app/pages/share/[token].vue`
- `/_bmad-output/implementation-artifacts/sprint-status.yaml`
- `/_bmad-output/implementation-artifacts/7-1-ai-informational-only-disclaimer-enforcement-across-surfaces.md`

### Change Log

- 2026-04-03: Enforced AI informational-only disclaimers across mobile summaries, health history, and web share summary views with centralized copy.
