<script setup lang="ts">
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
  return new Date(iso).toLocaleString('en-IN', { dateStyle: 'medium', timeStyle: 'short' })
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
  <div class="workbench">
    <NuxtLink to="/admin/users" class="back-link">← Back to Users</NuxtLink>

    <div v-if="error" class="error-box">{{ error }}</div>

    <div v-if="loading" class="skeleton-block" />

    <template v-else-if="data">
      <!-- User header -->
      <div class="user-header">
        <div>
          <h2 class="user-email">{{ data.user.email }}</h2>
          <div class="user-meta">
            <span>{{ data.user.displayName || 'No display name' }}</span>
            <span class="dot">·</span>
            <span class="role-badge" :class="`role-badge--${data.user.role}`">{{ data.user.role }}</span>
            <span class="dot">·</span>
            <span>Joined {{ fmtDate(data.user.createdAt) }}</span>
          </div>
        </div>
      </div>

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
      <div class="section">
        <h3 class="section-title">Profiles ({{ data.profiles.length }})</h3>
        <div v-if="data.profiles.length === 0" class="empty">No profiles.</div>
        <table v-else class="table">
          <thead><tr><th>Name</th><th>Reports</th><th>Created</th></tr></thead>
          <tbody>
            <tr v-for="p in data.profiles" :key="p.id">
              <td>{{ p.name }}</td>
              <td>{{ p.reportCount }}</td>
              <td>{{ fmtDate(p.createdAt) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Reports -->
      <div class="section">
        <h3 class="section-title">Reports ({{ data.reports.length }})</h3>
        <div v-if="data.reports.length === 0" class="empty">No reports.</div>
        <table v-else class="table">
          <thead><tr><th>File</th><th>Size</th><th>Status</th><th>Uploaded</th></tr></thead>
          <tbody>
            <tr v-for="r in data.reports" :key="r.id">
              <td class="td-file">{{ r.originalFileName }}</td>
              <td>{{ fmtBytes(r.sizeBytes) }}</td>
              <td><span class="badge" :class="STATUS_COLORS[r.status] || 'badge--grey'">{{ r.status }}</span></td>
              <td>{{ fmtDate(r.createdAt) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Sessions -->
      <div class="section">
        <h3 class="section-title">Recent Sessions ({{ data.sessions.length }})</h3>
        <div v-if="data.sessions.length === 0" class="empty">No sessions.</div>
        <table v-else class="table">
          <thead><tr><th>IP</th><th>Device</th><th>Created</th><th>Expires</th></tr></thead>
          <tbody>
            <tr v-for="s in data.sessions" :key="s.id">
              <td>{{ s.ipAddress || '—' }}</td>
              <td class="td-ua">{{ s.userAgent || '—' }}</td>
              <td>{{ fmtDate(s.createdAt) }}</td>
              <td>{{ fmtDate(s.expiresAt) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </div>
</template>

<style scoped>
.workbench { max-width: 1000px; }
.back-link { font-size: 13px; color: #6366f1; text-decoration: none; display: inline-block; margin-bottom: 24px; }
.back-link:hover { text-decoration: underline; }

.error-box { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 6px; padding: 10px 14px; font-size: 13px; margin-bottom: 16px; }

.user-header { margin-bottom: 20px; }
.user-email { font-size: 20px; font-weight: 700; color: #0f172a; margin: 0 0 6px; }
.user-meta { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #64748b; flex-wrap: wrap; }
.dot { color: #cbd5e1; }

.role-badge { font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 999px; background: #f1f5f9; color: #475569; }
.role-badge--superadmin { background: #ede9fe; color: #6d28d9; }
.role-badge--admin { background: #dbeafe; color: #1d4ed8; }

.status-summary { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 28px; }
.status-chip { font-size: 12px; padding: 4px 10px; border-radius: 999px; background: #f1f5f9; color: #374151; }

.section { margin-bottom: 32px; }
.section-title { font-size: 15px; font-weight: 600; color: #1e293b; margin: 0 0 12px; }
.empty { font-size: 13px; color: #94a3b8; }

.table { width: 100%; border-collapse: collapse; font-size: 13px; background: #fff; border-radius: 8px; overflow: hidden; border: 1px solid #e2e8f0; }
.table th { background: #f8fafc; padding: 10px 14px; text-align: left; font-weight: 600; color: #374151; }
.table td { padding: 10px 14px; border-top: 1px solid #f1f5f9; color: #374151; }
.td-file { font-weight: 500; max-width: 240px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.td-ua { max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 11px; color: #94a3b8; }

.badge { font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 999px; }
.badge--green { background: #dcfce7; color: #166534; }
.badge--amber { background: #fef9c3; color: #854d0e; }
.badge--orange { background: #ffedd5; color: #9a3412; }
.badge--red { background: #fee2e2; color: #991b1b; }
.badge--grey { background: #f1f5f9; color: #475569; }

.skeleton-block { height: 400px; background: #e2e8f0; border-radius: 10px; animation: pulse 1.4s ease-in-out infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
</style>
