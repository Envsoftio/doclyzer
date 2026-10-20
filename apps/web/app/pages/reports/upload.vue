<script setup lang="ts">
definePageMeta({ layout: 'consumer' })
const { profileId, profiles, request, requireSession } = useConsumer()
const file = ref<File | null>(null), busy = ref(false), error = ref(''), message = ref(''), duplicate = ref(false)
const router = useRouter()
onMounted(() => { void requireSession() })
function choose(event: Event) { file.value = (event.target as HTMLInputElement).files?.[0] ?? null; duplicate.value = false; error.value = '' }
async function upload() {
  if (!file.value || !profileId.value) return
  if (!['application/pdf','image/jpeg','image/png'].includes(file.value.type) && !/\.(pdf|jpe?g|png)$/i.test(file.value.name)) { error.value = 'Choose a PDF, JPG, or PNG file.'; return }
  busy.value = true; error.value = ''; message.value = 'Uploading your file…'
  try {
    const hash = Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', await file.value.arrayBuffer()))).map(x => x.toString(16).padStart(2,'0')).join('')
    const keyName = `report-upload:${profileId.value}:${hash}`
    const key = sessionStorage.getItem(keyName) ?? crypto.randomUUID(); sessionStorage.setItem(keyName,key)
    const form = new FormData(); form.append('file',file.value); form.append('profileId',profileId.value)
    const result = await request<{ reportId?: string; id?: string }>('/reports/processing/uploads',{method:'POST',body:form,headers:{'Idempotency-Key':key}})
    message.value = 'Upload accepted. Processing continues while you browse.'
    await router.push(result.reportId || result.id ? `/reports/${result.reportId ?? result.id}` : '/reports')
  } catch (cause) { const e = cause as Error & {code?:string}; error.value = e.message; duplicate.value = /DUPLICATE/.test(e.code ?? ''); message.value = '' }
  finally { busy.value = false }
}
</script>
<template><div><header class="page-heading"><div><p class="eyebrow">New report</p><h1>Add a report</h1></div></header><div class="card stack"><p>Choose a PDF, JPG, or PNG. Check the person and file before upload.</p><label class="field">Report file<input type="file" accept="application/pdf,image/jpeg,image/png" @change="choose" /></label><label class="field">This report belongs to<select v-model="profileId"><option v-for="p in profiles" :key="p.id" :value="p.id">{{ p.name }}</option></select></label><div v-if="file" class="alert success"><strong>{{ file.name }}</strong><br />{{ (file.size/1024/1024).toFixed(1) }} MB · For {{ profiles.find(p=>p.id===profileId)?.name }}</div><p v-if="message" role="status">{{ message }}</p><p v-if="error" role="alert" class="alert error">{{ error }}<span v-if="duplicate"> Check your existing reports before trying again.</span></p><div class="actions"><button :disabled="busy||!file||!profileId" @click="upload">{{ busy ? 'Uploading…' : 'Confirm and upload' }}</button><NuxtLink class="button secondary" to="/reports">Cancel</NuxtLink></div></div></div></template>
