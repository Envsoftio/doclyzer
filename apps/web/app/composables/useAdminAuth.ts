export const useAdminAuth = () => {
  const config = useRuntimeConfig()
  const apiBaseUrl = config.public.apiBaseUrl as string

  const accessToken = ref<string | null>(null)

  if (import.meta.client) {
    accessToken.value = sessionStorage.getItem('admin_access_token')
  }

  const isAuthenticated = computed(() => !!accessToken.value)

  const authHeaders = computed<Record<string, string>>(() => {
    const headers: Record<string, string> = {}
    if (accessToken.value) headers['Authorization'] = `Bearer ${accessToken.value}`
    return headers
  })

  async function login(email: string, password: string): Promise<void> {
    const data = await $fetch<{ data?: { accessToken?: string; token?: string } }>(
      `${apiBaseUrl}/auth/login`,
      { method: 'POST', body: { email, password } },
    )
    const token = data?.data?.accessToken ?? data?.data?.token ?? (data as Record<string, string>).accessToken ?? (data as Record<string, string>).token
    if (!token) throw new Error('Login failed: no access token returned')
    accessToken.value = token as string
    if (import.meta.client) sessionStorage.setItem('admin_access_token', token as string)
  }

  function logout(): void {
    accessToken.value = null
    if (import.meta.client) {
      sessionStorage.removeItem('admin_access_token')
    }
  }

  return {
    isAuthenticated,
    authHeaders,
    login,
    logout,
  }
}
