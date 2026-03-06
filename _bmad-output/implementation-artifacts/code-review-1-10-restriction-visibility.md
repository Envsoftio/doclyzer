# Code Review: Story 1.10 — Restriction Visibility, Rationale, and User Next Steps

**Story file:** `_bmad-output/implementation-artifacts/1-10-restriction-visibility-rationale-and-user-next-steps.md`  
**Story key:** 1-10-restriction-visibility-rationale-and-user-next-steps  
**Review date:** 2026-03-06  

---

## Git vs Story Discrepancies

- **Story File List:** 11 files (all account/restriction-related + home_screen, main, restriction_test).
- **Git modified/untracked:** All 11 files appear in git (modified or untracked). No file is listed in the story but missing from git.
- **Files changed in git but not in story File List:** `apps/api/src/modules/account/account.dto.ts` is modified in git; the diff is from other stories (data export, closure, communication preferences DTOs), not from 1-10. **No discrepancy** for 1-10.  
- **Sprint-status.yaml** was updated (story → review) but is not listed in the story File List; common to omit meta/tracking files. **1 minor documentation gap.**

---

## Issues Found

### HIGH (must fix)

1. **AC4 / Dev Notes not fully met — restriction banner missing on Account screen**  
   - **Requirement:** Dev Notes say: *"Minimum: show the restriction banner on **home and account** so the user always sees status, rationale, and next steps when restricted."*  
   - **Reality:** The banner is implemented only on `HomeScreen`. `AccountProfileScreen` does not fetch or display restriction status; a restricted user on the Account screen never sees the banner, rationale, or next steps.  
   - **Location:** `apps/mobile/lib/features/account/screens/account_profile_screen.dart` — no restriction repository, no banner.  
   - **Fix:** Add restriction status fetch and the same banner (or a shared widget) to AccountProfileScreen; inject `RestrictionRepository` and show banner when `isRestricted: true` with rationale and next steps.

---

### MEDIUM (should fix)

2. **No runtime guarantee that restricted responses include rationale and nextSteps**  
   - **Requirement:** Task says *"When restricted, all of rationale and nextSteps must be present; restrictedActions optional."* AC2 requires at least `rationale` and `nextSteps` when `isRestricted: true`.  
   - **Reality:** `getRestrictionStatus()` returns whatever is in `restrictionStore`. If an entry is written with missing or empty `rationale`/`nextSteps` (Epic 5 bug or misuse), the API can return `isRestricted: true` with `rationale`/`nextSteps` undefined or empty, violating AC2.  
   - **Location:** `apps/api/src/modules/account/account.service.ts` — `getRestrictionStatus()`.  
   - **Fix:** When an entry exists, validate that `rationale` and `nextSteps` are non-empty strings; otherwise return `{ isRestricted: false }` or treat as invalid and don’t expose a half-filled restricted state.

3. **E2E does not cover restricted-user response**  
   - **Reality:** E2E only covers: (1) valid token → 200 and `isRestricted: false`, (2) no token → 401. There is no e2e that seeds a restricted user (e.g. via app.get(AccountService) and seeding the store, or a test-only API) and asserts 200 with `isRestricted: true`, `rationale`, and `nextSteps`.  
   - **Location:** `apps/api/test/app.e2e-spec.ts` — `describe('Restriction Status')`.  
   - **Fix:** Add an e2e test that obtains a valid token, seeds the restriction store for that user (via `AccountService` from the app), calls `GET /account/restriction-status`, and asserts `data.isRestricted === true`, `data.rationale`, and `data.nextSteps` are present.

---

### LOW (nice to fix)

4. **Unit tests couple to private implementation**  
   - **Reality:** `account.service.spec.ts` mutates the private `restrictionStore` via `(service as unknown as { restrictionStore: ... }).restrictionStore`. This breaks if the property is renamed or refactored.  
   - **Location:** `apps/api/src/modules/account/account.service.spec.ts` (e.g. lines 259, 274).  
   - **Suggestion:** Prefer a test-only or package-visible way to seed the store (e.g. a package-private setter used only in tests), or document the coupling and accept the risk.

5. **File List omits sprint-status.yaml**  
   - **Reality:** The story status and `sprint-status.yaml` were updated as part of the workflow; the story File List does not mention `_bmad-output/implementation-artifacts/sprint-status.yaml`.  
   - **Suggestion:** Add it to the File List for transparency, or explicitly note in Dev Agent Record that sprint-status is updated by workflow and not listed as a “source code” change.

6. **No loading or error handling for restriction status on HomeScreen**  
   - **Reality:** Until `getStatus()` completes, `_restrictionStatus` is null so the UI shows “not restricted”. If `getStatus()` throws, the error is unhandled and the user never sees a banner or error.  
   - **Location:** `apps/mobile/lib/features/auth/screens/home_screen.dart` — `_loadRestrictionStatus()`.  
   - **Suggestion:** Optionally show a loading state and/or set error state on failure so the user sees feedback (e.g. “Unable to load restriction status” or retry).

---

## Summary

| Severity | Count |
|----------|--------|
| HIGH     | 1      |
| MEDIUM   | 2      |
| LOW      | 3      |

**Total:** 6 specific issues.  
**AC/task compliance:** One AC/Dev Notes gap (banner on Account screen). All tasks marked [x] are implemented; the only functional shortfall is the missing banner on the Account surface.
