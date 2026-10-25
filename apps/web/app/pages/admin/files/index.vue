<script setup lang="ts">
import { formatDisplayDate } from '../../../utils/formatDisplayDate'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Files — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

interface PipelineStatus {
  statusCounts: Record<string, number>
  totalInFlight: number
  oldestInFlightCreatedAt: string | null
}

const statuses = [
  { key: 'uploading', label: 'Uploading', tone: 'warm' },
  { key: 'queued', label: 'Queued', tone: 'warm' },
  { key: 'parsing', label: 'Parsing', tone: 'warm' },
  { key: 'parsed', label: 'Parsed', tone: 'good' },
  { key: 'unparsed', label: 'Unparsed', tone: 'neutral' },
  { key: 'content_not_recognized', label: 'Not recognized', tone: 'danger' },
  { key: 'failed_transient', label: 'Failed, retryable', tone: 'danger' },
  { key: 'failed_terminal', label: 'Failed, terminal', tone: 'danger' },
] as const

const data = ref<PipelineStatus | null>(null)
const loading = ref(true)
const refreshing = ref(false)
const error = ref('')
const refreshedAt = ref<string | null>(null)
const totalFiles = computed(() => Object.values(data.value?.statusCounts ?? {}).reduce((sum, count) => sum + count, 0))
const failedFiles = computed(() => (data.value?.statusCounts.failed_transient ?? 0) + (data.value?.statusCounts.failed_terminal ?? 0) + (data.value?.statusCounts.content_not_recognized ?? 0))
const statusRows = computed(() => statuses.map(status => ({ ...status, count: data.value?.statusCounts[status.key] ?? 0 })))
let refreshTimer: ReturnType<typeof setInterval> | undefined

async function loadData() {
  if (refreshing.value) return
  refreshing.value = true
  error.value = ''
  try {
    const response = await adminFetch<{ data: PipelineStatus }>('/admin/analytics/files/pipeline-status')
    data.value = response.data
    refreshedAt.value = new Date().toISOString()
  } catch (cause: unknown) {
    error.value = cause instanceof Error ? cause.message : 'Could not load file processing status.'
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

onMounted(() => {
  void loadData()
  refreshTimer = setInterval(() => { void loadData() }, 30_000)
})
onUnmounted(() => { if (refreshTimer) clearInterval(refreshTimer) })

function formatDate(value: string | null): string {
  return value ? formatDisplayDate(value, true) : '—'
}
</script>

<template>
  <div class="admin-ops files-page">
    <header class="admin-ops__header">
      <div>
        <p class="admin-ops__eyebrow">Manage / Files</p>
        <h1>File pipeline</h1>
        <p class="admin-ops__subtitle">Monitor uploads and parsing, then open reports to inspect their original files and extracted results.</p>
      </div>
      <div class="header-actions">
        <button class="admin-ops__button" type="button" :disabled="refreshing" @click="loadData">{{ refreshing ? 'Refreshing…' : 'Refresh status' }}</button>
        <NuxtLink to="/admin/reports" class="admin-ops__button admin-ops__button--primary">Browse reports →</NuxtLink>
      </div>
    </header>

    <p v-if="error" class="admin-ops__message admin-ops__message--error" role="alert">{{ error }}</p>
    <div v-if="loading" class="loading-grid" role="status" aria-label="Loading file pipeline"><div v-for="i in 4" :key="i" /></div>
    <template v-else-if="data">
      <section class="admin-ops__card overview">
        <div class="section-heading"><div><h2>Processing overview</h2><p>Updated automatically every 30 seconds<span v-if="refreshedAt"> · Last checked {{ formatDate(refreshedAt) }}</span></p></div><span v-if="data.totalInFlight" class="admin-ops__badge admin-ops__badge--warm">Processing</span><span v-else class="admin-ops__badge">All caught up</span></div>
        <div class="metric-grid">
          <div class="metric"><span>Total files</span><strong>{{ totalFiles }}</strong><small>Across all processing states</small></div>
          <div class="metric metric--warm"><span>In flight</span><strong>{{ data.totalInFlight }}</strong><small>Uploading, queued, or parsing</small></div>
          <div class="metric metric--good"><span>Parsed</span><strong>{{ data.statusCounts.parsed ?? 0 }}</strong><small>Ready for review in reports</small></div>
          <div class="metric metric--danger"><span>Needs attention</span><strong>{{ failedFiles }}</strong><small>Failed or not recognized</small></div>
        </div>
        <p v-if="data.oldestInFlightCreatedAt" class="queue-note">Oldest in-flight file entered the pipeline {{ formatDate(data.oldestInFlightCreatedAt) }}.</p>
      </section>

      <section class="admin-ops__card breakdown">
        <div class="section-heading"><div><h2>Status breakdown</h2><p>Counts across all users and reports.</p></div><NuxtLink to="/admin/reports">Inspect individual reports →</NuxtLink></div>
        <div class="admin-ops__table-wrap"><table class="admin-ops__table"><thead><tr><th scope="col">Status</th><th scope="col">Files</th><th scope="col">Share</th><th scope="col">View reports</th></tr></thead><tbody><tr v-for="row in statusRows" :key="row.key"><td><span class="admin-ops__badge" :class="{ 'admin-ops__badge--warm': row.tone === 'warm', 'admin-ops__badge--red': row.tone === 'danger' }">{{ row.label }}</span></td><td><strong>{{ row.count }}</strong></td><td>{{ totalFiles ? `${Math.round(row.count / totalFiles * 100)}%` : '0%' }}</td><td><NuxtLink :to="`/admin/reports?status=${row.key}`">Open {{ row.label.toLowerCase() }} →</NuxtLink></td></tr></tbody></table></div>
      </section>
    </template>
  </div>
</template>

<style scoped>
.files-page { max-width: 1280px; }
.header-actions { display: flex; gap: 10px; flex-wrap: wrap; }
.header-actions a { display: inline-flex; align-items: center; justify-content: center; text-decoration: none; }
.header-actions a.admin-ops__button--primary { color: #fff; }
.section-heading { display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 18px; }
.section-heading h2 { margin: 0 0 4px; }
.section-heading p { margin: 0; color: var(--brand-muted); font-size: 14px; }
.section-heading a { font-size: 14px; font-weight: 700; }
.metric-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; }
.metric { min-width: 0; padding: 18px; border: 1px solid var(--brand-border); border-radius: 12px; background: var(--brand-canvas); }
.metric span, .metric strong, .metric small { display: block; }
.metric span { color: var(--brand-muted); font-size: 13px; font-weight: 700; }
.metric strong { margin: 7px 0 3px; color: var(--brand-ink); font-size: clamp(26px, 2.3vw, 36px); line-height: 1.15; }
.metric small { color: var(--brand-muted); font-size: 12px; line-height: 1.5; }
.metric--warm { background: #fff9ee; border-color: #f0dfbc; }
.metric--good { background: var(--brand-mint); border-color: #b9dfd7; }
.metric--danger { background: #fff3f1; border-color: #efcbc6; }
.queue-note { margin: 18px 0 0 !important; padding: 11px 14px; border-radius: 9px; background: #fff9ee; color: #80571f !important; }
.breakdown .admin-ops__table { min-width: 560px; }
.breakdown .admin-ops__table th:nth-child(2), .breakdown .admin-ops__table td:nth-child(2) { text-align: right; }
.loading-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; }
.loading-grid > div { height: 135px; border-radius: 14px; background: var(--brand-mint); animation: pulse 1.4s ease-in-out infinite; }
@keyframes pulse { 50% { opacity: .55; } }
@media (max-width: 900px) { .metric-grid, .loading-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
@media (max-width: 640px) { .metric-grid, .loading-grid { grid-template-columns: 1fr; } .header-actions { width: 100%; } .header-actions > * { flex: 1; } .section-heading { align-items: flex-start; flex-direction: column; } }
@media (prefers-reduced-motion: reduce) { .loading-grid > div { animation: none; } }
</style>
