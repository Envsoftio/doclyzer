<script setup lang="ts">
import { ref } from 'vue'

useSeoMeta({ robots: 'noindex, nofollow', title: 'Admin Login — Doclyzer' })

const { login, startMfaChallenge, verifyMfa, issueAdminToken } = useAdminAuth()

type Step = 1 | 2 | 3
const step = ref<Step>(1)
const email = ref('')
const password = ref('')
const mfaCode = ref('')
const challengeId = ref('')
const error = ref('')
const loading = ref(false)

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await login(email.value.trim(), password.value)
    step.value = 2
    const id = await startMfaChallenge()
    challengeId.value = id
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'Login failed'
  } finally {
    loading.value = false
  }
}

async function handleMfa() {
  error.value = ''
  loading.value = true
  try {
    await verifyMfa(challengeId.value, mfaCode.value.trim())
    step.value = 3
    await issueAdminToken(challengeId.value)
    navigateTo('/admin/dashboard')
  } catch (e: unknown) {
    error.value = (e instanceof Error ? e.message : String(e)) || 'MFA verification failed'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-card">
      <h1 class="login-title">Doclyzer Admin</h1>

      <div class="steps">
        <span class="step" :class="{ 'step--active': step >= 1, 'step--done': step > 1 }">1. Credentials</span>
        <span class="step-divider">›</span>
        <span class="step" :class="{ 'step--active': step >= 2, 'step--done': step > 2 }">2. MFA</span>
        <span class="step-divider">›</span>
        <span class="step" :class="{ 'step--active': step >= 3 }">3. Access</span>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>

      <!-- Step 1: credentials -->
      <form v-if="step === 1" class="form" @submit.prevent="handleLogin">
        <label class="form-label">
          Email
          <input v-model="email" type="email" class="form-input" autocomplete="username" required />
        </label>
        <label class="form-label">
          Password
          <input v-model="password" type="password" class="form-input" autocomplete="current-password" required />
        </label>
        <button type="submit" class="btn-primary" :disabled="loading">
          {{ loading ? 'Signing in…' : 'Continue' }}
        </button>
      </form>

      <!-- Step 2: TOTP -->
      <form v-else-if="step === 2" class="form" @submit.prevent="handleMfa">
        <p class="hint">Enter your 6-digit authenticator code.</p>
        <label class="form-label">
          TOTP Code
          <input
            v-model="mfaCode"
            type="text"
            inputmode="numeric"
            pattern="[0-9]{6}"
            maxlength="6"
            class="form-input form-input--code"
            autocomplete="one-time-code"
            required
          />
        </label>
        <button type="submit" class="btn-primary" :disabled="loading">
          {{ loading ? 'Verifying…' : 'Verify & Continue' }}
        </button>
      </form>

      <!-- Step 3: issuing token -->
      <div v-else class="step-loading">
        <p>Issuing admin token…</p>
      </div>
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

.steps {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  margin-bottom: 24px;
  font-size: 12px;
  color: #94a3b8;
}
.step--active { color: #1e293b; font-weight: 600; }
.step--done { color: #22c55e; }
.step-divider { color: #cbd5e1; }

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

.hint { font-size: 13px; color: #6b7280; margin: 0; }
.step-loading { text-align: center; color: #6b7280; font-size: 14px; }
</style>
