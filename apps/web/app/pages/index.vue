<script setup lang="ts">
const config = useRuntimeConfig()
const siteUrl = config.public.siteUrl
const { incident: incidentStatus } = useIncidentStatus()

useSeoMeta({
  title: 'Doclyzer — Understand Your Medical Reports',
  description: 'Organise, understand, and share your lab reports and health history. AI-powered summaries. Doctor-ready sharing.',
  ogTitle: 'Doclyzer — Understand Your Medical Reports',
  ogDescription: 'Organise, understand, and share your medical reports and health history.',
  ogUrl: siteUrl,
  ogType: 'website',
  twitterCard: 'summary_large_image',
  twitterTitle: 'Doclyzer — Understand Your Medical Reports',
  twitterDescription: 'AI-powered medical report organiser. Share with your doctor.',
})

useHead({
  link: [{ rel: 'canonical', href: siteUrl }],
})
</script>

<template>
  <main class="hero">
    <div class="incident-slot">
      <IncidentBanner :incident="incidentStatus" surface="web_landing" />
    </div>
    <p class="eyebrow">Doclyzer Admin Preview</p>
    <h1>Secure health records, superadmin control</h1>
    <p>
      This surface is currently restricted to the superadmin team while we continue building
      multi-profile, analytics, and sharing workflows. If you are part of the squad, hop over to
      <code>/admin</code> to start working with the dashboard and MFA-protected actions.
    </p>
  </main>
</template>

<style scoped>
.hero {
  max-width: 680px;
  margin: 80px auto;
  padding: 0 24px;
  font-family: system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  color: #0f172a;
}

.hero h1 {
  font-size: 2.5rem;
  margin-bottom: 16px;
}

.hero .eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.3em;
  font-size: 0.8rem;
  color: #475569;
}

.hero code {
  background: #f8fafc;
  padding: 2px 6px;
  border-radius: 6px;
}

.incident-slot {
  margin-bottom: 24px;
}
</style>
