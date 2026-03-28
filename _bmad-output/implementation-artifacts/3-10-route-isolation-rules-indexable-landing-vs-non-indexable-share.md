# Story 3.10: Route Isolation Rules (Indexable Landing vs Non-Indexable Share)

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a platform owner,
I want route policy isolation enforced at the infrastructure level,
so that landing pages are indexable by search engines while share pages remain private and non-indexable.

## Acceptance Criteria

1. **Given** the `robots.txt` file is served, **When** a crawler reads it, **Then** the `/share/` path is explicitly disallowed with `Disallow: /share/` in addition to the existing blanket allow for landing routes.
2. **Given** any page under `/share/*` is rendered, **When** the HTML `<head>` is inspected, **Then** a `<meta name="robots" content="noindex, nofollow">` tag is present (existing behaviour — no regression).
3. **Given** a Nuxt route middleware is applied, **When** any request hits a `/share/*` route, **Then** the `X-Robots-Tag: noindex, nofollow` HTTP header is set on the response so that crawlers respect the directive even before parsing HTML.
4. **Given** the landing page (`/`) or any future landing route is rendered, **When** the HTML `<head>` is inspected, **Then** no `noindex` meta tag is present and the page remains fully indexable.
5. **Given** the `sitemap.xml` file is served, **When** a crawler reads it, **Then** no `/share/*` URLs are listed (existing behaviour — static sitemap only lists landing URLs; verify no regression).
6. **Given** both route policies are active, **When** a search engine processes the site, **Then** triple-layer protection is enforced for share routes: `robots.txt` `Disallow`, page-level `noindex` meta, and `X-Robots-Tag` HTTP header — while landing routes remain fully indexable with none of these restrictions.

## Tasks / Subtasks

- [x] Task 1: Update `public/robots.txt` to add `Disallow: /share/` (AC: #1)
  - [x] Add `Disallow: /share/` line under existing `User-Agent: *` block
  - [x] Keep existing `Sitemap:` directive unchanged

- [x] Task 2: Create Nuxt server middleware to set `X-Robots-Tag` header on share routes (AC: #3)
  - [x] Create `server/middleware/share-robots-header.ts`
  - [x] Intercept requests where URL path starts with `/share/`
  - [x] Set `X-Robots-Tag: noindex, nofollow` response header on matching requests
  - [x] Do NOT set this header on non-share routes

- [x] Task 3: Verify existing page-level meta tag protections (AC: #2, #4, #5)
  - [x] Confirm `app/pages/share/[token].vue` still has `useHead({ meta: [{ name: 'robots', content: 'noindex, nofollow' }] })`
  - [x] Confirm `app/pages/index.vue` has NO `noindex` meta tag
  - [x] Confirm `public/sitemap.xml` contains only landing URLs (no `/share/` entries)

## Dev Notes

### Current State of Route Isolation

The web app (`apps/web/`) currently has two page routes:
- `app/pages/index.vue` — landing page with full SEO head (indexable)
- `app/pages/share/[token].vue` — share viewer with `noindex, nofollow` meta (line 33-34)

Current `robots.txt` has a blanket allow (`Disallow:` with empty value = allow all). Story 3.9 established SEO foundations. This story adds infrastructure-level enforcement.

### Why Triple-Layer Protection

1. **`robots.txt` Disallow** — first line of defence; well-behaved crawlers check this before fetching. Prevents unnecessary crawl budget waste on share URLs.
2. **Page-level `<meta name="robots">` noindex** — already exists in `[token].vue`; catches crawlers that ignore robots.txt or find share URLs via external links.
3. **`X-Robots-Tag` HTTP header** — catches crawlers that process headers before parsing HTML; provides defence-in-depth for any non-HTML responses from share routes.

### `public/robots.txt` — Target Content

```
User-Agent: *
Disallow: /share/

Sitemap: https://doclyzer.com/sitemap.xml
```

Change: replace empty `Disallow:` with `Disallow: /share/`. This means all routes are allowed EXCEPT `/share/*`. The landing page `/` and any future public pages remain fully crawlable.

### Server Middleware — `server/middleware/share-robots-header.ts`

Nuxt 4 server middleware runs on every request. Use `defineEventHandler` from h3:

```typescript
// server/middleware/share-robots-header.ts
export default defineEventHandler((event) => {
  if (getRequestURL(event).pathname.startsWith('/share/')) {
    setResponseHeader(event, 'X-Robots-Tag', 'noindex, nofollow')
  }
})
```

Key points:
- Place in `apps/web/server/middleware/` — Nuxt auto-registers all files in this directory as server middleware
- Use `getRequestURL` from h3 (auto-imported in Nuxt server context) to get the URL
- Use `setResponseHeader` from h3 to set the header
- Do NOT use `defineNuxtRouteMiddleware` — that is client-side middleware, not server-side
- Do NOT use `setHeader` — use `setResponseHeader` which is the h3 API
- This middleware runs for ALL requests but only sets the header on `/share/` paths
- No npm packages needed — h3 utilities are built into Nuxt

### Architecture Compliance

- **ADR-S3-02:** "metadata, social tags, sitemap/robots, canonical strategy, structured data are mandatory" — Story 3.9 fulfilled the creation; this story enforces isolation rules.
- **Architecture:** "Landing routes are indexable; share routes are non-indexable by default" — this story enforces that policy at three layers.
- **Architecture:** "Nuxt route partitioning: strict landing vs share route groups" — the robots.txt and middleware enforce this partition at infrastructure level.
- **Architecture:** "Route-level trust boundaries are mandatory" — the X-Robots-Tag header enforces a trust boundary between landing and share routes.

### Project Structure Notes

Files to create/modify:
- `apps/web/public/robots.txt` — UPDATE: add `Disallow: /share/`
- `apps/web/server/middleware/share-robots-header.ts` — NEW: X-Robots-Tag middleware

No changes needed to:
- `apps/web/app/pages/share/[token].vue` — already has `noindex` meta (verify only)
- `apps/web/app/pages/index.vue` — already indexable (verify only)
- `apps/web/public/sitemap.xml` — already has only landing URLs (verify only)
- `apps/web/nuxt.config.ts` — no config changes required

No new npm packages required. All utilities (`getRequestURL`, `setResponseHeader`, `defineEventHandler`) are built into Nuxt via h3.

No API calls, no authentication, no backend (NestJS) changes, no Flutter changes.

### Previous Story Intelligence (3.9)

Story 3.9 established:
- `useSeoMeta()` + `useHead()` pattern for SEO tags in `index.vue`
- Static `sitemap.xml` approach (no Nuxt module)
- `robots.txt` with `Sitemap:` directive
- Confirmed share page `noindex` meta is at line 33-34 of `[token].vue`
- Agent model: claude-sonnet-4-6

Key learning: No Nuxt modules needed — built-in composables and h3 utilities are sufficient.

### References

- [Source: _bmad-output/planning-artifacts/architecture.md — ADR-S3-02 Landing SEO Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md — "Landing routes are indexable; share routes non-indexable"]
- [Source: _bmad-output/planning-artifacts/architecture.md — "Route-level trust boundaries are mandatory"]
- [Source: apps/web/public/robots.txt — current content]
- [Source: apps/web/app/pages/share/[token].vue:33-34 — existing noindex meta]
- [Source: apps/web/app/pages/index.vue — existing landing page with SEO head]
- [Source: apps/web/nuxt.config.ts — current config]
- [Source: _bmad-output/implementation-artifacts/3-9-landing-seo-mvp-*.md — previous story context]
- Google robots.txt spec: https://developers.google.com/search/docs/crawling-indexing/robots/create-robots-txt
- X-Robots-Tag spec: https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag#xrobotstag
- Nuxt server middleware: https://nuxt.com/docs/guide/directory-structure/server#server-middleware

## Dev Agent Record

### Agent Model Used

claude-opus-4-6

### Debug Log References

None — clean implementation, no issues encountered.

### Completion Notes List

- Task 1: Updated `robots.txt` — replaced empty `Disallow:` with `Disallow: /share/` to block crawlers from share routes. `Sitemap:` directive preserved unchanged.
- Task 2: Created `server/middleware/share-robots-header.ts` — Nuxt server middleware using h3 `defineEventHandler`, `getRequestURL`, and `setResponseHeader` to set `X-Robots-Tag: noindex, nofollow` on all `/share/*` requests. Non-share routes are unaffected.
- Task 3: Verified existing protections — `[token].vue:33-34` has `noindex, nofollow` meta, `index.vue` has no `noindex` tag, `sitemap.xml` lists only landing URL `/`. No regressions.
- All 6 ACs satisfied: triple-layer protection (robots.txt Disallow + page-level meta + X-Robots-Tag header) enforced for share routes; landing routes remain fully indexable.

### Change Log

- 2026-03-23: Implemented route isolation rules — robots.txt Disallow for /share/, X-Robots-Tag server middleware, verified existing meta protections. All ACs met.

### File List

- `apps/web/public/robots.txt` — MODIFIED: added `Disallow: /share/`
- `apps/web/server/middleware/share-robots-header.ts` — NEW: X-Robots-Tag header middleware
