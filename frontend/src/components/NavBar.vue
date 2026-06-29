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
        <li v-if="socialLinks.length" class="follow-item" :class="{ open: followOpen }">
          <button class="follow-trigger" @click="followOpen = !followOpen" @blur="onFollowBlur">
            Follow Us <span class="follow-chevron">▾</span>
          </button>
          <ul class="follow-dropdown">
            <li v-for="link in socialLinks" :key="link.link_id">
              <a :href="link.url" target="_blank" rel="noopener noreferrer" @click="menuOpen=false; followOpen=false">
                {{ link.platform }}
              </a>
            </li>
          </ul>
        </li>
      </ul>

      <div class="nav-right">
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
import { Zap, Menu, X } from 'lucide-vue-next';
import { companyApi, socialApi } from '@/api/index';

const isScrolled = ref(false);
const menuOpen = ref(false);
const followOpen = ref(false);
const logoSrc = ref('');
const companyName = ref('EON Marketing');
const socialLinks = ref([]);

function onScroll() { isScrolled.value = window.scrollY > 40; }
function onFollowBlur() { setTimeout(() => { followOpen.value = false; }, 150); }

onMounted(() => {
  window.addEventListener('scroll', onScroll);
  Promise.all([companyApi.get(), socialApi.getAll()]).then(([c, s]) => {
    if (c.data.logo_active) logoSrc.value = c.data.logo_active;
    if (c.data.name) companyName.value = c.data.name;
    socialLinks.value = s.data;
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
.hamburger { display: none; background: none; color: var(--text-primary); padding: 0.25rem; }

/* Follow Us dropdown */
.follow-item { position: relative; }
.follow-trigger {
  background: none; color: var(--text-secondary);
  padding: 0.45rem 0.9rem; border-radius: var(--radius);
  font-weight: 500; font-size: 0.9rem; cursor: pointer;
  display: flex; align-items: center; gap: 0.3rem;
  transition: color 0.2s;
}
.follow-trigger:hover { color: var(--text-primary); }
.follow-chevron { font-size: 0.7rem; transition: transform 0.2s; }
.follow-item.open .follow-chevron { transform: rotate(180deg); }
.follow-dropdown {
  display: none; position: absolute; top: calc(100% + 6px); left: 0;
  background: rgba(10,10,10,0.98); border: 1px solid var(--border);
  border-radius: var(--radius); min-width: 160px;
  backdrop-filter: blur(20px); list-style: none;
  padding: 0.4rem 0; z-index: 999;
  box-shadow: 0 8px 32px rgba(0,0,0,0.4);
}
.follow-item.open .follow-dropdown { display: block; }
.follow-dropdown li a {
  display: block; padding: 0.55rem 1rem;
  color: var(--text-secondary); font-size: 0.875rem;
  transition: color 0.15s, background 0.15s;
}
.follow-dropdown li a:hover { color: var(--green-primary); background: var(--green-glow); }

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

  /* Follow Us — flat list on mobile */
  .follow-item { width: 100%; }
  .follow-trigger { width: 100%; padding: 0.75rem 1rem; justify-content: space-between; }
  .follow-dropdown {
    display: none; position: static;
    background: var(--bg-secondary); border: none; border-radius: 0;
    box-shadow: none; backdrop-filter: none; padding: 0;
  }
  .follow-item.open .follow-dropdown { display: block; }
  .follow-dropdown li a { padding: 0.6rem 1.5rem; }
}
</style>
