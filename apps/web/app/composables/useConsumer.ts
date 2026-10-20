export interface ConsumerProfile { id: string; name: string; isActive: boolean; relation?: string | null; dateOfBirth?: string | null }
export interface LabResult { id: string; parameterName: string; value: string; unit?: string | null; sampleDate?: string | null; referenceRange?: string | null; isAbnormal?: boolean; reviewState?: string; reviewVersion: number; canonicalTestId?: string | null }
export interface ConsumerReport { id: string; profileId: string; originalFileName: string; contentType: string; status: string; processingState?: string; createdAt: string; collectionDate?: string; collectionDateStatus?: string; summary?: string; extractedLabValues: LabResult[]; deletedAt?: string; purgeAfterAt?: string }

export function useConsumer() {
  const config = useRuntimeConfig()
  const apiBase = String(config.public.apiBaseUrl).replace(/\/+$/, '')
  const token = useState<string>('consumer-token', () => '')
  const profiles = useState<ConsumerProfile[]>('consumer-profiles', () => [])
  const profileId = useState<string>('consumer-profile-id', () => '')
  const router = useRouter()

  function restore() {
    if (import.meta.client && !token.value) token.value = sessionStorage.getItem('doclyzerConsumerAccessToken') ?? ''
    return !!token.value
  }
  function clear() {
    token.value = ''
    profiles.value = []
    profileId.value = ''
    if (import.meta.client) {
      sessionStorage.removeItem('doclyzerConsumerAccessToken')
      sessionStorage.removeItem('doclyzerConsumerRefreshToken')
      localStorage.removeItem('doclyzerAuthTokens')
      window.dispatchEvent(new Event('doclyzer-auth-change'))
    }
  }
  async function request<T>(path: string, options: Record<string, unknown> = {}): Promise<T> {
    restore()
    try {
      const result = await $fetch<{ data: T }>(`${apiBase}${path}`, {
        ...options,
        headers: { ...(options.headers as Record<string, string> | undefined), Authorization: `Bearer ${token.value}` },
      })
      return result.data
    } catch (cause) {
      const error = cause as { statusCode?: number; data?: { error?: { message?: string; code?: string } }; message?: string }
      if (error.statusCode === 401) {
        clear()
        await router.replace('/login?expired=1')
      }
      throw Object.assign(new Error(error.data?.error?.message ?? error.message ?? 'Something went wrong. Try again.'), { code: error.data?.error?.code, statusCode: error.statusCode })
    }
  }
  async function loadProfiles() {
    const selected = profileId.value
    const rows = await request<ConsumerProfile[]>('/profiles')
    profiles.value = rows
    profileId.value = rows.find(p => p.id === selected)?.id ?? rows.find(p => p.isActive)?.id ?? rows[0]?.id ?? ''
    return rows
  }
  async function selectProfile(id: string) {
    if (id === profileId.value) return
    const previous = profileId.value
    profileId.value = id
    try {
      await request(`/profiles/${encodeURIComponent(id)}/activate`, { method: 'PATCH' })
      profiles.value = profiles.value.map(p => ({ ...p, isActive: p.id === id }))
    } catch (error) { profileId.value = previous; throw error }
  }
  async function requireSession() {
    if (!restore()) { await router.replace('/login'); return false }
    if (!profiles.value.length) await loadProfiles()
    return true
  }
  async function signOut() {
    try { if (restore()) await request('/auth/logout', { method: 'POST' }) }
    catch { /* Local session still ends when the server is unavailable. */ }
    finally { clear(); await router.replace('/login') }
  }
  return { token, profiles, profileId, apiBase, restore, clear, request, loadProfiles, selectProfile, requireSession, signOut }
}
