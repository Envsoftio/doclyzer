# User language and report descriptions

Supported languages are English (`en`), Hindi (`hi`), Kannada (`kn`), Telugu
(`te`), Malayalam (`ml`), Tamil (`ta`), Bengali (`bn`), Odia (`or`), Gujarati
(`gu`), Marathi (`mr`), and Punjabi in Gurmukhi script (`pa`). Signup and
account settings persist `users.preferred_language`. Mobile and consumer web
restore this preference after login. The description language control is local
to that description; it does not change the account preference.

Core consumer navigation, signup/login, account, upload, report list/detail, and
insight labels use catalogs. Admin, marketing, legal, and some secondary screens
and server-provided error messages remain English. Uploaded reports, names,
clinical test names, units, and original extracted values are not translated.

## Deployment

Run the normal database migrations before starting the updated API:

```sh
cd apps/api
npm run migration:run
```

Migration `1730819500000` adds the preference and narrative translation table.
Migration `1730819600000` extends the constraints for the eight additional
languages. Its rollback refuses to discard new-language preferences or cached
translations; migrate that data explicitly before rolling back.
Migration `1730819700000` adds Punjabi preferences and cached translations, with the same non-lossy rollback guard.
Existing users default to English. Translation uses the existing report narrative
model, API key, base URL, and token-price configuration. Consumer web remains
behind its existing feature flag.

## Descriptions and caching

`POST /v1/reports/:id/summary/language` takes `{ "locale": "hi" }`.
`POST /v1/reports/:id/results/insight` accepts `locale` alongside the existing
result selector. Omitting `locale` uses the account preference. Only the eleven codes above are accepted. Ownership is checked before translation or cache lookup.

English summaries and insights remain canonical. Each selected language is translated from that
saved prose, with instructions to preserve negation, uncertainty, comparisons,
and limitations. The service masks clinical names, units, numbers, and ranges,
then validates the protected tokens before restoring their exact text. Invalid
responses are not saved as successful translations. The requested Unicode script
is checked per segment, then a separate model call compares every translated
segment against its English source for faithfulness, actual language, and
patient-friendly wording. Any rejected, incomplete, malformed, or unavailable
review prevents a successful cache write. Hindi and Marathi share a script;
script validation alone cannot distinguish them.

Both calls currently use the configured narrative model. Their errors can be
correlated. Neither the script checks nor the automated review establish medical
or linguistic accuracy. Native clinical review remains pending for all languages
and is required before claiming clinical validation. The user has chosen plain,
patient-friendly terminology and will arrange that review later.

PostgreSQL stores successful translations by report, language, narrative kind,
source text, clinical results revision, and translation version. Switching back
to an unchanged description reuses the saved response. The first successful translation requires generation plus review (two provider
calls); subsequent unchanged reads require neither. A durable lease and an
in-process request map avoid duplicate concurrent generation. Failed attempts
can be retried; corrected results or changed source prose create a new cache
entry. Deleted reports cascade-delete translations. Translation charges appear
as a separate workload in usage analytics.

The clients display loading/retry states and let users select English when translation
is unavailable. They discard stale responses after a language/source change.

## Maintaining languages

- Web catalogs: `apps/web/i18n/locales/*.json`.
- Mobile catalogs: `apps/mobile/lib/l10n/app_*.arb`; run `flutter gen-l10n` after edits.
- Bundled Noto fonts for all nine scripts and their OFL licenses are included
  in both clients. Additional font provenance is in `localization/font-sources.json`.
  Web font Unicode ranges avoid downloading every script for one language.
- To change translation behavior for already cached text, increment
  `TRANSLATION_VERSION` in `narrative-translation.service.ts`.
- Adding another language also requires extending server validation/database
  constraints, client selectors, fonts, and translation instructions/validation.

## Verification

`npm run reports:language-test` checks validation, clinical literal protection,
cache reuse, source invalidation, concurrency, and retry behavior with synthetic
provider responses. `npm run reports:language-postgres-test` exercises the actual
migration/cache SQL in connection-local temporary PostgreSQL tables. Mobile
`test/language_support_test.dart` checks preference requests, narrow layouts with
enlarged text in all eleven languages, with real bundled fonts, switching while loading, source changes, and retry states.
These deterministic tests do not call a live model or certify translation semantics.
Run `node scripts/check-locales.mjs` from the repository root to validate registry
and catalog parity, placeholder multiplicity, numeric literals, plural branches,
and scripts. `python3 scripts/check-locale-fonts.py` checks the bundled fonts
cover every catalog letter and combining mark.

An opt-in live provider check uses only synthetic passages:

```sh
cd apps/api
RUN_LANGUAGE_LIVE_EVAL=1 npx ts-node scripts/narrative-language-live-eval.ts
```

It incurs provider charges and writes `docs/localization/narrative-review-fixtures.json`.
The saved passages cover comparisons, negation, diagnostic uncertainty, and
limitations. They are review fixtures, not patient records or proof of accuracy.
A fresh service instance must reuse each accepted cached result without another
provider call. UI catalogs for the added languages also received a separate
automated comparison/correction pass against the English strings. Versioned
catalog hashes and review counts are recorded in `localization/catalog-review.json`. Punjabi synthetic report checks are saved separately in `localization/punjabi-narrative-review-fixtures.json`.

## Native clinical review before release

For each language, have a native-speaking clinician review the saved fixtures
and representative complete report summaries and result insights. Include below,
within, above, positive/negative, missing units/ranges, and contradictory-data
cases. Check negation, possibility versus diagnosis, assignment of numbers to
tests, comparison direction, urgency, and natural patient-friendly terminology.
Record the reviewer, locale, approved text/version, corrections, and date. Model
or prompt changes should trigger re-evaluation. A passing automated check must
never be labeled “clinically reviewed” or “perfect”.
