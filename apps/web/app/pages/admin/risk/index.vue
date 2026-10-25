<script setup lang="ts">
import { formatDisplayDate } from '../../../utils/formatDisplayDate'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Risk — Doclyzer Admin' })

type Severity = 'low' | 'medium' | 'high' | 'critical'
type Status = 'open' | 'in_review' | 'resolved'
type Action = 'review' | 'resolve' | 'restrict' | 'suspend'
interface QueueItem {
  id: string
  targetType: string
  targetId: string
  signalType: string
  ruleCode: string
  severity: Severity
  status: Status
  confidenceScore: number
  detectionSummary: string | null
  detectionCount: number
  lastDetectedAt: string
  suggestedContainment: { action: string; reason: string } | null
}
interface QueueResponse { items: QueueItem[]; page: number; limit: number; total: number }

const { adminFetch } = useAdminApi()
const items = ref<QueueItem[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 20
const severityFilter = ref('')
const statusFilter = ref('')
const pageSearch = ref('')
const loading = ref(true)
const error = ref('')
const notice = ref('')
const dialog = ref<{ item: QueueItem; action: Action } | null>(null)
const auditNote = ref('')
const dialogError = ref('')
const saving = ref(false)
const noteInput = ref<HTMLTextAreaElement | null>(null)
let requestId = 0
let lastTrigger: HTMLElement | null = null

const pageCount = computed(() => Math.max(1, Math.ceil(total.value / pageSize)))
const visibleItems = computed(() => {
  const term = pageSearch.value.trim().toLowerCase()
  if (!term) return items.value
  return items.value.filter(item => [item.targetType, item.targetId, item.signalType, item.ruleCode, item.detectionSummary]
    .some(value => (value ?? '').toLowerCase().includes(term)))
})
const criticalCount = computed(() => items.value.filter(item => item.severity === 'critical').length)
const highCount = computed(() => items.value.filter(item => item.severity === 'high').length)
const openCount = computed(() => items.value.filter(item => item.status === 'open').length)

async function loadQueue() {
  const currentRequest = ++requestId
  loading.value = true
  error.value = ''
  try {
    const query = new URLSearchParams({ page: String(page.value), limit: String(pageSize) })
    if (severityFilter.value) query.set('severity', severityFilter.value)
    if (statusFilter.value) query.set('status', statusFilter.value)
    const response = await adminFetch<{ data: QueueResponse }>(`/admin/risk/suspicious-activity-queue?${query}`)
    if (currentRequest !== requestId) return
    items.value = response.data.items
    total.value = response.data.total
  } catch (e: unknown) {
    if (currentRequest !== requestId) return
    items.value = []
    total.value = 0
    error.value = e instanceof Error ? e.message : 'Could not load the risk queue.'
  } finally {
    if (currentRequest === requestId) loading.value = false
  }
}

function changeFilters() {
  page.value = 1
  pageSearch.value = ''
  loadQueue()
}
function changePage(nextPage: number) {
  if (nextPage < 1 || nextPage > pageCount.value) return
  page.value = nextPage
  pageSearch.value = ''
  loadQueue()
}
function canContain(item: QueueItem) {
  return item.targetType === 'account' || item.targetType === 'user'
}
function actionTitle(action: Action) {
  return { review: 'Mark in review', resolve: 'Resolve signal', restrict: 'Restrict account', suspend: 'Emergency suspend account' }[action]
}
function openDialog(item: QueueItem, action: Action, event: Event) {
  lastTrigger = event.currentTarget as HTMLElement
  dialog.value = { item, action }
  auditNote.value = ''
  dialogError.value = ''
  nextTick(() => noteInput.value?.focus())
}
function closeDialog() {
  if (saving.value) return
  dialog.value = null
  nextTick(() => lastTrigger?.focus())
}
function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape' && dialog.value) closeDialog()
}

async function submitAction() {
  if (!dialog.value || saving.value) return
  const note = auditNote.value.trim()
  if (note.length < (dialog.value.action === 'suspend' ? 10 : 1)) {
    dialogError.value = dialog.value.action === 'suspend'
      ? 'Enter at least 10 characters for the emergency audit note.'
      : 'Add a note explaining this action.'
    return
  }
  if (dialog.value.action !== 'suspend' && note.length > 256) {
    dialogError.value = 'Keep the note within 256 characters.'
    return
  }
  const { item, action } = dialog.value
  saving.value = true
  dialogError.value = ''
  try {
    if (action === 'review' || action === 'resolve') {
      await adminFetch(`/admin/risk/suspicious-activity/${encodeURIComponent(item.id)}/status`, {
        method: 'PATCH', body: { status: action === 'review' ? 'in_review' : 'resolved', notes: note },
      })
    } else if (action === 'restrict') {
      await adminFetch(`/admin/risk-controls/accounts/${encodeURIComponent(item.targetId)}/restriction`, {
        method: 'PATCH', body: { mode: 'suspended', rationale: note },
      })
    } else {
      await adminFetch(`/admin/emergency/accounts/${encodeURIComponent(item.targetId)}/suspension`, {
        method: 'PATCH', body: { suspended: true, auditNote: note },
      })
    }
    dialog.value = null
    notice.value = `${actionTitle(action)} applied to ${item.targetType} ${item.targetId}.`
    await loadQueue()
    if (page.value > pageCount.value) changePage(pageCount.value)
    nextTick(() => lastTrigger?.focus())
  } catch (e: unknown) {
    dialogError.value = e instanceof Error ? e.message : 'The action could not be applied.'
  } finally {
    saving.value = false
  }
}

onMounted(() => { loadQueue(); window.addEventListener('keydown', onKeydown) })
onUnmounted(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <div class="admin-ops risk-page">
    <header class="admin-ops__header">
      <div>
        <p class="admin-ops__eyebrow">Operations / Risk</p>
        <h1>Suspicious activity</h1>
        <p class="admin-ops__subtitle">Review detection signals and record containment decisions.</p>
      </div>
      <button class="admin-ops__button" type="button" :disabled="loading" @click="loadQueue">Refresh queue</button>
    </header>

    <p v-if="notice" class="admin-ops__message" role="status">{{ notice }}</p>
    <p v-if="error" class="admin-ops__message admin-ops__message--error" role="alert">{{ error }}</p>

    <section class="risk-overview" aria-label="Current page summary">
      <div class="risk-overview__item"><span>Signals in queue</span><strong>{{ total }}</strong><small>Across all matching pages</small></div>
      <div class="risk-overview__item"><span>Critical on this page</span><strong class="risk-overview__number--red">{{ criticalCount }}</strong><small>Prioritize immediate review</small></div>
      <div class="risk-overview__item"><span>High on this page</span><strong class="risk-overview__number--warm">{{ highCount }}</strong><small>Elevated severity</small></div>
      <div class="risk-overview__item"><span>Open on this page</span><strong>{{ openCount }}</strong><small>Awaiting review</small></div>
    </section>

    <section class="admin-ops__card risk-queue" aria-labelledby="risk-queue-title">
      <div class="risk-queue__heading">
        <div><h2 id="risk-queue-title">Detection queue</h2><p>Filter across the queue, then search within the loaded page.</p></div>
        <span class="risk-queue__count">{{ total }} matching signals</span>
      </div>
      <div class="risk-filters">
        <label class="admin-ops__field">Severity
          <select v-model="severityFilter" class="admin-ops__select" @change="changeFilters">
            <option value="">All severities</option><option value="critical">Critical</option><option value="high">High</option><option value="medium">Medium</option><option value="low">Low</option>
          </select>
        </label>
        <label class="admin-ops__field">Status
          <select v-model="statusFilter" class="admin-ops__select" @change="changeFilters">
            <option value="">All statuses</option><option value="open">Open</option><option value="in_review">In review</option><option value="resolved">Resolved</option>
          </select>
        </label>
        <label class="admin-ops__field risk-filters__search">Search this page
          <input v-model="pageSearch" class="admin-ops__input" type="search" placeholder="Target, rule, or summary" />
        </label>
      </div>

      <div v-if="loading" class="risk-loading" role="status">Loading signals…</div>
      <div v-else-if="error" class="admin-ops__empty">Queue unavailable. Use Refresh queue to try again.</div>
      <div v-else-if="!visibleItems.length" class="admin-ops__empty">
        {{ pageSearch ? 'No signals on this page match your search.' : 'No signals match these filters.' }}
      </div>
      <div v-else class="admin-ops__table-wrap">
        <table class="admin-ops__table risk-table">
          <thead><tr><th scope="col">Target</th><th scope="col">Detection</th><th scope="col">Severity</th><th scope="col">Status</th><th scope="col">Last detected</th><th scope="col">Actions</th></tr></thead>
          <tbody>
            <tr v-for="item in visibleItems" :key="item.id">
              <td><strong>{{ item.targetType }}</strong><span class="risk-table__sub risk-table__id">{{ item.targetId }}</span></td>
              <td class="risk-table__summary"><strong>{{ item.detectionSummary || item.signalType }}</strong><span class="risk-table__sub">{{ item.ruleCode }} · {{ item.detectionCount }} {{ item.detectionCount === 1 ? 'detection' : 'detections' }} · {{ item.confidenceScore }}% confidence</span><span v-if="item.suggestedContainment" class="risk-table__sub">Suggested: {{ item.suggestedContainment.action.replaceAll('_', ' ') }}</span></td>
              <td><span class="risk-pill" :class="`risk-pill--${item.severity}`">{{ item.severity }}</span></td>
              <td><span class="risk-pill risk-pill--status" :class="`risk-pill--${item.status}`">{{ item.status.replace('_', ' ') }}</span></td>
              <td class="risk-table__date">{{ formatDisplayDate(item.lastDetectedAt, true) }}</td>
              <td><div class="risk-actions">
                <button v-if="item.status === 'open'" class="risk-actions__button" type="button" @click="openDialog(item, 'review', $event)">Review</button>
                <button v-if="item.status !== 'resolved'" class="risk-actions__button" type="button" @click="openDialog(item, 'resolve', $event)">Resolve</button>
                <button v-if="canContain(item) && item.status !== 'resolved'" class="risk-actions__button risk-actions__button--warm" type="button" @click="openDialog(item, 'restrict', $event)">Restrict</button>
                <button v-if="canContain(item) && item.status !== 'resolved'" class="risk-actions__button risk-actions__button--danger" type="button" @click="openDialog(item, 'suspend', $event)">Suspend</button>
                <span v-if="item.status === 'resolved'" class="risk-table__sub">No pending action</span>
              </div></td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="!loading && !error && total > pageSize" class="admin-ops__pagination">
        <span>Page {{ page }} of {{ pageCount }} · {{ total }} signals</span>
        <div><button class="admin-ops__button" type="button" :disabled="page <= 1" @click="changePage(page - 1)">Previous</button><button class="admin-ops__button" type="button" :disabled="page >= pageCount" @click="changePage(page + 1)">Next</button></div>
      </div>
    </section>

    <div v-if="dialog" class="risk-dialog-overlay" @click.self="closeDialog">
      <form class="risk-dialog" role="dialog" aria-modal="true" aria-labelledby="risk-dialog-title" @submit.prevent="submitAction">
        <p class="admin-ops__eyebrow">Risk action</p>
        <h2 id="risk-dialog-title">{{ actionTitle(dialog.action) }}</h2>
        <p class="risk-dialog__target">{{ dialog.item.targetType }} · {{ dialog.item.targetId }}</p>
        <p class="risk-dialog__help">{{ dialog.action === 'suspend' ? 'This immediately suspends account access and records an emergency audit event.' : dialog.action === 'restrict' ? 'This restricts account access. The queue signal remains open until you resolve it.' : 'This updates the detection queue and records your note.' }}</p>
        <p v-if="dialogError" class="admin-ops__message admin-ops__message--error" role="alert">{{ dialogError }}</p>
        <label class="admin-ops__field">Audit note
          <textarea ref="noteInput" v-model="auditNote" class="admin-ops__textarea" :maxlength="dialog.action === 'suspend' ? 1024 : 256" rows="4" required placeholder="Explain why this action is needed" />
        </label>
        <div class="risk-dialog__actions">
          <button class="admin-ops__button" type="button" :disabled="saving" @click="closeDialog">Cancel</button>
          <button class="admin-ops__button" :class="dialog.action === 'suspend' ? 'risk-dialog__danger' : 'admin-ops__button--primary'" type="submit" :disabled="saving">{{ saving ? 'Applying…' : actionTitle(dialog.action) }}</button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
.risk-page { max-width: 1280px; }
.risk-overview { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; margin-bottom: 22px; }
.risk-overview__item { display: grid; gap: 5px; min-width: 0; padding: 18px 20px; border: 1px solid var(--brand-border); border-radius: 14px; background: #fff; box-shadow: 0 10px 24px rgba(13, 27, 42, .05); }
.risk-overview__item span { color: var(--brand-muted); font-size: 13px; font-weight: 700; }
.risk-overview__item strong { color: var(--brand-ink); font-size: 27px; line-height: 1.15; }
.risk-overview__item small { color: var(--brand-muted); font-size: 12px; }
.risk-overview__item .risk-overview__number--red { color: #a9342a; }
.risk-overview__item .risk-overview__number--warm { color: #94601a; }
.risk-queue__heading { display: flex; align-items: start; justify-content: space-between; gap: 12px; }
.risk-queue__heading p { margin: 0; color: var(--brand-muted); font-size: 14px; }
.risk-queue__count { white-space: nowrap; color: var(--brand-muted); font-size: 13px; }
.risk-filters { display: grid; grid-template-columns: minmax(145px, 190px) minmax(145px, 190px) minmax(220px, 1fr); gap: 12px; margin: 12px 0 20px; }
.risk-filters .admin-ops__field { margin: 0; }
.risk-loading { padding: 44px; text-align: center; color: var(--brand-muted); }
.risk-table { min-width: 880px; }
.risk-table td { vertical-align: top; }
.risk-table strong { font-weight: 700; }
.risk-table__summary { min-width: 240px; max-width: 360px; }
.risk-table__sub { display: block; margin-top: 4px; color: var(--brand-muted); font-size: 12px; line-height: 1.45; }
.risk-table__id { max-width: 180px; overflow-wrap: anywhere; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
.risk-table__date { white-space: nowrap; }
.risk-pill { display: inline-flex; align-items: center; min-height: 25px; padding: 3px 9px; border-radius: 99px; background: #edf2f5; color: #425968; font-size: 12px; font-weight: 700; text-transform: capitalize; white-space: nowrap; }
.risk-pill--critical { background: #ffe9e6; color: #a9342a; }
.risk-pill--high { background: #fff2dd; color: #94601a; }
.risk-pill--medium { background: #fff7e9; color: #805b27; }
.risk-pill--low, .risk-pill--resolved { background: var(--brand-mint); color: var(--brand-teal); }
.risk-pill--open { background: #eaf1fb; color: var(--brand-blue); }
.risk-pill--in_review { background: #fff2dd; color: #94601a; }
.risk-actions { display: flex; flex-wrap: wrap; gap: 6px; min-width: 168px; }
.risk-actions__button { padding: 6px 9px; border: 1px solid var(--brand-border); border-radius: 7px; background: #fff; color: var(--brand-blue); font: 700 12px var(--font-ui); cursor: pointer; white-space: nowrap; }
.risk-actions__button:hover { background: var(--brand-mint); }
.risk-actions__button--warm { border-color: #e8d0a0; color: #805414; }
.risk-actions__button--danger { border-color: #e7b3ae; color: #a9342a; }
.risk-actions__button--danger:hover { background: #fff1ef; }
.risk-dialog-overlay { position: fixed; inset: 0; z-index: 200; display: grid; place-items: center; padding: 16px; background: rgba(13, 27, 42, .55); }
.risk-dialog { width: min(100%, 490px); max-height: calc(100vh - 32px); overflow-y: auto; padding: 26px; border-radius: 16px; background: #fff; box-shadow: 0 24px 70px rgba(13, 27, 42, .25); }
.risk-dialog h2 { margin: 0; color: var(--brand-ink); font: 700 22px var(--font-display); }
.risk-dialog__target { margin: 6px 0 14px; color: var(--brand-muted); overflow-wrap: anywhere; font-size: 13px; }
.risk-dialog__help { margin: 0 0 18px; color: var(--brand-ink); font-size: 14px; line-height: 1.5; }
.risk-dialog__actions { display: flex; justify-content: flex-end; flex-wrap: wrap; gap: 9px; margin-top: 20px; }
.risk-dialog__danger { border-color: #ac3029; background: #ac3029; color: white; }
.risk-dialog__danger:hover { background: #8e211c; }
@media (max-width: 850px) { .risk-overview { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
@media (max-width: 640px) { .risk-filters { grid-template-columns: repeat(2, minmax(0, 1fr)); } .risk-filters__search { grid-column: 1 / -1; } .risk-queue__heading { flex-direction: column; } }
@media (max-width: 430px) { .risk-overview { gap: 8px; } .risk-overview__item { padding: 13px; } .risk-overview__item strong { font-size: 23px; } .risk-filters { grid-template-columns: 1fr; } .risk-filters__search { grid-column: auto; } }
</style>
