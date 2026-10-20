<script setup lang="ts">
import type { ConsumerReport } from '../../composables/useConsumer'
import { formatDisplayDate } from '../../utils/formatDisplayDate'
definePageMeta({ layout: 'consumer' })
const { profileId, profiles, request, requireSession } = useConsumer()
const reports = ref<ConsumerReport[]>([])
const query = ref('')
const bin = ref(false)
const loading = ref(true)
const error = ref('')
const busy = ref(false)
let version = 0
useHead({ title: 'Reports | Doclyzer' })
async function load() {
  const id = profileId.value; const current = ++version
  reports.value = []; loading.value = true; error.value = ''
  if (!id) { loading.value = false; return }
  try {
    const result = await request<{ reports: ConsumerReport[] }>(`${bin.value ? '/reports/recycle-bin' : '/reports'}?profileId=${encodeURIComponent(id)}`)
    if (current === version && id === profileId.value) reports.value = result.reports
  } catch (cause) { if (current === version) error.value = (cause as Error).message }
  finally { if (current === version) loading.value = false }
}
onMounted(async () => { try { if (await requireSession()) await load() } catch (cause) { error.value = (cause as Error).message; loading.value = false } })
watch([profileId, bin], () => { query.value = ''; void load() })
const visible = computed(() => reports.value.filter(r => !query.value || `${r.originalFileName} ${r.collectionDate ?? ''} ${r.status} ${(r.extractedLabValues ?? []).map(v => v.parameterName).join(' ')}`.toLowerCase().includes(query.value.toLowerCase())))
const grouped = computed(() => {
  const groups = new Map<string, ConsumerReport[]>()
  for (const r of visible.value) { const key = r.collectionDateStatus === 'multiple' ? 'Multiple collection dates' : r.collectionDate ? formatDisplayDate(r.collectionDate) : 'Unknown collection date'; groups.set(key, [...groups.get(key) ?? [], r]) }
  return [...groups].map(([label, items]) => ({ label, items }))
})
async function changeReport(report: ConsumerReport, action: 'delete' | 'restore' | 'retry') {
  if (action === 'delete' && !confirm(`Move ${report.originalFileName} to the recycle bin?`)) return
  busy.value = true; error.value = ''
  try { await request(`/reports/${encodeURIComponent(report.id)}${action === 'restore' ? '/restore' : action === 'retry' ? '/retry' : ''}`, { method: action === 'delete' ? 'DELETE' : 'POST' }); await load() }
  catch (cause) { error.value = (cause as Error).message } finally { busy.value = false }
}
</script>
<template>
  <div><header class="page-heading"><div><p class="eyebrow">Your records</p><h1>Reports</h1><p class="muted">Browse by collection date and review each result.</p></div><NuxtLink class="button" to="/reports/upload">Add report</NuxtLink></header>
    <div v-if="profiles.length" class="row"><label class="field">Search reports<input v-model="query" type="search" placeholder="Filename, date or status" /></label><div class="actions"><button :class="{ secondary: bin }" @click="bin=false">Reports</button><button :class="{ secondary: !bin }" @click="bin=true">Recycle bin</button></div></div>
    <p v-if="error" role="alert" class="alert error">{{ error }} <button class="secondary" @click="load">Retry</button></p><p v-if="loading" role="status">Loading reports…</p>
    <div v-else-if="!profiles.length" class="empty"><h2>Add a profile first</h2><p>Reports belong to a person in your family.</p><NuxtLink class="button" to="/you">Manage profiles</NuxtLink></div>
    <div v-else-if="!visible.length" class="empty"><h2>{{ query ? 'No matching reports' : bin ? 'Recycle bin is empty' : 'No reports yet' }}</h2><p v-if="!query && !bin">Add a PDF or photo to start your history.</p><NuxtLink v-if="!query && !bin" class="button" to="/reports/upload">Add report</NuxtLink></div>
    <section v-for="group in grouped" v-else :key="group.label"><h2>{{ group.label }}</h2><article v-for="report in group.items" :key="report.id" class="card row"><div><h3><NuxtLink :to="`/reports/${report.id}`">{{ report.originalFileName }}</NuxtLink></h3><p class="muted">Uploaded {{ formatDisplayDate(report.createdAt) }} · {{ (report.processingState ?? report.status).replaceAll('_',' ') }}</p><p v-if="report.purgeAfterAt">Scheduled for permanent deletion {{ formatDisplayDate(report.purgeAfterAt) }}</p></div><div class="actions"><button v-if="bin" :disabled="busy" @click="changeReport(report,'restore')">Restore</button><template v-else><NuxtLink class="button secondary" :to="`/reports/${report.id}`">View results</NuxtLink><button v-if="['failed','needs_attention','cancelled'].includes(report.processingState ?? '')" :disabled="busy" class="secondary" @click="changeReport(report,'retry')">Retry</button><button :disabled="busy" class="text-button" @click="changeReport(report,'delete')">Delete</button></template></div></article></section>
  </div>
</template>
<style scoped>.page-heading{align-items:flex-start}.card h3{margin:0 0 7px;overflow-wrap:anywhere}.card p{margin:0}.card .actions{margin-left:auto}@media(max-width:550px){.page-heading{display:block}.page-heading .button{margin-top:12px}.card .actions{margin-left:0}}</style>
