<script setup lang="ts">
const { apiBase } = useConsumer()
const form = reactive({ email: '', password: '' })
const busy = ref(false)
const error = ref('')
const router = useRouter()
async function submit() {
  busy.value = true; error.value = ''
  try { await $fetch(`${apiBase}/auth/register`, { method: 'POST', body: form }); await router.push('/login?registered=1') }
  catch (cause) { const e = cause as { data?: { error?: { message?: string } } }; error.value = e.data?.error?.message ?? 'Could not create your account.' }
  finally { busy.value = false }
}
</script>
<template><main class="auth"><NuxtLink to="/" class="brand">doclyzer.</NuxtLink><h1>Create an account</h1><p>Keep your lab reports together and review results over time.</p><p v-if="error" role="alert" class="error">{{ error }}</p><form @submit.prevent="submit"><label>Email<input v-model.trim="form.email" type="email" autocomplete="email" required /></label><label>Password<input v-model="form.password" type="password" autocomplete="new-password" minlength="8" required /></label><p>Use at least 8 characters with uppercase, lowercase, a number, and a symbol.</p><button :disabled="busy">{{ busy ? 'Creating…' : 'Create account' }}</button></form><p>Already have an account? <NuxtLink to="/login">Sign in</NuxtLink></p></main></template>
<style scoped>.auth{max-width:520px;margin:6vh auto;padding:24px;font-family:system-ui,sans-serif;color:#193a2d}.brand{font-weight:800;font-size:24px}.auth h1{font-size:2.5rem}.auth form{display:grid;gap:18px}.auth label{display:grid;gap:7px;font-weight:700}.auth input{min-height:46px;border:1px solid #9eb9a8;border-radius:10px;padding:10px;font:inherit}.auth button{min-height:48px;background:#245d49;color:white;border:0;border-radius:10px;font:inherit;font-weight:700}.error{background:#fce8e8;padding:12px}</style>
