<script setup lang="ts">
const props = defineProps<{ reportId: string; summary: string }>()
const { locale, t } = useI18n()
const { request } = useConsumer()
const language = ref(locale.value)
const translated = ref('')
const loading = ref(false)
const errorCode = ref('')
let version = 0
let retryTimer: ReturnType<typeof setTimeout> | undefined

async function load(attempt = 0) {
  const current = ++version
  if (retryTimer) clearTimeout(retryTimer)
  retryTimer = undefined
  translated.value = ''
  errorCode.value = ''
  loading.value = language.value !== 'en'
  if (!loading.value) return
  try {
    const result = await request<{ summary: string | null; locale: string }>(`/reports/${encodeURIComponent(props.reportId)}/summary/language`, {
      method: 'POST', body: { locale: language.value },
    })
    if (current !== version) return
    if (result.locale !== language.value || !result.summary) { errorCode.value = 'NARRATIVE_SOURCE_CHANGED'; return }
    translated.value = result.summary
  } catch (error) {
    if (current !== version) return
    const code = (error as { code?: string }).code ?? ''
    if (code === 'NARRATIVE_PENDING' && attempt < 10) {
      retryTimer = setTimeout(() => { if (current === version) void load(attempt + 1) }, 12_000)
      return
    }
    errorCode.value = code || 'unavailable'
  } finally { if (current === version && !retryTimer) loading.value = false }
}

watch(locale, value => { language.value = value })
watch([language, () => props.summary, () => props.reportId], () => { void load() })
onMounted(() => void load())
onBeforeUnmount(() => { ++version; if (retryTimer) clearTimeout(retryTimer) })
</script>

<template>
  <div>
    <LanguageSelector v-model="language" description />
    <p v-if="language === 'en'" lang="en" class="summary-text">{{ summary }}</p>
    <p v-else-if="loading" role="status">{{ t('translationLoading') }}</p>
    <div v-else-if="errorCode" role="alert">
      <p>{{ t(errorCode === 'NARRATIVE_SOURCE_CHANGED' ? 'sourceChanged' : 'translationFailed') }}</p>
      <button class="secondary" type="button" @click="load()">{{ t('tryAgain') }}</button>
    </div>
    <template v-else>
      <p :lang="language" class="summary-text">{{ translated }}</p>
      <p class="muted">{{ t('translationNote') }}</p>
    </template>
  </div>
</template>

<style scoped>.summary-text { white-space: pre-wrap; line-height: 1.7; overflow-wrap: anywhere; }</style>
