<script setup lang="ts">
// Nuxt auto-imports: useSeoMeta, navigateTo, useAdminAuth are all available at runtime
useSeoMeta({ robots: 'noindex, nofollow' })
const { isAuthenticated } = useAdminAuth()
if (isAuthenticated.value) {
  navigateTo('/admin/dashboard')
} else {
  navigateTo('/admin/login')
}
</script>
