<script setup lang="ts">
const { t, locale } = useI18n()
const { statusLabel } = useReportLabels()
import type { ConsumerReport } from '../../composables/useConsumer'
import { formatDisplayDate as formatDateForLocale } from '../../utils/formatDisplayDate'
function formatDisplayDate(value: string, includeTime = false) { return formatDateForLocale(value, includeTime, locale.value) }
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
  for (const r of visible.value) { const key = r.collectionDateStatus === 'multiple' ? t('multipleCollectionDates') : r.collectionDate ? formatDisplayDate(r.collectionDate) : t('unknownCollectionDate'); groups.set(key, [...groups.get(key) ?? [], r]) }
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
  <div><header class="page-heading"><div><p class="eyebrow">{{ t('yourRecords') }}</p><h1>{{ t('reports') }}</h1><p class="muted">{{ t('browseCollectionDate') }}</p></div><NuxtLink class="button" to="/reports/upload">{{ t('addReport') }}</NuxtLink></header>
    <div v-if="profiles.length" class="row"><label class="field">{{ t('searchReportsShort') }}<input v-model="query" type="search" :placeholder="t('searchReportsHint')" /></label><div class="actions"><button :class="{ secondary: bin }" @click="bin=false">{{ t('reports') }}</button><button :class="{ secondary: !bin }" @click="bin=true">{{ t('recycleBin') }}</button></div></div>
    <p v-if="error" role="alert" class="alert error">{{ error }} <button class="secondary" @click="load">{{ t('retry') }}</button></p><p v-if="loading" role="status">{{ t('loadingReports') }}</p>
    <div v-else-if="!profiles.length" class="empty"><h2>{{ t('addProfileFirst') }}</h2><p>{{ t('reportsBelongHelp') }}</p><NuxtLink class="button" to="/you">{{ t('manageProfilesWeb') }}</NuxtLink></div>
    <div v-else-if="!visible.length" class="empty"><h2>{{ query ? t('noMatchingReportsTitle') : bin ? t('emptyRecycleBin') : t('noReportsYet') }}</h2><p v-if="!query && !bin">{{ t('addPdfHelp') }}</p><NuxtLink v-if="!query && !bin" class="button" to="/reports/upload">{{ t('addReport') }}</NuxtLink></div>
    <section v-for="group in grouped" v-else :key="group.label"><h2>{{ group.label }}</h2><article v-for="report in group.items" :key="report.id" class="card row"><div><h3><NuxtLink :to="`/reports/${report.id}`">{{ report.originalFileName }}</NuxtLink></h3><p class="muted">{{ t('uploadedOn', { date: formatDisplayDate(report.createdAt) }) }} · {{ statusLabel(report.processingState ?? report.status) }}</p><p v-if="report.purgeAfterAt">{{ t('deletionScheduled', { date: formatDisplayDate(report.purgeAfterAt) }) }}</p></div><div class="actions"><button v-if="bin" :disabled="busy" @click="changeReport(report,'restore')">{{ t('restore') }}</button><template v-else><NuxtLink class="button secondary" :to="`/reports/${report.id}`">{{ t('viewResults') }}</NuxtLink><button v-if="['failed','needs_attention','cancelled'].includes(report.processingState ?? '')" :disabled="busy" class="secondary" @click="changeReport(report,'retry')">{{ t('retry') }}</button><button :disabled="busy" class="text-button" @click="changeReport(report,'delete')">{{ t('delete') }}</button></template></div></article></section>
  </div>
</template>
<style scoped>.page-heading{align-items:flex-start}.card h3{margin:0 0 7px;overflow-wrap:anywhere}.card p{margin:0}.card .actions{margin-left:auto}@media(max-width:550px){.page-heading{display:block}.page-heading .button{margin-top:12px}.card .actions{margin-left:0}}</style>
