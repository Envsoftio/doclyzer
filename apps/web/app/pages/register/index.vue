<script setup lang="ts">
const config = useRuntimeConfig()
const siteUrl = config.public.siteUrl
const registerUrl = `${siteUrl.replace(/\/+$/, '')}/register`

useSeoMeta({
  title: 'Create Your Doclyzer Account',
  description: 'Create your Doclyzer account to upload, understand, and share medical reports.',
  robots: 'noindex, nofollow',
})

useHead({
  link: [{ rel: 'canonical', href: registerUrl }],
})
</script>

<template>
  <main class="register-page">
    <h1>Create your account</h1>
    <p>Registration UI is being set up for the web app.</p>
    <p>You can continue using the mobile app for now.</p>
    <NuxtLink to="/">Back to Home</NuxtLink>
  </main>
</template>

<style scoped>
.register-page {
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
