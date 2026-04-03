<script setup lang="ts">
import { ref, onMounted } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Risk — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

interface FlaggedAccount {
  userId: string
  email?: string
  reason?: string
  flaggedAt?: string
  severity?: string
  [key: string]: unknown
}

const queue = ref<FlaggedAccount[]>([])
const loading = ref(true)
const error = ref('')

const modal = ref<{ open: boolean; action: 'restrict' | 'suspend'; userId: string; email: string }>({
  open: false, action: 'restrict', userId: '', email: '',
})
const modalNote = ref('')
const modalLoading = ref(false)
const modalError = ref('')
const modalSuccess = ref('')

onMounted(async () => {
  try {
    const res = await adminFetch<{ data: FlaggedAccount[] }>('/admin/risk/suspicious-activity-queue')
    const raw = (res as Record<string, unknown>).data
    queue.value = Array.isArray(raw) ? raw : []
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load risk queue'
  } finally {
    loading.value = false
  }
})

function openModal(action: 'restrict' | 'suspend', userId: string, email: string) {
  modal.value = { open: true, action, userId, email }
  modalNote.value = ''
  modalError.value = ''
  modalSuccess.value = ''
}

function closeModal() {
  modal.value.open = false
}

async function submitAction() {
  if (!modalNote.value.trim()) {
    modalError.value = 'A note is required for audit purposes.'
    return
  }
  modalError.value = ''
  modalLoading.value = true
  try {
    if (modal.value.action === 'restrict') {
      await adminFetch(`/admin/risk/accounts/${modal.value.userId}/restriction`, {
        method: 'PATCH',
        body: { note: modalNote.value.trim(), restrictionType: 'restricted' },
      })
    } else {
      await adminFetch(`/admin/emergency/accounts/${modal.value.userId}/suspension`, {
        method: 'PATCH',
        body: { note: modalNote.value.trim() },
      })
    }
    modalSuccess.value = `Action applied successfully.`
    queue.value = queue.value.filter((u) => u.userId !== modal.value.userId)
    setTimeout(closeModal, 1500)
  } catch (e: unknown) {
    modalError.value = (e instanceof Error ? e.message : String(e)) || 'Action failed'
  } finally {
    modalLoading.value = false
  }
}

function fmtDate(iso?: string): string {
  if (!iso) return '—'
  return new Date(iso).toLocaleString('en-IN', { dateStyle: 'medium', timeStyle: 'short' })
}
</script>

<template>
  <div class="risk-page">
    <h2 class="page-title">Risk & Suspicious Activity</h2>

    <div v-if="error" class="error-box" role="alert" aria-live="assertive">
      {{ error }}
    </div>

    <div v-if="loading" class="skeleton-block" />

    <template v-else>
      <div v-if="queue.length === 0" class="empty-state">
        No flagged accounts in the queue.
      </div>

      <table v-else class="table">
        <thead>
          <tr>
            <th>User</th>
            <th>Reason</th>
            <th>Flagged at</th>
            <th>Severity</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in queue" :key="item.userId">
            <td class="td-email">{{ item.email || item.userId }}</td>
            <td>{{ item.reason || '—' }}</td>
            <td>{{ fmtDate(item.flaggedAt) }}</td>
            <td>
              <span class="badge" :class="item.severity === 'high' ? 'badge--red' : 'badge--amber'">
                {{ item.severity || 'medium' }}
              </span>
            </td>
            <td class="td-actions">
              <button class="btn-action btn-action--restrict" @click="openModal('restrict', item.userId, item.email || item.userId)">
                Restrict
              </button>
              <button class="btn-action btn-action--suspend" @click="openModal('suspend', item.userId, item.email || item.userId)">
                Suspend
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </template>

    <!-- Action modal -->
    <div v-if="modal.open" class="modal-overlay" @click.self="closeModal">
      <div class="modal">
        <h3 class="modal-title">
          {{ modal.action === 'restrict' ? 'Restrict Account' : 'Emergency Suspend Account' }}
        </h3>
        <p class="modal-user">{{ modal.email }}</p>

        <div v-if="modalError" class="error-box" role="alert" aria-live="assertive">
          {{ modalError }}
        </div>
        <div v-if="modalSuccess" class="success-box" role="status" aria-live="polite">{{ modalSuccess }}</div>

        <label class="form-label">
          Mandatory audit note
          <textarea v-model="modalNote" class="form-textarea" rows="3" placeholder="Reason for this action…" required />
        </label>

        <div class="modal-actions">
          <button class="btn-cancel" @click="closeModal">Cancel</button>
          <button
            class="btn-confirm"
            :class="modal.action === 'suspend' ? 'btn-confirm--red' : ''"
            :disabled="modalLoading"
            @click="submitAction"
          >
            {{ modalLoading ? 'Applying…' : modal.action === 'restrict' ? 'Restrict' : 'Suspend' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.risk-page { max-width: 1000px; }
.page-title { font-size: 22px; font-weight: 700; margin: 0 0 24px; color: #0f172a; }

.error-box { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 6px; padding: 10px 14px; font-size: 13px; margin-bottom: 16px; }
.success-box { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; border-radius: 6px; padding: 10px 14px; font-size: 13px; margin-bottom: 16px; }
.empty-state { text-align: center; padding: 48px; color: #6b7280; font-size: 14px; }

.table { width: 100%; border-collapse: collapse; font-size: 13px; background: #fff; border-radius: 8px; overflow: hidden; border: 1px solid #e2e8f0; }
.table th { background: #f8fafc; padding: 10px 14px; text-align: left; font-weight: 600; color: #374151; }
.table td { padding: 10px 14px; border-top: 1px solid #f1f5f9; color: #374151; }
.td-email { font-weight: 500; color: #1e293b; }
.td-actions { display: flex; gap: 8px; }

.badge { font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 999px; }
.badge--red { background: #fee2e2; color: #991b1b; }
.badge--amber { background: #fef9c3; color: #854d0e; }

.btn-action { padding: 5px 12px; font-size: 12px; font-weight: 600; border: none; border-radius: 5px; cursor: pointer; font-family: inherit; }
.btn-action--restrict { background: #fef3c7; color: #92400e; }
.btn-action--restrict:hover { background: #fde68a; }
.btn-action--suspend { background: #fee2e2; color: #991b1b; }
.btn-action--suspend:hover { background: #fecaca; }

.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 200;
  display: flex; align-items: center; justify-content: center;
}
.modal {
  background: #fff; border-radius: 12px; padding: 32px; width: 100%; max-width: 420px;
  box-shadow: 0 8px 40px rgba(0,0,0,0.15);
}
.modal-title { font-size: 17px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
.modal-user { font-size: 13px; color: #64748b; margin: 0 0 20px; }
.modal-note { font-size: 11px; color: #94a3b8; margin-top: 14px; }

.form-label { display: flex; flex-direction: column; gap: 6px; font-size: 13px; font-weight: 500; color: #374151; margin-bottom: 16px; }
.form-textarea { padding: 10px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 13px; font-family: inherit; resize: vertical; outline: none; }
.form-textarea:focus { border-color: #6366f1; }

.modal-actions { display: flex; gap: 10px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: #f1f5f9; border: 1px solid #d1d5db; border-radius: 6px; font-size: 13px; cursor: pointer; font-family: inherit; }
.btn-cancel:hover { background: #e2e8f0; }
.btn-confirm { padding: 8px 16px; background: #4f46e5; color: #fff; border: none; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer; font-family: inherit; }
.btn-confirm:hover:not(:disabled) { background: #4338ca; }
.btn-confirm--red { background: #dc2626; }
.btn-confirm--red:hover:not(:disabled) { background: #b91c1c; }
.btn-confirm:disabled { opacity: 0.6; cursor: not-allowed; }

.skeleton-block { height: 300px; background: #e2e8f0; border-radius: 10px; animation: pulse 1.4s ease-in-out infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
</style>
