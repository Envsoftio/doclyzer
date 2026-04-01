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
    <button class="mobile-toggle" @click="sidebarOpen = !sidebarOpen" aria-label="Toggle nav">
      ☰
    </button>
    <nav class="sidebar" :class="{ 'sidebar--open': sidebarOpen }">
      <div class="sidebar__brand">Doclyzer Admin</div>
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
      <button class="sidebar__logout" @click="handleLogout">Logout</button>
    </nav>
    <main class="admin-main">
      <slot />
    </main>
  </div>
</template>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
  font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
  background: #f9fafb;
  color: #111827;
}

.sidebar {
  width: 200px;
  background: #1e293b;
  color: #f1f5f9;
  display: flex;
  flex-direction: column;
  padding: 24px 0;
  flex-shrink: 0;
}

.sidebar__brand {
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.05em;
  padding: 0 20px 24px;
  color: #94a3b8;
  text-transform: uppercase;
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
  padding: 10px 20px;
  color: #cbd5e1;
  text-decoration: none;
  font-size: 14px;
  transition: background 0.15s;
}
.sidebar__link:hover { background: #334155; }
.sidebar__link--active { background: #334155; color: #f1f5f9; font-weight: 600; }

.sidebar__icon { font-size: 16px; }

.sidebar__logout {
  margin: 16px 20px 0;
  padding: 8px 14px;
  background: transparent;
  border: 1px solid #475569;
  color: #94a3b8;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  text-align: left;
}
.sidebar__logout:hover { background: #334155; color: #f1f5f9; }

.admin-main {
  flex: 1;
  padding: 32px;
  overflow-y: auto;
}

.mobile-toggle {
  display: none;
  position: fixed;
  top: 12px;
  left: 12px;
  z-index: 100;
  background: #1e293b;
  color: #f1f5f9;
  border: none;
  font-size: 20px;
  padding: 6px 10px;
  border-radius: 6px;
  cursor: pointer;
}

@media (max-width: 768px) {
  .mobile-toggle { display: block; }
  .sidebar {
    position: fixed;
    left: -220px;
    top: 0;
    bottom: 0;
    z-index: 99;
    transition: left 0.2s;
    width: 220px;
  }
  .sidebar--open { left: 0; }
  .admin-main { padding: 16px; padding-top: 56px; }
}
</style>
