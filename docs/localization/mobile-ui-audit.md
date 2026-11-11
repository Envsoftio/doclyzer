# Mobile UI localization audit

The static direct-widget scan currently finds **0** uncataloged literals. It excludes the Doclyzer brand, email/date format examples, and interpolated strings. A manual pass also moved visible conditional labels, error states, onboarding copy, report status badges, medical range explanations, billing history labels, support-form headings, and relative-date words into ARB messages. The result is recorded in `mobile-ui-audit.json`.

This is source coverage, not proof of native-language quality. The 672 new English keys have draft translations in all ten non-English ARBs and are marked `draft_needs_native_review` in `mobile-ui-draft-review.json`; each matching ARB metadata description also states that review is required. Clinical, sharing, deletion, and billing copy needs priority review before release.

Server-provided free text can still appear in the language supplied by the server: report names, lab data, plan names, incident/restriction explanations, support diagnostics, and unknown response messages. The client now shows localized fallback errors for unknown API failures, while raw diagnostics are retained for support. Source reports and user-entered content are never translated by the UI catalog. The audit does not establish live-device or every-state visual coverage.
