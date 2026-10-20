<script setup lang="ts">
const { apiBase } = useConsumer(); const email = ref(''); const sent = ref(false); const error = ref(''); const busy = ref(false)
async function submit(){ busy.value=true;error.value='';try{await $fetch(`${apiBase}/auth/forgot-password`,{method:'POST',body:{email:email.value}});sent.value=true}catch(cause){error.value=(cause as {data?:{error?:{message?:string}}}).data?.error?.message??'Could not send the reset link.'}finally{busy.value=false}}
</script>
<template><main class="auth"><h1>Reset your password</h1><p v-if="sent" role="status">If this email has an account, a reset link is on its way.</p><form v-else @submit.prevent="submit"><label>Email<input v-model.trim="email" type="email" autocomplete="email" required /></label><p v-if="error" role="alert">{{ error }}</p><button :disabled="busy">Send reset link</button></form><NuxtLink to="/login">Back to sign in</NuxtLink></main></template>
<style scoped>.auth{max-width:500px;margin:10vh auto;padding:24px;font-family:system-ui}.auth form,.auth label{display:grid;gap:12px}input,button{min-height:44px;padding:10px;font:inherit}</style>
