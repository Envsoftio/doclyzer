# Story 3.9: Landing SEO MVP (Metadata, Canonical, Sitemap/Robots, Structured Data)

Status: review

## Story

As a prospective user,
I want SEO-ready landing pages,
So that discovery and value communication improve.

## Acceptance Criteria

1. **Given** the landing root route (`/`) is public, **When** a search engine crawler visits it, **Then** the page includes a valid `<title>`, `<meta name="description">`, Open Graph tags (`og:title`, `og:description`, `og:url`, `og:type`, `og:image`), and Twitter Card tags (`twitter:card`, `twitter:title`, `twitter:description`).
2. **Given** the landing page is rendered, **When** a crawler reads the `<head>`, **Then** a `<link rel="canonical">` tag is present pointing to the canonical URL of that route (e.g. `https://doclyzer.com/`).
3. **Given** the site is deployed, **When** a crawler fetches `/sitemap.xml`, **Then** a valid XML sitemap is returned listing at minimum the landing root URL, with correct `<lastmod>` and `<changefreq>` values.
4. **Given** the site is deployed, **When** a crawler fetches `/robots.txt`, **Then** the file allows all landing routes and includes a `Sitemap:` directive pointing to the sitemap URL.
5. **Given** the landing page is rendered, **When** a search engine reads structured data, **Then** a valid JSON-LD block is present using `WebSite` or `WebApplication` schema (schema.org) with at minimum `name`, `url`, and `description` properties.
6. **Given** the share route (`/share/:token`) already sets `noindex, nofollow`, **When** this story is implemented, **Then** the share page meta is unchanged (no regression).

## Tasks / Subtasks

- [x] Task 1: Add `NUXT_PUBLIC_SITE_URL` to runtime config (AC: #2, #3, #4)
  - [x] In `nuxt.config.ts`, add `siteUrl: process.env.NUXT_PUBLIC_SITE_URL ?? 'https://doclyzer.com'` under `runtimeConfig.public`
  - [x] Add `NUXT_PUBLIC_SITE_URL=https://doclyzer.com` to `apps/web/.env.example`

- [x] Task 2: Create `app/pages/index.vue` — landing page with full SEO head (AC: #1, #2, #5)
  - [x] Use `useSeoMeta()` composable to set: `title`, `description`, `ogTitle`, `ogDescription`, `ogUrl`, `ogType` (`'website'`), `ogImage`, `twitterCard` (`'summary_large_image'`), `twitterTitle`, `twitterDescription`
  - [x] Use `useHead()` to add `<link rel="canonical">` and the JSON-LD `<script type="application/ld+json">` block
  - [x] JSON-LD schema: `@type: "WebSite"`, `name`, `url`, `description` — use `const config = useRuntimeConfig()` to source `siteUrl`
  - [x] Page body: minimal value-prop content (heading, subheading, CTA button linking to `/register` or app store) — functional placeholder is fine for MVP; focus on correctness of SEO tags over final marketing copy
  - [x] Verify no change to `app/pages/share/[token].vue` head configuration (AC: #6)

- [x] Task 3: Create `public/sitemap.xml` (AC: #3)
  - [x] Static XML file listing at minimum `<url><loc>https://doclyzer.com/</loc><changefreq>weekly</changefreq><priority>1.0</priority></url>`
  - [x] Include `<lastmod>` using the ISO date of implementation (2026-03-23)
  - [x] Use standard sitemap 0.9 namespace: `xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"`

- [x] Task 4: Update `public/robots.txt` (AC: #4)
  - [x] Add `Sitemap: https://doclyzer.com/sitemap.xml` directive at the bottom
  - [x] Keep existing `User-Agent: *` / `Disallow:` lines (blanket allow — share route `noindex` is already enforced by the page-level meta tag; per-route robots rules are Story 3.10's scope)

## Dev Notes

### Nuxt 4 SEO Composables — Use These, Not Raw `useHead` for Meta

Nuxt 4 (≥3.8) provides `useSeoMeta()` and `useServerSeoMeta()` as the preferred composables for SEO meta tags. They are typed, validate tag names, and avoid duplication bugs.

```typescript
// app/pages/index.vue — inside <script setup>
const config = useRuntimeConfig()
const siteUrl = config.public.siteUrl  // e.g. 'https://doclyzer.com'

useSeoMeta({
  title: 'Doclyzer — Understand Your Medical Reports',
  description: 'Organise, understand, and share your lab reports and health history. AI-powered summaries. Doctor-ready sharing.',
  ogTitle: 'Doclyzer — Understand Your Medical Reports',
  ogDescription: 'Organise, understand, and share your lab reports and health history.',
  ogUrl: siteUrl,
  ogType: 'website',
  ogImage: `${siteUrl}/og-image.png`,   // placeholder — add actual OG image to public/ later
  twitterCard: 'summary_large_image',
  twitterTitle: 'Doclyzer — Understand Your Medical Reports',
  twitterDescription: 'AI-powered medical report organiser. Share with your doctor.',
})

useHead({
  link: [{ rel: 'canonical', href: siteUrl }],
  script: [
    {
      type: 'application/ld+json',
      children: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'WebSite',
        name: 'Doclyzer',
        url: siteUrl,
        description: 'Organise, understand, and share your medical reports.',
      }),
    },
  ],
})
```

**Do NOT** use `<Head>` component or `definePageMeta({ head: ... })` — they are older patterns. Use composables.

### `nuxt.config.ts` Change

```typescript
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL ?? 'http://localhost:3000/v1',
      siteUrl: process.env.NUXT_PUBLIC_SITE_URL ?? 'https://doclyzer.com',   // ADD THIS
    },
  },
})
```

### `public/sitemap.xml` — Static MVP Approach

No Nuxt module needed for MVP. A static `public/sitemap.xml` is served as-is by Nuxt's static file handler.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://doclyzer.com/</loc>
    <lastmod>2026-03-23</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

**Do NOT** use `@nuxtjs/sitemap` module — it requires additional config and is overkill for an MVP with one public landing URL. Add more `<url>` entries (e.g. `/pricing`, `/terms`) when those pages are created.

### `public/robots.txt` — Add Sitemap Directive Only

Current content (do not remove existing lines):
```
User-Agent: *
Disallow:
```

Target content:
```
User-Agent: *
Disallow:

Sitemap: https://doclyzer.com/sitemap.xml
```

**Do NOT** add `Disallow: /share/` here — that is explicitly Story 3.10's scope ("Route Isolation Rules"). The share page already protects itself via `noindex, nofollow` meta (verified in `app/pages/share/[token].vue` line 1 of `useHead`).

### Existing Share Page — Verify No Regression

`app/pages/share/[token].vue` already has:
```typescript
useHead({
  meta: [{ name: 'robots', content: 'noindex, nofollow' }],
})
```
Do not touch this file. After implementing Task 2, manually verify the share page still renders the `noindex` meta (AC: #6).

### OG Image Placeholder

`ogImage` references `/og-image.png`. For MVP, either:
- Create a 1200×630 placeholder PNG in `public/og-image.png`, OR
- Omit `ogImage` entirely from `useSeoMeta()` (valid for MVP — OG image is not in the acceptance criteria)

**Recommendation:** Omit `ogImage` for MVP to avoid a broken image reference. Add it when a real design asset exists.

### Project Structure Notes

Files to create/modify:
- `apps/web/nuxt.config.ts` — add `siteUrl` to `runtimeConfig.public`
- `apps/web/.env.example` — add `NUXT_PUBLIC_SITE_URL=https://doclyzer.com`
- `apps/web/app/pages/index.vue` — NEW landing page (no existing file)
- `apps/web/public/sitemap.xml` — NEW static sitemap
- `apps/web/public/robots.txt` — UPDATE to add `Sitemap:` directive

Do NOT create: layouts/, components/, middleware/ — not needed for MVP.

No new npm packages required. All composables (`useSeoMeta`, `useHead`, `useRuntimeConfig`) are built into Nuxt 4.

No API calls, no authentication, no backend changes.

### Architecture Compliance

- ADR-S3-02: "metadata, social tags, sitemap/robots, canonical strategy, structured data are mandatory" — this story fulfils all five mandatory SEO items.
- Architecture: "Landing routes are indexable; share routes non-indexable" — index.vue will be crawlable; share/[token].vue remains noindex.
- Architecture: "CI/CD SEO quality gates for landing" — the SEO tags added here are what those gates will verify.
- Architecture: "Nuxt route partitioning: strict landing vs share route groups" — landing pages go in `app/pages/` root; share stays in `app/pages/share/`. This story establishes the landing group root.

### References

- [Source: _bmad-output/planning-artifacts/architecture.md — ADR-S3-02 Landing SEO Baseline]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md — Platform Strategy, Design System section]
- [Source: apps/web/nuxt.config.ts — current runtimeConfig structure]
- [Source: apps/web/public/robots.txt — existing content]
- [Source: apps/web/app/pages/share/[token].vue — existing noindex meta pattern]
- Nuxt useSeoMeta docs: https://nuxt.com/docs/api/composables/use-seo-meta
- Schema.org WebSite type: https://schema.org/WebSite
- Sitemap protocol: https://www.sitemaps.org/protocol.html

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Implemented all 4 tasks. `nuxt.config.ts` now exposes `siteUrl` via `runtimeConfig.public`. `app/pages/index.vue` created with `useSeoMeta()` for title/OG/Twitter tags and `useHead()` for canonical link and JSON-LD WebSite schema. `public/sitemap.xml` created as static file with landing URL. `public/robots.txt` updated with `Sitemap:` directive. `ogImage` omitted per Dev Notes recommendation (no real asset yet). Confirmed `apps/web/app/pages/share/[token].vue` still has `noindex, nofollow` unchanged (AC #6).

### File List

- apps/web/nuxt.config.ts
- apps/web/.env.example
- apps/web/app/pages/index.vue (NEW)
- apps/web/public/sitemap.xml (NEW)
- apps/web/public/robots.txt

### Change Log

- 2026-03-23: Story 3-9 implemented — landing SEO MVP. Added siteUrl to runtimeConfig, created index.vue with full SEO head (useSeoMeta + useHead canonical + JSON-LD), created sitemap.xml, updated robots.txt with Sitemap directive.
