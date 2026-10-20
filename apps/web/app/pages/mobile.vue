<script setup lang="ts">
const config = useRuntimeConfig()
const iosUrl = String(config.public.iosAppUrl || '')
const androidUrl = String(config.public.androidAppUrl || '')
const accessEmail = 'mailto:vishnu@envsoft.io?subject=Doclyzer%20mobile%20app%20access'
useHead({ title: 'Use the Doclyzer mobile app', meta: [{ name: 'robots', content: 'noindex, nofollow' }] })
</script>

<template>
  <main class="mobile-page">
    <NuxtLink to="/" class="brand">doclyzer<span>.</span></NuxtLink>
    <section class="panel">
      <p class="eyebrow">Mobile app</p>
      <h1>Continue on your phone</h1>
      <p>Doclyzer accounts and reports are available in the mobile app. Open the app on your phone to sign in or create an account.</p>
      <div v-if="iosUrl || androidUrl" class="actions">
        <a v-if="iosUrl" :href="iosUrl">Get the iPhone app</a>
        <a v-if="androidUrl" :href="androidUrl">Get the Android app</a>
      </div>
      <p v-else class="note">Need access to the mobile app? <a :href="accessEmail">Contact the Doclyzer team</a>.</p>
      <NuxtLink to="/" class="back">Back to home</NuxtLink>
    </section>
  </main>
</template>

<style scoped>
.mobile-page{min-height:100vh;background:#f6f5ef;color:#193b35;font-family:'Plus Jakarta Sans',system-ui,sans-serif;padding:32px clamp(20px,5vw,80px)}.brand{font-family:'Space Grotesk',sans-serif;font-size:27px;font-weight:700;letter-spacing:-.06em;color:inherit;text-decoration:none}.brand span{color:#75a47c}.panel{max-width:620px;margin:clamp(60px,12vh,150px) auto;background:#fff;border:1px solid #dce7db;border-radius:24px;padding:clamp(28px,5vw,56px);box-shadow:0 18px 55px #21472d14}.eyebrow{text-transform:uppercase;letter-spacing:.16em;color:#5f8c6a;font-weight:800;font-size:12px}h1{font-family:'Space Grotesk',sans-serif;font-size:clamp(38px,7vw,58px);line-height:1.1;letter-spacing:-.055em;margin:12px 0 20px}p{line-height:1.7;color:#4d6658}.actions{display:flex;gap:12px;flex-wrap:wrap;margin:30px 0}.actions a{background:#245d49;color:white;padding:14px 18px;border-radius:12px;font-weight:700;text-decoration:none;min-height:44px}.note{margin:30px 0}.note a,.back{color:#245d49;font-weight:700}.back{display:inline-block;margin-top:18px}:focus-visible{outline:3px solid #bd8b39;outline-offset:4px}
</style>
