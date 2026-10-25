<script setup lang="ts">
import { formatDisplayDate } from '../../../utils/formatDisplayDate'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Report inspection — Doclyzer Admin' })
const route = useRoute()
const { adminFetch } = useAdminApi()
type RangeStatus = 'below' | 'within' | 'above' | 'unknown'
type LabValue = { id: string; parameterName: string; originalParameterName: string; value: string; rawResult: string; unit: string | null; sampleDate: string | null; referenceRange: string | null; rangeStatus: RangeStatus; reviewState: string; extractionSource: string }
type Section = { heading: string; tests: { parameterName: string; value: string; unit?: string; sampleDate?: string; referenceRange?: string }[] }
type StructuredReport = { patientDetails?: Record<string, unknown>; labDetails?: Record<string, unknown>; sections?: Section[]; extractionReview?: Record<string, unknown> }
type Report = { id: string; userId: string; userEmail: string | null; profileName: string | null; originalFileName: string; contentType: string; sizeBytes: number; status: string; processingState: string | null; processingStage: string | null; processingErrorCode: string | null; createdAt: string; updatedAt: string; deletedAt: string | null; summary: string | null; parsedTranscript: string | null; structuredReport: StructuredReport | null; parsedRangeStatuses: RangeStatus[][]; extractedLabValues: LabValue[] }
const report = ref<Report | null>(null)
const loading = ref(true)
const error = ref('')
const fileError = ref('')
const fileLoading = ref(false)
const fileUrl = ref('')
const resultSearch = ref('')
const resultPage = ref(1)
const resultPageSize = 20
const showTranscript = ref(false)
const showJson = ref(false)
const filteredResults = computed(() => report.value?.extractedLabValues.filter(row => `${row.parameterName} ${row.originalParameterName} ${row.value} ${row.unit ?? ''} ${row.reviewState} ${rangeLabel(row.rangeStatus)}`.toLowerCase().includes(resultSearch.value.toLowerCase())) ?? [])
const pagedResults = computed(() => filteredResults.value.slice((resultPage.value - 1) * resultPageSize, resultPage.value * resultPageSize))
const resultPages = computed(() => Math.max(1, Math.ceil(filteredResults.value.length / resultPageSize)))
watch(resultSearch, () => { resultPage.value = 1 })

onMounted(async () => {
  try {
    const response = await adminFetch<{ data: Report }>(`/admin/reports/${route.params.id}`)
    report.value = response.data
  } catch (e: unknown) { error.value = e instanceof Error ? e.message : 'Could not load report' }
  finally { loading.value = false }
})

function closeFile() { if (fileUrl.value) URL.revokeObjectURL(fileUrl.value); fileUrl.value = '' }
onUnmounted(closeFile)
async function previewFile() {
  if (!report.value || fileLoading.value) return
  closeFile()
  fileLoading.value = true
  fileError.value = ''
  try {
    const blob = await adminFetch<Blob>(`/admin/reports/${report.value.id}/file`, { responseType: 'blob' })
    fileUrl.value = URL.createObjectURL(blob)
  } catch (e: unknown) { fileError.value = e instanceof Error ? e.message : 'Could not load original file' }
  finally { fileLoading.value = false }
}
function readable(value: unknown) { return value == null || value === '' ? '—' : String(value) }
function date(value: string | null) { return value ? formatDisplayDate(value, true) : '—' }
function label(key: string) { return key.replace(/([A-Z])/g, ' $1').replace(/^./, c => c.toUpperCase()) }
function rangeLabel(status: RangeStatus | undefined) {
  return { below: 'Below range', within: 'In listed range', above: 'Above range', unknown: 'Range unclear' }[status ?? 'unknown']
}
function rangeClass(status: RangeStatus | undefined) {
  return `result-row--${status === 'below' || status === 'above' || status === 'within' ? status : 'unknown'}`
}
</script>

<template>
  <div class="admin-ops report-inspection">
    <NuxtLink to="/admin/reports" class="admin-ops__back">← Reports</NuxtLink>
    <p v-if="loading" class="admin-ops__muted" role="status">Loading report…</p>
    <p v-if="error" class="admin-ops__message admin-ops__message--error" role="alert">{{ error }}</p>
    <template v-if="report">
      <header class="admin-ops__header"><div><p class="admin-ops__eyebrow">Report inspection · Read only</p><h1>{{ report.originalFileName }}</h1><p class="admin-ops__subtitle">{{ report.userEmail || report.userId }} · {{ report.profileName || 'Unknown profile' }} · Uploaded {{ date(report.createdAt) }}</p></div><span class="admin-ops__badge">{{ report.status.replaceAll('_', ' ') }}</span></header>
      <div class="report-grid">
        <section class="admin-ops__card"><h2>Original file</h2><p class="admin-ops__muted">{{ report.contentType }} · {{ (report.sizeBytes / 1024).toFixed(0) }} KB</p><div class="admin-ops__actions"><button class="admin-ops__button admin-ops__button--primary" :disabled="fileLoading" @click="previewFile">{{ fileLoading ? 'Loading file…' : fileUrl ? 'Reload preview' : 'Preview original' }}</button><a v-if="fileUrl" class="admin-ops__button" :href="fileUrl" :download="report.originalFileName">Download</a><button v-if="fileUrl" class="admin-ops__button" @click="closeFile">Close</button></div><p v-if="fileError" class="admin-ops__message admin-ops__message--error" role="alert">{{ fileError }}</p><div v-if="fileUrl" class="file-preview"><img v-if="report.contentType.startsWith('image/')" :src="fileUrl" alt="Original uploaded report" /><iframe v-else-if="report.contentType === 'application/pdf'" :src="fileUrl" title="Original uploaded report" /><p v-else>Preview is unavailable for this file type. Use Download to inspect it.</p></div></section>
        <section class="admin-ops__card"><h2>Processing</h2><dl class="metadata"><dt>Status</dt><dd>{{ report.status.replaceAll('_', ' ') }}</dd><dt>State / stage</dt><dd>{{ readable(report.processingState) }} / {{ readable(report.processingStage) }}</dd><dt>Error code</dt><dd>{{ readable(report.processingErrorCode) }}</dd><dt>Updated</dt><dd>{{ date(report.updatedAt) }}</dd><dt>Report ID</dt><dd class="admin-ops__code">{{ report.id }}</dd><dt>Owner</dt><dd><NuxtLink :to="`/admin/users/${report.userId}`">{{ report.userEmail || report.userId }}</NuxtLink></dd><dt>Deleted</dt><dd>{{ date(report.deletedAt) }}</dd></dl></section>
      </div>
      <section v-if="report.summary" class="admin-ops__card"><h2>Summary</h2><p class="report-text">{{ report.summary }}</p></section>
      <section v-if="report.structuredReport" class="admin-ops__card"><h2>Parsed report</h2><div class="report-grid"><div v-for="[heading, details] in [['Patient details', report.structuredReport.patientDetails], ['Lab details', report.structuredReport.labDetails]] as [string, Record<string, unknown> | undefined][]" :key="heading"><h3>{{ heading }}</h3><dl v-if="details" class="metadata"><template v-for="(value, key) in details" :key="key"><dt>{{ label(String(key)) }}</dt><dd>{{ readable(value) }}</dd></template></dl><p v-else class="admin-ops__muted">Unavailable</p></div></div><div v-for="(section, index) in report.structuredReport.sections || []" :key="index" class="parsed-section"><h3>{{ section.heading || `Section ${index + 1}` }}</h3><div class="admin-ops__table-wrap"><table class="admin-ops__table"><thead><tr><th>Test</th><th>Result</th><th>Unit</th><th>Range</th><th>Date</th><th>Comparison</th></tr></thead><tbody><tr v-for="(test, testIndex) in section.tests || []" :key="testIndex" :class="rangeClass(report.parsedRangeStatuses?.[index]?.[testIndex])"><td>{{ test.parameterName }}</td><td>{{ test.value }}</td><td>{{ readable(test.unit) }}</td><td>{{ readable(test.referenceRange) }}</td><td>{{ readable(test.sampleDate) }}</td><td><span class="range-chip" :class="rangeClass(report.parsedRangeStatuses?.[index]?.[testIndex])">{{ rangeLabel(report.parsedRangeStatuses?.[index]?.[testIndex]) }}</span></td></tr></tbody></table></div></div><button class="admin-ops__text-button" @click="showJson = !showJson">{{ showJson ? 'Hide' : 'Show' }} raw structured JSON</button><pre v-if="showJson" class="raw-output">{{ JSON.stringify(report.structuredReport, null, 2) }}</pre></section>
      <section class="admin-ops__card"><div class="section-heading"><div><h2>Extracted results ({{ report.extractedLabValues.length }})</h2><p class="admin-ops__muted">Values persisted for the app. Compare them with the original file.</p></div><label class="admin-ops__field">Filter results<input v-model="resultSearch" class="admin-ops__input" type="search" placeholder="Test, value, review state" /></label></div><p v-if="!filteredResults.length" class="admin-ops__empty">No extracted results match.</p><div v-else class="admin-ops__table-wrap"><table class="admin-ops__table"><thead><tr><th>Test</th><th>Value</th><th>Unit</th><th>Range</th><th>Comparison</th><th>Sample date</th><th>Review</th><th>Source</th></tr></thead><tbody><tr v-for="row in pagedResults" :key="row.id" :class="rangeClass(row.rangeStatus)"><td><strong>{{ row.parameterName }}</strong><small v-if="row.originalParameterName !== row.parameterName">Original: {{ row.originalParameterName }}</small></td><td>{{ row.value }}<small v-if="row.rawResult !== row.value">Raw: {{ row.rawResult }}</small></td><td>{{ readable(row.unit) }}</td><td>{{ readable(row.referenceRange) }}</td><td><span class="range-chip" :class="rangeClass(row.rangeStatus)">{{ rangeLabel(row.rangeStatus) }}</span></td><td>{{ readable(row.sampleDate) }}</td><td>{{ row.reviewState }}</td><td>{{ row.extractionSource }}</td></tr></tbody></table></div><footer v-if="filteredResults.length > resultPageSize" class="admin-ops__pagination"><span>{{ (resultPage - 1) * resultPageSize + 1 }}–{{ Math.min(resultPage * resultPageSize, filteredResults.length) }} of {{ filteredResults.length }}</span><div><button class="admin-ops__button" :disabled="resultPage <= 1" @click="resultPage--">Previous</button><span>Page {{ resultPage }} of {{ resultPages }}</span><button class="admin-ops__button" :disabled="resultPage >= resultPages" @click="resultPage++">Next</button></div></footer></section>
      <section class="admin-ops__card"><h2>Parser transcript</h2><p v-if="!report.parsedTranscript" class="admin-ops__muted">No transcript is stored for this report.</p><template v-else><button class="admin-ops__text-button" @click="showTranscript = !showTranscript">{{ showTranscript ? 'Hide' : 'Show' }} transcript</button><pre v-if="showTranscript" class="raw-output">{{ report.parsedTranscript }}</pre></template></section>
    </template>
  </div>
</template>

<style scoped>
.report-inspection { max-width: 1440px; }
.admin-ops__back { display: inline-block; margin-bottom: 20px; }
.report-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; margin-bottom: 18px; }
.report-grid .admin-ops__card { margin: 0; }
.report-inspection > .admin-ops__card { margin-top: 18px; }
.metadata { display: grid; grid-template-columns: 125px minmax(0, 1fr); gap: 10px 16px; margin: 16px 0 0; font-size: 14px; }
.metadata dt { color: var(--brand-muted); }
.metadata dd { margin: 0; overflow-wrap: anywhere; }
.file-preview { margin-top: 18px; min-height: 320px; border: 1px solid var(--brand-border); border-radius: 10px; overflow: hidden; background: #f4f7fa; }
.file-preview iframe { width: 100%; height: 560px; border: 0; }
.file-preview img { display: block; max-width: 100%; max-height: 700px; margin: auto; }
.file-preview p { padding: 16px; }
.report-text { white-space: pre-wrap; line-height: 1.65; }
.parsed-section { margin-top: 20px; }
.parsed-section h3, .report-grid h3 { font-size: 16px; margin: 16px 0 10px; }
.raw-output { max-height: 440px; overflow: auto; padding: 18px; background: #f4f7fa; border-radius: 10px; white-space: pre-wrap; overflow-wrap: anywhere; font-size: 13px; line-height: 1.6; }
.section-heading { display: flex; justify-content: space-between; align-items: end; gap: 16px; }
.section-heading .admin-ops__field { min-width: 230px; }
td small { display: block; margin-top: 4px; color: var(--brand-muted); }
.admin-ops__table tbody tr.result-row--within td { background: #e8f5ec; }
.admin-ops__table tbody tr.result-row--below td,
.admin-ops__table tbody tr.result-row--above td { background: #fff0ed; }
.admin-ops__table tbody tr.result-row--within:hover td { background: #dcefe2; }
.admin-ops__table tbody tr.result-row--below:hover td,
.admin-ops__table tbody tr.result-row--above:hover td { background: #fbe4df; }
.admin-ops__table tbody tr.result-row--within td:first-child { box-shadow: inset 3px 0 #4f9868; }
.admin-ops__table tbody tr.result-row--below td:first-child,
.admin-ops__table tbody tr.result-row--above td:first-child { box-shadow: inset 3px 0 #c35a4d; }
.range-chip { display: inline-block; padding: 5px 9px; border-radius: 999px; background: #eef2f4; color: var(--brand-muted); font-size: 12px; font-weight: 700; white-space: nowrap; }
.range-chip.result-row--within { background: #d8efdf; color: #166534; }
.range-chip.result-row--below,
.range-chip.result-row--above { background: #fbe0da; color: #96392f; }
@media (max-width: 850px) { .report-grid { grid-template-columns: 1fr; } .section-heading { align-items: stretch; flex-direction: column; } }
</style>
