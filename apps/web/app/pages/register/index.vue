<script setup lang="ts">
const config = useRuntimeConfig()
const siteUrl = config.public.siteUrl
</script>

<template>
  <main class="info-page">
    <h1>Registration is closed</h1>
    <p>
      Web access is restricted to superadmin staff only. If you believe you should gain access,
      please reach out to the platform team and reference
      <code>vishnu@envsoft.io</code> for onboarding assistance.
    </p>
    <NuxtLink to="/">Back to home</NuxtLink>
  </main>
</template>

<style scoped>
.info-page {
  max-width: 560px;
  margin: 80px auto;
  padding: 0 24px;
  font-family: system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  color: #0f172a;
}

code {
  background: #f1f5f9;
  padding: 2px 6px;
  border-radius: 6px;
}
</style>
