<script setup lang="ts">
const processing = useState<Record<string, { status: string; acknowledgedAt?: string }>>('report-processing', () => ({}))
const readyCount = computed(() => Object.values(processing.value).filter(r => r.status === 'ready' && !r.acknowledgedAt).length)
const dismissing = ref(false)
const dismissError = ref('')
const config = useRuntimeConfig()
async function dismissReady() {
  dismissing.value = true
  dismissError.value = ''
  const token = sessionStorage.getItem('doclyzerConsumerAccessToken')
  try {
    for (const [id, row] of Object.entries(processing.value)) {
      if (row.status !== 'ready' || row.acknowledgedAt) continue
      await $fetch(`${String(config.public.apiBaseUrl).replace(/\/+$/, '')}/reports/processing/${encodeURIComponent(id)}/acknowledge`, {
        method: 'POST', headers: { Authorization: `Bearer ${token}` },
      })
      if (token !== sessionStorage.getItem('doclyzerConsumerAccessToken')) return
      if (processing.value[id] === row) row.acknowledgedAt = new Date().toISOString()
    }
  } catch { dismissError.value = 'Could not dismiss notifications. Try again.' }
  finally { dismissing.value = false }
}
</script>
<template>
  <div>
    <NuxtRouteAnnouncer />
    <div v-if="readyCount" role="status" style="padding:12px;text-align:center;background:#e6f4ee"><NuxtLink to="/reports">{{ readyCount }} report(s) ready to review</NuxtLink> <button :disabled="dismissing" @click="dismissReady">Dismiss</button><span v-if="dismissError" role="alert">{{ dismissError }}</span></div>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<style>
body {
  margin: 0;
}
</style>
