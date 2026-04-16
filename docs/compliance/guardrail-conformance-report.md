# Guardrail Conformance Report

Generated: 2026-04-16T11:11:23.098Z
Overall: **PASS**

## Check Results

| # | Check | Status | Evidence |
|---|-------|--------|----------|
| 1 | AI Disclaimer — Web component | ✅ PASS | `apps/web/app/components/AiDisclaimerNote.vue` |
| 2 | AI Disclaimer — Mobile widget | ✅ PASS | `apps/mobile/lib/shared/ai_disclaimer_note.dart` |
| 3 | PHI Telemetry static scan script | ✅ PASS | `apps/api/scripts/phi-telemetry-check.ts` |
| 4 | PHI Telemetry CI job (phi-telemetry-check) | ✅ PASS | `.github/workflows/ci.yml → phi-telemetry-check` |
| 5 | Security Policy static scan script | ✅ PASS | `apps/api/scripts/security-policy-check.ts` |
| 6 | Security Policy CI job (security-policy-check) | ✅ PASS | `.github/workflows/ci.yml → security-policy-check` |
| 7 | Migration Check CI job (migration-check) | ✅ PASS | `.github/workflows/ci.yml → migration-check` |
| 8 | SEO Quality CI job (seo-quality-check) | ✅ PASS | `.github/workflows/ci.yml → seo-quality-check` |
| 9 | PHI Governance CI job (phi-governance-gate) | ✅ PASS | `.github/workflows/ci.yml → phi-governance-gate` |

## Guardrail Coverage

- **Epic 7.1 — AI Disclaimer Enforcement:** Checks 1–2
- **Epic 7.2 — PHI-Safe Telemetry:** Checks 3–4, 9
- **Epic 7.3 — CI Compliance Gates:** Checks 5–8
