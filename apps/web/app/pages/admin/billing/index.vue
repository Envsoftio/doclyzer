<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Billing — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

interface BillingOrderItem {
  id: string
  userId: string
  userEmail: string
  userDisplayName: string | null
  creditPackId: string
  creditPackName: string
  credits: number
  amount: number
  finalAmount: number
  currency: string
  status: string
  statusLabel: string
  credited: boolean
  provider: 'revenuecat' | 'razorpay' | 'internal'
  checkoutProvider: 'revenuecat' | 'razorpay' | 'internal'
  orderReference: string
  paymentReference: string | null
  failureReason: string | null
  reviewReason: string | null
  createdAt: string
  updatedAt: string
}

interface BillingResponse {
  items: BillingOrderItem[]
  pagination: {
    page: number
    pageSize: number
    totalItems: number
    totalPages: number
  }
}

const loading = ref(true)
const savingAdjustment = ref(false)
const error = ref('')
const resultMessage = ref('')
const orders = ref<BillingOrderItem[]>([])
const totalItems = ref(0)
const totalPages = ref(1)
const page = ref(1)
const pageSize = 25

const search = ref('')
const status = ref('all')
const reviewState = ref<'all' | 'needs_review' | 'clear'>('all')
const dateFrom = ref('')
const dateTo = ref('')

const selectedOrder = ref<BillingOrderItem | null>(null)
const adjustmentOpen = ref(false)
const adjustmentAmount = ref('')
const adjustmentReason = ref('')
const adjustmentError = ref('')

let debounceTimer: ReturnType<typeof setTimeout>

const statusOptions = [
  { label: 'All statuses', value: 'all' },
  { label: 'Pending payment', value: 'payment_pending' },
  { label: 'Client confirmed', value: 'client_purchase_confirmed' },
  { label: 'Webhook pending', value: 'webhook_pending' },
  { label: 'Reconciled', value: 'reconciled' },
  { label: 'Failed', value: 'failed' },
  { label: 'Pending review', value: 'pending_review' },
]

async function loadOrders() {
  loading.value = true
  error.value = ''
  try {
    const params = new URLSearchParams({
      page: String(page.value),
      pageSize: String(pageSize),
      reviewState: reviewState.value,
    })
    if (search.value.trim()) params.set('search', search.value.trim())
    if (status.value !== 'all') params.set('status', status.value)
    if (dateFrom.value) params.set('dateFrom', dateFrom.value)
    if (dateTo.value) params.set('dateTo', dateTo.value)

    const res = await adminFetch<{ data: BillingResponse }>(`/billing/admin/orders?${params.toString()}`)
    const data = (res as Record<string, BillingResponse>).data
    orders.value = data?.items ?? []
    totalItems.value = data?.pagination.totalItems ?? 0
    totalPages.value = data?.pagination.totalPages ?? 1
    if (selectedOrder.value) {
      selectedOrder.value = orders.value.find((item) => item.id === selectedOrder.value?.id) ?? selectedOrder.value
    }
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load billing orders'
  } finally {
    loading.value = false
  }
}

watch(search, () => {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    page.value = 1
    loadOrders()
  }, 300)
})

watch([status, reviewState, dateFrom, dateTo], () => {
  page.value = 1
  loadOrders()
})

onMounted(loadOrders)
onUnmounted(() => clearTimeout(debounceTimer))

function formatDate(iso: string): string {
  return new Date(iso).toLocaleString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

function formatMoney(amount: number, currency: string): string {
  const prefix = currency === 'INR' ? '₹' : `${currency} `
  return `${prefix}${amount.toFixed(2)}`
}

function statusBadgeClass(value: string): string {
  switch (value) {
    case 'reconciled':
      return 'badge badge--green'
    case 'pending_review':
      return 'badge badge--amber'
    case 'failed':
      return 'badge badge--red'
    default:
      return 'badge badge--blue'
  }
}

function openAdjustment(order: BillingOrderItem) {
  selectedOrder.value = order
  adjustmentOpen.value = true
  adjustmentAmount.value = ''
  adjustmentReason.value = ''
  adjustmentError.value = ''
  resultMessage.value = ''
}

async function submitAdjustment() {
  if (!selectedOrder.value) return
  const amount = Number(adjustmentAmount.value)
  if (!Number.isFinite(amount) || amount === 0) {
    adjustmentError.value = 'Enter a non-zero credit adjustment.'
    return
  }
  if (!adjustmentReason.value.trim()) {
    adjustmentError.value = 'A reason is required.'
    return
  }

  savingAdjustment.value = true
  adjustmentError.value = ''
  error.value = ''
  try {
    const res = await adminFetch<{ data: { adjustment: { newCreditBalance: number } } }>(
      '/billing/admin/manual-credit-adjustments',
      {
        method: 'POST',
        body: {
          userId: selectedOrder.value.userId,
          adjustment: amount,
          reason: adjustmentReason.value.trim(),
        },
      },
    )
    const balance = (res as Record<string, { adjustment: { newCreditBalance: number } }>).data?.adjustment.newCreditBalance
    resultMessage.value = `Credit adjustment saved. New balance: ${balance?.toFixed(2) ?? 'updated'}.`
    adjustmentOpen.value = false
    await loadOrders()
  } catch (e: unknown) {
    adjustmentError.value = (e instanceof Error ? e.message : String(e)) || 'Failed to save credit adjustment'
  } finally {
    savingAdjustment.value = false
  }
}

const showingOrdersLabel = computed(() => `${orders.value.length} of ${totalItems.value} orders`)
</script>

<template>
  <div class="billing-page">
    <div class="page-header">
      <div>
        <h2 class="page-title">Billing</h2>
        <p class="page-subtitle">Review order reconciliation and apply audited manual credit adjustments.</p>
      </div>
      <button class="secondary-btn" :disabled="loading" @click="loadOrders">Refresh</button>
    </div>

    <div class="toolbar">
      <input v-model="search" type="search" class="search-input" placeholder="Search by user, order, or payment reference…" />
      <select v-model="status" class="select-input">
        <option v-for="item in statusOptions" :key="item.value" :value="item.value">{{ item.label }}</option>
      </select>
      <select v-model="reviewState" class="select-input">
        <option value="all">All review states</option>
        <option value="needs_review">Needs review</option>
        <option value="clear">Clear only</option>
      </select>
      <input v-model="dateFrom" type="date" class="date-input" />
      <input v-model="dateTo" type="date" class="date-input" />
      <span class="total-label">{{ showingOrdersLabel }}</span>
    </div>

    <div v-if="error" class="error-box" role="alert" aria-live="assertive">{{ error }}</div>
    <div v-if="resultMessage" class="success-box" role="status">{{ resultMessage }}</div>

    <div v-if="loading" class="skeleton-table">
      <div v-for="i in 8" :key="i" class="skeleton-row" />
    </div>

    <template v-else>
      <div v-if="orders.length === 0" class="empty-state">No billing orders match the current filters.</div>

      <div v-else class="layout-grid">
        <div class="table-wrap">
          <table class="table">
            <thead>
              <tr>
                <th>User</th>
                <th>Pack</th>
                <th>Total</th>
                <th>Status</th>
                <th>Provider</th>
                <th>Updated</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in orders" :key="order.id" class="table-row">
                <td>
                  <div class="cell-strong">{{ order.userEmail }}</div>
                  <div class="cell-subtle">{{ order.userDisplayName || order.userId }}</div>
                </td>
                <td>
                  <div class="cell-strong">{{ order.creditPackName }}</div>
                  <div class="cell-subtle">{{ order.credits }} credits</div>
                </td>
                <td>
                  <div class="cell-strong">{{ formatMoney(order.finalAmount, order.currency) }}</div>
                  <div class="cell-subtle">Base {{ formatMoney(order.amount, order.currency) }}</div>
                </td>
                <td>
                  <span :class="statusBadgeClass(order.status)">{{ order.statusLabel }}</span>
                  <div v-if="order.reviewReason" class="cell-warning">{{ order.reviewReason }}</div>
                  <div v-else-if="order.failureReason" class="cell-warning">{{ order.failureReason }}</div>
                </td>
                <td>
                  <div class="cell-strong">{{ order.provider }}</div>
                  <div class="cell-subtle">{{ order.paymentReference || order.orderReference }}</div>
                </td>
                <td>{{ formatDate(order.updatedAt) }}</td>
                <td class="actions-cell">
                  <button class="link-btn" @click="selectedOrder = order">Details</button>
                  <button class="link-btn" @click="openAdjustment(order)">Adjust credits</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <aside class="detail-panel">
          <template v-if="selectedOrder">
            <h3 class="detail-title">Order details</h3>
            <dl class="detail-list">
              <div><dt>User</dt><dd>{{ selectedOrder.userEmail }}</dd></div>
              <div><dt>Pack</dt><dd>{{ selectedOrder.creditPackName }} · {{ selectedOrder.credits }} credits</dd></div>
              <div><dt>Status</dt><dd>{{ selectedOrder.statusLabel }}</dd></div>
              <div><dt>Review</dt><dd>{{ selectedOrder.reviewReason || 'Clear' }}</dd></div>
              <div><dt>Failure</dt><dd>{{ selectedOrder.failureReason || '—' }}</dd></div>
              <div><dt>Provider</dt><dd>{{ selectedOrder.provider }}</dd></div>
              <div><dt>Order ref</dt><dd>{{ selectedOrder.orderReference }}</dd></div>
              <div><dt>Payment ref</dt><dd>{{ selectedOrder.paymentReference || '—' }}</dd></div>
              <div><dt>Total</dt><dd>{{ formatMoney(selectedOrder.finalAmount, selectedOrder.currency) }}</dd></div>
              <div><dt>Credited</dt><dd>{{ selectedOrder.credited ? 'Yes' : 'No' }}</dd></div>
              <div><dt>Created</dt><dd>{{ formatDate(selectedOrder.createdAt) }}</dd></div>
              <div><dt>Updated</dt><dd>{{ formatDate(selectedOrder.updatedAt) }}</dd></div>
            </dl>
            <button class="primary-btn" @click="openAdjustment(selectedOrder)">Manual credit adjustment</button>
          </template>
          <div v-else class="detail-empty">Select an order to inspect reconciliation details.</div>
        </aside>
      </div>

      <div v-if="totalPages > 1" class="pagination">
        <button class="page-btn" :disabled="page <= 1" @click="page -= 1; loadOrders()">← Prev</button>
        <span class="page-info">Page {{ page }} of {{ totalPages }}</span>
        <button class="page-btn" :disabled="page >= totalPages" @click="page += 1; loadOrders()">Next →</button>
      </div>
    </template>

    <div v-if="adjustmentOpen && selectedOrder" class="modal-overlay" @click.self="adjustmentOpen = false">
      <div class="modal">
        <h3 class="modal-title">Manual Credit Adjustment</h3>
        <p class="modal-user">{{ selectedOrder.userEmail }}</p>

        <div v-if="adjustmentError" class="error-box" role="alert" aria-live="assertive">{{ adjustmentError }}</div>

        <label class="form-label">
          Credit delta
          <input v-model="adjustmentAmount" class="text-input" type="number" step="0.01" placeholder="Use negative values to deduct credits" />
        </label>

        <label class="form-label">
          Reason
          <textarea v-model="adjustmentReason" class="text-area" rows="3" placeholder="Required audit reason" />
        </label>

        <div class="modal-actions">
          <button class="secondary-btn" @click="adjustmentOpen = false">Cancel</button>
          <button class="primary-btn" :disabled="savingAdjustment" @click="submitAdjustment">
            {{ savingAdjustment ? 'Saving…' : 'Apply adjustment' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.billing-page { max-width: 1280px; }
.page-header { display: flex; justify-content: space-between; gap: 16px; align-items: flex-start; margin-bottom: 20px; }
.page-title { font-size: 22px; font-weight: 700; margin: 0; color: #0f172a; }
.page-subtitle { margin: 6px 0 0; color: #64748b; font-size: 14px; }

.toolbar { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-bottom: 16px; }
.search-input, .select-input, .date-input, .text-input, .text-area {
  border: 1px solid #d1d5db; border-radius: 6px; font: inherit; padding: 9px 12px; background: #fff;
}
.search-input { min-width: 280px; flex: 1 1 280px; }
.select-input, .date-input { min-width: 150px; }
.text-area { width: 100%; resize: vertical; }
.total-label { font-size: 13px; color: #64748b; }

.layout-grid { display: grid; grid-template-columns: minmax(0, 1fr) 320px; gap: 16px; align-items: start; }
.table-wrap { border: 1px solid #e2e8f0; border-radius: 8px; overflow: auto; background: #fff; }
.table { width: 100%; min-width: 920px; border-collapse: collapse; font-size: 13px; }
.table th { background: #f8fafc; padding: 10px 14px; text-align: left; font-weight: 600; color: #374151; }
.table td { padding: 10px 14px; border-top: 1px solid #f1f5f9; vertical-align: top; }
.table-row:hover td { background: #f8fafc; }
.cell-strong { font-weight: 600; color: #1e293b; }
.cell-subtle { color: #64748b; font-size: 12px; margin-top: 2px; }
.cell-warning { color: #b45309; font-size: 12px; margin-top: 4px; }
.actions-cell { display: flex; gap: 8px; flex-wrap: wrap; }

.detail-panel { border: 1px solid #e2e8f0; border-radius: 8px; background: #fff; padding: 16px; position: sticky; top: 16px; }
.detail-title { margin: 0 0 12px; font-size: 16px; color: #0f172a; }
.detail-empty { color: #64748b; font-size: 14px; }
.detail-list { display: grid; gap: 10px; margin: 0 0 16px; }
.detail-list div { display: grid; gap: 2px; }
.detail-list dt { font-size: 12px; color: #64748b; }
.detail-list dd { margin: 0; color: #0f172a; font-size: 13px; word-break: break-word; }

.badge { display: inline-flex; align-items: center; padding: 3px 8px; border-radius: 999px; font-size: 11px; font-weight: 600; }
.badge--green { background: #dcfce7; color: #166534; }
.badge--amber { background: #fef3c7; color: #92400e; }
.badge--red { background: #fee2e2; color: #991b1b; }
.badge--blue { background: #dbeafe; color: #1d4ed8; }

.error-box { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 6px; padding: 10px 14px; font-size: 13px; margin-bottom: 16px; }
.success-box { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; border-radius: 6px; padding: 10px 14px; font-size: 13px; margin-bottom: 16px; }
.empty-state, .skeleton-row { border-radius: 8px; }
.empty-state { text-align: center; color: #6b7280; padding: 48px; border: 1px dashed #cbd5e1; }
.skeleton-table { display: flex; flex-direction: column; gap: 8px; }
.skeleton-row { height: 44px; background: #e2e8f0; animation: pulse 1.4s ease-in-out infinite; }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; margin-top: 20px; }
.page-info { color: #64748b; font-size: 13px; }

.primary-btn, .secondary-btn, .page-btn, .link-btn {
  border-radius: 6px; font: inherit; cursor: pointer;
}
.primary-btn {
  border: none; background: #4f46e5; color: #fff; padding: 9px 14px; font-weight: 600;
}
.primary-btn:disabled { opacity: 0.6; cursor: not-allowed; }
.secondary-btn, .page-btn {
  border: 1px solid #d1d5db; background: #fff; color: #0f172a; padding: 9px 14px;
}
.link-btn {
  border: none; background: transparent; color: #1d4ed8; padding: 0; font-weight: 600;
}

.modal-overlay { position: fixed; inset: 0; background: rgba(15, 23, 42, 0.4); display: flex; align-items: center; justify-content: center; z-index: 200; }
.modal { width: min(100%, 420px); background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 16px 48px rgba(15, 23, 42, 0.18); }
.modal-title { margin: 0 0 6px; font-size: 18px; color: #0f172a; }
.modal-user { margin: 0 0 16px; color: #64748b; font-size: 13px; }
.form-label { display: grid; gap: 6px; margin-bottom: 14px; font-size: 13px; color: #374151; }
.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 16px; }

@media (max-width: 1100px) {
  .layout-grid { grid-template-columns: 1fr; }
  .detail-panel { position: static; }
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
</style>
