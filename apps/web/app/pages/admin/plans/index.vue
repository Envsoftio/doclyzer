<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Plans — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

interface PlanLimits {
  maxProfilesPerPlan: number
  reportCap: number
  shareLinkLimit: number
  aiChatEnabled: boolean
}
interface PlanConfig {
  planId: string
  planName: string
  tier: 'free' | 'paid'
  isActive: boolean
  configVersion: number
  limits: PlanLimits
}

const plans = ref<PlanConfig[]>([])
const edits = ref<Record<string, PlanLimits>>({})
const loading = ref(true)
const savingId = ref<string | null>(null)
const error = ref('')
const success = ref('')
const orderedPlans = computed(() => [...plans.value].sort((a, b) => {
  const order: Record<string, number> = { Free: 0, Starter: 1, Pro: 2, 'Pro Monthly': 2 }
  return (order[a.planName] ?? 3) - (order[b.planName] ?? 3)
}))

function changed(plan: PlanConfig) {
  const edit = edits.value[plan.planId]
  return !!edit && Object.keys(edit).some(key =>
    edit[key as keyof PlanLimits] !== plan.limits[key as keyof PlanLimits],
  )
}

async function loadPlans() {
  loading.value = true
  error.value = ''
  try {
    const response = await adminFetch<{ data: { plans: PlanConfig[] } }>('/entitlements/admin/plan-configs')
    plans.value = response.data.plans
    edits.value = Object.fromEntries(plans.value.map(plan => [plan.planId, { ...plan.limits }]))
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Failed to load plans.'
  } finally {
    loading.value = false
  }
}

async function savePlan(plan: PlanConfig) {
  if (savingId.value) return
  const edit = edits.value[plan.planId]
  if (!edit) return
  const fields: Array<[number, number, string]> = [
    [edit.maxProfilesPerPlan, 1, 'Profiles'],
    [edit.reportCap, 1, 'Reports'],
    [edit.shareLinkLimit, 0, 'Share links'],
  ]
  for (const [value, minimum, label] of fields) {
    if (!Number.isSafeInteger(value) || value < minimum) {
      error.value = `${label} must be a whole number of at least ${minimum}.`
      return
    }
  }
  savingId.value = plan.planId
  error.value = ''
  success.value = ''
  try {
    const response = await adminFetch<{ data: { plan: PlanConfig } }>(
      `/entitlements/admin/plan-configs/${encodeURIComponent(plan.planId)}`,
      { method: 'PUT', body: { ...edit, expectedConfigVersion: plan.configVersion } },
    )
    const saved = response.data.plan
    plans.value = plans.value.map(item => item.planId === saved.planId ? saved : item)
    edits.value[saved.planId] = { ...saved.limits }
    success.value = `${saved.planName} limits saved.`
  } catch (e: unknown) {
    if (typeof e === 'object' && e !== null && 'statusCode' in e && e.statusCode === 409) {
      await loadPlans()
      error.value = 'The plan changed while saving. Review the current limits and try again.'
    } else {
      error.value = e instanceof Error ? e.message : 'Failed to save plan limits.'
    }
  } finally {
    savingId.value = null
  }
}

onMounted(loadPlans)
</script>

<template>
  <div class="plans-page admin-ops">
    <header class="page-header">
      <div>
        <p class="admin-ops__eyebrow">Manage / Product</p>
        <h1>Plans</h1>
        <p>Set limits for Free, Starter, and Pro users. Report limits apply to stored reports and uploads in progress.</p>
      </div>
      <button type="button" class="secondary-btn" :disabled="loading || !!savingId" @click="loadPlans">Refresh</button>
    </header>
    <p v-if="error" class="message error" role="alert">{{ error }}</p>
    <p v-if="success" class="message success" role="status">{{ success }}</p>
    <p v-if="loading">Loading plan settings…</p>
    <p v-else-if="!orderedPlans.length">No plans found. Run the database migrations.</p>
    <div v-else class="plan-grid">
      <form v-for="plan in orderedPlans" :key="plan.planId" class="plan-card" @submit.prevent="savePlan(plan)">
        <div class="plan-heading">
          <div>
            <h3>{{ plan.planName }}</h3>
            <p>{{ plan.isActive ? 'Active' : 'Inactive — unavailable for new subscriptions' }}</p>
          </div>
          <span>Version {{ plan.configVersion }}</span>
        </div>
        <template v-if="edits[plan.planId]">
          <label :for="`profiles-${plan.planId}`">Maximum profiles per user</label>
          <input :id="`profiles-${plan.planId}`" v-model.number="edits[plan.planId]!.maxProfilesPerPlan" type="number" min="1" step="1" required inputmode="numeric">
          <label :for="`reports-${plan.planId}`">Maximum reports per user</label>
          <input :id="`reports-${plan.planId}`" v-model.number="edits[plan.planId]!.reportCap" type="number" min="1" step="1" required inputmode="numeric">
          <label :for="`links-${plan.planId}`">Maximum share links per user</label>
          <input :id="`links-${plan.planId}`" v-model.number="edits[plan.planId]!.shareLinkLimit" type="number" min="0" step="1" required inputmode="numeric">
          <label class="checkbox-label"><input v-model="edits[plan.planId]!.aiChatEnabled" type="checkbox">AI chat enabled</label>
        </template>
        <p class="hint">Changes apply to new actions immediately. Existing files and profiles remain available.</p>
        <button type="submit" class="primary-btn" :disabled="!!savingId || !changed(plan)">
          {{ savingId === plan.planId ? 'Saving…' : 'Save limits' }}
        </button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.plans-page { max-width: 1280px; }
.page-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; margin-bottom: 24px; }
.page-header p:not(.admin-ops__eyebrow), .plan-heading p, .hint { color: #607186; font-size: 13px; line-height: 1.55; }
.page-header p:not(.admin-ops__eyebrow) { margin: 8px 0 0; }
.plan-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(290px, 1fr)); gap: 18px; }
.plan-card { background: rgba(255,255,255,.9); border: 1px solid rgba(13,27,42,.1); border-radius: 16px; padding: 22px; box-shadow: 0 12px 28px rgba(13,27,42,.06); }
.plan-heading { display: flex; justify-content: space-between; gap: 16px; align-items: flex-start; margin-bottom: 24px; }
.plan-heading h3 { margin: 0; font: 700 19px var(--font-display); color: #0d1b2a; }
.plan-heading p { margin: 5px 0 0; }
.plan-heading span { color: #607186; font-size: 11px; white-space: nowrap; }
label { display: block; color: #34465b; font-size: 12px; font-weight: 700; margin: 16px 0 8px; }
input[type='number'] { width: 100%; border: 1px solid #cbd6e2; border-radius: 9px; min-height: 42px; padding: 9px 11px; background: #fff; color: #17283b; font: 500 13px var(--font-ui); }
.checkbox-label { display: flex; align-items: center; gap: 8px; }
.checkbox-label input { accent-color: var(--brand-teal); }
.hint { margin: 18px 0; }
button { min-height: 40px; border-radius: 9px; padding: 9px 14px; font: 700 12px var(--font-ui); cursor: pointer; }
button:disabled { opacity: .55; cursor: not-allowed; }
button:focus-visible, input:focus-visible { outline: 2px solid var(--brand-teal-bright); outline-offset: 2px; }
.primary-btn { border: 1px solid var(--brand-blue); background: var(--brand-blue); color: #fff; }
.primary-btn:hover { background: #0d405e; }
.secondary-btn { border: 1px solid #ccd6e0; background: #fff; color: #26394d; }
.message { padding: 11px 13px; border-radius: 9px; font-size: 13px; }
.error { background: #fff1ef; border: 1px solid #efbeb9; color: #a52626; }
.success { background: #effaf3; border: 1px solid #b9dfcb; color: #16653b; }
@media (max-width: 640px) { .page-header { flex-direction: column; } .plan-card { padding: 16px; } }
</style>
