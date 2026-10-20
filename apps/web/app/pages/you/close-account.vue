<script setup lang="ts">
definePageMeta({layout:'consumer'})
const {request,requireSession}=useConsumer(),confirmed=ref(false),status=ref(''),error=ref(''),busy=ref(false)
onMounted(async()=>{if(await requireSession()){try{const data=await request<{status:string|null}>('/account/closure-request');status.value=data.status??''}catch(cause){error.value=(cause as Error).message}}})
async function close(){if(!confirmed.value)return;busy.value=true;error.value='';try{const data=await request<{status:string}>('/account/closure-requests',{method:'POST',body:{confirmClosure:true}});status.value=data.status??'requested'}catch(cause){error.value=(cause as Error).message}finally{busy.value=false}}
</script>
<template><div><NuxtLink to="/you">← You</NuxtLink><h1>Close your account</h1><p v-if="status" class="alert success">Closure request: {{ status }}</p><p v-if="error" role="alert" class="alert error">{{ error }}</p><div class="card"><p>Account closure affects your profiles, reports, and share links. Request a data export from You first if you want a copy of your records.</p><label><input v-model="confirmed" type="checkbox" /> I understand and want to request account closure.</label><p><button :disabled="!confirmed||busy||!!status" @click="close">Request closure</button></p></div></div></template>
