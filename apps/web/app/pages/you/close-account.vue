<script setup lang="ts">
definePageMeta({ layout: 'consumer' })
useSeoMeta({ title: 'Delete account — Doclyzer', robots: 'noindex, nofollow' })
const { request, restore, signOut } = useConsumer()
const confirmed = ref(false)
const password = ref('')
const closure = ref<{ status: string; purgeAfterAt?: string } | null>(null)
const error = ref('')
const busy = ref(false)

onMounted(async () => {
  if (!restore()) { await navigateTo('/login'); return }
  try {
    const data = await request<{ request: { status: string; purgeAfterAt?: string } | null }>('/account/closure-request')
    closure.value = data.request
  } catch (cause) { error.value = (cause as Error).message }
})

async function close() {
  if (!confirmed.value || !password.value) return
  busy.value = true; error.value = ''
  try {
    closure.value = await request<{ status: string; purgeAfterAt?: string }>('/account/closure-requests', { method: 'POST', body: { confirmClosure: true, password: password.value } })
    password.value = ''
    await signOut()
  } catch (cause) { error.value = (cause as Error).message }
  finally { busy.value = false }
}

async function restoreAccount() {
  busy.value = true; error.value = ''
  try {
    await request('/account/closure-request/restore', { method: 'POST' })
    await navigateTo('/home')
  } catch (cause) { error.value = (cause as Error).message }
  finally { busy.value = false }
}
</script>

<template>
  <div>
    <NuxtLink v-if="closure?.status !== 'pending'" to="/you">← You</NuxtLink>
    <h1>Delete your account</h1>
    <p v-if="error" role="alert" class="alert error">{{ error }}</p>
    <div class="card" v-if="closure?.status === 'pending'">
      <h2>Deletion is scheduled</h2>
      <p>Your account is disabled. Sign in and restore it before {{ closure.purgeAfterAt ? new Date(closure.purgeAfterAt).toLocaleDateString() : 'the 30-day deadline' }}.</p>
      <button :disabled="busy" @click="restoreAccount">Restore my account</button>
    </div>
    <div v-else class="card">
      <p>Your account access and share links stop immediately. You can restore your account within 30 days by signing in again. After 30 days, your account, profiles, reports, and stored files are deleted from active storage. A basic deletion record remains for the superadmin. Independent payment and security audit records may remain where required.</p>
      <p>Export any data you want to keep before requesting deletion.</p>
      <label><input v-model="confirmed" type="checkbox" /> I understand and want to delete my account.</label>
      <p><label>Confirm with your current password <input v-model="password" type="password" autocomplete="current-password" /></label></p>
      <p><button :disabled="!confirmed || !password || busy" @click="close">Schedule account deletion</button></p>
    </div>
  </div>
</template>
