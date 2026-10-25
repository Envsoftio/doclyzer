<script setup lang="ts">
import { formatDisplayDate } from '../../../utils/formatDisplayDate'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Reports — Doclyzer Admin' })

const { adminFetch } = useAdminApi()
const route = useRoute()
type ReportRow = { id: string; userId: string; userEmail: string; profileName: string; originalFileName: string; sizeBytes: number; status: string; createdAt: string; deletedAt: string | null }
type ReportPage = { items: ReportRow[]; total: number; page: number; pageSize: number; totalPages: number }
const rows = ref<ReportPage | null>(null)
const loading = ref(false)
const error = ref('')
const search = ref('')
const status = ref(typeof route.query.status === 'string' ? route.query.status : '')
const userId = ref(typeof route.query.userId === 'string' ? route.query.userId : '')
const page = ref(1)
const pageSize = ref(25)
let requestVersion = 0

async function load() {
  const version = ++requestVersion
  loading.value = true
  error.value = ''
  try {
    const params = new URLSearchParams({ page: String(page.value), pageSize: String(pageSize.value) })
    if (search.value.trim()) params.set('search', search.value.trim())
    if (status.value) params.set('status', status.value)
    if (userId.value.trim()) params.set('userId', userId.value.trim())
    const response = await adminFetch<{ data: ReportPage }>(`/admin/reports?${params}`)
    if (version === requestVersion) rows.value = response.data
  } catch (e: unknown) {
    if (version === requestVersion) error.value = e instanceof Error ? e.message : 'Could not load reports'
  } finally {
    if (version === requestVersion) loading.value = false
  }
}

function applyFilters() { page.value = 1; void load() }
function changePage(next: number) { page.value = next; void load() }
watch(() => route.query.userId, (value) => { userId.value = typeof value === 'string' ? value : ''; applyFilters() })
watch(() => route.query.status, (value) => { status.value = typeof value === 'string' ? value : ''; applyFilters() })
onMounted(load)
function size(bytes: number) { return bytes < 1024 ? `${bytes} B` : bytes < 1024 * 1024 ? `${(bytes / 1024).toFixed(1)} KB` : `${(bytes / (1024 * 1024)).toFixed(1)} MB` }
</script>

<template>
  <div class="admin-ops">
    <header class="admin-ops__header">
      <div><p class="admin-ops__eyebrow">Files and parsing</p><h1>Reports</h1><p class="admin-ops__subtitle">Find a user report and inspect its original file and parsed results for debugging.</p></div>
      <NuxtLink to="/admin/files" class="admin-ops__button">Pipeline status</NuxtLink>
    </header>

    <section class="admin-ops__card">
      <form class="admin-ops__row" @submit.prevent="applyFilters">
        <label class="admin-ops__field">Search file, email, or report ID<input v-model="search" class="admin-ops__input" type="search" placeholder="Filename, email, or ID" /></label>
        <label class="admin-ops__field">Status<select v-model="status" class="admin-ops__select"><option value="">All statuses</option><option v-for="item in ['uploading', 'queued', 'parsing', 'parsed', 'unparsed', 'content_not_recognized', 'failed_transient', 'failed_terminal']" :key="item" :value="item">{{ item.replaceAll('_', ' ') }}</option></select></label>
        <label class="admin-ops__field">Rows per page<select v-model.number="pageSize" class="admin-ops__select"><option :value="25">25</option><option :value="50">50</option><option :value="100">100</option></select></label>
        <button class="admin-ops__button admin-ops__button--primary" type="submit">Apply filters</button>
      </form>
      <div v-if="userId" class="admin-ops__message">Showing reports for one user. <button class="admin-ops__text-button" type="button" @click="userId = ''; applyFilters()">Clear user filter</button></div>
      <p v-if="error" class="admin-ops__message admin-ops__message--error" role="alert">{{ error }}</p>
      <p v-if="loading" class="admin-ops__muted" role="status">Loading reports…</p>
      <div v-else-if="rows?.items.length" class="admin-ops__table-wrap">
        <table class="admin-ops__table"><thead><tr><th>File</th><th>User</th><th>Profile</th><th>Status</th><th>Size</th><th>Uploaded</th><th>Open</th></tr></thead>
          <tbody><tr v-for="report in rows.items" :key="report.id"><td class="file-cell"><strong>{{ report.originalFileName }}</strong><small v-if="report.deletedAt">Deleted</small></td><td><NuxtLink :to="`/admin/users/${report.userId}`">{{ report.userEmail }}</NuxtLink></td><td>{{ report.profileName }}</td><td><span class="admin-ops__badge" :class="{ 'admin-ops__badge--red': report.status.startsWith('failed') || report.status === 'content_not_recognized', 'admin-ops__badge--warm': ['queued', 'parsing', 'uploading'].includes(report.status) }">{{ report.status.replaceAll('_', ' ') }}</span></td><td>{{ size(report.sizeBytes) }}</td><td>{{ formatDisplayDate(report.createdAt, true) }}</td><td><NuxtLink :to="`/admin/reports/${report.id}`">Inspect →</NuxtLink></td></tr></tbody>
        </table>
      </div>
      <p v-else-if="rows" class="admin-ops__empty">No reports match these filters.</p>
      <footer v-if="rows" class="admin-ops__pagination"><span>{{ rows.total ? (rows.page - 1) * rows.pageSize + 1 : 0 }}–{{ Math.min(rows.page * rows.pageSize, rows.total) }} of {{ rows.total }} reports</span><div><button class="admin-ops__button" :disabled="loading || page <= 1" @click="changePage(page - 1)">Previous</button><span>Page {{ page }} of {{ rows.totalPages }}</span><button class="admin-ops__button" :disabled="loading || page >= rows.totalPages" @click="changePage(page + 1)">Next</button></div></footer>
    </section>
  </div>
</template>

<style scoped>
.file-cell { min-width: 190px; max-width: 340px; overflow-wrap: anywhere; }
.file-cell strong, .file-cell small { display: block; }
.file-cell small { color: #a9342a; margin-top: 3px; }
.admin-ops__row .admin-ops__field:first-child { flex: 2; min-width: 220px; }
.admin-ops__row > button { margin-bottom: 15px; }
</style>
