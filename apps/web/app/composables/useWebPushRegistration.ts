type FirebaseMessagingCompat = {
  getToken: (options: {
    vapidKey: string
    serviceWorkerRegistration: ServiceWorkerRegistration
  }) => Promise<string>
}

type FirebaseCompat = {
  apps: unknown[]
  initializeApp: (config: Record<string, string>) => unknown
  messaging: () => FirebaseMessagingCompat
}

let firebaseLoadPromise: Promise<FirebaseCompat> | null = null

export const useWebPushRegistration = () => {
  const config = useRuntimeConfig()
  const { adminFetch } = useAdminApi()

  const firebaseConfig = computed(() => ({
    apiKey: config.public.fcmApiKey as string,
    authDomain: config.public.fcmAuthDomain as string,
    projectId: config.public.fcmProjectId as string,
    messagingSenderId: config.public.fcmMessagingSenderId as string,
    appId: config.public.fcmAppId as string,
  }))

  const webPushConfigured = computed(() =>
    Boolean(
      firebaseConfig.value.apiKey &&
        firebaseConfig.value.projectId &&
        firebaseConfig.value.messagingSenderId &&
        firebaseConfig.value.appId &&
        config.public.fcmVapidKey,
    ),
  )

  const webPushSupported = computed(() =>
    process.client &&
    'Notification' in window &&
    'serviceWorker' in navigator &&
    'PushManager' in window,
  )

  async function enableWebPush(): Promise<string> {
    if (!webPushSupported.value) {
      throw new Error('Web push is not supported in this browser')
    }
    if (!webPushConfigured.value) {
      throw new Error('Firebase web push config is not available')
    }

    const permission = await Notification.requestPermission()
    if (permission !== 'granted') {
      throw new Error('Notification permission was not granted')
    }

    const swUrl = buildServiceWorkerUrl(firebaseConfig.value)
    const registration = await navigator.serviceWorker.register(swUrl)
    const firebase = await loadFirebaseCompat()
    if (firebase.apps.length === 0) {
      firebase.initializeApp(firebaseConfig.value)
    }
    const token = await firebase.messaging().getToken({
      vapidKey: config.public.fcmVapidKey as string,
      serviceWorkerRegistration: registration,
    })
    const res = await adminFetch<{ data: { id: string } }>('/notifications/device-tokens', {
      method: 'POST',
      body: {
        token,
        platform: isLikelyMobileWeb() ? 'mobile_web' : 'web',
        provider: 'fcm',
        installationId: getOrCreateWebInstallationId(),
        appVersion: 'web',
        deviceLabel: navigator.userAgent.slice(0, 120),
        preferences: {
          billing: true,
          referrals: true,
          product: true,
          adminAnnouncements: true,
        },
      },
    })
    return res.data.id
  }

  return {
    enableWebPush,
    webPushConfigured,
    webPushSupported,
  }
}

function loadFirebaseCompat(): Promise<FirebaseCompat> {
  if (firebaseLoadPromise) return firebaseLoadPromise
  firebaseLoadPromise = new Promise((resolve, reject) => {
    const existing = (window as Window & { firebase?: FirebaseCompat }).firebase
    if (existing) {
      resolve(existing)
      return
    }
    const appScript = document.createElement('script')
    appScript.src = 'https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js'
    appScript.async = true
    appScript.onerror = () => reject(new Error('Failed to load Firebase app SDK'))
    appScript.onload = () => {
      const messagingScript = document.createElement('script')
      messagingScript.src = 'https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js'
      messagingScript.async = true
      messagingScript.onerror = () => reject(new Error('Failed to load Firebase messaging SDK'))
      messagingScript.onload = () => {
        const firebase = (window as Window & { firebase?: FirebaseCompat }).firebase
        if (!firebase) reject(new Error('Firebase SDK did not initialize'))
        else resolve(firebase)
      }
      document.head.appendChild(messagingScript)
    }
    document.head.appendChild(appScript)
  })
  return firebaseLoadPromise
}

function buildServiceWorkerUrl(config: Record<string, string>): string {
  const params = new URLSearchParams(config)
  return `/firebase-messaging-sw.js?${params.toString()}`
}

function getOrCreateWebInstallationId(): string {
  const key = 'doclyzer_web_installation_id'
  const existing = localStorage.getItem(key)
  if (existing) return existing
  const id = `web_${Date.now()}_${Math.random().toString(36).slice(2)}`
  localStorage.setItem(key, id)
  return id
}

function isLikelyMobileWeb(): boolean {
  return window.matchMedia('(pointer: coarse)').matches || window.innerWidth < 768
}
