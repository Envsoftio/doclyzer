<script setup lang="ts">
const route = useRoute()

const navItems = [
  { label: 'Dashboard', icon: '📊', href: '/admin/dashboard' },
  { label: 'Users', icon: '🧑‍💼', href: '/admin/users' },
  { label: 'Files', icon: '📁', href: '/admin/files' },
  { label: 'Risk', icon: '🚨', href: '/admin/risk' },
]
</script>

<template>
  <nav class="admin-nav">
    <div class="admin-nav__brand">Doclyzer Admin</div>
    <ul class="admin-nav__list">
      <li v-for="item in navItems" :key="item.href">
        <NuxtLink
          :to="item.href"
          class="admin-nav__link"
          :class="{ 'admin-nav__link--active': route.path.startsWith(item.href) }"
        >
          <span class="admin-nav__icon">{{ item.icon }}</span>
          <span class="admin-nav__label">{{ item.label }}</span>
        </NuxtLink>
      </li>
    </ul>
  </nav>
</template>

<style scoped>
.admin-nav {
  display: flex;
  flex-direction: column;
  font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
}

.admin-nav__brand {
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: #94a3b8;
  padding: 0 20px 20px;
}

.admin-nav__list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.admin-nav__link {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 20px;
  color: #cbd5e1;
  text-decoration: none;
  font-size: 14px;
}
.admin-nav__link:hover,
.admin-nav__link--active {
  background: #334155;
  color: #f1f5f9;
}
.admin-nav__link--active { font-weight: 600; }

.admin-nav__icon { font-size: 16px; }
.admin-nav__label { font-size: 14px; }

@media (max-width: 768px) {
  .admin-nav {
    flex-direction: row;
    align-items: center;
    overflow-x: auto;
  }
  .admin-nav__brand { display: none; }
  .admin-nav__list { display: flex; flex-direction: row; }
  .admin-nav__link { white-space: nowrap; }
}
</style>
