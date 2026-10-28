<script setup lang="ts">
import PushCampaigns from '../../../components/admin/PushCampaigns.vue'
import { formatDisplayDate } from '../../../utils/formatDisplayDate'
import { onMounted, ref } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Notifications — Doclyzer Admin' })

const { adminFetch } = useAdminApi()
const { enableWebPush, webPushConfigured, webPushSupported } = useWebPushRegistration()

interface Metrics {
  snapshotAt: string
  activePushTokens: number
  activePushTokensByPlatform: Record<string, number>
  pushSends: number
  livePushSends: number
  pushOpens: number
  deliveryByOutcome: Record<string, number>
}

interface PushAuditItem {
  id: string
  senderUserId: string | null
  notificationType: string
  status: string
  audienceFilter: Record<string, string | number | boolean | null>
  title: string
  body: string
  dryRun: boolean
  targetCount: number
  sentCount: number
  failedCount: number
  skippedCount: number
  provider: string | null
  createdAt: string
}

const loading = ref(true)
const sending = ref(false)
const error = ref('')
const resultMessage = ref('')
const webPushStatus = ref('')
const metrics = ref<Metrics | null>(null)
const auditItems = ref<PushAuditItem[]>([])
const auditPage = ref(1)
const auditPageSize = ref(25)
const auditTotal = ref(0)
const auditTotalPages = ref(1)
const auditDryRun = ref('')

async function loadNotifications() {
  loading.value = true
  error.value = ''
  try {
    const [metricsRes, auditRes] = await Promise.all([
      adminFetch<{ data: Metrics }>('/admin/notifications/metrics'),
      adminFetch<{ data: { items: PushAuditItem[]; pagination: { total: number; totalPages: number } } }>(`/admin/notifications/push/audit?page=${auditPage.value}&pageSize=${auditPageSize.value}${auditDryRun.value ? `&dryRun=${auditDryRun.value}` : ''}`),
    ])
    metrics.value = metricsRes.data
    auditItems.value = auditRes.data.items
    auditTotal.value = auditRes.data.pagination.total
    auditTotalPages.value = auditRes.data.pagination.totalPages
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load notification operations'
  } finally {
    loading.value = false
  }
}
function applyAuditFilter() { auditPage.value = 1; void loadNotifications() }
function changeAuditPage(next: number) { auditPage.value = next; void loadNotifications() }

async function enableCurrentBrowserPush() {
  webPushStatus.value = ''
  error.value = ''
  try {
    const id = await enableWebPush()
    webPushStatus.value = `This browser is registered for push (${id}).`
    await loadNotifications()
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Web push registration failed'
  }
}

function formatDate(iso: string): string {
  return formatDisplayDate(iso, true)
}

function platformSummary(value: Record<string, number> | undefined): string {
  if (!value) return 'No active tokens'
  const rows = Object.entries(value).filter(([, count]) => count > 0)
  if (rows.length === 0) return 'No active tokens'
  return rows.map(([platform, count]) => `${platform}: ${count}`).join(' · ')
}

onMounted(loadNotifications)
</script>

<template>
  <div class="notifications-page">
    <PushCampaigns />
    <div class="page-header">
      <div>
        <h2 class="page-title">Notifications</h2>
        <p class="page-subtitle">Push broadcasts, delivery health, and audit trail.</p>
      </div>
      <button class="secondary-btn" :disabled="loading" @click="loadNotifications">Refresh</button>
    </div>

    <div v-if="error" class="error-box" role="alert" aria-live="assertive">{{ error }}</div>
    <div v-if="resultMessage" class="success-box" role="status">{{ resultMessage }}</div>

    <div class="metrics-grid">
      <div class="metric-card">
        <span class="metric-label">Active tokens</span>
        <strong>{{ metrics?.activePushTokens ?? '—' }}</strong>
        <small>{{ platformSummary(metrics?.activePushTokensByPlatform) }}</small>
      </div>
      <div class="metric-card">
        <span class="metric-label">Live sends</span>
        <strong>{{ metrics?.livePushSends ?? '—' }}</strong>
        <small>{{ metrics?.pushSends ?? 0 }} total including dry runs</small>
      </div>
      <div class="metric-card">
        <span class="metric-label">Opens</span>
        <strong>{{ metrics?.pushOpens ?? '—' }}</strong>
        <small>Recorded app opens; campaign tests excluded</small>
      </div>
      <div class="metric-card">
        <span class="metric-label">Failures</span>
        <strong>{{ metrics?.deliveryByOutcome?.failed ?? 0 }}</strong>
        <small>{{ metrics?.deliveryByOutcome?.sent ?? 0 }} provider-accepted requests</small>
      </div>
    </div>

    <section class="panel">
      <h3 class="section-title">Browser registration</h3>
      <div class="browser-push-row">
        <div>
          <strong>Current browser</strong>
          <span>{{ webPushConfigured ? 'Firebase web push config detected.' : 'Firebase web push config is not set.' }}</span>
          <small v-if="webPushStatus">{{ webPushStatus }}</small>
        </div>
        <button
          class="secondary-btn"
          :disabled="!webPushSupported || !webPushConfigured"
          @click="enableCurrentBrowserPush"
        >
          Enable web push
        </button>
      </div>
    </section>

    <section class="panel">
      <h3 class="section-title">Push Audit</h3>
      <div class="audit-controls"><label>Send type<select v-model="auditDryRun" @change="applyAuditFilter"><option value="">All</option><option value="true">Dry runs</option><option value="false">Live sends</option></select></label><label>Rows per page<select v-model.number="auditPageSize" @change="applyAuditFilter"><option :value="25">25</option><option :value="50">50</option><option :value="100">100</option></select></label></div>
      <div v-if="loading" class="empty-state">Loading notification audit…</div>
      <div v-else-if="auditItems.length === 0" class="empty-state">No push sends recorded yet.</div>
      <div v-else class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th>Created</th>
              <th>State</th>
              <th>Audience</th>
              <th>Message</th>
              <th>Targets</th>
              <th>Delivery</th>
              <th>Provider</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in auditItems" :key="item.id">
              <td>{{ formatDate(item.createdAt) }}</td>
              <td>
                <span class="state-pill" :class="{ 'state-pill--dry': item.dryRun }">
                  {{ item.dryRun ? 'dry run' : item.status }}
                </span>
              </td>
              <td>{{ item.audienceFilter.recipientScope }} {{ item.audienceFilter.recipientSegment || '' }}</td>
              <td>
                <strong>{{ item.title }}</strong>
                <span>{{ item.body }}</span>
              </td>
              <td>{{ item.targetCount }} <span v-if="item.skippedCount">({{ item.skippedCount }} skipped)</span></td>
              <td>{{ item.sentCount }} sent · {{ item.failedCount }} failed</td>
              <td>{{ item.provider || '—' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="!loading && auditTotal" class="admin-ops__pagination"><span>{{ (auditPage - 1) * auditPageSize + 1 }}–{{ Math.min(auditPage * auditPageSize, auditTotal) }} of {{ auditTotal }}</span><div><button class="admin-ops__button" :disabled="auditPage <= 1" @click="changeAuditPage(auditPage - 1)">Previous</button><span>Page {{ auditPage }} of {{ auditTotalPages }}</span><button class="admin-ops__button" :disabled="auditPage >= auditTotalPages" @click="changeAuditPage(auditPage + 1)">Next</button></div></div>
    </section>
  </div>
</template>

<style scoped>
.notifications-page { max-width: 1180px; }
.audit-controls { display: flex; gap: 12px; flex-wrap: wrap; margin: 12px 0; }
.audit-controls label { min-width: 155px; }
.page-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; margin-bottom: 20px; }
.page-title { font-size: 22px; font-weight: 700; margin: 0 0 4px; color: #0f172a; }
.page-subtitle { margin: 0; color: #64748b; font-size: 13px; }

.error-box,
.success-box { border-radius: 6px; padding: 10px 14px; font-size: 13px; margin-bottom: 16px; }
.error-box { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
.success-box { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }

.metrics-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 18px; }
.metric-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; min-height: 104px; display: flex; flex-direction: column; gap: 6px; }
.metric-label { color: #64748b; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; }
.metric-card strong { font-size: 28px; line-height: 1; color: #0f172a; }
.metric-card small { color: #64748b; font-size: 12px; line-height: 1.4; }

.panel { background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 18px; margin-bottom: 18px; }
.section-title { font-size: 16px; margin: 0 0 16px; color: #0f172a; }
.browser-push-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; margin-bottom: 16px; background: #f8fafc; }
.browser-push-row div { display: flex; flex-direction: column; gap: 3px; }
.browser-push-row strong { font-size: 13px; color: #0f172a; }
.browser-push-row span,
.browser-push-row small { font-size: 12px; color: #64748b; }
.form-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
label { display: flex; flex-direction: column; gap: 6px; font-size: 12px; font-weight: 600; color: #475569; }
.span-2 { grid-column: span 2; }
input,
select,
textarea { width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 9px 10px; font: inherit; color: #0f172a; background: #fff; box-sizing: border-box; }
textarea { resize: vertical; min-height: 86px; }
input:focus,
select:focus,
textarea:focus { outline: none; border-color: #2563eb; box-shadow: 0 0 0 2px #dbeafe; }
.actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 16px; }

.primary-btn,
.secondary-btn { border-radius: 6px; padding: 8px 14px; font: inherit; font-weight: 700; cursor: pointer; }
.primary-btn { border: 1px solid #1d4ed8; background: #1d4ed8; color: #fff; }
.secondary-btn { border: 1px solid #cbd5e1; background: #fff; color: #334155; }
.primary-btn:disabled,
.secondary-btn:disabled { opacity: 0.45; cursor: not-allowed; }

.table-wrap { width: 100%; overflow-x: auto; -webkit-overflow-scrolling: touch; }
.table { width: 100%; min-width: 960px; border-collapse: collapse; font-size: 13px; }
.table th { background: #f8fafc; padding: 10px 12px; text-align: left; color: #475569; font-weight: 700; white-space: nowrap; }
.table td { padding: 10px 12px; border-top: 1px solid #f1f5f9; color: #334155; vertical-align: top; }
.table td strong { display: block; color: #0f172a; margin-bottom: 2px; }
.table td span { color: #64748b; }
.state-pill { display: inline-flex; align-items: center; border-radius: 999px; background: #dcfce7; color: #166534; padding: 2px 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
.state-pill--dry { background: #e0f2fe; color: #0369a1; }
.empty-state { color: #64748b; font-size: 14px; padding: 28px 0; text-align: center; }

@media (max-width: 920px) {
  .metrics-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}

@media (max-width: 640px) {
  .page-header { flex-direction: column; }
  .metrics-grid,
  .form-grid { grid-template-columns: 1fr; }
  .span-2 { grid-column: span 1; }
  .actions { justify-content: stretch; }
  .actions button { flex: 1; }
  .browser-push-row { flex-direction: column; align-items: stretch; }
}
</style>
