// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  css: ['~/assets/brand.css'],
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  devServer: {
    port: 3005,
  },
  nitro: {
    compressPublicAssets: { gzip: true, brotli: true },
  },
  app: {
    head: {
      htmlAttrs: { lang: 'en' },
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        {
          rel: 'preload',
          href: '/fonts/plus-jakarta-sans-v12-latin.woff2',
          as: 'font',
          type: 'font/woff2',
          crossorigin: '',
        },
      ],
    },
  },
  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL ?? 'http://localhost:4002/v1',
      siteUrl: process.env.NUXT_PUBLIC_SITE_URL ?? 'https://doclyzer.com',
      // Consumer web implementation is retained for a later release.
      consumerWebEnabled: process.env.NUXT_PUBLIC_CONSUMER_WEB_ENABLED === 'true',
      iosAppUrl: process.env.NUXT_PUBLIC_IOS_APP_URL ?? '',
      androidAppUrl: process.env.NUXT_PUBLIC_ANDROID_APP_URL ?? '',
      fcmApiKey: process.env.NUXT_PUBLIC_FCM_API_KEY ?? '',
      fcmAuthDomain: process.env.NUXT_PUBLIC_FCM_AUTH_DOMAIN ?? '',
      fcmProjectId: process.env.NUXT_PUBLIC_FCM_PROJECT_ID ?? '',
      fcmMessagingSenderId: process.env.NUXT_PUBLIC_FCM_MESSAGING_SENDER_ID ?? '',
      fcmAppId: process.env.NUXT_PUBLIC_FCM_APP_ID ?? '',
      fcmVapidKey: process.env.NUXT_PUBLIC_FCM_VAPID_KEY ?? '',
    },
  },
  routeRules: {
    '/fonts/**': { headers: { 'Cache-Control': 'public, max-age=31536000, immutable' } },
    '/landing/**': { headers: { 'Cache-Control': 'public, max-age=2592000' } },
    '/admin/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/mobile': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/login': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/register': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/forgot-password': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/reset-password': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/home': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/reports': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/reports/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/trends': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/trends/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/you': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/you/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
  },
})
