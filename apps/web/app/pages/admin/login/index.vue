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
      <h1 class="login-title">Doclyzer Admin</h1>

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
  background: #f1f5f9;
  font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
}

.login-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.08);
  padding: 40px;
  width: 100%;
  max-width: 380px;
}

.login-title {
  font-size: 20px;
  font-weight: 700;
  margin: 0 0 24px;
  color: #0f172a;
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
  color: #374151;
}

.form-input {
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  outline: none;
  font-family: inherit;
}
.form-input:focus { border-color: #6366f1; box-shadow: 0 0 0 2px rgba(99,102,241,0.15); }
.form-input--code { letter-spacing: 0.3em; font-size: 20px; text-align: center; }

.btn-primary {
  padding: 10px;
  background: #4f46e5;
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
}
.btn-primary:hover:not(:disabled) { background: #4338ca; }
.btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }

</style>
