<script setup lang="ts">
const config = useRuntimeConfig()
const siteUrl = config.public.siteUrl
const adminUrl = `${siteUrl.replace(/\/+$/, '')}/admin`

useSeoMeta({
  title: 'Doclyzer Admin',
  description: 'Doclyzer superadmin console entry point.',
  robots: 'noindex, nofollow',
})

useHead({
  link: [{ rel: 'canonical', href: adminUrl }],
})
</script>

<template>
  <main class="admin-page">
    <h1>Doclyzer Admin</h1>
    <p>The superadmin dashboard is being set up.</p>
    <p>Please check back soon or contact platform support for access.</p>
    <NuxtLink to="/">Back to Home</NuxtLink>
  </main>
</template>

<style scoped>
.admin-page {
  max-width: 720px;
  margin: 48px auto;
  padding: 0 24px;
  font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
  color: #111827;
}

h1 {
  margin: 0 0 16px;
}

p {
  margin: 0 0 10px;
}
</style>
