<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { FetchError } from 'ofetch'
import { useRouter } from '#app'

const config = useRuntimeConfig()
const baseApiUrl = config.public.apiBaseUrl.replace(/\/+$/, '')
const router = useRouter()
const route = useRoute()
const consumerToken = useState<string>('consumer-token', () => '')

type FormErrors = {
  email?: string
  password?: string
}

const form = reactive({
  email: '',
  password: '',
})

const fieldErrors = reactive<FormErrors>({})
const generalError = ref<string | null>(null)
const isSubmitting = ref(false)

const canSubmit = computed(
  () =>
    !isSubmitting.value &&
    form.email.trim().length > 0 &&
    form.password.length > 0,
)

const resetErrors = () => {
  fieldErrors.email = undefined
  fieldErrors.password = undefined
  generalError.value = null
}

const extractFetchError = (error: unknown): { message: string; code?: string } => {
  if (error instanceof FetchError) {
    const payload = error.data as Record<string, unknown> | undefined
    const errorInfo = payload?.error as Record<string, string> | undefined
    return {
      message: errorInfo?.message ?? error.message ?? 'Unable to log in right now',
      code: errorInfo?.code,
    }
  }

  if (error instanceof Error) {
    return { message: error.message, code: undefined }
  }

  return { message: 'Unable to log in right now', code: undefined }
}

const applyApiError = (message: string, code?: string) => {
  switch (code) {
    case 'AUTH_EMAIL_INVALID':
      fieldErrors.email = message
      return
    case 'AUTH_PASSWORD_INVALID':
      fieldErrors.password = message
      return
    case 'AUTH_INVALID_CREDENTIALS':
    case 'AUTH_SESSION_REVOKED':
    case 'AUTH_UNAUTHORIZED':
    case 'AUTH_RATE_LIMITED':
      generalError.value = message
      return
    default:
      generalError.value = message
  }
}

const persistTokens = (tokens: { accessToken: string; refreshToken?: string }) => {
  if (!process.client) return
  window.localStorage.removeItem('doclyzerAuthTokens')
  window.sessionStorage.setItem('doclyzerConsumerAccessToken', tokens.accessToken)
  consumerToken.value = tokens.accessToken
  if (tokens.refreshToken) window.sessionStorage.setItem('doclyzerConsumerRefreshToken', tokens.refreshToken)
}

const submitForm = async () => {
  resetErrors()
  isSubmitting.value = true

  try {
    const payload = {
      email: form.email.trim(),
      password: form.password,
    }

    const response = await $fetch<{
      data: {
        accessToken: string
        refreshToken: string
        expiresIn: number
      }
    }>(`${baseApiUrl}/auth/login`, {
      method: 'POST',
      body: payload,
    })

    const data = response.data
    persistTokens(data)
    const closure = await $fetch<{ data: { status: string | null } }>(`${baseApiUrl}/account/closure-request`, {
      headers: { Authorization: `Bearer ${data.accessToken}` },
    })
    await router.push(closure.data.status === 'pending' || !config.public.consumerWebEnabled ? '/you/close-account' : '/home')
  } catch (error) {
    const { message, code } = extractFetchError(error)
    applyApiError(message, code)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <main class="login-page">
    <section class="intro">
      <p class="eyebrow">Welcome back</p>
      <h1>Sign in to Doclyzer</h1>
      <p>
        Enter the email and password you used during registration to view your reports.
      </p>
    </section>

    <div v-if="generalError" class="alert error" role="alert">
      {{ generalError }}
    </div>
    <p v-if="route.query.expired" role="status" class="alert error">Your session expired. Sign in again.</p>
    <p v-if="route.query.registered" role="status" class="alert">Account created. Sign in to continue.</p>

    <form class="login-form" @submit.prevent="submitForm" novalidate>
      <label class="form-control">
        <span>Email</span>
        <input
          v-model="form.email"
          type="email"
          name="email"
          autocomplete="email"
          placeholder="you@example.com"
          :disabled="isSubmitting"
          required
        />
        <p v-if="fieldErrors.email" class="field-error" role="alert">{{ fieldErrors.email }}</p>
      </label>

      <label class="form-control">
        <span>Password</span>
        <input
          v-model="form.password"
          type="password"
          name="password"
          autocomplete="current-password"
          placeholder="At least 8 characters"
          minlength="8"
          :disabled="isSubmitting"
          required
        />
        <p class="helper-text">Passwords must include uppercase, lowercase, digits, and a symbol.</p>
        <p v-if="fieldErrors.password" class="field-error" role="alert">
          {{ fieldErrors.password }}
        </p>
      </label>

      <button type="submit" class="primary" :disabled="!canSubmit">
        <span v-if="isSubmitting">Submitting…</span>
        <span v-else>Log in</span>
      </button>
    </form>

    <p class="support-note">
      Need to create an account? <NuxtLink to="/register">Register</NuxtLink>.
    </p>
    <p class="support-note"><NuxtLink to="/forgot-password">Forgot password?</NuxtLink></p>
    <p class="support-note">
      <NuxtLink to="/">Back to home</NuxtLink>
    </p>
  </main>
</template>

<style scoped>
.login-page {
  max-width: 600px;
  margin: 48px auto;
  padding: 0 24px 48px;
  font-family: system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  color: #0f172a;
}

.intro {
  margin-bottom: 32px;
}

.eyebrow {
  text-transform: uppercase;
  font-size: 13px;
  letter-spacing: 0.2em;
  color: #475569;
  margin: 0 0 8px;
}

.intro h1 {
  margin: 0 0 12px;
  font-size: 2.25rem;
  line-height: 1.1;
}

.intro p {
  margin: 0;
  color: #475569;
  font-size: 1rem;
  line-height: 1.5;
}

.alert {
  padding: 16px 20px;
  border-radius: 12px;
  margin-bottom: 24px;
  font-size: 0.95rem;
}

.alert.error {
  background: #fef2f2;
  border: 1px solid #f87171;
  color: #b91c1c;
}

.alert-note {
  margin: 8px 0 0;
  font-size: 0.9rem;
  color: inherit;
}

.alert-note .strong {
  font-weight: 600;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-control {
  display: flex;
  flex-direction: column;
  gap: 8px;
  font-weight: 500;
}

.form-control input,
.form-control textarea {
  border: 1px solid #cbd5f5;
  border-radius: 12px;
  padding: 12px 14px;
  font-size: 1rem;
  transition: border 0.2s ease;
  font-family: inherit;
}

.form-control input:focus,
.form-control textarea:focus {
  border-color: #6366f1;
  outline: none;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
}

.helper-text {
  margin: 0;
  font-size: 0.85rem;
  color: #475569;
}

.field-error {
  margin: 0;
  font-size: 0.85rem;
  color: #b91c1c;
}

.primary {
  border: none;
  background: #312e81;
  color: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s ease;
}

.primary:disabled {
  background: #a5b4fc;
  cursor: not-allowed;
}

.primary:not(:disabled):hover {
  background: #4338ca;
}

.support-note {
  margin-top: 18px;
  color: #475569;
  font-size: 0.95rem;
}

.support-note a {
  color: #2563eb;
  text-decoration: underline;
}
</style>
