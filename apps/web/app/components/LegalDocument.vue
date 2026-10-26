<script setup lang="ts">
import privacy from '../../content/legal/Doclyzer_Privacy_Policy.md?raw'
import terms from '../../content/legal/Doclyzer_Terms_and_Conditions.md?raw'
import refunds from '../../content/legal/Doclyzer_Refund_and_Cancellation_Policy.md?raw'
import { renderLegalMarkdown } from '../utils/renderLegalMarkdown'

type Policy = 'privacy' | 'terms' | 'refunds'
const props = defineProps<{ policy: Policy }>()
const documents = {
  privacy: { title: 'Privacy Policy', route: '/privacy-policy', source: privacy },
  terms: { title: 'Terms and Conditions', route: '/terms-and-conditions', source: terms },
  refunds: { title: 'Refund and Cancellation Policy', route: '/refund-and-cancellation-policy', source: refunds },
}
const document = computed(() => documents[props.policy])
const html = computed(() => renderLegalMarkdown(document.value.source))
const siteUrl = useRuntimeConfig().public.siteUrl.replace(/\/+$/, '')
useSeoMeta({
  title: () => `${document.value.title} | Doclyzer`,
  description: () => `Read the Doclyzer ${document.value.title.toLowerCase()}.`,
  robots: 'noindex, nofollow',
  ogTitle: () => `${document.value.title} | Doclyzer`,
  ogUrl: () => `${siteUrl}${document.value.route}`,
})
useHead({ link: [{ rel: 'canonical', href: () => `${siteUrl}${document.value.route}` }] })
</script>

<template>
  <div class="legal-page">
    <MarketingHeader />
    <main id="main" class="legal-main">
      <nav class="policy-nav" aria-label="Legal documents">
        <NuxtLink to="/privacy-policy" :aria-current="policy === 'privacy' ? 'page' : undefined">Privacy</NuxtLink>
        <NuxtLink to="/terms-and-conditions" :aria-current="policy === 'terms' ? 'page' : undefined">Terms</NuxtLink>
        <NuxtLink to="/refund-and-cancellation-policy" :aria-current="policy === 'refunds' ? 'page' : undefined">Refunds</NuxtLink>
      </nav>
      <article class="document" v-html="html" />
    </main>
    <MarketingFooter />
  </div>
</template>

<style scoped>
.legal-page{background:var(--brand-canvas);color:var(--brand-ink);font-family:var(--brand-font);min-height:100vh}
.legal-main{width:min(calc(100% - 48px),900px);margin:0 auto;padding:52px 0 100px}
.policy-nav{display:flex;flex-wrap:wrap;gap:10px;border-bottom:1px solid var(--brand-border);padding-bottom:30px;margin-bottom:48px}
.policy-nav a{display:inline-flex;align-items:center;padding:10px 14px;border:1px solid var(--brand-border);border-radius:10px;color:var(--brand-blue);text-decoration:none;font-size:13px;font-weight:700}
.policy-nav a[aria-current="page"]{background:var(--brand-mint);border-color:var(--brand-teal);color:var(--brand-ink)}
.document{font-size:15px;line-height:1.8;color:#405c61;overflow-wrap:anywhere}
.document :deep(h1){font-size:clamp(34px,5vw,48px);line-height:1.18;letter-spacing:-.035em;color:var(--brand-ink);margin:0 0 24px}
.document :deep(h2){font-size:clamp(22px,3vw,27px);line-height:1.3;letter-spacing:-.025em;color:var(--brand-ink);margin:42px 0 16px}
.document :deep(h3){font-size:18px;line-height:1.4;color:var(--brand-ink);margin:27px 0 11px}
.document :deep(p){margin:0 0 17px}.document :deep(strong){color:var(--brand-ink)}
.document :deep(ul),.document :deep(ol){padding-left:26px;margin:0 0 22px}.document :deep(li){padding-left:5px;margin:6px 0}
.document :deep(hr){border:0;border-top:1px solid var(--brand-border);margin:34px 0}
.document :deep(blockquote){background:var(--brand-mint);border-left:4px solid var(--brand-teal);margin:24px 0;padding:17px 22px;border-radius:0 12px 12px 0}.document :deep(blockquote p){margin:0}
@media(max-width:600px){.legal-main{padding:32px 0 72px}.policy-nav{margin-bottom:36px}.document{font-size:14px}.document :deep(h2){margin-top:34px}}
</style>
