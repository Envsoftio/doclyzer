// Keep the consumer web pages in source for a later release. Until then,
// direct URLs must not expose web registration, sign-in, or private journeys.
export default defineNuxtRouteMiddleware((to) => {
  const enabled = useRuntimeConfig().public.consumerWebEnabled
  if (enabled) return
  // Account deletion and restoration must remain accessible from a browser.
  if (to.path === '/login' || to.path === '/you/close-account') return
  if (import.meta.client) {
    sessionStorage.removeItem('doclyzerConsumerAccessToken')
    sessionStorage.removeItem('doclyzerConsumerRefreshToken')
    useState<string>('consumer-token', () => '').value = ''
  }
  const consumerPaths = /^\/(?:login|register|forgot-password|reset-password|home|reports|trends|you)(?:\/|$)/
  if (consumerPaths.test(to.path)) return navigateTo('/mobile', { redirectCode: 302 })
})
