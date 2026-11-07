<script setup lang="ts">
const { t, locale } = useI18n()
const { statusLabel } = useReportLabels()
import type { ConsumerReport } from '../composables/useConsumer'
import { formatDisplayDate as formatDateForLocale } from '../utils/formatDisplayDate'
function formatDisplayDate(value: string, includeTime = false) { return formatDateForLocale(value, includeTime, locale.value) }
definePageMeta({layout:'consumer'})
const { profileId, profiles, request, requireSession } = useConsumer()
const reports=ref<ConsumerReport[]>([]), loading=ref(true), error=ref('')
useHead({title:'Home | Doclyzer'})
async function load(){ const id=profileId.value;reports.value=[];loading.value=true;error.value='';if(!id){loading.value=false;return}try{const data=await request<{reports:ConsumerReport[]}>(`/reports?profileId=${encodeURIComponent(id)}`);if(id===profileId.value)reports.value=data.reports}catch(cause){error.value=(cause as Error).message}finally{loading.value=false}}
onMounted(async()=>{try{if(await requireSession())await load()}catch(cause){error.value=(cause as Error).message;loading.value=false}})
watch(profileId,()=>void load())
const latest=computed(()=>reports.value[0]);const attention=computed(()=>reports.value.filter(r=>['failed','needs_attention','processing'].includes(r.processingState??'')))
</script>
<template><div><header class="page-heading"><div><p class="eyebrow">{{ profiles.find(p=>p.id===profileId)?.name ?? t('yourSpace') }}</p><h1>{{ t('resultsOnePlace') }}</h1><p class="muted">{{ t('homeReviewHelp') }}</p></div><NuxtLink class="button" to="/reports/upload">{{ t('addReport') }}</NuxtLink></header><p v-if="error" role="alert" class="alert error">{{ error }} <button class="secondary" @click="load">{{ t('retry') }}</button></p><p v-if="loading" role="status">{{ t('loadingYourReports') }}</p><div v-else-if="!profiles.length" class="empty"><h2>{{ t('startProfile') }}</h2><p>{{ t('startProfileHelp') }}</p><NuxtLink class="button" to="/you">{{ t('addProfile') }}</NuxtLink></div><div v-else-if="!reports.length" class="empty"><h2>{{ t('noReportsYet') }}</h2><p>{{ t('addLabReportHelp') }}</p><NuxtLink class="button" to="/reports/upload">{{ t('addReport') }}</NuxtLink></div><template v-else><section v-if="attention.length" class="card"><h2>{{ t('needsAttention') }}</h2><p>{{ t('reviewReportCount', { count: attention.length }) }}</p><NuxtLink to="/reports">{{ t('seeReports') }}</NuxtLink></section><section class="card"><p class="eyebrow">{{ t('latestReport') }}</p><h2>{{ latest?.originalFileName }}</h2><p class="muted">{{ latest?.collectionDate ? t('collectedOn', { date: formatDisplayDate(latest.collectionDate) }) : t('unknownCollection') }}</p><p>{{ statusLabel(latest?.processingState ?? latest?.status) }}</p><NuxtLink v-if="latest" class="button" :to="`/reports/${latest.id}`">{{ t('viewReport') }}</NuxtLink></section><div class="grid"><NuxtLink class="card" to="/reports"><h2>{{ t('reportHistory') }}</h2><p>{{ t('findEveryReport') }}</p></NuxtLink><NuxtLink class="card" to="/trends"><h2>{{ t('trends') }}</h2><p>{{ t('comparableOverTime') }}</p></NuxtLink></div></template></div></template>
