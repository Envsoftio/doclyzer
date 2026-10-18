# Observation identity and unit rules

The parser accepts any laboratory test label. It keeps the original label, result, unit, and date even when there is no approved mapping. An unknown label remains its own exact-label trend series and is marked `needs_review`; the system never guesses that two different names mean the same test.

Newly extracted observations can also carry `identityEvidence`: the report lab name, section heading, explicit specimen, method, printed test code, and source table row text when available. These are source claims for future terminology matching, not verified canonical identities. Missing details stay absent. Existing observations have no backfilled identity evidence; the original report remains available for review.

Approved mappings live in `lab_tests`, `lab_test_aliases`, and `lab_unit_rules`. These tables start empty. Add rules only after checking representative source reports and recording an accountable reviewer in `approved_by`. Normalize alias keys by trimming, collapsing internal spaces, and lowercasing. Normalize source unit keys by trimming, removing spaces, and lowercasing. Each alias has one canonical test. A unit rule applies only to that canonical test; `decimal_exponent` is an exact power-of-ten conversion to `target_unit`. Unsupported conversions stay separate.

At read time, aliases that collide after normalization but point to different tests are excluded and their observations require review. There are no built-in test names or special-case identity rules in production. The approval process is the trust boundary: assigning two different analytes to the same canonical test will merge their histories. Reviewers must check analyte meaning before approving an alias, and correct mistaken rules before refreshing stored observations.

Example approval transaction, with placeholders to replace after review:

```sql
BEGIN;
INSERT INTO lab_tests (id, display_name, approved_by)
VALUES ('reviewed-test-id', 'Reviewed test name', 'reviewer identity');
INSERT INTO lab_test_aliases (alias_key, canonical_test_id, approved_by)
VALUES ('observed label', 'reviewed-test-id', 'reviewer identity');
INSERT INTO lab_unit_rules (canonical_test_id, source_unit_key, target_unit, decimal_exponent, approved_by)
VALUES ('reviewed-test-id', 'source-unit', 'target-unit', 0, 'reviewer identity');
COMMIT;
```

Add another alias only after verifying it has the same analyte meaning. Add a conversion only after verifying dimensional compatibility; `0` means the source and target units are equivalent. Trend reads use current approved rules immediately. To update persisted canonical and normalized fields on older observations, first run `npm run observations:refresh` for an aggregate dry run, then `npm run observations:refresh -- --apply` from `apps/api`. This preserves original fields and correction history.
