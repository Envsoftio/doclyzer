<script setup lang="ts">
import { ref } from 'vue'

useSeoMeta({ robots: 'noindex, nofollow', title: 'Admin Login — Doclyzer' })

const { login } = useAdminAuth()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await login(email.value.trim(), password.value)
    navigateTo('/admin/dashboard')
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Login failed'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-brand"><img src="/Doclyzer-logo.svg" width="856" height="183" alt="Doclyzer" /></div>
      <h1 class="login-title">Admin console</h1>

      <div v-if="error" class="error-box" role="alert" aria-live="assertive">
        {{ error }}
      </div>

      <form class="form" @submit.prevent="handleLogin">
        <label class="form-label">
          Email
          <input v-model="email" type="email" class="form-input" autocomplete="username" required />
        </label>
        <label class="form-label">
          Password
          <input v-model="password" type="password" class="form-input" autocomplete="current-password" required />
        </label>
        <button type="submit" class="btn-primary" :disabled="loading">
          {{ loading ? 'Signing in…' : 'Sign In' }}
        </button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: radial-gradient(70rem 40rem at 90% -10%, var(--brand-mint), transparent 60%), var(--brand-canvas);
  font-family: var(--brand-font);
}

.login-card {
  background: #fff;
  border: 1px solid var(--brand-border);
  border-radius: 24px;
  box-shadow: 0 12px 30px rgba(16, 62, 84, 0.08);
  padding: 40px;
  width: 100%;
  max-width: 380px;
}

.login-brand { display: flex; align-items: center; justify-content: center; margin-bottom: 26px; }
.login-brand img { display: block; width: 180px; height: auto; }
.login-title {
  font-size: 20px;
  font-weight: 700;
  margin: 0 0 24px;
  color: var(--brand-ink);
  text-align: center;
}

.error-box {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
  border-radius: 6px;
  padding: 10px 14px;
  font-size: 13px;
  margin-bottom: 16px;
}

.form { display: flex; flex-direction: column; gap: 16px; }

.form-label {
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 13px;
  font-weight: 500;
  color: var(--brand-ink);
}

.form-input {
  padding: 10px 12px;
  border: 1px solid var(--brand-border);
  border-radius: 9px;
  font-size: 14px;
  outline: none;
  font-family: inherit;
}
.form-input:focus { border-color: var(--brand-teal); box-shadow: 0 0 0 3px rgba(19,143,138,0.15); }
.form-input--code { letter-spacing: 0.3em; font-size: 20px; text-align: center; }

.btn-primary {
  padding: 10px;
  background: var(--brand-blue);
  color: #fff;
  border: none;
  border-radius: 9px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
}
.btn-primary:hover:not(:disabled) { background: #0d405e; }
.btn-primary:focus-visible, .form-input:focus-visible { outline: 2px solid var(--brand-teal-bright); outline-offset: 2px; }
.btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }

</style>
