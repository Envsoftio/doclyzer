<script setup lang="ts">
import { formatDisplayDate } from '../../../utils/formatDisplayDate'
import { ref, onMounted } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'User Workbench — Doclyzer Admin' })

const route = useRoute()
const { adminFetch } = useAdminApi()

const userId = route.params.id as string

interface WorkbenchData {
  user: { id: string; email: string; displayName: string | null; role: string; createdAt: string }
  profiles: { id: string; name: string; createdAt: string; reportCount: number }[]
  reports: { id: string; profileId: string; originalFileName: string; sizeBytes: number; status: string; createdAt: string; updatedAt: string }[]
  sessions: { id: string; ipAddress: string | null; userAgent: string | null; createdAt: string; expiresAt: string }[]
  reportStatusSummary: Record<string, number>
}

const data = ref<WorkbenchData | null>(null)
const loading = ref(true)
const error = ref('')
const reportSearch = ref('')
const reportStatus = ref('')
const reportPage = ref(1)
const reportPageSize = 10
const filteredReports = computed(() => data.value?.reports.filter(r =>
  (!reportStatus.value || r.status === reportStatus.value) &&
  (!reportSearch.value.trim() || r.originalFileName.toLowerCase().includes(reportSearch.value.trim().toLowerCase())),
) ?? [])
const visibleReports = computed(() => filteredReports.value.slice((reportPage.value - 1) * reportPageSize, reportPage.value * reportPageSize))
const reportPages = computed(() => Math.max(1, Math.ceil(filteredReports.value.length / reportPageSize)))
watch([reportSearch, reportStatus], () => { reportPage.value = 1 })

onMounted(async () => {
  try {
    const res = await adminFetch<{ data: WorkbenchData }>(`/admin/analytics/users/${userId}`)
    data.value = (res as Record<string, WorkbenchData>).data
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load user'
  } finally {
    loading.value = false
  }
})

function fmtDate(iso: string): string {
  return formatDisplayDate(iso, true)
}

function fmtBytes(b: number): string {
  if (b < 1024) return `${b} B`
  if (b < 1024 * 1024) return `${(b / 1024).toFixed(1)} KB`
  return `${(b / 1024 / 1024).toFixed(1)} MB`
}

const STATUS_COLORS: Record<string, string> = {
  parsed: 'badge--green',
  queued: 'badge--amber',
  parsing: 'badge--amber',
  uploading: 'badge--amber',
  failed_transient: 'badge--orange',
  failed_terminal: 'badge--red',
  content_not_recognized: 'badge--red',
  unparsed: 'badge--grey',
}
</script>

<template>
  <div class="admin-ops workbench">
    <NuxtLink to="/admin/users" class="admin-ops__back back-link">← Users</NuxtLink>

    <div v-if="error" class="admin-ops__message admin-ops__message--error" role="alert" aria-live="assertive">
      {{ error }}
    </div>

    <div v-if="loading" class="skeleton-block" />

    <template v-else-if="data">
      <!-- User header -->
      <header class="admin-ops__header user-header">
        <div>
          <p class="admin-ops__eyebrow">Manage / Account workbench</p>
          <h1 class="user-email">{{ data.user.email }}</h1>
          <div class="user-meta">
            <span>{{ data.user.displayName || 'No display name' }}</span>
            <span class="dot">·</span>
            <span class="admin-ops__badge">{{ data.user.role }}</span>
            <span class="dot">·</span>
            <span>Joined {{ fmtDate(data.user.createdAt) }}</span>
          </div>
        </div>
        <NuxtLink class="admin-ops__button" :to="`/admin/reports?userId=${data.user.id}`">Browse reports</NuxtLink>
      </header>

      <!-- Report status summary -->
      <div class="status-summary">
        <div
          v-for="(count, status) in data.reportStatusSummary"
          :key="status"
          class="status-chip"
          :class="STATUS_COLORS[status] || 'badge--grey'"
        >
          {{ status }}: <strong>{{ count }}</strong>
        </div>
      </div>

      <!-- Profiles -->
      <section class="admin-ops__card section">
        <h3 class="section-title">Profiles ({{ data.profiles.length }})</h3>
        <div v-if="data.profiles.length === 0" class="admin-ops__empty">No profiles.</div>
        <div v-else class="admin-ops__table-wrap"><table class="admin-ops__table">
          <thead><tr><th>Name</th><th>Reports</th><th>Created</th></tr></thead>
          <tbody>
            <tr v-for="p in data.profiles" :key="p.id">
              <td>{{ p.name }}</td>
              <td>{{ p.reportCount }}</td>
              <td>{{ fmtDate(p.createdAt) }}</td>
            </tr>
          </tbody>
        </table></div>
      </section>

      <!-- Reports -->
      <section class="admin-ops__card section">
        <div class="report-heading"><h3 class="section-title">Reports ({{ data.reports.length }})</h3><NuxtLink :to="`/admin/reports?userId=${data.user.id}`">Browse all user reports →</NuxtLink></div>
        <div class="report-filters"><label class="admin-ops__field">Find file<input v-model="reportSearch" class="admin-ops__input" type="search" placeholder="Search filename" /></label><label class="admin-ops__field">Status<select v-model="reportStatus" class="admin-ops__select"><option value="">All statuses</option><option v-for="status in Object.keys(data.reportStatusSummary)" :key="status" :value="status">{{ status.replaceAll('_', ' ') }}</option></select></label></div>
        <div v-if="filteredReports.length === 0" class="admin-ops__empty">No reports match.</div>
        <div v-else class="admin-ops__table-wrap"><table class="admin-ops__table">
          <thead><tr><th>File</th><th>Size</th><th>Status</th><th>Uploaded</th><th>Open</th></tr></thead>
          <tbody>
            <tr v-for="r in visibleReports" :key="r.id">
              <td class="td-file">{{ r.originalFileName }}</td>
              <td>{{ fmtBytes(r.sizeBytes) }}</td>
              <td><span class="admin-ops__badge" :class="STATUS_COLORS[r.status] || 'badge--grey'">{{ r.status.replaceAll('_', ' ') }}</span></td>
              <td>{{ fmtDate(r.createdAt) }}</td>
              <td><NuxtLink :to="`/admin/reports/${r.id}`">Inspect →</NuxtLink></td>
            </tr>
          </tbody>
        </table></div>
        <div v-if="filteredReports.length > reportPageSize" class="admin-ops__pagination"><span>{{ (reportPage - 1) * reportPageSize + 1 }}–{{ Math.min(reportPage * reportPageSize, filteredReports.length) }} of {{ filteredReports.length }}</span><div><button class="admin-ops__button" :disabled="reportPage <= 1" @click="reportPage--">Previous</button><span>Page {{ reportPage }} of {{ reportPages }}</span><button class="admin-ops__button" :disabled="reportPage >= reportPages" @click="reportPage++">Next</button></div></div>
      </section>

      <!-- Sessions -->
      <section class="admin-ops__card section">
        <h3 class="section-title">Recent Sessions ({{ data.sessions.length }})</h3>
        <div v-if="data.sessions.length === 0" class="admin-ops__empty">No sessions.</div>
        <div v-else class="admin-ops__table-wrap"><table class="admin-ops__table">
          <thead><tr><th>IP</th><th>Device</th><th>Created</th><th>Expires</th></tr></thead>
          <tbody>
            <tr v-for="s in data.sessions" :key="s.id">
              <td>{{ s.ipAddress || '—' }}</td>
              <td class="td-ua">{{ s.userAgent || '—' }}</td>
              <td>{{ fmtDate(s.createdAt) }}</td>
              <td>{{ fmtDate(s.expiresAt) }}</td>
            </tr>
          </tbody>
        </table></div>
      </section>
    </template>
  </div>
</template>

<style scoped>
.workbench { max-width: 1280px; }
.back-link { display: inline-block; margin-bottom: 18px; font-size: 14px; font-weight: 700; text-decoration: none; }
.back-link:hover { text-decoration: underline; }
.user-header { align-items: center; }
.user-header > a { display: inline-flex; align-items: center; justify-content: center; text-decoration: none; }
.user-email { overflow-wrap: anywhere; }
.user-meta { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 8px; color: var(--brand-muted); font-size: 14px; }
.dot { color: var(--brand-border); }
.status-summary { display: flex; flex-wrap: wrap; gap: 9px; margin-bottom: 20px; }
.status-chip { padding: 6px 11px; border-radius: 999px; background: var(--brand-mint); color: var(--brand-ink); font-size: 13px; }
.section { margin-bottom: 0; }
.section-title { margin: 0 0 14px; color: var(--brand-ink); font-size: 19px; font-weight: 700; }
.report-heading { display: flex; justify-content: space-between; align-items: baseline; gap: 16px; flex-wrap: wrap; }
.report-heading a { font-size: 14px; font-weight: 700; }
.report-filters { display: flex; gap: 12px; flex-wrap: wrap; margin: 4px 0 14px; }
.report-filters label { flex: 1; min-width: 180px; }
.td-file { min-width: 180px; max-width: 320px; overflow-wrap: anywhere; font-weight: 650; }
.td-ua { min-width: 180px; max-width: 280px; overflow-wrap: anywhere; color: var(--brand-muted); font-size: 13px; }
.badge--green { background: #dcfce7; color: #166534; }
.badge--amber { background: #fff2dd; color: #854d0e; }
.badge--orange { background: #ffedd5; color: #9a3412; }
.badge--red { background: #ffe9e6; color: #991b1b; }
.badge--grey { background: #eef3f3; color: var(--brand-muted); }
.skeleton-block { height: 360px; border-radius: 16px; background: var(--brand-mint); animation: pulse 1.4s ease-in-out infinite; }
@keyframes pulse { 50% { opacity: .55; } }
@media (max-width: 640px) { .user-header { align-items: flex-start; } .user-header > a { width: 100%; text-align: center; } }
@media (prefers-reduced-motion: reduce) { .skeleton-block { animation: none; } }
</style>
