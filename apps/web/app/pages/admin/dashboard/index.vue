<script setup lang="ts">
import { ref, onMounted } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Dashboard — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

const startDate = ref(new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10))
const endDate = ref(new Date().toISOString().slice(0, 10))

const coreMetrics = ref<Record<string, unknown> | null>(null)
const activityMetrics = ref<Record<string, unknown> | null>(null)
const pipelineStatus = ref<Record<string, unknown> | null>(null)
const loading = ref(true)
const error = ref('')

async function loadData() {
  loading.value = true
  error.value = ''
  try {
    const [core, activity, pipeline] = await Promise.all([
      adminFetch<{ data: Record<string, unknown> }>(
        `/admin/analytics/core-product?startDate=${startDate.value}T00:00:00Z&endDate=${endDate.value}T23:59:59Z`,
      ),
      adminFetch<{ data: Record<string, unknown> }>('/admin/analytics/user-activity'),
      adminFetch<{ data: Record<string, unknown> }>('/admin/analytics/files/pipeline-status'),
    ])
    coreMetrics.value = (core as Record<string, unknown>).data as Record<string, unknown>
    activityMetrics.value = (activity as Record<string, unknown>).data as Record<string, unknown>
    pipelineStatus.value = (pipeline as Record<string, unknown>).data as Record<string, unknown>
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load data'
  } finally {
    loading.value = false
  }
}

onMounted(loadData)

function getMetric(path: string): unknown {
  const parts = path.split('.')
  let obj: unknown = coreMetrics.value
  for (const p of parts) {
    if (obj == null || typeof obj !== 'object') return '-'
    obj = (obj as Record<string, unknown>)[p]
  }
  return obj ?? '-'
}

function pct(n: unknown): string {
  return typeof n === 'number' ? `${n.toFixed(1)}%` : '-'
}
</script>

<template>
  <div class="dashboard">
    <h2 class="page-title">Dashboard</h2>

    <!-- Date range -->
    <div class="date-range">
      <label>From <input v-model="startDate" type="date" class="date-input" /></label>
      <label>To <input v-model="endDate" type="date" class="date-input" /></label>
      <button class="btn-secondary" @click="loadData">Refresh</button>
    </div>

    <div v-if="error" class="error-box">{{ error }}</div>

    <template v-if="loading">
      <div class="skeleton-row">
        <div v-for="i in 4" :key="i" class="skeleton-card" />
      </div>
      <div class="skeleton-block" />
    </template>

    <template v-else>
      <!-- Core metric cards -->
      <div class="card-row">
        <div class="metric-card">
          <div class="metric-label">Signups</div>
          <div class="metric-value">{{ getMetric('metrics.signups.current') }}</div>
          <div class="metric-delta">vs {{ getMetric('metrics.signups.baseline') }}</div>
        </div>
        <div class="metric-card">
          <div class="metric-label">Sessions</div>
          <div class="metric-value">{{ getMetric('metrics.usage.current') }}</div>
          <div class="metric-delta">vs {{ getMetric('metrics.usage.baseline') }}</div>
        </div>
        <div class="metric-card">
          <div class="metric-label">Revenue</div>
          <div class="metric-value">₹{{ getMetric('metrics.monetization.current') }}</div>
          <div class="metric-delta">vs ₹{{ getMetric('metrics.monetization.baseline') }}</div>
        </div>
        <div class="metric-card">
          <div class="metric-label">Parse Success</div>
          <div class="metric-value">{{ pct(getMetric('metrics.behavior.current')) }}</div>
          <div class="metric-delta">vs {{ pct(getMetric('metrics.behavior.baseline')) }}</div>
        </div>
      </div>

      <!-- Activity overview -->
      <div v-if="activityMetrics" class="section">
        <h3 class="section-title">Activity Overview</h3>
        <div class="card-row">
          <div class="stat-chip">
            <span class="stat-chip__label">Total Users</span>
            <span class="stat-chip__value">{{ (activityMetrics as Record<string,unknown>).totalUsers }}</span>
          </div>
          <div class="stat-chip">
            <span class="stat-chip__label">Active (7d)</span>
            <span class="stat-chip__value">{{ (activityMetrics as Record<string,unknown>).activeUsersLast7Days }}</span>
          </div>
          <div class="stat-chip">
            <span class="stat-chip__label">Profiles</span>
            <span class="stat-chip__value">{{ (activityMetrics as Record<string,unknown>).totalProfiles }}</span>
          </div>
          <div class="stat-chip">
            <span class="stat-chip__label">In Pipeline</span>
            <span class="stat-chip__value stat-chip__value--amber">{{ (activityMetrics as Record<string,unknown>).reportsInPipeline }}</span>
          </div>
        </div>
      </div>

      <!-- Funnel -->
      <div v-if="coreMetrics && (coreMetrics as Record<string,unknown>).funnel" class="section">
        <h3 class="section-title">Funnel</h3>
        <table class="table">
          <thead><tr><th>Stage</th><th>Current</th><th>Baseline</th><th>Delta</th></tr></thead>
          <tbody>
            <tr v-for="row in ((coreMetrics as Record<string,unknown>).funnel as Record<string,unknown>[])" :key="(row as Record<string,unknown>).stage as string">
              <td>{{ (row as Record<string,string>).stage }}</td>
              <td>{{ (row as Record<string,unknown>).currentValue }}</td>
              <td>{{ (row as Record<string,unknown>).baselineValue }}</td>
              <td :class="{ 'td-green': Number((row as Record<string,unknown>).delta) > 0, 'td-red': Number((row as Record<string,unknown>).delta) < 0 }">
                {{ Number((row as Record<string,unknown>).delta) > 0 ? '+' : '' }}{{ (row as Record<string,unknown>).delta }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pipeline status -->
      <div v-if="pipelineStatus" class="section">
        <h3 class="section-title">Processing Status <span class="badge-amber">{{ (pipelineStatus as Record<string,unknown>).totalInFlight }} in-flight</span></h3>
        <div class="card-row">
          <div
            v-for="(count, status) in ((pipelineStatus as Record<string,unknown>).statusCounts as Record<string,number>)"
            :key="status"
            class="status-chip"
            :class="`status-chip--${status}`"
          >
            <span class="status-chip__name">{{ status }}</span>
            <span class="status-chip__count">{{ count }}</span>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.dashboard { max-width: 1100px; }
.page-title { font-size: 22px; font-weight: 700; margin: 0 0 24px; color: #0f172a; }

.date-range {
  display: flex;
  gap: 12px;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 24px;
  font-size: 13px;
  color: #374151;
}
.date-input {
  margin-left: 6px;
  padding: 6px 10px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 13px;
  font-family: inherit;
}
.btn-secondary {
  padding: 6px 14px;
  background: #f1f5f9;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  font-family: inherit;
}
.btn-secondary:hover { background: #e2e8f0; }

.error-box {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
  border-radius: 6px;
  padding: 10px 14px;
  font-size: 13px;
  margin-bottom: 16px;
}

.card-row { display: flex; flex-wrap: wrap; gap: 16px; margin-bottom: 24px; }

.metric-card {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 20px 24px;
  min-width: 160px;
  flex: 1;
}
.metric-label { font-size: 12px; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 6px; }
.metric-value { font-size: 28px; font-weight: 700; color: #0f172a; }
.metric-delta { font-size: 12px; color: #94a3b8; margin-top: 4px; }

.stat-chip {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 14px 18px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 120px;
  flex: 1;
}
.stat-chip__label { font-size: 12px; color: #64748b; }
.stat-chip__value { font-size: 22px; font-weight: 700; color: #0f172a; }
.stat-chip__value--amber { color: #d97706; }

.section { margin-bottom: 32px; }
.section-title { font-size: 15px; font-weight: 600; color: #1e293b; margin: 0 0 14px; display: flex; align-items: center; gap: 10px; }

.badge-amber {
  font-size: 12px;
  font-weight: 500;
  background: #fef3c7;
  color: #92400e;
  padding: 2px 8px;
  border-radius: 999px;
}

.table { width: 100%; border-collapse: collapse; font-size: 13px; background: #fff; border-radius: 8px; overflow: hidden; border: 1px solid #e2e8f0; }
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
  min-width: 100px;
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

.skeleton-row { display: flex; gap: 16px; margin-bottom: 24px; }
.skeleton-card { flex: 1; height: 90px; background: #e2e8f0; border-radius: 10px; animation: pulse 1.4s ease-in-out infinite; }
.skeleton-block { height: 200px; background: #e2e8f0; border-radius: 10px; animation: pulse 1.4s ease-in-out infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
</style>
