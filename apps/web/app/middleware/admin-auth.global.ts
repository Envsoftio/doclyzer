export default defineNuxtRouteMiddleware(async (to) => {
  if (!/^\/admin(?:\/|$)/.test(to.path) || to.path === '/admin/login') return
  // Admin credentials live in sessionStorage and are checked on the client.
  if (import.meta.server) return

  const { verify } = useAdminAuth()
  if (!(await verify())) return navigateTo('/admin/login')
})
