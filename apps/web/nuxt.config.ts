// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  css: ['~/assets/brand.css'],
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  devServer: {
    port: 3005,
  },
  app: {
    head: {
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap',
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
    '/admin/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/home': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/reports': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/reports/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/trends': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/trends/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/you': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
    '/you/**': { headers: { 'X-Robots-Tag': 'noindex, nofollow' } },
  },
})
