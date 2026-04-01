export const useAdminAuth = () => {
  const config = useRuntimeConfig()
  const apiBaseUrl = config.public.apiBaseUrl as string

  const accessToken = ref<string | null>(null)
  const adminActionToken = ref<string | null>(null)

  if (import.meta.client) {
    accessToken.value = sessionStorage.getItem('admin_access_token')
    adminActionToken.value = sessionStorage.getItem('admin_action_token')
  }

  const isAuthenticated = computed(() => !!accessToken.value)
  const hasAdminToken = computed(() => !!adminActionToken.value)

  const authHeaders = computed<Record<string, string>>(() => {
    const headers: Record<string, string> = {}
    if (accessToken.value) headers['Authorization'] = `Bearer ${accessToken.value}`
    if (adminActionToken.value) headers['X-Admin-Action-Token'] = adminActionToken.value
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

  async function startMfaChallenge(): Promise<string> {
    const data = await $fetch<{ data?: { challengeId?: string } }>(
      `${apiBaseUrl}/auth/superadmin/elevation/challenge`,
      { method: 'POST', headers: { Authorization: `Bearer ${accessToken.value}` } },
    )
    const challengeId = data?.data?.challengeId ?? (data as Record<string, string>).challengeId
    if (!challengeId) throw new Error('MFA challenge failed: no challengeId returned')
    return challengeId as string
  }

  async function verifyMfa(challengeId: string, code: string): Promise<void> {
    await $fetch(`${apiBaseUrl}/auth/superadmin/elevation/verify`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${accessToken.value}` },
      body: { challengeId, code },
    })
  }

  async function issueAdminToken(challengeId: string): Promise<void> {
    const data = await $fetch<{ data?: { adminActionToken?: string } }>(
      `${apiBaseUrl}/auth/superadmin/elevation/token`,
      {
        method: 'POST',
        headers: { Authorization: `Bearer ${accessToken.value}` },
        body: { challengeId },
      },
    )
    const token =
      data?.data?.adminActionToken ??
      (data as Record<string, string>).adminActionToken
    if (!token) throw new Error('Failed to issue admin action token')
    adminActionToken.value = token as string
    if (import.meta.client) sessionStorage.setItem('admin_action_token', token as string)
  }

  function logout(): void {
    accessToken.value = null
    adminActionToken.value = null
    if (import.meta.client) {
      sessionStorage.removeItem('admin_access_token')
      sessionStorage.removeItem('admin_action_token')
    }
  }

  return {
    isAuthenticated,
    hasAdminToken,
    authHeaders,
    login,
    startMfaChallenge,
    verifyMfa,
    issueAdminToken,
    logout,
  }
}
