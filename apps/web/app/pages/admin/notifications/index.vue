<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'

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

const notificationType = ref<'announcement' | 'incident' | 'support' | 'billing' | 'referral' | 'system'>('announcement')
const category = ref<'admin_announcements' | 'billing' | 'referrals' | 'product' | 'security' | 'compliance'>('admin_announcements')
const recipientScope = ref<'all' | 'segment' | 'single'>('segment')
const recipientSegment = ref('mobile')
const recipientUserId = ref('')
const title = ref('')
const body = ref('')
const deepLink = ref('')
const approvalToken = ref('')

const requiresApproval = computed(() => recipientScope.value !== 'single')
const canDryRun = computed(() => title.value.trim().length >= 3 && body.value.trim().length >= 3)
const canSendLive = computed(() => canDryRun.value && (!requiresApproval.value || approvalToken.value.trim().length > 0))

async function loadNotifications() {
  loading.value = true
  error.value = ''
  try {
    const [metricsRes, auditRes] = await Promise.all([
      adminFetch<{ data: Metrics }>('/admin/notifications/metrics'),
      adminFetch<{ data: { items: PushAuditItem[] } }>('/admin/notifications/push/audit?page=1&pageSize=25'),
    ])
    metrics.value = metricsRes.data
    auditItems.value = auditRes.data.items
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load notification operations'
  } finally {
    loading.value = false
  }
}

function buildPayload(includeApproval: boolean) {
  const payload: Record<string, unknown> = {
    notificationType: notificationType.value,
    category: category.value,
    recipientScope: recipientScope.value,
    title: title.value.trim(),
    body: body.value.trim(),
    idempotencyKey: `push-${Date.now()}-${Math.random().toString(36).slice(2)}`,
  }
  if (recipientScope.value === 'segment') payload.recipientSegment = recipientSegment.value.trim()
  if (recipientScope.value === 'single') payload.recipientUserId = recipientUserId.value.trim()
  if (deepLink.value.trim()) payload.deepLink = deepLink.value.trim()
  if (includeApproval && approvalToken.value.trim()) payload.approvalToken = approvalToken.value.trim()
  return payload
}

async function dryRunPush() {
  if (!canDryRun.value) return
  sending.value = true
  error.value = ''
  resultMessage.value = ''
  try {
    const res = await adminFetch<{ data: PushAuditItem }>('/admin/notifications/push/dry-run', {
      method: 'POST',
      body: buildPayload(false),
    })
    resultMessage.value = `Dry run matched ${res.data.targetCount} active tokens (${res.data.skippedCount} skipped by preferences).`
    await loadNotifications()
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Dry run failed'
  } finally {
    sending.value = false
  }
}

async function sendLivePush() {
  if (!canSendLive.value) return
  sending.value = true
  error.value = ''
  resultMessage.value = ''
  try {
    const res = await adminFetch<{ data: PushAuditItem }>('/admin/notifications/push/send', {
      method: 'POST',
      body: buildPayload(true),
    })
    resultMessage.value = `Live push completed: ${res.data.sentCount} sent, ${res.data.failedCount} failed.`
    await loadNotifications()
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Live push failed'
  } finally {
    sending.value = false
  }
}

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
  return new Date(iso).toLocaleString('en-IN', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  })
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
        <small>Tracked by mobile push-open calls</small>
      </div>
      <div class="metric-card">
        <span class="metric-label">Failures</span>
        <strong>{{ metrics?.deliveryByOutcome?.failed ?? 0 }}</strong>
        <small>{{ metrics?.deliveryByOutcome?.sent ?? 0 }} sent deliveries</small>
      </div>
    </div>

    <section class="panel">
      <h3 class="section-title">Broadcast</h3>
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
      <div class="form-grid">
        <label>
          Type
          <select v-model="notificationType">
            <option value="announcement">Announcement</option>
            <option value="incident">Incident</option>
            <option value="support">Support</option>
            <option value="billing">Billing</option>
            <option value="referral">Referral</option>
            <option value="system">System</option>
          </select>
        </label>
        <label>
          Category
          <select v-model="category">
            <option value="admin_announcements">Admin announcements</option>
            <option value="billing">Billing</option>
            <option value="referrals">Referrals</option>
            <option value="product">Product</option>
            <option value="security">Security</option>
            <option value="compliance">Compliance</option>
          </select>
        </label>
        <label>
          Audience
          <select v-model="recipientScope">
            <option value="segment">Segment</option>
            <option value="single">Single user</option>
            <option value="all">All active tokens</option>
          </select>
        </label>
        <label v-if="recipientScope === 'segment'">
          Segment
          <select v-model="recipientSegment">
            <option value="mobile">Mobile apps</option>
            <option value="android">Android</option>
            <option value="ios">iOS</option>
            <option value="web">Web browsers</option>
            <option value="mobile_web">Mobile web</option>
            <option value="all">All platforms</option>
          </select>
        </label>
        <label v-if="recipientScope === 'single'">
          User ID
          <input v-model="recipientUserId" type="text" placeholder="User UUID" />
        </label>
        <label>
          Deep link
          <input v-model="deepLink" type="text" placeholder="doclyzer://..." />
        </label>
        <label class="span-2">
          Title
          <input v-model="title" type="text" maxlength="120" placeholder="Short notification title" />
        </label>
        <label class="span-2">
          Body
          <textarea v-model="body" rows="3" maxlength="280" placeholder="Notification body" />
        </label>
        <label v-if="requiresApproval" class="span-2">
          Approval token
          <input v-model="approvalToken" type="password" placeholder="Required for segment and all live sends" />
        </label>
      </div>
      <div class="actions">
        <button class="secondary-btn" :disabled="sending || !canDryRun" @click="dryRunPush">Dry run</button>
        <button class="primary-btn" :disabled="sending || !canSendLive" @click="sendLivePush">Send push</button>
      </div>
    </section>

    <section class="panel">
      <h3 class="section-title">Push Audit</h3>
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
    </section>
  </div>
</template>

<style scoped>
.notifications-page { max-width: 1180px; }
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
