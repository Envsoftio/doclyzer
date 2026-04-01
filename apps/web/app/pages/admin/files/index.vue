<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Files — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

interface PipelineStatus {
  statusCounts: Record<string, number>
  totalInFlight: number
  oldestInFlightCreatedAt: string | null
}

const data = ref<PipelineStatus | null>(null)
const loading = ref(true)
const error = ref('')
let refreshTimer: ReturnType<typeof setInterval>

async function loadData() {
  error.value = ''
  try {
    const res = await adminFetch<{ data: PipelineStatus }>('/admin/analytics/files/pipeline-status')
    data.value = (res as Record<string, PipelineStatus>).data
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load pipeline status'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
  refreshTimer = setInterval(loadData, 30_000)
})
onUnmounted(() => clearInterval(refreshTimer))

const STATUS_CONFIG: Record<string, { label: string; cls: string }> = {
  parsed: { label: 'Parsed', cls: 'card--green' },
  queued: { label: 'Queued', cls: 'card--amber' },
  parsing: { label: 'Parsing', cls: 'card--amber' },
  uploading: { label: 'Uploading', cls: 'card--amber' },
  failed_transient: { label: 'Failed (transient)', cls: 'card--orange' },
  failed_terminal: { label: 'Failed (terminal)', cls: 'card--red' },
  content_not_recognized: { label: 'Not recognized', cls: 'card--red' },
  unparsed: { label: 'Unparsed', cls: 'card--grey' },
}

function statusLabel(s: string): string {
  return STATUS_CONFIG[s]?.label ?? s
}
function statusClass(s: string): string {
  return STATUS_CONFIG[s]?.cls ?? 'card--grey'
}
function fmtDate(iso: string): string {
  return new Date(iso).toLocaleString('en-IN', { dateStyle: 'medium', timeStyle: 'short' })
}
</script>

<template>
  <div class="files-page">
    <div class="page-header">
      <h2 class="page-title">File Pipeline</h2>
      <span class="refresh-hint">Auto-refreshes every 30s</span>
    </div>

    <div v-if="error" class="error-box">{{ error }}</div>

    <div v-if="loading" class="skeleton-row">
      <div v-for="i in 6" :key="i" class="skeleton-card" />
    </div>

    <template v-else-if="data">
      <!-- In-flight banner -->
      <div class="inflight-banner" :class="data.totalInFlight > 0 ? 'inflight-banner--active' : ''">
        <span class="inflight-count">{{ data.totalInFlight }}</span>
        <span>files currently in-flight (uploading / queued / parsing)</span>
        <span v-if="data.oldestInFlightCreatedAt" class="inflight-oldest">
          · oldest since {{ fmtDate(data.oldestInFlightCreatedAt) }}
        </span>
      </div>

      <!-- Status cards -->
      <div class="card-grid">
        <div
          v-for="(count, status) in data.statusCounts"
          :key="status"
          class="status-card"
          :class="statusClass(status as string)"
        >
          <div class="status-card__label">{{ statusLabel(status as string) }}</div>
          <div class="status-card__count">{{ count }}</div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.files-page { max-width: 900px; }
.page-header { display: flex; align-items: baseline; gap: 16px; margin-bottom: 24px; }
.page-title { font-size: 22px; font-weight: 700; color: #0f172a; margin: 0; }
.refresh-hint { font-size: 12px; color: #94a3b8; }

.error-box { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 6px; padding: 10px 14px; font-size: 13px; margin-bottom: 16px; }

.inflight-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 14px 18px;
  margin-bottom: 24px;
  font-size: 14px;
  color: #374151;
}
.inflight-banner--active { background: #fffbeb; border-color: #fde68a; }
.inflight-count { font-size: 28px; font-weight: 700; color: #d97706; min-width: 40px; }
.inflight-banner--active .inflight-count { color: #d97706; }
.inflight-oldest { font-size: 12px; color: #94a3b8; }

.card-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 16px; }

.status-card {
  border-radius: 10px;
  padding: 20px;
  border: 1px solid #e2e8f0;
  background: #f8fafc;
}
.status-card__label { font-size: 12px; color: #64748b; margin-bottom: 8px; }
.status-card__count { font-size: 32px; font-weight: 700; color: #0f172a; }

.card--green { background: #f0fdf4; border-color: #bbf7d0; }
.card--green .status-card__count { color: #16a34a; }
.card--amber { background: #fffbeb; border-color: #fde68a; }
.card--amber .status-card__count { color: #d97706; }
.card--orange { background: #fff7ed; border-color: #fed7aa; }
.card--orange .status-card__count { color: #ea580c; }
.card--red { background: #fef2f2; border-color: #fecaca; }
.card--red .status-card__count { color: #dc2626; }
.card--grey { background: #f8fafc; border-color: #e2e8f0; }
.card--grey .status-card__count { color: #64748b; }

.skeleton-row { display: flex; gap: 16px; flex-wrap: wrap; }
.skeleton-card { width: 160px; height: 100px; background: #e2e8f0; border-radius: 10px; animation: pulse 1.4s ease-in-out infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
</style>
