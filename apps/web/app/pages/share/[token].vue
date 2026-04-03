<script setup lang="ts">
interface PublicLabValueDto {
  parameterName: string
  value: string
  unit: string | null
}

interface PublicReportDto {
  id: string
  originalFileName: string
  status: string
  summary: string | null
  createdAt: string
  labValues: PublicLabValueDto[]
}

interface PublicShareDto {
  profileName: string
  scope: string
  reports: PublicReportDto[]
}

interface ApiSuccessResponse {
  success: true
  data: PublicShareDto
  correlationId: string
}

const { incident: incidentStatus } = useIncidentStatus()

const route = useRoute()
const token = route.params.token as string
const config = useRuntimeConfig()

useHead({
  meta: [{ name: 'robots', content: 'noindex, nofollow' }],
})

const shareData = ref<PublicShareDto | null>(null)
const errorStatus = ref<number | null>(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await $fetch<ApiSuccessResponse>(
      `${config.public.apiBaseUrl}/sharing/public/${token}`,
    )
    shareData.value = res.data
  } catch (err: unknown) {
    const fetchError = err as { response?: { status?: number } }
    errorStatus.value = fetchError?.response?.status ?? 500
  } finally {
    loading.value = false
  }
})

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

interface TrendPoint {
  date: string
  value: string
  unit: string | null
}

function computeTrends(reports: PublicReportDto[]): [string, TrendPoint[]][] {
  const paramMap = new Map<string, TrendPoint[]>()
  const sorted = [...reports].sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())
  for (const report of sorted) {
    for (const lv of report.labValues) {
      if (!paramMap.has(lv.parameterName)) paramMap.set(lv.parameterName, [])
      paramMap.get(lv.parameterName)!.push({ date: report.createdAt, value: lv.value, unit: lv.unit })
    }
  }
  return [...paramMap.entries()]
    .filter(([, points]) => points.length >= 2)
    .sort(([a], [b]) => a.localeCompare(b))
}

const sortedReports = computed(() => {
  if (!shareData.value) return []
  return [...shareData.value.reports].sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())
})

const trends = computed(() => {
  if (!shareData.value) return []
  return computeTrends(shareData.value.reports)
})

function printPage() {
  if (typeof window !== 'undefined') window.print()
}

const trendDates = computed(() => {
  if (trends.value.length === 0) return []
  return (trends.value[0]?.[1] ?? []).map((pt) => pt.date)
})
</script>

<template>
  <div class="page-wrap">
    <div class="incident-slot">
      <IncidentBanner :incident="incidentStatus" surface="web_share" />
    </div>
    <!-- Loading -->
    <div v-if="loading">
      <p>Loading…</p>
    </div>

    <!-- 404: Link not found -->
    <div v-else-if="errorStatus === 404">
      <h1>Link Not Found</h1>
      <p>The share link you followed does not exist.</p>
    </div>

    <!-- 410: Link expired or revoked -->
    <div v-else-if="errorStatus === 410">
      <h1>Link Expired or Revoked</h1>
      <p>This share link has expired or been revoked by the owner.</p>
    </div>

    <!-- Generic error -->
    <div v-else-if="errorStatus !== null">
      <h1>Something Went Wrong</h1>
      <p>Unable to load the shared content. Please try again later.</p>
    </div>

    <!-- Success -->
    <div v-else-if="shareData">
      <div class="page-header">
        <h1>{{ shareData.profileName }}'s Health Reports</h1>
        <button class="no-print print-btn" @click="printPage">Print / Save as PDF</button>
      </div>

      <!-- Trends at a Glance -->
      <section v-if="trends.length > 0" class="trends-section">
        <h2>Trends at a Glance</h2>
        <table class="data-table">
          <thead>
            <tr>
              <th>Parameter</th>
              <th v-for="date in trendDates" :key="date">{{ formatDate(date) }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="[param, points] in trends" :key="param">
              <td class="param-name">{{ param }}</td>
              <td v-for="(pt, i) in points" :key="i">
                {{ pt.value }}<span v-if="pt.unit" class="unit"> {{ pt.unit }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </section>

      <!-- Empty state -->
      <p v-if="shareData.reports.length === 0" class="empty-note">
        No parsed reports are available on this share link.
      </p>

      <!-- Timeline -->
      <section v-else class="timeline">
        <div
          v-for="report in sortedReports"
          :key="report.id"
          class="report-card"
        >
          <h2 class="report-date">{{ formatDate(report.createdAt) }}</h2>
          <div class="report-filename">{{ report.originalFileName }}</div>

          <blockquote v-if="report.summary" class="report-summary">
            {{ report.summary }}
          </blockquote>

          <table v-if="report.labValues.length > 0" class="data-table lab-table">
            <thead>
              <tr>
                <th>Parameter</th>
                <th>Value</th>
                <th>Unit</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="lv in report.labValues" :key="lv.parameterName">
                <td>{{ lv.parameterName }}</td>
                <td>{{ lv.value }}</td>
                <td>{{ lv.unit ?? '—' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <a href="#top" class="no-print back-to-top">Back to top</a>
    </div>
  </div>
</template>

<style scoped>
.page-wrap {
  max-width: 760px;
  margin: 48px auto;
  padding: 0 24px;
  font-family: Georgia, 'Times New Roman', serif;
  color: #1a1a1a;
}

.incident-slot {
  margin-bottom: 24px;
}

.page-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 32px;
  flex-wrap: wrap;
}

.page-header h1 {
  margin: 0;
  font-size: 1.6rem;
  font-weight: 700;
}

.print-btn {
  font-family: sans-serif;
  font-size: 0.875rem;
  padding: 6px 14px;
  border: 1px solid #555;
  background: transparent;
  cursor: pointer;
  border-radius: 4px;
}

.trends-section {
  margin-bottom: 40px;
  padding-bottom: 24px;
  border-bottom: 2px solid #333;
}

.trends-section h2 {
  font-size: 1.2rem;
  margin-bottom: 12px;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.data-table th,
.data-table td {
  border: 1px solid #ccc;
  padding: 6px 10px;
  text-align: left;
  vertical-align: top;
}

.data-table th {
  background: #f5f5f5;
  font-weight: 600;
}

.param-name {
  font-weight: 600;
}

.unit {
  color: #555;
  font-size: 0.85em;
}

.report-card {
  margin-bottom: 40px;
  padding-bottom: 32px;
  border-bottom: 1px solid #ddd;
}

.report-date {
  font-size: 1.15rem;
  font-weight: 700;
  margin: 0 0 4px;
}

.report-filename {
  font-size: 0.875rem;
  color: #555;
  font-family: sans-serif;
  margin-bottom: 12px;
}

.report-summary {
  margin: 0 0 16px;
  padding: 10px 16px;
  border-left: 3px solid #888;
  background: #fafafa;
  font-size: 0.95rem;
  line-height: 1.6;
  font-style: italic;
}

.lab-table {
  margin-top: 8px;
}

.empty-note {
  color: #555;
}

.back-to-top {
  display: inline-block;
  margin-top: 32px;
  font-family: sans-serif;
  font-size: 0.875rem;
  color: #444;
}
</style>

<style>
@media print {
  .no-print { display: none !important; }
  body { color: #000 !important; background: #fff !important; }
  .report-card { break-inside: avoid; page-break-inside: avoid; }
  .report-summary { background: transparent; border-left: 2px solid #000; }
  .data-table th { background: transparent; }
}
</style>
