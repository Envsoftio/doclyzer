<script setup lang="ts">
const { isAuthenticated, logout } = useAdminAuth()
const route = useRoute()

onMounted(() => {
  if (!isAuthenticated.value) {
    navigateTo('/admin/login')
  }
})

function handleLogout() {
  logout()
  navigateTo('/admin/login')
}

const navItems = [
  { label: 'Dashboard', icon: 'dashboard', href: '/admin/dashboard', group: 'Workspace' },
  { label: 'Users', icon: 'users', href: '/admin/users', group: 'Manage' },
  { label: 'Deleted accounts', icon: 'users', href: '/admin/deleted-accounts', group: 'Manage' },
  { label: 'Files', icon: 'files', href: '/admin/files', group: 'Manage' },
  { label: 'Billing', icon: 'billing', href: '/admin/billing', group: 'Manage' },
  { label: 'Risk', icon: 'risk', href: '/admin/risk', group: 'Operations' },
  { label: 'Notifications', icon: 'notifications', href: '/admin/notifications', group: 'Operations' },
]

const sidebarOpen = ref(false)
const navGroups = ['Workspace', 'Manage', 'Operations']

watch(() => route.path, () => { sidebarOpen.value = false })

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') sidebarOpen.value = false
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <div class="admin-layout">
    <div v-if="sidebarOpen" class="mobile-overlay" @click="sidebarOpen = false" />
    <button class="mobile-toggle" type="button" :aria-expanded="sidebarOpen" aria-controls="admin-sidebar" aria-label="Open navigation" @click="sidebarOpen = true">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M4 7h16M4 12h16M4 17h16" /></svg>
    </button>
    <aside id="admin-sidebar" class="sidebar" :class="{ 'sidebar--open': sidebarOpen }">
      <div class="sidebar__header">
        <div class="sidebar__brand">
          <span class="sidebar__brand-mark" aria-hidden="true"><span></span><span></span><span></span></span>
          <div class="sidebar__brand-copy">
            <div class="sidebar__brand-title">doclyzer<span class="sidebar__brand-dot">.</span></div>
            <div class="sidebar__brand-subtitle">ADMIN CONSOLE</div>
          </div>
        </div>
        <button class="sidebar__close" type="button" aria-label="Close navigation" @click="sidebarOpen = false">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M5 5l14 14M19 5L5 19" /></svg>
        </button>
      </div>
      <nav class="sidebar__nav" aria-label="Admin navigation">
        <div v-for="group in navGroups" :key="group" class="sidebar__group">
          <p class="sidebar__group-label">{{ group }}</p>
          <ul class="sidebar__list">
            <li v-for="item in navItems.filter(item => item.group === group)" :key="item.href">
              <NuxtLink :to="item.href" class="sidebar__link" :class="{ 'sidebar__link--active': route.path.startsWith(item.href) }" :aria-current="route.path.startsWith(item.href) ? 'page' : undefined" @click="sidebarOpen = false">
                <svg class="sidebar__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                  <template v-if="item.icon === 'dashboard'"><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></template>
                  <template v-else-if="item.icon === 'users'"><path d="M16 20v-1.5a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4V20" /><circle cx="9" cy="7" r="3.5" /><path d="M17 4.5a3.5 3.5 0 0 1 0 7M22 20v-1.5a4 4 0 0 0-3-3.87" /></template>
                  <template v-else-if="item.icon === 'files'"><path d="M4 7V5a2 2 0 0 1 2-2h4l2 2h6a2 2 0 0 1 2 2v2" /><path d="M3 9h18l-2 11H5L3 9Z" /></template>
                  <template v-else-if="item.icon === 'billing'"><rect x="2.5" y="5" width="19" height="14" rx="2.5" /><path d="M2.5 10h19M7 15h3" /></template>
                  <template v-else-if="item.icon === 'risk'"><path d="M12 2.5 20 6v5.5c0 5-3.3 8.3-8 10-4.7-1.7-8-5-8-10V6l8-3.5Z" /><path d="M12 8v5M12 16.5h.01" /></template>
                  <template v-else><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9ZM10 21h4" /></template>
                </svg>
                <span class="sidebar__link-label">{{ item.label }}</span>
                <svg v-if="route.path.startsWith(item.href)" class="sidebar__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6" /></svg>
              </NuxtLink>
            </li>
          </ul>
        </div>
      </nav>
      <div class="sidebar__footer">
        <div class="sidebar__access"><span class="sidebar__access-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="10" width="14" height="11" rx="2" /><path d="M8 10V7a4 4 0 0 1 8 0v3" /></svg></span><span><strong>Superadmin access</strong><small>Actions are audited</small></span></div>
        <button class="sidebar__logout" type="button" @click="handleLogout"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 21H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h3M16 17l5-5-5-5M21 12H9" /></svg><span>Sign out</span></button>
      </div>
    </aside>
    <main class="admin-main">
      <slot />
    </main>
  </div>
</template>

<style scoped>
.admin-layout {
  --bg-0: #fffaf2;
  --bg-1: #edf7ff;
  --surface: rgba(255, 255, 255, 0.82);
  --surface-strong: #ffffff;
  --ink: #0d1b2a;
  --ink-soft: #4b5c70;
  --line: rgba(13, 27, 42, 0.12);
  --accent: #dc2626;
  --accent-soft: #fee2e2;
  display: flex;
  min-height: 100vh;
  --font-ui: 'Plus Jakarta Sans', 'Inter', 'Avenir Next', 'Segoe UI', sans-serif;
  --font-display: 'Space Grotesk', 'Plus Jakarta Sans', 'Segoe UI', sans-serif;
  font-family: var(--font-ui);
  background:
    radial-gradient(80rem 40rem at 10% -10%, var(--bg-0), transparent 70%),
    radial-gradient(70rem 35rem at 95% 0%, var(--bg-1), transparent 60%),
    #f4f7fb;
  color: var(--ink);
  position: relative;
}

.sidebar {
  width: 264px;
  height: 100vh;
  position: sticky;
  top: 0;
  background: #101e2e;
  color: #eaf0f6;
  display: flex;
  flex-direction: column;
  padding: 0 13px 16px;
  flex-shrink: 0;
  box-sizing: border-box;
  border-right: 1px solid #233549;
  box-shadow: 10px 0 32px rgba(13, 27, 42, 0.08);
  z-index: 2;
}

.sidebar__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 100px;
  margin: 0 9px 25px;
  border-bottom: 1px solid rgba(225, 234, 244, 0.12);
}

.sidebar__brand {
  display: flex;
  gap: 11px;
  align-items: center;
}

.sidebar__brand-mark {
  width: 39px;
  height: 39px;
  border-radius: 12px;
  display: grid;
  grid-template-columns: repeat(2, 8px);
  grid-template-rows: repeat(2, 8px);
  align-content: center;
  justify-content: center;
  gap: 4px;
  background: #e45d53;
  box-shadow: 0 5px 14px rgba(228, 93, 83, 0.19);
  transform: rotate(-7deg);
}
.sidebar__brand-mark span {
  display: block;
  background: #fff;
  border-radius: 2px;
}
.sidebar__brand-mark span:first-child { grid-row: span 2; }
.sidebar__brand-mark span:last-child { opacity: 0.7; }
.sidebar__brand-copy { line-height: 1.1; }
.sidebar__brand-dot { color: #fa857b; }
.sidebar__brand-title {
  font-size: 19px;
  font-weight: 750;
  letter-spacing: -0.06em;
  font-family: var(--font-display);
}

.sidebar__brand-subtitle {
  margin-top: 5px;
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 0.18em;
  color: #8295aa;
}

.sidebar__close { display: none; }
.sidebar__nav { flex: 1; }
.sidebar__group + .sidebar__group { margin-top: 25px; }
.sidebar__group-label {
  margin: 0 12px 9px;
  color: #788ba1;
  font-size: 10px;
  font-weight: 800;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}
.sidebar__list { list-style: none; padding: 0; margin: 0; }
.sidebar__list li + li { margin-top: 3px; }
.sidebar__link {
  position: relative;
  display: flex;
  align-items: center;
  gap: 13px;
  min-height: 45px;
  padding: 0 13px;
  color: #aebfd0;
  text-decoration: none;
  font-size: 13px;
  font-weight: 550;
  border-radius: 9px;
  transition: background 0.16s ease, color 0.16s ease;
}
.sidebar__link:hover {
  background: #1d3044;
  color: #fff;
}
.sidebar__link--active {
  background: #263a4e;
  color: #fff;
  font-weight: 700;
}
.sidebar__link--active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 9px;
  bottom: 9px;
  width: 3px;
  background: #f37468;
  border-radius: 0 3px 3px 0;
}
.sidebar__icon { width: 18px; height: 18px; flex-shrink: 0; }
.sidebar__link--active .sidebar__icon { color: #fb9b91; }
.sidebar__link-label { flex: 1; }
.sidebar__arrow { width: 14px; height: 14px; color: #fc9b92; }
.sidebar__footer {
  padding: 18px 3px 0;
  border-top: 1px solid rgba(225, 234, 244, 0.12);
}
.sidebar__access {
  display: flex;
  align-items: center;
  gap: 11px;
  padding: 0 9px 17px;
}
.sidebar__access-icon {
  width: 34px;
  height: 34px;
  display: grid;
  place-items: center;
  border-radius: 10px;
  background: rgba(243, 116, 104, 0.13);
  color: #f38a80;
}
.sidebar__access-icon svg { width: 16px; height: 16px; }
.sidebar__access strong, .sidebar__access small { display: block; }
.sidebar__access strong { font-size: 11px; font-weight: 700; color: #e7edf4; }
.sidebar__access small { margin-top: 3px; font-size: 10px; color: #8295aa; }

.sidebar__logout {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  min-height: 42px;
  padding: 0 10px;
  background: transparent;
  border: 1px solid #34475b;
  color: #b9c9d8;
  border-radius: 9px;
  cursor: pointer;
  font-size: 12px;
  text-align: left;
  font-weight: 650;
  font-family: var(--font-ui);
}
.sidebar__logout:hover {
  background: #263a4e;
  color: #fff;
}
.sidebar__logout svg { width: 17px; height: 17px; }
.sidebar__link:focus-visible, .sidebar__logout:focus-visible, .sidebar__close:focus-visible, .mobile-toggle:focus-visible { outline: 2px solid #fb9b91; outline-offset: 2px; }

.admin-main {
  flex: 1;
  padding: 28px;
  overflow-y: auto;
  position: relative;
  z-index: 1;
}

.mobile-toggle {
  display: none;
  position: fixed;
  top: 14px;
  left: 14px;
  z-index: 120;
  background: var(--surface-strong);
  color: var(--ink);
  border: 1px solid var(--line);
  box-shadow: 0 8px 24px rgba(13, 27, 42, 0.16);
  width: 42px;
  height: 42px;
  align-items: center;
  justify-content: center;
  padding: 9px;
  border-radius: 10px;
  cursor: pointer;
}
.mobile-toggle svg { width: 22px; height: 22px; }

.mobile-overlay {
  position: fixed;
  inset: 0;
  background: rgba(13, 27, 42, 0.42);
  backdrop-filter: blur(2px);
  z-index: 90;
}

@media (max-width: 768px) {
  .mobile-toggle { display: flex; }
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
    z-index: 99;
    width: min(280px, 85vw);
    height: 100vh;
    transform: translateX(-100%);
    transition: transform 0.22s ease;
    overflow-y: auto;
  }
  .sidebar--open { transform: translateX(0); }
  .sidebar__close { display: grid; place-items: center; width: 32px; height: 32px; border: 0; border-radius: 7px; color: #b9c9d8; background: transparent; cursor: pointer; }
  .sidebar__close:hover { background: #263a4e; color: white; }
  .sidebar__close svg { width: 19px; height: 19px; }
  .admin-main { padding: 14px; padding-top: 62px; }
}
@media (prefers-reduced-motion: reduce) {
  .sidebar, .sidebar__link { transition: none; }
}
</style>
