import type { FetchOptions } from 'ofetch'

export const useAdminApi = () => {
  const config = useRuntimeConfig()
  const apiBaseUrl = config.public.apiBaseUrl as string
  const { isAuthenticated, authHeaders } = useAdminAuth()

  async function adminFetch<T>(url: string, options?: FetchOptions): Promise<T> {
    if (!isAuthenticated.value) throw new Error('Not authenticated')
    return $fetch<T>(`${apiBaseUrl}${url}`, {
      ...options,
      headers: {
        ...authHeaders.value,
        ...(options?.headers as Record<string, string> | undefined),
      },
    })
  }

  return { adminFetch }
}
