<template>
  <div class="admin-shell">
    <aside class="admin-sidebar" :class="{ collapsed: sidebarCollapsed }">
      <div class="sidebar-header">
        <RouterLink to="/admin/dashboard" class="sidebar-logo">
          <span>⚡</span>
          <span v-if="!sidebarCollapsed" class="logo-text">EON Admin</span>
        </RouterLink>
        <button class="collapse-btn" @click="sidebarCollapsed = !sidebarCollapsed">{{ sidebarCollapsed ? '›' : '‹' }}</button>
      </div>

      <nav class="sidebar-nav">
        <RouterLink v-for="item in navItems" :key="item.to" :to="item.to" class="nav-item" :title="item.label">
          <span class="nav-icon">{{ item.icon }}</span>
          <span v-if="!sidebarCollapsed" class="nav-label">{{ item.label }}</span>
        </RouterLink>
      </nav>

      <div class="sidebar-footer">
        <button class="nav-item help-nav-btn" @click="helpOpen = true" title="Help">
          <span class="nav-icon">❓</span>
          <span v-if="!sidebarCollapsed" class="nav-label">Help</span>
        </button>
        <RouterLink to="/" class="nav-item" title="View Site" target="_blank">
          <span class="nav-icon">🌐</span>
          <span v-if="!sidebarCollapsed" class="nav-label">View Site</span>
        </RouterLink>
        <button class="nav-item logout-btn" @click="doLogout" title="Logout">
          <span class="nav-icon">🚪</span>
          <span v-if="!sidebarCollapsed" class="nav-label">Logout</span>
        </button>
      </div>
    </aside>

    <div class="admin-main">
      <header class="admin-topbar">
        <div class="topbar-left">
          <button class="mobile-menu-btn" @click="sidebarCollapsed = !sidebarCollapsed">☰</button>
          <h2 class="page-title">{{ currentTitle }}</h2>
        </div>
        <div class="topbar-right">
          <button class="help-btn" @click="helpOpen = true" title="Help" aria-label="Open help">?</button>
          <span class="admin-badge badge badge-green">Admin</span>
        </div>
      </header>

      <HelpPanel :open="helpOpen" :page="route.name" @close="helpOpen = false" />
      <main class="admin-content">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import HelpPanel from '@/components/admin/HelpPanel.vue';

const auth = useAuthStore();
const router = useRouter();
const route = useRoute();
const sidebarCollapsed = ref(false);
const helpOpen = ref(false);

const navItems = [
  { to: '/admin/dashboard', icon: '📊', label: 'Dashboard' },
  { to: '/admin/products', icon: '📦', label: 'Products' },
  { to: '/admin/categories', icon: '🏷️', label: 'Categories' },
  { to: '/admin/content', icon: '📝', label: 'Content Editor' },
  { to: '/admin/company', icon: '🏢', label: 'Company Info' },
  { to: '/admin/social', icon: '🔗', label: 'Social Links' },
  { to: '/admin/seo', icon: '🔍', label: 'SEO Manager' },
];

const titles = {
  'admin-dashboard': 'Dashboard',
  'admin-products': 'Products',
  'admin-categories': 'Categories',
  'admin-content': 'Content Editor',
  'admin-company': 'Company Info',
  'admin-social': 'Social Links',
  'admin-seo': 'SEO Manager',
};
const currentTitle = computed(() => titles[route.name] || 'Admin');

function doLogout() {
  auth.logout();
  router.push('/admin/login');
}
</script>

<style scoped>
.admin-shell { display: flex; min-height: 100vh; }
.admin-sidebar {
  width: 240px; background: var(--bg-secondary);
  border-right: 1px solid var(--border);
  display: flex; flex-direction: column;
  position: fixed; top: 0; left: 0; bottom: 0; z-index: 100;
  transition: width 0.25s ease;
}
.admin-sidebar.collapsed { width: 64px; }
.sidebar-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 1rem 0.75rem; border-bottom: 1px solid var(--border); min-height: 64px;
}
.sidebar-logo { display: flex; align-items: center; gap: 0.5rem; color: var(--text-primary); font-weight: 800; font-size: 1.05rem; text-decoration: none; }
.logo-text { white-space: nowrap; }
.collapse-btn { background: none; color: var(--text-muted); font-size: 1.2rem; padding: 0.25rem 0.4rem; border-radius: var(--radius); }
.collapse-btn:hover { color: var(--green-primary); }
.sidebar-nav { flex: 1; padding: 0.75rem 0.5rem; display: flex; flex-direction: column; gap: 0.15rem; overflow-y: auto; }
.nav-item {
  display: flex; align-items: center; gap: 0.75rem;
  padding: 0.65rem 0.75rem; border-radius: var(--radius);
  color: var(--text-secondary); font-size: 0.9rem; font-weight: 500;
  text-decoration: none; background: none; width: 100%; cursor: pointer;
  transition: all 0.2s; white-space: nowrap;
}
.nav-item:hover { background: var(--green-glow); color: var(--green-primary); }
.nav-item.router-link-active { background: var(--green-glow); color: var(--green-primary); border: 1px solid var(--green-border); }
.nav-icon { font-size: 1.1rem; flex-shrink: 0; }
.sidebar-footer { padding: 0.75rem 0.5rem; border-top: 1px solid var(--border); }
.help-nav-btn { color: var(--green-secondary); }
.help-nav-btn:hover { color: var(--green-primary); background: var(--green-glow); }
.logout-btn { color: var(--text-muted); }
.logout-btn:hover { color: #ef5350; background: rgba(239,83,80,0.1); }

.admin-main { flex: 1; margin-left: 240px; display: flex; flex-direction: column; min-height: 100vh; transition: margin-left 0.25s ease; }
.admin-sidebar.collapsed ~ .admin-main { margin-left: 64px; }
.admin-topbar {
  height: 64px; background: var(--bg-secondary);
  border-bottom: 1px solid var(--border);
  display: flex; align-items: center; justify-content: space-between;
  padding: 0 1.5rem; position: sticky; top: 0; z-index: 50;
}
.topbar-left { display: flex; align-items: center; gap: 1rem; }
.topbar-right { display: flex; align-items: center; gap: 0.75rem; }
.page-title { font-size: 1.1rem; font-weight: 700; }
.mobile-menu-btn { display: none; background: none; color: var(--text-primary); font-size: 1.2rem; }
.help-btn {
  width: 2rem; height: 2rem; border-radius: 50%;
  background: var(--green-glow); border: 1px solid var(--green-border);
  color: var(--green-primary); font-weight: 800; font-size: 1rem;
  cursor: pointer; transition: all 0.2s;
}
.help-btn:hover { background: var(--green-primary); color: #000; }
.admin-content { flex: 1; padding: 2rem 1.5rem; }

@media (max-width: 768px) {
  .admin-sidebar { transform: translateX(-100%); }
  .admin-sidebar.collapsed { transform: translateX(0); width: 240px; }
  .admin-main { margin-left: 0 !important; }
  .mobile-menu-btn { display: flex; }
}
</style>
