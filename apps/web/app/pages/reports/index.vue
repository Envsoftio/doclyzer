<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { formatDisplayDate } from '../../utils/formatDisplayDate'

type Profile = { id: string; name: string; isActive: boolean }
type Report = {
  id: string
  profileId: string
  originalFileName: string
  contentType: string
  status: string
  createdAt: string
  collectionDate?: string
  collectionDateStatus?: 'known' | 'unknown' | 'multiple'
  deletedAt?: string
  purgeAfterAt?: string
}

const config = useRuntimeConfig()
const router = useRouter()
const apiBase = String(config.public.apiBaseUrl).replace(/\/+$/, '')
const token = ref('')
const profiles = ref<Profile[]>([])
const profileId = ref('')
const reports = ref<Report[]>([])
const deletedReports = ref<Report[]>([])
const query = ref('')
const showingBin = ref(false)
const loading = ref(true)
const busy = ref(false)
const errorMessage = ref('')
const feedback = ref('')
const originalUrl = ref('')
const originalType = ref('')
const originalName = ref('')
let loadVersion = 0

useHead({ title: 'Your reports | Doclyzer', meta: [{ name: 'robots', content: 'noindex, nofollow' }] })

async function request<T>(path: string, options: Record<string, unknown> = {}): Promise<T> {
  try {
    return await $fetch<T>(`${apiBase}${path}`, {
      ...options,
      headers: { Authorization: `Bearer ${token.value}` },
    })
  } catch (error) {
    if ((error as { statusCode?: number }).statusCode === 401) {
      sessionStorage.removeItem('doclyzerConsumerAccessToken')
      await router.replace('/login')
      throw new Error('Your session has expired. Sign in again.')
    }
    const payload = (error as { data?: { error?: { message?: string } } }).data
    throw new Error(payload?.error?.message ?? 'Unable to load reports. Try again.')
  }
}

async function loadReports() {
  if (!profileId.value) return
  const version = ++loadVersion
  const selectedId = profileId.value
  loading.value = true
  errorMessage.value = ''
  try {
    const endpoint = showingBin.value ? '/reports/recycle-bin' : '/reports'
    const result = await request<{ data: { reports: Report[] } }>(
      `${endpoint}?profileId=${encodeURIComponent(selectedId)}`,
    )
    if (version !== loadVersion || selectedId !== profileId.value) return
    if (showingBin.value) deletedReports.value = result.data.reports
    else reports.value = result.data.reports
  } catch (error) {
    if (version === loadVersion) errorMessage.value = (error as Error).message
  } finally {
    if (version === loadVersion) loading.value = false
  }
}

onMounted(async () => {
  token.value = sessionStorage.getItem('doclyzerConsumerAccessToken') ?? ''
  if (!token.value) {
    await router.replace('/login')
    return
  }
  try {
    const result = await request<{ data: Profile[] }>('/profiles')
    profiles.value = result.data
    profileId.value = result.data.find((profile) => profile.isActive)?.id ?? result.data[0]?.id ?? ''
    if (!profileId.value) loading.value = false
  } catch (error) {
    errorMessage.value = (error as Error).message
    loading.value = false
  }
})

watch(profileId, () => {
  closeOriginal()
  reports.value = []
  deletedReports.value = []
  query.value = ''
  void loadReports()
})
watch(showingBin, () => {
  closeOriginal()
  void loadReports()
})

function collectionLabel(report: Report): string {
  if (report.collectionDateStatus === 'multiple') return 'Multiple collection dates'
  return report.collectionDate ? formatDisplayDate(report.collectionDate) : 'Unknown collection date'
}

const visibleReports = computed(() => {
  const term = query.value.trim().toLocaleLowerCase()
  const source = showingBin.value ? deletedReports.value : reports.value
  return source.filter((report) =>
    !term || report.originalFileName.toLocaleLowerCase().includes(term)
      || (report.collectionDate ?? '').toLocaleLowerCase().includes(term),
  )
})

const groups = computed(() => {
  const byDate = new Map<string, Report[]>()
  for (const report of visibleReports.value) {
    const label = collectionLabel(report)
    byDate.set(label, [...(byDate.get(label) ?? []), report])
  }
  return [...byDate].map(([label, items]) => ({ label, items })).sort((a, b) => {
    const aDate = Date.parse(a.items[0]?.collectionDate ?? '')
    const bDate = Date.parse(b.items[0]?.collectionDate ?? '')
    if (!Number.isNaN(aDate) && !Number.isNaN(bDate)) return bDate - aDate
    if (!Number.isNaN(aDate)) return -1
    if (!Number.isNaN(bDate)) return 1
    return a.label.localeCompare(b.label)
  })
})

async function openOriginal(report: Report) {
  errorMessage.value = ''
  busy.value = true
  try {
    const blob = await request<Blob>(`/reports/${encodeURIComponent(report.id)}/file`, {
      responseType: 'blob',
    })
    closeOriginal()
    originalUrl.value = URL.createObjectURL(blob)
    originalType.value = report.contentType
    originalName.value = report.originalFileName
  } catch (error) {
    errorMessage.value = (error as Error).message
  } finally {
    busy.value = false
  }
}

function closeOriginal() {
  if (originalUrl.value) URL.revokeObjectURL(originalUrl.value)
  originalUrl.value = ''
}
onBeforeUnmount(closeOriginal)

async function deleteReport(report: Report) {
  if (!window.confirm(`Move ${report.originalFileName} to the recycle bin? It will be permanently deleted after 30 days.`)) return
  busy.value = true
  errorMessage.value = ''
  try {
    await request(`/reports/${encodeURIComponent(report.id)}`, { method: 'DELETE' })
    feedback.value = 'Report moved to recycle bin.'
    await loadReports()
  } catch (error) {
    errorMessage.value = (error as Error).message
  } finally {
    busy.value = false
  }
}

async function restoreReport(report: Report) {
  busy.value = true
  errorMessage.value = ''
  try {
    await request(`/reports/${encodeURIComponent(report.id)}/restore`, { method: 'POST' })
    feedback.value = 'Report restored.'
    await loadReports()
  } catch (error) {
    errorMessage.value = (error as Error).message
  } finally {
    busy.value = false
  }
}

function signOut() {
  closeOriginal()
  sessionStorage.removeItem('doclyzerConsumerAccessToken')
  localStorage.removeItem('doclyzerAuthTokens')
  void router.replace('/login')
}
</script>

<template>
  <main class="reports-page">
    <header class="topbar">
      <NuxtLink to="/" class="brand">doclyzer.</NuxtLink>
      <button type="button" class="quiet" @click="signOut">Sign out</button>
    </header>
    <section class="heading">
      <p class="eyebrow">Your records</p>
      <h1>Reports</h1>
      <p>Find a report, check when its sample was collected, and open the original.</p>
    </section>
    <div v-if="profiles.length" class="controls">
      <label>Profile
        <select v-model="profileId" aria-label="Report profile">
          <option v-for="profile in profiles" :key="profile.id" :value="profile.id">{{ profile.name }}</option>
        </select>
      </label>
      <label>Search reports
        <input v-model="query" type="search" placeholder="Search by filename or collection date" />
      </label>
    </div>
    <nav v-if="profiles.length" class="tabs" aria-label="Report views">
      <button type="button" :aria-current="!showingBin ? 'page' : undefined" @click="showingBin = false">Reports</button>
      <button type="button" :aria-current="showingBin ? 'page' : undefined" @click="showingBin = true">Recycle bin</button>
    </nav>
    <p v-if="feedback" role="status" class="notice">{{ feedback }}</p>
    <p v-if="errorMessage" role="alert" class="error">{{ errorMessage }} <button type="button" @click="loadReports">Retry</button></p>
    <p v-if="loading" role="status">Loading reports…</p>
    <p v-else-if="!profiles.length">No profiles yet. Add a profile in the mobile app to start keeping reports.</p>
    <p v-else-if="!visibleReports.length" class="empty">{{ query ? 'No reports match your search.' : showingBin ? 'Recycle bin is empty.' : 'No reports yet.' }}</p>
    <section v-for="group in groups" v-else :key="group.label" class="group">
      <h2>{{ group.label }}</h2>
      <article v-for="report in group.items" :key="report.id" class="report-card">
        <div class="report-info">
          <h3>{{ report.originalFileName }}</h3>
          <p>Collected: {{ collectionLabel(report) }}</p>
          <p>Uploaded: {{ formatDisplayDate(report.createdAt) }}</p>
          <p>Status: {{ showingBin ? 'Deleted' : report.status.replaceAll('_', ' ') }}</p>
          <p v-if="showingBin && report.purgeAfterAt">Permanent deletion: {{ formatDisplayDate(report.purgeAfterAt) }}</p>
        </div>
        <div class="actions">
          <button v-if="showingBin" type="button" :disabled="busy" @click="restoreReport(report)">Restore</button>
          <template v-else>
            <button type="button" :disabled="busy" @click="openOriginal(report)">Open original</button>
            <button type="button" class="quiet" :disabled="busy" @click="deleteReport(report)">Move to recycle bin</button>
          </template>
        </div>
      </article>
    </section>
    <div v-if="originalUrl" class="viewer-backdrop" @click.self="closeOriginal">
      <section class="viewer" role="dialog" aria-modal="true" :aria-label="`Original file: ${originalName}`">
        <header><strong>{{ originalName }}</strong><button type="button" @click="closeOriginal">Close</button></header>
        <img v-if="originalType.startsWith('image/')" :src="originalUrl" :alt="originalName" />
        <iframe v-else :src="originalUrl" :title="originalName" />
      </section>
    </div>
  </main>
</template>

<style scoped>
.reports-page{max-width:960px;margin:auto;padding:24px;color:#19302d;font-family:system-ui,sans-serif}
.topbar,.report-card,.actions,.viewer header{display:flex;justify-content:space-between;align-items:center;gap:16px}
.brand{font-weight:800;font-size:22px;color:inherit;text-decoration:none}.heading{margin:44px 0 28px}.heading h1{font-size:clamp(2rem,7vw,3.5rem);margin:0}.heading p{margin:8px 0}.eyebrow{text-transform:uppercase;letter-spacing:.12em;font-size:.8rem;font-weight:700}
.controls{display:flex;flex-wrap:wrap;gap:16px}.controls label{display:grid;gap:6px;flex:1;min-width:220px;font-weight:600}.controls input,.controls select{font:inherit;border:1px solid #9baea9;border-radius:10px;padding:12px;background:white;color:inherit}
.tabs{display:flex;gap:8px;margin:24px 0}.tabs button[aria-current=page]{background:#214e43;color:white}.group{margin:24px 0}.group h2{font-size:1.1rem}.report-card{align-items:flex-start;border:1px solid #d7e1dd;border-radius:16px;padding:18px;margin:10px 0;background:#fff}.report-card h3{overflow-wrap:anywhere;margin:0 0 8px}.report-card p{margin:4px 0}.actions{justify-content:flex-end;flex-wrap:wrap}button{cursor:pointer;font:inherit;border:1px solid #214e43;background:#214e43;color:white;padding:10px 14px;border-radius:9px;min-height:44px}button:disabled{opacity:.55;cursor:wait}.quiet,.tabs button{background:white;color:#214e43}.notice{background:#e5f4eb;padding:12px;border-radius:8px}.error{background:#fce8e8;padding:12px;border-radius:8px}.empty{padding:32px;text-align:center;background:#f5f8f6;border-radius:12px}button:focus-visible,input:focus-visible,select:focus-visible{outline:3px solid #e4a746;outline-offset:2px}
.viewer-backdrop{position:fixed;inset:0;background:#122d2ac9;z-index:20;padding:16px;display:grid;place-items:center}.viewer{width:min(100%,1000px);height:min(100%,850px);background:white;border-radius:12px;display:flex;flex-direction:column;padding:12px}.viewer header{padding:4px 4px 12px}.viewer strong{overflow-wrap:anywhere}.viewer iframe,.viewer img{width:100%;flex:1;min-height:0;border:0;object-fit:contain}
@media(max-width:600px){.report-card{display:block}.actions{justify-content:flex-start;margin-top:16px}.heading{margin-top:28px}}
</style>
