<script setup lang="ts">
const { apiBase } = useConsumer()
const { locale, setLocale, t } = useI18n()
const form = reactive({ email: '', password: '' })
const busy = ref(false)
const error = ref('')
const router = useRouter()
async function submit() {
  busy.value = true; error.value = ''
  try { await $fetch(`${apiBase}/auth/register`, { method: 'POST', body: { ...form, preferredLanguage: locale.value } }); await router.push('/login?registered=1') }
  catch (cause) { const e = cause as { data?: { error?: { message?: string } } }; error.value = e.data?.error?.message ?? 'Could not create your account.' }
  finally { busy.value = false }
}
</script>
<template><main class="auth"><NuxtLink to="/" class="brand">doclyzer.</NuxtLink><h1>{{ t('createAnAccount') }}</h1><p>{{ t('registerIntro') }}</p><p v-if="error" role="alert" class="error">{{ error }}</p><form @submit.prevent="submit"><LanguageSelector :model-value="locale" :disabled="busy" @update:model-value="setLocale" /><p>{{ t('languageHelp') }}</p><label>{{ t('email') }}<input v-model.trim="form.email" type="email" autocomplete="email" required /></label><label>{{ t('password') }}<input v-model="form.password" type="password" autocomplete="new-password" minlength="8" required /></label><p>{{ t('passwordHelp') }}</p><button :disabled="busy">{{ busy ? t('creating') : t('createAccount') }}</button></form><p>{{ t('alreadyAccountWeb') }}<NuxtLink to="/login">{{ t('signIn') }}</NuxtLink></p></main></template>
<style scoped>.auth{max-width:520px;margin:6vh auto;padding:24px;font-family:system-ui,sans-serif;color:#193a2d}.brand{font-weight:800;font-size:24px}.auth p a{margin-inline-start:.35em}.auth h1{font-size:2.5rem}.auth form{display:grid;gap:18px}.auth label{display:grid;gap:7px;font-weight:700}.auth input{min-height:46px;border:1px solid #9eb9a8;border-radius:10px;padding:10px;font:inherit}.auth button{min-height:48px;background:#245d49;color:white;border:0;border-radius:10px;font:inherit;font-weight:700}.error{background:#fce8e8;padding:12px}</style>
