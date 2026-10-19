<script setup lang="ts">
const processing = useState<Record<string, { status: string; acknowledgedAt?: string }>>('report-processing', () => ({}))
const readyCount = computed(() => Object.values(processing.value).filter(r => r.status === 'ready' && !r.acknowledgedAt).length)
</script>
<template>
  <div>
    <NuxtRouteAnnouncer />
    <div v-if="readyCount" role="status" style="padding:12px;text-align:center;background:#e6f4ee"><NuxtLink to="/reports">{{ readyCount }} report(s) ready to review</NuxtLink></div>
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
