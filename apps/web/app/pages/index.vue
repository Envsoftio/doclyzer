<script setup lang="ts">
const config = useRuntimeConfig()
const siteUrl = config.public.siteUrl

useSeoMeta({
  title: 'Doclyzer — Understand Your Medical Reports',
  description: 'Organise, understand, and share your lab reports and health history. AI-powered summaries. Doctor-ready sharing.',
  ogTitle: 'Doclyzer — Understand Your Medical Reports',
  ogDescription: 'Organise, understand, and share your lab reports and health history.',
  ogUrl: siteUrl,
  ogType: 'website',
  twitterCard: 'summary_large_image',
  twitterTitle: 'Doclyzer — Understand Your Medical Reports',
  twitterDescription: 'AI-powered medical report organiser. Share with your doctor.',
})

useHead({
  link: [{ rel: 'canonical', href: siteUrl }],
  script: [
    {
      type: 'application/ld+json',
      children: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'WebSite',
        name: 'Doclyzer',
        url: siteUrl,
        description: 'Organise, understand, and share your medical reports.',
      }),
    },
  ],
})
</script>

<template>
  <main>
    <h1>Understand Your Medical Reports</h1>
    <p>Organise, understand, and share your lab reports and health history. AI-powered summaries. Doctor-ready sharing.</p>
    <NuxtLink to="/register">Get Started</NuxtLink>
  </main>
</template>
