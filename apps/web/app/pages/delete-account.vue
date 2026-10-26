<script setup lang="ts">
const siteUrl = useRuntimeConfig().public.siteUrl.replace(/\/+$/, '')
useSeoMeta({
  title: 'Delete your account | Doclyzer',
  description: 'How to delete or restore your Doclyzer account and what happens to your data.',
  ogUrl: `${siteUrl}/delete-account`,
})
useHead({ link: [{ rel: 'canonical', href: `${siteUrl}/delete-account` }] })
</script>

<template>
  <main class="page">
    <NuxtLink to="/" class="brand" aria-label="Doclyzer home"><img src="/Doclyzer-logo.svg" width="856" height="183" alt="" /></NuxtLink>
    <p class="eyebrow">ACCOUNT & DATA</p>
    <h1>Delete your account</h1>
    <p class="intro">You can request account deletion from Doclyzer in the Flutter app or the web app. Your access ends immediately. You have 30 days to change your mind.</p>

    <section>
      <h2>Request deletion</h2>
      <ol>
        <li>Sign in to Doclyzer.</li>
        <li>In the Flutter app, open <strong>You → Account & Data → Close Account</strong>. In the web app, open <strong>You → Close account</strong>.</li>
        <li>Read the impact, enter your current password, and confirm <strong>Schedule account deletion</strong>.</li>
      </ol>
      <p>If you cannot access the app, contact <a href="mailto:vishnu@envsoft.io?subject=Account%20deletion%20request">vishnu@envsoft.io</a> from your account email. We will verify ownership before processing the request. Do not send your password or medical records by email.</p>
    </section>

    <section>
      <h2>What happens to your data?</h2>
      <p>Your account and share links become inaccessible as soon as you confirm. Your profiles, reports, extracted results, account data, and uploaded files remain recoverable for 30 days. After that period, the service deletes the account data from its active database and stored file versions from B2. A basic record of the account identifier, email, and deletion dates remains visible to the superadmin. Independent payment and tamper-evident security audit records may remain where required.</p>
    </section>

    <section>
      <h2>Restore within 30 days</h2>
      <p>Sign in with your existing account before the deadline. Choose <strong>Restore my account</strong> on the deletion screen. After the deadline, restoration is unavailable. Previously issued share links stay disabled; you can create new ones after restoring.</p>
      <p>Someone who already downloaded a shared report may still have their local copy after your share link is revoked.</p>
    </section>

    <div class="actions"><NuxtLink to="/mobile">Open the mobile app</NuxtLink><NuxtLink to="/you/close-account">Open web account settings</NuxtLink></div>
    <NuxtLink to="/" class="back">← Back to Doclyzer</NuxtLink>
  </main>
</template>

<style scoped>
.page{max-width:760px;margin:0 auto;padding:44px 24px 80px;color:#193735;font-family:'Plus Jakarta Sans',system-ui,sans-serif;line-height:1.75}.brand img{display:block;width:178px;height:auto}.eyebrow{margin:64px 0 8px;color:#54816a;font-size:11px;font-weight:800;letter-spacing:.15em}h1{font:700 clamp(42px,7vw,68px)/1.08 'Space Grotesk',sans-serif;letter-spacing:-.05em;margin:0 0 24px}.intro{font-size:18px;color:#49645a}section{border-top:1px solid #d9dfd4;margin-top:40px;padding-top:24px}h2{font:700 25px 'Space Grotesk',sans-serif;letter-spacing:-.03em;margin:0 0 10px}p,li{color:#405c51}li{padding-left:5px;margin-bottom:10px}a{color:#245d49}.actions{display:flex;gap:12px;flex-wrap:wrap;margin:38px 0}.actions a{display:inline-flex;padding:12px 18px;border-radius:10px;background:#245d49;color:white;font-weight:700;text-decoration:none}.actions a+ a{background:#e8f0e9;color:#245d49}.back{font-weight:700}
</style>
