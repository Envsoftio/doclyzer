# Dev Prompt: Superadmin UI + Real Docling Parsing Pipeline

**Priority: CRITICAL — implement immediately**

You are a senior fullstack dev working on the **doclyzer** project (NestJS API + Nuxt 4 web app + Flutter mobile).

This prompt covers two parallel tracks that must be implemented together:
- **Track A**: Full superadmin UI in Nuxt
- **Track B**: Real Docling PDF parsing + lab extraction (replace stubs)

Read this entire prompt before starting. Follow all guardrails exactly.

---

## CRITICAL GUARDRAILS

- **No tests** — manual QA only (project policy)
- **No external UI libraries** — use plain CSS with `system-ui` font (match existing page patterns)
- **PHI-safe**: never log parsed transcript, lab values, or user health data
- **Superadmin endpoints** always require `AuthGuard + SuperadminGuard + AdminActionTokenGuard`
- **No new DB migrations** unless explicitly stated
- **Keep thin controllers** — business logic lives in services
- **Use TypeORM repositories** via dependency injection — no raw SQL strings
- **Correlation IDs** on all API responses

---

## CODEBASE CONTEXT

### Project root: `/Users/vishnu/Work/Server/doclyzer`

### Key paths
```
apps/api/src/modules/analytics-admin/     ← backend analytics module (extend this)
apps/api/src/modules/reports/             ← report upload/parse pipeline (fix stubs here)
apps/api/src/config/reports.config.ts     ← report config (add Docling keys here)
apps/api/src/database/entities/           ← TypeORM entities
apps/web/app/pages/admin/                 ← Nuxt admin pages (currently placeholder only)
apps/web/app/pages/admin/index.vue        ← current placeholder (replace with redirect)
apps/web/app/composables/                 ← Nuxt composables (create admin auth here)
apps/web/app/layouts/                     ← Nuxt layouts (create admin layout here)
apps/web/server/api/admin/               ← existing Nuxt server API contract stubs
```

### Existing entities you'll query
- `UserEntity` — `id, email, displayName, role, createdAt, updatedAt`
- `SessionEntity` — `id, userId, ipAddress, userAgent, createdAt, expiresAt`
- `ProfileEntity` — `id, userId, name, createdAt`
- `ReportEntity` — `id, userId, profileId, originalFileName, sizeBytes, status, contentHash, createdAt, updatedAt`
- `ReportLabValueEntity` — `id, reportId, parameterName, value, unit, sampleDate, sortOrder`
- `ReportProcessingAttemptEntity` — `id, reportId, trigger, outcome, attemptedAt`

### Existing analytics-admin module
- `analytics-admin.controller.ts` — has `GET /admin/analytics/core-product` and governance endpoints
- `analytics-admin.service.ts` — aggregate metrics (signups, sessions, reports, revenue)
- `analytics-admin.module.ts` — registers UserEntity, SessionEntity, ProfileEntity, ReportEntity, OrderEntity

### Existing auth flow for superadmin
- `POST /v1/auth/login` → `{ accessToken, refreshToken }`
- `POST /v1/auth/superadmin/elevation/challenge` → `{ challengeId }` (needs `Authorization: Bearer <accessToken>` + role=superadmin)
- `POST /v1/auth/superadmin/elevation/verify` → `{ verified: true }`
- `POST /v1/auth/superadmin/elevation/token` → `{ adminActionToken }`
- All superadmin API calls need: `Authorization: Bearer <accessToken>` + `X-Admin-Action-Token: <adminActionToken>`

### Existing report parse config (reports.config.ts)
```ts
parseStubFail: boolean        // PARSE_STUB_FAIL
parseStubRetrySucceeds: boolean
parseStubContentNotRecognized: boolean
reportSummaryEnabled: boolean // REPORT_SUMMARY_ENABLED
reportSummaryHttpUrl: string  // REPORT_SUMMARY_HTTP_URL
```

### Current parse stub location
`apps/api/src/modules/reports/reports.service.ts` line ~509 — `runParseStub()` method
Called at line ~184 during upload and ~415 during retry.

### Docker compose location
`docker-compose.yml` at project root

---

## TRACK B: Real Docling Parsing Pipeline

### Step B1 — Update `reports.config.ts`

Add to `ReportsConfig` interface and `registerAs` factory:
```ts
doclingEnabled: boolean        // DOCLING_ENABLED
doclingHttpUrl: string         // DOCLING_HTTP_URL (e.g. http://docling:5001)
doclingTimeoutMs: number       // DOCLING_TIMEOUT_MS (default: 60000)
```

### Step B2 — Create `apps/api/src/modules/reports/docling.client.ts`

```ts
@Injectable()
export class DoclingClient {
  constructor(private readonly configService: ConfigService) {}

  async parsePdf(buffer: Buffer): Promise<{ text: string } | null>
  // POST to ${doclingHttpUrl}/v1alpha/convert/source
  // Body: { file_source: { base64_string: buffer.toString('base64'), filename: 'report.pdf' } }
  // Response shape: { document: { export_formats: { md?: string } } }
  // Extract markdown as transcript text
  // Return null if: disabled, URL not set, request fails, timeout
  // Never throw — always graceful fallback
  // Timeout via AbortController (same pattern as report-summary.service.ts)
  // Log warnings PHI-safe (no buffer content in logs)
}
```

**Docling API shape** (docling-serve v0.4+):
- Endpoint: `POST /v1alpha/convert/source`
- Request body:
```json
{
  "file_source": {
    "base64_string": "<base64pdf>",
    "filename": "report.pdf"
  },
  "options": { "to_formats": ["md"] }
}
```
- Response: `{ "document": { "export_formats": { "md": "<markdown text>" } } }`
- Extract `data.document.export_formats.md` as transcript

### Step B3 — Create `apps/api/src/modules/reports/lab-value-extractor.ts`

```ts
export interface ExtractedLabValue {
  parameterName: string
  value: string
  unit: string | null
  sampleDate: string | null
}

export class LabValueExtractor {
  extract(transcript: string): ExtractedLabValue[]
}
```

Regex patterns to match common lab report formats:
- `Glucose: 95 mg/dL` → `/([\w\s\-\/]+):\s*([\d.]+)\s*([\w\/%]+)/g`
- `HbA1c    5.4    %` (tab-separated table rows)
- `TSH | 2.1 | mIU/L` (pipe-delimited)
- `Haemoglobin (Hb) 14.2 g/dL`

Clean up parameter names: trim, normalize whitespace, title-case.
Skip lines where value is not a parseable number.
Cap extraction at 100 values per report.

### Step B4 — Modify `apps/api/src/modules/reports/reports.service.ts`

1. Inject `DoclingClient` and `LabValueExtractor` in constructor
2. Replace `runParseStub()` call in `uploadReport()` with:

```ts
const doclingResult = await this.doclingClient.parsePdf(file.buffer);
const status: ReportStatus = doclingResult ? 'parsed' : 'failed_transient';
const transcript = doclingResult?.text ?? null;
const labValues: ExtractedLabValue[] = transcript
  ? this.labExtractor.extract(transcript)
  : [];
```

3. After saving the report entity, persist lab values:
```ts
if (labValues.length > 0) {
  const labEntities = labValues.map((lv, i) =>
    this.reportLabValueRepo.create({
      reportId: entity.id,
      parameterName: lv.parameterName,
      value: lv.value,
      unit: lv.unit ?? null,
      sampleDate: lv.sampleDate ?? null,
      sortOrder: i,
    }),
  );
  await this.reportLabValueRepo.save(labEntities);
}
```

4. Do the same replacement in `retryParse()` (~line 415)

5. Keep `runParseStub()` method as fallback — if `DOCLING_ENABLED=false`, use the stub (backwards compatible)

### Step B5 — Modify `apps/api/src/modules/reports/reports.module.ts`

Register `DoclingClient` as a provider. `LabValueExtractor` is a plain class (not injectable, instantiate directly in service).

### Step B6 — Add Docling to `docker-compose.yml`

```yaml
  docling:
    image: ds4sd/docling-serve:latest
    ports:
      - "5001:5001"
    environment:
      - DOCLING_NUM_THREADS=2
    restart: unless-stopped
```

### Step B7 — Update `.env.example`

```
# Docling PDF Parsing Service
DOCLING_ENABLED=false
DOCLING_HTTP_URL=http://localhost:5001
DOCLING_TIMEOUT_MS=60000
```

---

## TRACK A: Backend User Activity API (Story 5-18)

### Step A1 — Create `apps/api/src/modules/analytics-admin/user-activity.service.ts`

Injectable service, inject repositories: `UserEntity`, `ProfileEntity`, `ReportEntity`, `SessionEntity`.

Implement these methods:

**`getUserActivityMetrics()`** — returns:
```ts
{
  totalUsers: number
  activeUsersLast7Days: number    // distinct user_ids with session in last 7 days
  totalProfiles: number
  reportsInPipeline: number       // status IN ('uploading','queued','parsing')
  totalParsedReports: number      // status = 'parsed'
  totalFailedReports: number      // status IN ('failed_transient','failed_terminal')
}
```

**`getUserDirectory(query: UserDirectoryQueryDto)`** — paginated user list:
```ts
// Input: { page=1, limit=50, sortBy='createdAt', sortDir='DESC', search?: string, accountStatus?: string }
// Output: { users: UserDirectoryItem[], total: number, page: number, limit: number }
// UserDirectoryItem: { id, email, displayName, role, createdAt, profileCount, reportCount, lastLoginAt }
// lastLoginAt = MAX(session.created_at) for that user
// Use single JOIN query: users LEFT JOIN profiles LEFT JOIN reports LEFT JOIN sessions
// search filters on email ILIKE '%query%'
```

**`getUserWorkbench(userId: string)`** — single user detail:
```ts
// Returns:
{
  user: { id, email, displayName, role, createdAt },
  profiles: { id, name, createdAt, reportCount }[],
  reports: { id, profileId, originalFileName, sizeBytes, status, createdAt, updatedAt }[],
  sessions: { id, ipAddress, userAgent, createdAt, expiresAt }[],
  reportStatusSummary: Record<ReportStatus, number>
}
// Throw NotFoundException if user not found
```

**`getFilePipelineStatus()`** — queue state:
```ts
// Returns:
{
  statusCounts: Record<ReportStatus, number>  // count per status
  totalInFlight: number                        // uploading+queued+parsing
  oldestInFlightCreatedAt: string | null       // ISO, for detecting stuck uploads
}
```

### Step A2 — Create DTOs/types in `analytics-admin.dto.ts` (extend existing file)

Add:
```ts
export class UserDirectoryQueryDto {
  @IsOptional() @IsInt() @Min(1) page?: number
  @IsOptional() @IsInt() @Min(1) @Max(200) limit?: number
  @IsOptional() @IsString() sortBy?: 'createdAt' | 'email' | 'reportCount'
  @IsOptional() @IsString() sortDir?: 'ASC' | 'DESC'
  @IsOptional() @IsString() search?: string
}
```

### Step A3 — Extend `analytics-admin.controller.ts`

Add four new endpoints:
```ts
@Get('user-activity')
async getUserActivityMetrics(@Req() req): Promise<object>

@Get('users')
async getUserDirectory(@Query() query: UserDirectoryQueryDto, @Req() req): Promise<object>

@Get('users/:userId')
async getUserWorkbench(@Param('userId') userId: string, @Req() req): Promise<object>

@Get('files/pipeline-status')
async getFilePipelineStatus(@Req() req): Promise<object>
```

All endpoints: same guard pattern (`AuthGuard, SuperadminGuard, AdminActionTokenGuard`), use `successResponse()`, propagate correlation ID.

### Step A4 — Register `UserActivityService` in `analytics-admin.module.ts`

Add to providers and inject repositories already available in the module.

---

## TRACK A: Superadmin UI (Nuxt Web App)

### Step A5 — Create `apps/web/app/composables/useAdminAuth.ts`

```ts
// Manages: accessToken, adminActionToken, MFA state
// Storage: sessionStorage (cleared on tab close for security)
// Exposes:
//   isAuthenticated: computed<boolean>
//   hasAdminToken: computed<boolean>
//   login(email, password): Promise<void>   → calls POST /auth/login
//   startMfaChallenge(): Promise<string>     → returns challengeId
//   verifyMfa(challengeId, code): Promise<void>
//   issueAdminToken(challengeId): Promise<void>
//   logout(): void
//   authHeaders: computed<Record<string,string>>  → { Authorization, X-Admin-Action-Token }
```

### Step A6 — Create `apps/web/app/composables/useAdminApi.ts`

```ts
// Thin wrapper around $fetch that always injects authHeaders
// adminFetch<T>(url: string, options?: FetchOptions): Promise<T>
// Throws if not authenticated
// Uses: useRuntimeConfig().public.apiBaseUrl as base
```

### Step A7 — Create `apps/web/app/layouts/admin.vue`

Layout with:
- Left sidebar nav (120px wide on desktop, collapses on mobile)
- Main content area
- Nav links: Dashboard, Users, Files, Risk
- Show logged-in user email + Logout button
- Use `definePageMeta({ layout: 'admin' })` in child pages
- CSS only — no external deps

### Step A8 — Create `apps/web/app/components/admin/AdminNav.vue`

Sidebar nav component:
- Logo/title: "Doclyzer Admin"
- Nav items with icons (use Unicode: 📊 🧑‍💼 📁 🚨) and labels
- Active state via `useRoute().path`
- Responsive: collapses to top bar on mobile

### Step A9 — Replace `apps/web/app/pages/admin/index.vue`

Replace placeholder with:
```vue
<script setup>
const { isAuthenticated, hasAdminToken } = useAdminAuth()
if (isAuthenticated.value && hasAdminToken.value) {
  navigateTo('/admin/dashboard')
} else {
  navigateTo('/admin/login')
}
</script>
```

### Step A10 — Create `apps/web/app/pages/admin/login/index.vue`

Three-step MFA login:
- **Step 1**: Email + password form → `POST /v1/auth/login`
- **Step 2**: TOTP code entry → challenge + verify
- **Step 3**: Issue admin token → redirect to `/admin/dashboard`

Progress indicator showing current step.
Error handling for wrong credentials, invalid MFA code, expired challenge.
`robots: noindex,nofollow` meta.

### Step A11 — Create `apps/web/app/pages/admin/dashboard/index.vue`

```
definePageMeta({ layout: 'admin' })
```

Sections:
1. **Date range picker** — last 7d / 30d / 90d / custom (startDate, endDate inputs)
2. **Metric cards row** — Signups, Sessions, Revenue, Parse success rate (from `GET /admin/analytics/core-product`)
3. **Activity overview** — totalUsers, activeUsersLast7Days, totalProfiles, reportsInPipeline (from `GET /admin/analytics/user-activity`)
4. **Funnel table** — signups → active sessions → parsed reports
5. **Processing status** — mini version of pipeline status (counts by status)

Use `onMounted` to fetch. Show skeleton loaders while loading.

### Step A12 — Create `apps/web/app/pages/admin/users/index.vue`

```
definePageMeta({ layout: 'admin' })
```

- Search input (debounced, 300ms)
- Table: Email, Display Name, Role, Signup Date, Profiles, Reports, Last Login
- Pagination controls (prev/next, show total)
- Click row → `navigateTo('/admin/users/' + user.id)`
- Empty state for no results

### Step A13 — Create `apps/web/app/pages/admin/users/[id].vue`

```
definePageMeta({ layout: 'admin' })
```

Sections:
1. **User header** — email, displayName, role, signup date, account status badge
2. **Profiles** — table of profiles with report count
3. **Reports** — table of reports (fileName, size, status badge, uploadedAt)
   - Status badge colors: green=parsed, orange=queued/parsing, red=failed, grey=unparsed
4. **Sessions** — table of recent sessions (IP, device, created, expires)
5. **Report status summary** — count per status as inline stat chips

### Step A14 — Create `apps/web/app/pages/admin/files/index.vue`

```
definePageMeta({ layout: 'admin' })
```

- **Pipeline status cards** — one card per status with count and color coding
- **In-flight badge** — total currently uploading/queued/parsing
- **Oldest in-flight** — timestamp to detect stuck uploads
- Auto-refresh every 30s

Status color map:
- `parsed` → green
- `queued`, `parsing`, `uploading` → amber
- `failed_transient` → orange
- `failed_terminal`, `content_not_recognized` → red
- `unparsed` → grey

### Step A15 — Create `apps/web/app/pages/admin/risk/index.vue`

```
definePageMeta({ layout: 'admin' })
```

Sections:
1. **Suspicious activity queue** — `GET /v1/admin/risk/suspicious-activity-queue` — list flagged accounts with reason, timestamp
2. **Quick actions** per user — Restrict / Suspend with confirmation modal + mandatory note field
   - Restrict: `PATCH /v1/admin/risk/accounts/:userId/restriction`
   - Emergency suspend: `PATCH /v1/admin/emergency/accounts/:userId/suspension`
3. Note: always show "requires admin action token — re-authenticate if expired"

### Step A16 — Update `apps/web/nuxt.config.ts`

Add route rules for noindex on all admin routes:
```ts
routeRules: {
  '/admin/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } }
}
```

---

## FINAL CHECKLIST BEFORE MARKING DONE

- [ ] `docker compose up` starts Docling on port 5001
- [ ] Upload real PDF → report status = `parsed`, lab values extracted
- [ ] Upload with `DOCLING_ENABLED=false` → falls back to stub behavior
- [ ] `GET /v1/admin/analytics/user-activity` returns counts
- [ ] `GET /v1/admin/analytics/users` returns paginated list
- [ ] `GET /v1/admin/analytics/users/:id` returns workbench
- [ ] `GET /v1/admin/analytics/files/pipeline-status` returns queue state
- [ ] Navigate to `/admin` → redirects to `/admin/login`
- [ ] Login flow: password → MFA → admin token stored in sessionStorage
- [ ] Dashboard shows live metrics
- [ ] User directory search + pagination works
- [ ] User workbench shows profiles, reports, sessions
- [ ] Files page shows pipeline counts, auto-refreshes
- [ ] Risk page loads suspicious queue + restriction action works
- [ ] All admin pages are `noindex,nofollow`
- [ ] No PHI in any log output
