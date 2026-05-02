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
  { label: 'Dashboard', icon: '📊', href: '/admin/dashboard' },
  { label: 'Users', icon: '🧑‍💼', href: '/admin/users' },
  { label: 'Files', icon: '📁', href: '/admin/files' },
  { label: 'Risk', icon: '🚨', href: '/admin/risk' },
]

const sidebarOpen = ref(false)
</script>

<template>
  <div class="admin-layout">
    <div v-if="sidebarOpen" class="mobile-overlay" @click="sidebarOpen = false" />
    <button class="mobile-toggle" @click="sidebarOpen = !sidebarOpen" aria-label="Toggle nav">
      ☰
    </button>
    <nav class="sidebar" :class="{ 'sidebar--open': sidebarOpen }">
      <div class="sidebar__brand">
        <span class="sidebar__brand-mark">DL</span>
        <div>
          <div class="sidebar__brand-title">Doclyzer Admin</div>
          <div class="sidebar__brand-subtitle">Superadmin Workspace</div>
        </div>
      </div>
      <ul class="sidebar__nav">
        <li v-for="item in navItems" :key="item.href">
          <NuxtLink
            :to="item.href"
            class="sidebar__link"
            :class="{ 'sidebar__link--active': route.path.startsWith(item.href) }"
            @click="sidebarOpen = false"
          >
            <span class="sidebar__icon">{{ item.icon }}</span>
            <span>{{ item.label }}</span>
          </NuxtLink>
        </li>
      </ul>
      <p class="sidebar__footnote">Restricted operations are audited.</p>
      <button class="sidebar__logout" @click="handleLogout">Logout</button>
    </nav>
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
  width: 250px;
  background: linear-gradient(180deg, rgba(13, 27, 42, 0.94), rgba(16, 35, 56, 0.96));
  color: #eff5ff;
  display: flex;
  flex-direction: column;
  padding: 18px 12px 14px;
  flex-shrink: 0;
  border-right: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 18px 0 44px rgba(13, 27, 42, 0.18);
  backdrop-filter: blur(4px);
  z-index: 2;
}

.sidebar__brand {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 4px 10px 20px;
}

.sidebar__brand-mark {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: #7f1d1d;
  background: linear-gradient(135deg, #ffedd5, #fecaca);
  box-shadow: 0 6px 18px rgba(220, 38, 38, 0.32);
}

.sidebar__brand-title {
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.01em;
  font-family: var(--font-display);
}

.sidebar__brand-subtitle {
  font-size: 11px;
  color: #b6c4d8;
  font-family: var(--font-ui);
}

.sidebar__nav {
  list-style: none;
  margin: 0;
  padding: 0;
  flex: 1;
}

.sidebar__link {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 12px;
  color: #d4dfef;
  text-decoration: none;
  font-size: 13px;
  font-family: var(--font-ui);
  border-radius: 10px;
  border: 1px solid transparent;
  transition: transform 0.15s, background 0.15s, border-color 0.15s;
}
.sidebar__link:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(255, 255, 255, 0.12);
  transform: translateX(2px);
}
.sidebar__link--active {
  background: linear-gradient(90deg, rgba(220, 38, 38, 0.2), rgba(255, 255, 255, 0.1));
  border-color: rgba(254, 202, 202, 0.4);
  color: #fff;
  font-weight: 600;
}

.sidebar__icon { font-size: 16px; }

.sidebar__footnote {
  margin: 8px 10px 12px;
  font-size: 11px;
  color: #b6c4d8;
  font-family: var(--font-ui);
}

.sidebar__logout {
  margin: 0 10px 6px;
  padding: 10px 12px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #eff5ff;
  border-radius: 10px;
  cursor: pointer;
  font-size: 12px;
  text-align: center;
  font-weight: 600;
  font-family: var(--font-ui);
}
.sidebar__logout:hover {
  background: rgba(220, 38, 38, 0.18);
  border-color: rgba(254, 202, 202, 0.48);
}

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
  font-size: 20px;
  padding: 8px 12px;
  border-radius: 10px;
  cursor: pointer;
}

.mobile-overlay {
  position: fixed;
  inset: 0;
  background: rgba(13, 27, 42, 0.42);
  backdrop-filter: blur(2px);
  z-index: 90;
}

@media (max-width: 768px) {
  .mobile-toggle { display: block; }
  .sidebar {
    position: fixed;
    left: -280px;
    top: 0;
    bottom: 0;
    z-index: 99;
    transition: left 0.22s ease;
    width: 260px;
  }
  .sidebar--open { left: 0; }
  .admin-main { padding: 14px; padding-top: 62px; }
}
</style>
