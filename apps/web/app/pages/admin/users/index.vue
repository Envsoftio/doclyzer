<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'

definePageMeta({ layout: 'admin' })
useSeoMeta({ robots: 'noindex, nofollow', title: 'Users — Doclyzer Admin' })

const { adminFetch } = useAdminApi()

interface UserItem {
  id: string
  email: string
  displayName: string | null
  role: string
  createdAt: string
  profileCount: number
  reportCount: number
  lastLoginAt: string | null
}

const search = ref('')
const page = ref(1)
const limit = 50
const users = ref<UserItem[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')

let debounceTimer: ReturnType<typeof setTimeout>

async function loadUsers() {
  loading.value = true
  error.value = ''
  try {
    const params = new URLSearchParams({
      page: String(page.value),
      limit: String(limit),
      sortBy: 'createdAt',
      sortDir: 'DESC',
    })
    if (search.value.trim()) params.set('search', search.value.trim())
    const res = await adminFetch<{ data: { users: UserItem[]; total: number } }>(
      `/admin/analytics/users?${params}`,
    )
    users.value = (res as Record<string, unknown>).data
      ? ((res as Record<string, { users: UserItem[]; total: number }>).data).users
      : []
    total.value = (res as Record<string, unknown>).data
      ? ((res as Record<string, { users: UserItem[]; total: number }>).data).total
      : 0
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Failed to load users'
  } finally {
    loading.value = false
  }
}

watch(search, () => {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => { page.value = 1; loadUsers() }, 300)
})

onMounted(loadUsers)

const totalPages = computed(() => Math.ceil(total.value / limit))

function formatDate(iso: string | null): string {
  if (!iso) return '—'
  return new Date(iso).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })
}
</script>

<template>
  <div class="users-page">
    <h2 class="page-title">Users</h2>

    <div class="toolbar">
      <input v-model="search" type="search" class="search-input" placeholder="Search by email…" />
      <span class="total-label">{{ total }} users</span>
    </div>

    <div v-if="error" class="error-box">{{ error }}</div>

    <div v-if="loading" class="skeleton-table">
      <div v-for="i in 8" :key="i" class="skeleton-row" />
    </div>

    <template v-else>
      <div v-if="users.length === 0" class="empty-state">
        No users found{{ search ? ` for "${search}"` : '' }}.
      </div>

      <table v-else class="table">
        <thead>
          <tr>
            <th>Email</th>
            <th>Name</th>
            <th>Role</th>
            <th>Signed up</th>
            <th>Profiles</th>
            <th>Reports</th>
            <th>Last login</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="user in users"
            :key="user.id"
            class="table-row"
            @click="navigateTo(`/admin/users/${user.id}`)"
          >
            <td class="td-email">{{ user.email }}</td>
            <td>{{ user.displayName || '—' }}</td>
            <td><span class="role-badge" :class="`role-badge--${user.role}`">{{ user.role }}</span></td>
            <td>{{ formatDate(user.createdAt) }}</td>
            <td>{{ user.profileCount }}</td>
            <td>{{ user.reportCount }}</td>
            <td>{{ formatDate(user.lastLoginAt) }}</td>
          </tr>
        </tbody>
      </table>

      <div v-if="totalPages > 1" class="pagination">
        <button class="page-btn" :disabled="page <= 1" @click="page--; loadUsers()">← Prev</button>
        <span class="page-info">Page {{ page }} of {{ totalPages }}</span>
        <button class="page-btn" :disabled="page >= totalPages" @click="page++; loadUsers()">Next →</button>
      </div>
    </template>
  </div>
</template>

<style scoped>
.users-page { max-width: 1100px; }
.page-title { font-size: 22px; font-weight: 700; margin: 0 0 24px; color: #0f172a; }

.toolbar { display: flex; align-items: center; gap: 16px; margin-bottom: 20px; }
.search-input {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  font-family: inherit;
  width: 280px;
  outline: none;
}
.search-input:focus { border-color: #6366f1; }
.total-label { font-size: 13px; color: #64748b; }

.error-box { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 6px; padding: 10px 14px; font-size: 13px; margin-bottom: 16px; }

.empty-state { text-align: center; color: #6b7280; padding: 48px; font-size: 14px; }

.table { width: 100%; border-collapse: collapse; font-size: 13px; background: #fff; border-radius: 8px; overflow: hidden; border: 1px solid #e2e8f0; }
.table th { background: #f8fafc; padding: 10px 14px; text-align: left; font-weight: 600; color: #374151; white-space: nowrap; }
.table td { padding: 10px 14px; border-top: 1px solid #f1f5f9; color: #374151; }
.table-row { cursor: pointer; }
.table-row:hover td { background: #f8fafc; }
.td-email { font-weight: 500; color: #1e293b; }

.role-badge { font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 999px; background: #f1f5f9; color: #475569; }
.role-badge--superadmin { background: #ede9fe; color: #6d28d9; }
.role-badge--admin { background: #dbeafe; color: #1d4ed8; }

.pagination { display: flex; align-items: center; gap: 16px; margin-top: 20px; justify-content: center; }
.page-btn { padding: 6px 14px; border: 1px solid #d1d5db; border-radius: 6px; background: #fff; font-size: 13px; cursor: pointer; font-family: inherit; }
.page-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.page-btn:hover:not(:disabled) { background: #f1f5f9; }
.page-info { font-size: 13px; color: #64748b; }

.skeleton-table { display: flex; flex-direction: column; gap: 8px; }
.skeleton-row { height: 44px; background: #e2e8f0; border-radius: 6px; animation: pulse 1.4s ease-in-out infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
</style>
