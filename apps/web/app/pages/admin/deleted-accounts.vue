<script setup lang="ts">
import { formatDisplayDate } from '../../utils/formatDisplayDate'
definePageMeta({ layout: 'admin' })
useSeoMeta({ title: 'Deleted accounts — Doclyzer Admin', robots: 'noindex, nofollow' })
const { adminFetch } = useAdminApi()
const records = ref<Array<{ userId: string; email: string; requestedAt: string; purgedAt: string }>>([])
const error = ref('')
const search = ref('')
const page = ref(1)
const pageSize = 20
const filtered = computed(() => records.value.filter(record => `${record.email} ${record.userId}`.toLowerCase().includes(search.value.trim().toLowerCase())))
const visible = computed(() => filtered.value.slice((page.value - 1) * pageSize, page.value * pageSize))
const pages = computed(() => Math.max(1, Math.ceil(filtered.value.length / pageSize)))
watch(search, () => { page.value = 1 })
onMounted(async () => {
  try {
    const result = await adminFetch<{ data: typeof records.value }>('/account/deletion-records')
    records.value = result.data
  } catch (cause) { error.value = (cause as Error).message }
})
</script>

<template>
  <div class="admin-ops">
    <header class="admin-ops__header"><div><p class="admin-ops__eyebrow">Manage / Users</p><h1>Deleted accounts</h1><p class="admin-ops__subtitle">Deletion records for permanently removed accounts.</p></div></header>
    <section class="admin-ops__card"><label class="admin-ops__field">Find email or account ID<input v-model="search" class="admin-ops__input" type="search" placeholder="Email or ID" /></label>
    <p v-if="error" class="admin-ops__message admin-ops__message--error" role="alert">{{ error }}</p>
    <p v-else-if="!filtered.length" class="admin-ops__empty">No deletion records match.</p>
    <div v-else class="admin-ops__table-wrap"><table class="admin-ops__table">
      <thead><tr><th>Email</th><th>Account ID</th><th>Requested</th><th>Purged</th></tr></thead>
      <tbody><tr v-for="record in visible" :key="record.userId"><td>{{ record.email }}</td><td class="admin-ops__code">{{ record.userId }}</td><td>{{ formatDisplayDate(record.requestedAt) }}</td><td>{{ formatDisplayDate(record.purgedAt) }}</td></tr></tbody>
    </table></div>
    <div v-if="filtered.length > pageSize" class="admin-ops__pagination"><span>{{ (page - 1) * pageSize + 1 }}–{{ Math.min(page * pageSize, filtered.length) }} of {{ filtered.length }}</span><div><button class="admin-ops__button" :disabled="page <= 1" @click="page--">Previous</button><span>Page {{ page }} of {{ pages }}</span><button class="admin-ops__button" :disabled="page >= pages" @click="page++">Next</button></div></div></section>
  </div>
</template>
