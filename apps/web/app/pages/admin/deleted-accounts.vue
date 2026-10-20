<script setup lang="ts">
import { formatDisplayDate } from '../../utils/formatDisplayDate'
definePageMeta({ layout: 'admin' })
useSeoMeta({ title: 'Deleted accounts — Doclyzer Admin', robots: 'noindex, nofollow' })
const { adminFetch } = useAdminApi()
const records = ref<Array<{ userId: string; email: string; requestedAt: string; purgedAt: string }>>([])
const error = ref('')
onMounted(async () => {
  try {
    const result = await adminFetch<{ data: typeof records.value }>('/account/deletion-records')
    records.value = result.data
  } catch (cause) { error.value = (cause as Error).message }
})
</script>

<template>
  <main>
    <h1>Deleted accounts</h1>
    <p>Basic deletion records are visible to superadmins only. Account data and files have been removed.</p>
    <p v-if="error" role="alert">{{ error }}</p>
    <p v-else-if="!records.length">No permanently deleted accounts.</p>
    <table v-else>
      <thead><tr><th>Email</th><th>Account ID</th><th>Requested</th><th>Purged</th></tr></thead>
      <tbody><tr v-for="record in records" :key="record.userId"><td>{{ record.email }}</td><td>{{ record.userId }}</td><td>{{ formatDisplayDate(record.requestedAt) }}</td><td>{{ formatDisplayDate(record.purgedAt) }}</td></tr></tbody>
    </table>
  </main>
</template>

<style scoped>
main{max-width:1100px}h1{font-size:24px}p{color:#475569}table{border-collapse:collapse;width:100%;background:white}th,td{text-align:left;padding:12px;border-bottom:1px solid #e2e8f0;font-size:13px}th{color:#334155;background:#f8fafc}td{word-break:break-word}
</style>
