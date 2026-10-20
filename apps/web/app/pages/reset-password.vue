<script setup lang="ts">
const { apiBase } = useConsumer(); const route=useRoute();const password=ref('');const done=ref(false);const error=ref('');const busy=ref(false)
async function submit(){busy.value=true;error.value='';try{await $fetch(`${apiBase}/auth/reset-password`,{method:'POST',body:{token:String(route.query.token??''),newPassword:password.value}});done.value=true}catch(cause){error.value=(cause as {data?:{error?:{message?:string}}}).data?.error?.message??'Could not reset your password.'}finally{busy.value=false}}
</script>
<template><main class="auth"><h1>Choose a new password</h1><p v-if="done" role="status">Password updated. <NuxtLink to="/login">Sign in</NuxtLink></p><form v-else @submit.prevent="submit"><label>New password<input v-model="password" type="password" autocomplete="new-password" minlength="8" required /></label><p v-if="error" role="alert">{{ error }}</p><button :disabled="busy||!route.query.token">Save password</button></form></main></template>
<style scoped>.auth{max-width:500px;margin:10vh auto;padding:24px;font-family:system-ui}.auth form,.auth label{display:grid;gap:12px}input,button{min-height:44px;padding:10px;font:inherit}</style>
