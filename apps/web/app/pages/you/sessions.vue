<script setup lang="ts">
definePageMeta({layout:'consumer'})
const {request,requireSession}=useConsumer();const sessions=ref<{sessionId:string;createdAt?:string;isCurrent?:boolean;userAgent?:string}[]>([]),error=ref(''),busy=ref(false)
async function load(){try{sessions.value=await request('/auth/sessions')}catch(cause){error.value=(cause as Error).message}}
onMounted(async()=>{if(await requireSession())await load()})
async function revoke(id:string){busy.value=true;try{await request(`/auth/sessions/${id}`,{method:'DELETE'});await load()}catch(cause){error.value=(cause as Error).message}finally{busy.value=false}}
</script>
<template><div><NuxtLink to="/you">← You</NuxtLink><h1>Signed-in sessions</h1><p v-if="error" role="alert" class="alert error">{{ error }}</p><p v-for="s in sessions" :key="s.sessionId" class="card row"><span>{{ s.userAgent ?? 'Unknown device' }} · {{ s.createdAt ? new Date(s.createdAt).toLocaleString() : 'unknown date' }} {{ s.isCurrent?'· This device':'' }}</span><button v-if="!s.isCurrent" :disabled="busy" class="secondary" @click="revoke(s.sessionId)">Revoke</button></p><p v-if="!sessions.length">No sessions to show.</p></div></template>
