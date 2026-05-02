<script setup lang="ts">
import { ref, onMounted } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'System Dashboard — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

const startDate = ref(new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10))
const endDate = ref(new Date().toISOString().slice(0, 10))
const productSlice = ref<'all' | 'free' | 'paid'>('all')

const dashboard = ref<Record<string, any> | null>(null)
const loading = ref(true)
const exportLoading = ref(false)
const error = ref('')

// Geography filtering is not implemented: no geography column exists on user/session/report entities.
// The filter is removed from the UI; the backend still accepts the param for forward-compatibility
// but reports geographyApplied: false in dataState so callers and audit exports are accurate.
const productOptions: Array<{ label: string; value: 'all' | 'free' | 'paid' }> = [
  { label: 'All plans', value: 'all' },
  { label: 'Free tier', value: 'free' },
  { label: 'Paid tier', value: 'paid' },
]

async function loadData() {
  loading.value = true
  error.value = ''
  try {
    const response = await adminFetch<{ data: Record<string, any> }>(
      `/admin/analytics/system-dashboard?startDate=${startDate.value}T00:00:00Z&endDate=${endDate.value}T23:59:59Z&productSlice=${productSlice.value}`,
    )
    dashboard.value = (response as Record<string, any>).data as Record<string, any>
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load data'
  } finally {
    loading.value = false
  }
}

async function exportDashboard(format: 'json' | 'csv') {
  exportLoading.value = true
  error.value = ''
  try {
    const response = await adminFetch<{ data: Record<string, any> }>(
      '/admin/analytics/system-dashboard/export',
      {
        method: 'POST',
        body: {
          startDate: `${startDate.value}T00:00:00Z`,
          endDate: `${endDate.value}T23:59:59Z`,
          productSlice: productSlice.value,
          format,
        },
      },
    )

    const payload = (response as Record<string, any>).data as Record<string, any>
    if (format === 'csv' && payload.csv) {
      downloadFile(`system-dashboard-${startDate.value}-${endDate.value}.csv`, payload.csv, 'text/csv')
    } else {
      const jsonContent = JSON.stringify(payload, null, 2)
      downloadFile(`system-dashboard-${startDate.value}-${endDate.value}.json`, jsonContent, 'application/json')
    }
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to export'
  } finally {
    exportLoading.value = false
  }
}

function downloadFile(filename: string, content: string, mime: string) {
  const blob = new Blob([content], { type: mime })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  link.click()
  URL.revokeObjectURL(url)
}

function formatDelta(metric: Record<string, any>): string {
  const delta = typeof metric?.delta === 'number' ? metric.delta : 0
  return `${delta > 0 ? '+' : ''}${delta}`
}

function formatCurrency(value: unknown): string {
  if (typeof value !== 'number') return '-'
  return `₹${value.toFixed(2)}`
}

function formatPercent(value: unknown): string {
  if (typeof value !== 'number') return '-'
  return `${value.toFixed(1)}%`
}

function formatCount(value: unknown): string {
  return typeof value === 'number' ? String(value) : '-'
}

function resolveAccountWorkbenchLink(): string {
  const topItem = dashboard.value?.governance?.suspiciousActivity?.topItems?.[0]
  if (!topItem || typeof topItem.targetId !== 'string' || topItem.targetId.length === 0) {
    return '/admin/users'
  }
  const targetType = typeof topItem.targetType === 'string' ? topItem.targetType.toLowerCase() : ''
  if (targetType === 'user' || targetType === 'account') {
    return `/admin/users/${topItem.targetId}`
  }
  return '/admin/users'
}

onMounted(loadData)
</script>

<template>
  <div class="dashboard">
    <div class="header-row">
      <div>
        <h2 class="page-title">System Dashboard</h2>
        <p class="page-subtitle">Operational, product, billing, and governance signals in one view.</p>
      </div>
      <div class="export-actions">
        <button class="btn-secondary" :disabled="exportLoading" @click="exportDashboard('json')">Export JSON</button>
        <button class="btn-secondary" :disabled="exportLoading" @click="exportDashboard('csv')">Export CSV</button>
      </div>
    </div>

    <div class="filters">
      <label>From <input v-model="startDate" type="date" class="date-input" /></label>
      <label>To <input v-model="endDate" type="date" class="date-input" /></label>
      <!-- Geography filter is formally de-scoped: entities have no geography column yet.
           The backend accepts the parameter for future compatibility but does not apply it. -->
      <span class="filter-note">Geography: not available (see data state)</span>
      <label>
        Product Slice
        <select v-model="productSlice" class="select-input">
          <option v-for="option in productOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
        </select>
      </label>
      <button class="btn-primary" @click="loadData">Refresh</button>
    </div>

    <div v-if="error" class="error-box" role="alert" aria-live="assertive">
      {{ error }}
    </div>

    <!-- Geography filtering is formally de-scoped: no geography column exists on entities yet.
         The backend surfaces geographyApplied: false so this notice is always shown when data loads. -->
    <div v-if="dashboard?.dataState?.geographyApplied === false" class="info-box" role="note">
      Geography filtering is not yet available — all data shown is global. Filtered views by region will be added when entity geography columns are introduced.
    </div>

    <template v-if="loading">
      <div class="skeleton-row">
        <div v-for="i in 4" :key="i" class="skeleton-card" />
      </div>
      <div class="skeleton-block" />
    </template>

    <template v-else-if="dashboard">
      <div class="section">
        <h3 class="section-title">Overview</h3>
        <div class="card-row">
          <div class="metric-card">
            <div class="metric-label">Users</div>
            <div class="metric-value">{{ dashboard.overview?.users?.current }}</div>
            <div class="metric-delta">{{ formatDelta(dashboard.overview?.users) }} vs baseline</div>
          </div>
          <div class="metric-card">
            <div class="metric-label">Sessions</div>
            <div class="metric-value">{{ dashboard.overview?.sessions?.current }}</div>
            <div class="metric-delta">{{ formatDelta(dashboard.overview?.sessions) }} vs baseline</div>
          </div>
          <div class="metric-card">
            <div class="metric-label">Revenue (Credit Packs)</div>
            <div class="metric-value">{{ formatCurrency(dashboard.payments?.creditPacks?.revenue) }}</div>
            <div class="metric-delta">{{ dashboard.payments?.creditPacks?.orderCount }} orders</div>
          </div>
          <div class="metric-card">
            <div class="metric-label">Processing Success</div>
            <div class="metric-value">{{ formatPercent(dashboard.overview?.processingSuccess?.current) }}</div>
            <div class="metric-delta">{{ formatDelta(dashboard.overview?.processingSuccess) }} pts vs baseline</div>
          </div>
        </div>
      </div>

      <div class="section">
        <h3 class="section-title">Activity Trends</h3>
        <div class="split-grid">
          <div class="panel">
            <h4 class="panel-title">Funnel</h4>
            <table class="table">
              <thead>
                <tr><th>Stage</th><th>Current</th><th>Baseline</th><th>Delta</th></tr>
              </thead>
              <tbody>
                <tr v-for="row in dashboard.activity?.funnel ?? []" :key="row.stage">
                  <td>{{ row.stage }}</td>
                  <td>{{ row.currentValue }}</td>
                  <td>{{ row.baselineValue }}</td>
                  <td :class="{ 'td-green': row.delta > 0, 'td-red': row.delta < 0 }">
                    {{ row.delta > 0 ? '+' : '' }}{{ row.delta }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="panel">
            <h4 class="panel-title">Retention</h4>
            <div class="stack">
              <div v-for="slice in dashboard.activity?.retention ?? []" :key="slice.label" class="retention-row">
                <div class="retention-label">{{ slice.label }}</div>
                <div class="retention-value">{{ formatPercent(slice.currentRate) }}</div>
                <div class="retention-delta">{{ slice.delta > 0 ? '+' : '' }}{{ slice.delta }} pts</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="section">
        <h3 class="section-title">Payments & Refunds</h3>
        <div class="card-row">
          <div class="stat-chip">
            <span class="stat-chip__label">Credit Pack Revenue</span>
            <span class="stat-chip__value">{{ formatCurrency(dashboard.payments?.creditPacks?.revenue) }}</span>
            <span class="stat-chip__meta">{{ formatCount(dashboard.payments?.creditPacks?.orderCount) }} orders</span>
          </div>
          <div class="stat-chip">
            <span class="stat-chip__label">Subscriptions (Active)</span>
            <span class="stat-chip__value">{{ formatCount(dashboard.payments?.subscriptions?.active) }}</span>
            <span class="stat-chip__meta">{{ formatCount(dashboard.payments?.subscriptions?.new) }} new</span>
          </div>
          <div class="stat-chip">
            <span class="stat-chip__label">Refunds</span>
            <span class="stat-chip__value">{{ formatCount(dashboard.payments?.refunds?.count) }}</span>
            <span class="stat-chip__meta">{{ formatCurrency(dashboard.payments?.refunds?.amount) }}</span>
          </div>
        </div>
      </div>

      <div class="section">
        <div class="section-title">
          File & Report Inventory
          <NuxtLink to="/admin/files" class="section-link">View files</NuxtLink>
        </div>
        <div class="card-row">
          <div class="stat-chip">
            <span class="stat-chip__label">In Flight</span>
            <span class="stat-chip__value">{{ formatCount(dashboard.files?.totalInFlight) }}</span>
            <span class="stat-chip__meta">Oldest: {{ dashboard.files?.oldestInFlightCreatedAt ?? '—' }}</span>
          </div>
          <div class="stat-chip">
            <span class="stat-chip__label">Parsed</span>
            <span class="stat-chip__value">{{ formatCount(dashboard.files?.parsedCount) }}</span>
          </div>
          <div class="stat-chip">
            <span class="stat-chip__label">Failed</span>
            <span class="stat-chip__value stat-chip__value--red">{{ formatCount(dashboard.files?.failedCount) }}</span>
          </div>
        </div>
        <div class="card-row">
          <div
            v-for="(count, status) in dashboard.files?.statusCounts ?? {}"
            :key="status"
            class="status-chip"
            :class="`status-chip--${status}`"
          >
            <span class="status-chip__name">{{ status }}</span>
            <span class="status-chip__count">{{ count }}</span>
          </div>
        </div>
      </div>

      <div class="section">
        <div class="section-title">
          Governance Signals
          <NuxtLink to="/admin/risk" class="section-link">Review risk queue</NuxtLink>
        </div>
        <div class="split-grid">
          <div class="panel">
            <h4 class="panel-title">Suspicious Activity Queue</h4>
            <div class="stat-chip stat-chip--tight">
              <span class="stat-chip__label">Open Items</span>
              <span class="stat-chip__value">{{ formatCount(dashboard.governance?.suspiciousActivity?.openCount) }}</span>
            </div>
            <ul class="list">
              <li v-for="item in dashboard.governance?.suspiciousActivity?.topItems ?? []" :key="item.id">
                <strong>{{ item.severity.toUpperCase() }}</strong> — {{ item.detectionSummary || 'No summary' }}
                <span class="list-meta">{{ item.targetType }} · {{ item.lastDetectedAt }}</span>
              </li>
            </ul>
          </div>
          <div class="panel">
            <h4 class="panel-title">Recent Audit Actions</h4>
            <ul class="list">
              <li v-for="event in dashboard.governance?.auditActions?.recent ?? []" :key="event.id">
                <strong>{{ event.action }}</strong> — {{ event.target }}
                <span class="list-meta">{{ event.outcome }} · {{ event.performedAt }}</span>
              </li>
            </ul>
            <div class="stat-chip stat-chip--tight">
              <span class="stat-chip__label">Governance Reviews Pending</span>
              <span class="stat-chip__value">{{ formatCount(dashboard.governance?.reviewState?.pendingCount) }}</span>
              <span class="stat-chip__meta">Last reviewed {{ dashboard.governance?.reviewState?.lastReviewedAt ?? '—' }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="section">
        <h3 class="section-title">Incident & Opportunity Panel</h3>
        <div class="split-grid">
          <div class="panel">
            <h4 class="panel-title">Correlated Signals</h4>
            <div class="stat-grid">
              <div>
                <div class="stat-grid__label">Pipeline failures</div>
                <div class="stat-grid__value">{{ formatCount(dashboard.incidents?.pipelineFailures) }}</div>
              </div>
              <div>
                <div class="stat-grid__label">Suspicious queue</div>
                <div class="stat-grid__value">{{ formatCount(dashboard.incidents?.suspiciousQueue) }}</div>
              </div>
              <div>
                <div class="stat-grid__label">Recent audit actions</div>
                <div class="stat-grid__value">{{ formatCount(dashboard.incidents?.recentAuditActions) }}</div>
              </div>
            </div>
          </div>
          <div class="panel">
            <h4 class="panel-title">Recommended Next Steps</h4>
            <ul class="list">
              <li>
                Review the risk queue and apply protective restrictions if needed.
                <NuxtLink to="/admin/risk" class="inline-link">Open risk queue</NuxtLink>
              </li>
              <li>
                Investigate affected accounts in the user workbench.
                <NuxtLink :to="resolveAccountWorkbenchLink()" class="inline-link">Open account workbench</NuxtLink>
              </li>
              <li>
                Audit failed file processing batches for remediation.
                <NuxtLink to="/admin/files" class="inline-link">Open files console</NuxtLink>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.dashboard {
  --font-ui: 'Plus Jakarta Sans', 'Inter', 'Avenir Next', 'Segoe UI', sans-serif;
  --font-display: 'Space Grotesk', 'Plus Jakarta Sans', 'Segoe UI', sans-serif;
  max-width: 1260px;
  margin: 0 auto;
  padding-bottom: 24px;
  font-family: var(--font-ui);
}

.page-title {
  font-size: clamp(1.55rem, 1.2vw + 1.25rem, 2.1rem);
  font-weight: 700;
  margin: 0;
  color: #0f172a;
  letter-spacing: -0.02em;
  font-family: var(--font-display);
}

.page-subtitle {
  font-size: 13px;
  margin-top: 8px;
  color: #526277;
  max-width: 60ch;
}

.header-row {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 18px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.86), rgba(255, 248, 242, 0.84));
  border: 1px solid rgba(13, 27, 42, 0.08);
  border-radius: 16px;
  padding: 18px 18px 16px;
  box-shadow: 0 12px 30px rgba(13, 27, 42, 0.06);
}

.export-actions { display: flex; gap: 10px; }

.filters {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 24px;
  font-size: 12px;
  color: #334155;
  background: rgba(255, 255, 255, 0.78);
  border: 1px solid rgba(13, 27, 42, 0.08);
  border-radius: 14px;
  padding: 12px 14px;
  box-shadow: 0 8px 22px rgba(13, 27, 42, 0.05);
}

.date-input,
.select-input {
  margin-left: 6px;
  padding: 7px 10px;
  border: 1px solid rgba(13, 27, 42, 0.16);
  border-radius: 8px;
  font-size: 13px;
  font-family: inherit;
  background: #fff;
}

.date-input:focus,
.select-input:focus {
  outline: none;
  border-color: #d97706;
  box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.15);
}

.btn-primary,
.btn-secondary {
  padding: 8px 14px;
  border-radius: 10px;
  font-size: 13px;
  cursor: pointer;
  font-family: inherit;
  transition: transform 0.14s, box-shadow 0.18s, background 0.18s;
}

.btn-primary {
  background: linear-gradient(145deg, #0f172a, #1e293b);
  color: #fff;
  border: 1px solid #111827;
  box-shadow: 0 8px 20px rgba(15, 23, 42, 0.25);
}

.btn-secondary {
  background: #fff;
  border: 1px solid rgba(13, 27, 42, 0.16);
  color: #0f172a;
}

.btn-primary:hover,
.btn-secondary:hover {
  transform: translateY(-1px);
}

.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-box {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fda4af;
  border-radius: 12px;
  padding: 12px 14px;
  font-size: 13px;
  margin-bottom: 16px;
}

.info-box {
  background: #f0f9ff;
  color: #075985;
  border: 1px solid #bae6fd;
  border-radius: 12px;
  padding: 12px 14px;
  font-size: 13px;
  margin-bottom: 16px;
}

.filter-note {
  font-size: 12px;
  color: #6b7280;
  align-self: center;
  font-style: italic;
}

.section {
  margin-bottom: 26px;
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(13, 27, 42, 0.08);
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 12px 28px rgba(13, 27, 42, 0.06);
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  letter-spacing: 0.01em;
  font-family: var(--font-display);
}

.section-link {
  font-size: 12px;
  color: #b45309;
  text-decoration: none;
  font-weight: 600;
}

.section-link:hover { text-decoration: underline; }

.card-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 12px;
}

.metric-card {
  background:
    radial-gradient(65% 110% at 0% 0%, rgba(255, 237, 213, 0.42), transparent 60%),
    #fff;
  border: 1px solid rgba(13, 27, 42, 0.1);
  border-radius: 14px;
  padding: 18px 18px 16px;
  min-width: 200px;
  flex: 1;
  box-shadow: 0 8px 20px rgba(13, 27, 42, 0.05);
}
.metric-label {
  font-size: 11px;
  color: #5f6f84;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-bottom: 7px;
  font-family: var(--font-ui);
}

.metric-value {
  font-size: clamp(1.2rem, 1vw + 1.05rem, 1.7rem);
  font-weight: 700;
  color: #0f172a;
  font-family: var(--font-display);
}

.metric-delta { font-size: 11px; color: #6b7b90; margin-top: 5px; }

.stat-chip {
  background: #fff;
  border: 1px solid rgba(13, 27, 42, 0.12);
  border-radius: 12px;
  padding: 12px 14px;
  display: flex;
  flex-direction: column;
  gap: 5px;
  min-width: 150px;
  flex: 1;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.55);
}
.stat-chip--tight { margin-top: 12px; }
.stat-chip__label { font-size: 11px; color: #617287; text-transform: uppercase; letter-spacing: 0.05em; }
.stat-chip__value { font-size: 20px; font-weight: 700; color: #0f172a; }
.stat-chip__value--red { color: #dc2626; }
.stat-chip__meta { font-size: 11px; color: #7b8ca1; }

.split-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 12px;
}

.panel {
  background: #fff;
  border: 1px solid rgba(13, 27, 42, 0.12);
  border-radius: 12px;
  padding: 14px;
  box-shadow: 0 8px 20px rgba(13, 27, 42, 0.04);
}

.panel-title {
  font-size: 12px;
  font-weight: 600;
  color: #213044;
  margin: 0 0 12px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  font-family: var(--font-display);
}

.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  border: 1px solid rgba(13, 27, 42, 0.12);
}
.table th {
  background: linear-gradient(180deg, #f8fafc, #eef2f7);
  padding: 10px 12px;
  text-align: left;
  font-weight: 600;
  color: #2a3a4f;
  font-size: 12px;
  font-family: var(--font-display);
}

.table td {
  padding: 10px 12px;
  border-top: 1px solid #eef2f6;
  color: #334155;
}
.td-green { color: #16a34a; font-weight: 600; }
.td-red { color: #dc2626; font-weight: 600; }

.status-chip {
  padding: 10px 14px;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 110px;
  background: #f1f5f9;
  border: 1px solid rgba(13, 27, 42, 0.1);
}
.status-chip__name { font-size: 11px; color: #64748b; }
.status-chip__count { font-size: 18px; font-weight: 700; color: #0f172a; }
.status-chip--parsed { background: #f0fdf4; border-color: #bbf7d0; }
.status-chip--parsed .status-chip__count { color: #16a34a; }
.status-chip--queued, .status-chip--parsing, .status-chip--uploading { background: #fffbeb; border-color: #fde68a; }
.status-chip--queued .status-chip__count, .status-chip--parsing .status-chip__count, .status-chip--uploading .status-chip__count { color: #d97706; }
.status-chip--failed_transient { background: #fff7ed; border-color: #fed7aa; }
.status-chip--failed_transient .status-chip__count { color: #ea580c; }
.status-chip--failed_terminal, .status-chip--content_not_recognized { background: #fef2f2; border-color: #fecaca; }
.status-chip--failed_terminal .status-chip__count, .status-chip--content_not_recognized .status-chip__count { color: #dc2626; }

.list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: grid;
  gap: 8px;
  font-size: 13px;
  color: #334155;
}

.list li {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 9px 10px;
}

.list-meta { display: block; font-size: 11px; color: #7b8ca1; margin-top: 4px; }
.inline-link { margin-left: 6px; font-size: 12px; color: #b45309; text-decoration: none; font-weight: 600; }
.inline-link:hover { text-decoration: underline; }

.retention-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #eef2f7;
  font-size: 13px;
  color: #334155;
}
.retention-row:last-child { border-bottom: none; }
.retention-label { font-weight: 500; }
.retention-value { font-weight: 600; }
.retention-delta { font-size: 12px; color: #64748b; }

.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 10px;
}
.stat-grid > div {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 10px;
}
.stat-grid__label { font-size: 11px; color: #617287; }
.stat-grid__value { font-size: 17px; font-weight: 700; color: #0f172a; }

.skeleton-row { display: flex; gap: 16px; margin-bottom: 24px; }
.skeleton-card {
  flex: 1;
  height: 96px;
  background: linear-gradient(90deg, #e2e8f0 25%, #f1f5f9 50%, #e2e8f0 75%);
  background-size: 220% 100%;
  border-radius: 12px;
  animation: shimmer 1.4s linear infinite;
}
.skeleton-block {
  height: 220px;
  background: linear-gradient(90deg, #e2e8f0 25%, #f1f5f9 50%, #e2e8f0 75%);
  background-size: 220% 100%;
  border-radius: 12px;
  animation: shimmer 1.4s linear infinite;
}

@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -20% 0; }
}

@media (max-width: 900px) {
  .header-row {
    flex-direction: column;
    align-items: stretch;
  }
}

@media (max-width: 640px) {
  .dashboard {
    max-width: 100%;
  }
  .filters {
    gap: 8px;
    padding: 10px;
  }
  .section {
    padding: 12px;
  }
}
</style>
