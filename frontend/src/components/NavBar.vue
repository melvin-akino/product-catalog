<template>
  <nav class="navbar" :class="{ scrolled: isScrolled, 'menu-open': menuOpen }">
    <div class="container nav-inner">
      <RouterLink to="/" class="nav-logo">
        <img v-if="logoSrc" :src="logoSrc" :alt="companyName" class="logo-img" @error="logoSrc = ''" />
        <template v-else>
          <Zap :size="22" class="logo-icon" />
          <span class="logo-text">EON<span class="text-green">.</span></span>
        </template>
      </RouterLink>

      <ul class="nav-links" :class="{ open: menuOpen }">
        <li><RouterLink to="/" @click="menuOpen=false" exact-active-class="nav-active">Home</RouterLink></li>
        <li><RouterLink to="/catalog" @click="menuOpen=false" active-class="nav-active">Products</RouterLink></li>
        <li><RouterLink to="/about" @click="menuOpen=false" active-class="nav-active">About</RouterLink></li>
        <li><RouterLink to="/contact" @click="menuOpen=false" active-class="nav-active">Contact</RouterLink></li>
        <li>
          <RouterLink to="/catalog" class="btn-cta" active-class="" exact-active-class="" @click="menuOpen=false">
            View Catalog
          </RouterLink>
        </li>
      </ul>

      <div class="nav-right">
        <RouterLink to="/admin/login" class="admin-link" title="Admin Panel">
          <Lock :size="16" />
        </RouterLink>
        <button class="hamburger" @click="menuOpen = !menuOpen" aria-label="Toggle menu">
          <Menu v-if="!menuOpen" :size="22" />
          <X v-else :size="22" />
        </button>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { RouterLink } from 'vue-router';
import { Zap, Lock, Menu, X } from 'lucide-vue-next';
import { companyApi } from '@/api/index';

const isScrolled = ref(false);
const menuOpen = ref(false);
const logoSrc = ref('');
const companyName = ref('EON Marketing');

function onScroll() { isScrolled.value = window.scrollY > 40; }
onMounted(() => {
  window.addEventListener('scroll', onScroll);
  companyApi.get().then(({ data }) => {
    if (data.logo_active) logoSrc.value = data.logo_active;
    if (data.name) companyName.value = data.name;
  }).catch(() => {});
});
onUnmounted(() => window.removeEventListener('scroll', onScroll));
</script>

<style scoped>
.navbar {
  position: fixed; top: 0; left: 0; right: 0; z-index: 900;
  background: rgba(10,10,10,0.6);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid transparent;
  transition: all 0.3s ease;
}
.navbar.scrolled {
  background: rgba(10,10,10,0.97);
  border-bottom-color: var(--border);
  box-shadow: 0 1px 32px rgba(0,0,0,0.5);
}
.nav-inner {
  display: flex; align-items: center; justify-content: space-between;
  height: 68px;
}
.nav-logo {
  display: flex; align-items: center; gap: 0.4rem;
  text-decoration: none; color: var(--text-primary);
}
.logo-icon { color: var(--green-primary); }
.logo-text { font-size: 1.35rem; font-weight: 800; letter-spacing: -0.03em; }
.logo-img { height: 40px; max-width: 150px; object-fit: contain; }

.nav-links {
  display: flex; align-items: center; gap: 0.125rem; list-style: none;
}
.nav-links a {
  color: var(--text-secondary); padding: 0.45rem 0.9rem;
  border-radius: var(--radius); font-weight: 500; font-size: 0.9rem;
  transition: color 0.2s; position: relative;
}
.nav-links a:hover { color: var(--text-primary); }
.nav-links a.nav-active { color: var(--text-primary); }
.nav-links a.nav-active::after {
  content: ''; position: absolute; bottom: -2px; left: 0.9rem; right: 0.9rem;
  height: 2px; background: var(--green-primary); border-radius: 2px;
}
.btn-cta {
  background: var(--green-primary) !important; color: #000 !important;
  font-weight: 700 !important; padding: 0.45rem 1.1rem !important;
  border-radius: var(--radius) !important;
  margin-left: 0.5rem;
}
.btn-cta:hover { background: var(--green-secondary) !important; }
.btn-cta::after { display: none !important; }

.nav-right { display: flex; align-items: center; gap: 0.5rem; }
.admin-link {
  display: flex; align-items: center;
  color: var(--text-muted); padding: 0.4rem;
  border-radius: var(--radius); transition: color 0.2s;
}
.admin-link:hover { color: var(--green-primary); }

.hamburger { display: none; background: none; color: var(--text-primary); padding: 0.25rem; }

@media (max-width: 820px) {
  .hamburger { display: flex; }
  .nav-links {
    display: none; position: absolute; top: 68px; left: 0; right: 0;
    background: rgba(10,10,10,0.98); border-bottom: 1px solid var(--border);
    backdrop-filter: blur(20px);
    flex-direction: column; padding: 1rem; gap: 0.25rem;
  }
  .nav-links.open { display: flex; }
  .nav-links li { width: 100%; }
  .nav-links a { display: block; width: 100%; padding: 0.75rem 1rem; border-radius: var(--radius); }
  .nav-links a.nav-active::after { display: none; }
  .logo-img { height: 32px; }
}
</style>
