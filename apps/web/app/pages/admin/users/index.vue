<script setup lang="ts">
import { formatDisplayDate } from '../../../utils/formatDisplayDate'

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
  activeDeviceCount: number
  lastLoginAt: string | null
}

const search = ref('')
const sortBy = ref<'createdAt' | 'email' | 'reportCount'>('createdAt')
const sortDir = ref<'ASC' | 'DESC'>('DESC')
const page = ref(1)
const pageSize = ref(25)
const users = ref<UserItem[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const totalPages = computed(() => Math.max(1, Math.ceil(total.value / pageSize.value)))
let debounceTimer: ReturnType<typeof setTimeout> | undefined
let requestVersion = 0

async function loadUsers() {
  const version = ++requestVersion
  loading.value = true
  error.value = ''
  try {
    const params = new URLSearchParams({
      page: String(page.value),
      limit: String(pageSize.value),
      sortBy: sortBy.value,
      sortDir: sortDir.value,
    })
    if (search.value.trim()) params.set('search', search.value.trim())
    const response = await adminFetch<{ data: { users: UserItem[]; total: number } }>(`/admin/analytics/users?${params}`)
    if (version !== requestVersion) return
    users.value = response.data.users
    total.value = response.data.total
  } catch (cause: unknown) {
    if (version === requestVersion) error.value = cause instanceof Error ? cause.message : 'Could not load users.'
  } finally {
    if (version === requestVersion) loading.value = false
  }
}

function applyFilters() {
  if (debounceTimer) clearTimeout(debounceTimer)
  page.value = 1
  void loadUsers()
}

function changePage(next: number) {
  page.value = next
  void loadUsers()
}

watch(search, () => {
  if (debounceTimer) clearTimeout(debounceTimer)
  debounceTimer = setTimeout(applyFilters, 350)
})
onMounted(loadUsers)
onUnmounted(() => { if (debounceTimer) clearTimeout(debounceTimer) })

function formatDate(iso: string | null): string {
  return iso ? formatDisplayDate(iso, true) : '—'
}
</script>

<template>
  <div class="admin-ops users-page">
    <header class="admin-ops__header">
      <div>
        <p class="admin-ops__eyebrow">Manage / Accounts</p>
        <h1>Users</h1>
        <p class="admin-ops__subtitle">Find an account, review its activity, and inspect its reports.</p>
      </div>
      <button class="admin-ops__button" type="button" :disabled="loading" @click="loadUsers">Refresh</button>
    </header>

    <section class="admin-ops__card">
      <form class="admin-ops__row filters" @submit.prevent="applyFilters">
        <label class="admin-ops__field filter-search">Search accounts
          <input v-model="search" class="admin-ops__input" type="search" placeholder="Name, email, or UUID" autocomplete="off" />
        </label>
        <label class="admin-ops__field">Sort by
          <select v-model="sortBy" class="admin-ops__select" @change="applyFilters">
            <option value="createdAt">Sign-up date</option>
            <option value="email">Email</option>
            <option value="reportCount">Report count</option>
          </select>
        </label>
        <label class="admin-ops__field">Order
          <select v-model="sortDir" class="admin-ops__select" @change="applyFilters">
            <option value="DESC">Descending</option>
            <option value="ASC">Ascending</option>
          </select>
        </label>
        <label class="admin-ops__field">Rows
          <select v-model.number="pageSize" class="admin-ops__select" @change="applyFilters">
            <option :value="25">25</option>
            <option :value="50">50</option>
            <option :value="100">100</option>
          </select>
        </label>
        <button class="admin-ops__button admin-ops__button--primary" type="submit">Apply</button>
      </form>

      <div class="result-heading">
        <div><h2>Account directory</h2><p>{{ total }} {{ total === 1 ? 'account' : 'accounts' }}{{ search.trim() ? ' matching this search' : '' }}</p></div>
        <NuxtLink to="/admin/deleted-accounts">Deleted accounts →</NuxtLink>
      </div>

      <p v-if="error" class="admin-ops__message admin-ops__message--error" role="alert">{{ error }}</p>
      <div v-if="loading" class="loading-rows" role="status" aria-label="Loading users"><div v-for="i in 6" :key="i" /></div>
      <p v-else-if="users.length === 0" class="admin-ops__empty">No users match the current search.</p>
      <div v-else class="admin-ops__table-wrap">
        <table class="admin-ops__table">
          <thead><tr><th scope="col">Account</th><th scope="col">Role</th><th scope="col">Signed up</th><th scope="col">Profiles</th><th scope="col">Reports</th><th scope="col">Active push devices</th><th scope="col">Last login</th><th scope="col">Actions</th></tr></thead>
          <tbody>
            <tr v-for="user in users" :key="user.id">
              <td class="account-cell"><strong>{{ user.email }}</strong><small>{{ user.displayName || 'No display name' }}</small></td>
              <td><span class="admin-ops__badge">{{ user.role.replaceAll('_', ' ') }}</span></td>
              <td>{{ formatDate(user.createdAt) }}</td>
              <td>{{ user.profileCount }}</td>
              <td>{{ user.reportCount }}</td>
              <td>{{ user.activeDeviceCount ?? '—' }}</td>
              <td>{{ formatDate(user.lastLoginAt) }}</td>
              <td class="actions-cell"><NuxtLink :to="`/admin/users/${user.id}`">Workbench</NuxtLink><NuxtLink :to="`/admin/reports?userId=${user.id}`">Reports</NuxtLink></td>
            </tr>
          </tbody>
        </table>
      </div>

      <footer v-if="!loading && total > 0" class="admin-ops__pagination">
        <span>{{ (page - 1) * pageSize + 1 }}–{{ Math.min(page * pageSize, total) }} of {{ total }} accounts</span>
        <div><button class="admin-ops__button" type="button" :disabled="page <= 1" @click="changePage(page - 1)">Previous</button><span>Page {{ page }} of {{ totalPages }}</span><button class="admin-ops__button" type="button" :disabled="page >= totalPages" @click="changePage(page + 1)">Next</button></div>
      </footer>
    </section>
  </div>
</template>

<style scoped>
.users-page { max-width: 1280px; }
.filters { margin-bottom: 18px; }
.filters > .filter-search { flex: 2; min-width: 220px; }
.filters > button { margin-bottom: 15px; }
.result-heading { display: flex; align-items: end; justify-content: space-between; gap: 16px; margin-bottom: 16px; }
.result-heading h2 { margin-bottom: 3px; }
.result-heading p { margin: 0; color: var(--brand-muted); font-size: 14px; }
.result-heading a { font-size: 14px; font-weight: 700; white-space: nowrap; }
.account-cell { min-width: 210px; overflow-wrap: anywhere; }
.account-cell strong, .account-cell small { display: block; }
.account-cell small { margin-top: 3px; color: var(--brand-muted); font-size: 13px; }
.actions-cell { white-space: nowrap; }
.actions-cell a { font-weight: 700; margin-right: 14px; }
.loading-rows { display: grid; gap: 8px; }
.loading-rows > div { height: 48px; border-radius: 8px; background: linear-gradient(90deg, var(--brand-mint), #f6fbfa, var(--brand-mint)); background-size: 200% 100%; animation: shimmer 1.5s ease-in-out infinite; }
@keyframes shimmer { to { background-position: -200% 0; } }
@media (max-width: 640px) { .result-heading { align-items: flex-start; flex-direction: column; } .filters > button { margin-bottom: 0; width: 100%; } }
@media (prefers-reduced-motion: reduce) { .loading-rows > div { animation: none; } }
</style>
