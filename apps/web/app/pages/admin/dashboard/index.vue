<script setup lang="ts">
import { ref, onMounted } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'System Dashboard — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

const startDate = ref(new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10))
const endDate = ref(new Date().toISOString().slice(0, 10))
const geography = ref('all')
const productSlice = ref<'all' | 'free' | 'paid'>('all')

const dashboard = ref<Record<string, any> | null>(null)
const loading = ref(true)
const exportLoading = ref(false)
const error = ref('')

// Geography filtering is not yet implemented in backend queries; only 'all' is available.
const geographyOptions = ['all']
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
      `/admin/analytics/system-dashboard?startDate=${startDate.value}T00:00:00Z&endDate=${endDate.value}T23:59:59Z&geography=${geography.value}&productSlice=${productSlice.value}`,
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
          geography: geography.value,
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
      <label>
        Geography
        <select v-model="geography" class="select-input">
          <option v-for="option in geographyOptions" :key="option" :value="option">{{ option }}</option>
        </select>
      </label>
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
                <NuxtLink to="/admin/users" class="inline-link">Open user directory</NuxtLink>
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
.dashboard { max-width: 1200px; }
.page-title { font-size: 24px; font-weight: 700; margin: 0; color: #0f172a; }
.page-subtitle { font-size: 13px; margin-top: 6px; color: #64748b; }

.header-row {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
}

.export-actions { display: flex; gap: 10px; }

.filters {
  display: flex;
  gap: 12px;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 24px;
  font-size: 13px;
  color: #374151;
}
.date-input,
.select-input {
  margin-left: 6px;
  padding: 6px 10px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 13px;
  font-family: inherit;
}
.btn-primary,
.btn-secondary {
  padding: 6px 14px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  font-family: inherit;
}
.btn-primary {
  background: #0f172a;
  color: #fff;
  border: 1px solid #0f172a;
}
.btn-secondary {
  background: #f1f5f9;
  border: 1px solid #cbd5e1;
  color: #0f172a;
}
.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-box {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
  border-radius: 6px;
  padding: 10px 14px;
  font-size: 13px;
  margin-bottom: 16px;
}

.section { margin-bottom: 32px; }
.section-title {
  font-size: 15px;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 14px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.section-link {
  font-size: 12px;
  color: #2563eb;
  text-decoration: none;
}
.section-link:hover { text-decoration: underline; }

.card-row { display: flex; flex-wrap: wrap; gap: 16px; margin-bottom: 16px; }
.metric-card {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 20px 24px;
  min-width: 200px;
  flex: 1;
}
.metric-label { font-size: 12px; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 6px; }
.metric-value { font-size: 26px; font-weight: 700; color: #0f172a; }
.metric-delta { font-size: 12px; color: #94a3b8; margin-top: 4px; }

.stat-chip {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 14px 18px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 150px;
  flex: 1;
}
.stat-chip--tight { margin-top: 12px; }
.stat-chip__label { font-size: 12px; color: #64748b; }
.stat-chip__value { font-size: 22px; font-weight: 700; color: #0f172a; }
.stat-chip__value--red { color: #dc2626; }
.stat-chip__meta { font-size: 11px; color: #94a3b8; }

.split-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
}
.panel {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 16px;
}
.panel-title {
  font-size: 13px;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 12px;
}

.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #e2e8f0;
}
.table th { background: #f8fafc; padding: 10px 14px; text-align: left; font-weight: 600; color: #374151; }
.table td { padding: 10px 14px; border-top: 1px solid #f1f5f9; color: #374151; }
.td-green { color: #16a34a; font-weight: 600; }
.td-red { color: #dc2626; font-weight: 600; }

.status-chip {
  padding: 10px 16px;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 110px;
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
}
.status-chip__name { font-size: 11px; color: #64748b; }
.status-chip__count { font-size: 20px; font-weight: 700; color: #0f172a; }
.status-chip--parsed { background: #f0fdf4; border-color: #bbf7d0; }
.status-chip--parsed .status-chip__count { color: #16a34a; }
.status-chip--queued, .status-chip--parsing, .status-chip--uploading { background: #fffbeb; border-color: #fde68a; }
.status-chip--queued .status-chip__count, .status-chip--parsing .status-chip__count, .status-chip--uploading .status-chip__count { color: #d97706; }
.status-chip--failed_transient { background: #fff7ed; border-color: #fed7aa; }
.status-chip--failed_transient .status-chip__count { color: #ea580c; }
.status-chip--failed_terminal, .status-chip--content_not_recognized { background: #fef2f2; border-color: #fecaca; }
.status-chip--failed_terminal .status-chip__count, .status-chip--content_not_recognized .status-chip__count { color: #dc2626; }

.list { list-style: none; padding: 0; margin: 0; display: grid; gap: 8px; font-size: 13px; color: #334155; }
.list-meta { display: block; font-size: 11px; color: #94a3b8; margin-top: 4px; }
.inline-link { margin-left: 6px; font-size: 12px; color: #2563eb; text-decoration: none; }
.inline-link:hover { text-decoration: underline; }

.retention-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f1f5f9;
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
  gap: 12px;
}
.stat-grid__label { font-size: 12px; color: #64748b; }
.stat-grid__value { font-size: 18px; font-weight: 700; color: #0f172a; }

.skeleton-row { display: flex; gap: 16px; margin-bottom: 24px; }
.skeleton-card { flex: 1; height: 90px; background: #e2e8f0; border-radius: 10px; animation: pulse 1.4s ease-in-out infinite; }
.skeleton-block { height: 200px; background: #e2e8f0; border-radius: 10px; animation: pulse 1.4s ease-in-out infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
</style>
