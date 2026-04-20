<template>
  <nav class="navbar" :class="{ scrolled: isScrolled, 'menu-open': menuOpen }">
    <div class="container nav-inner">
      <RouterLink to="/" class="nav-logo">
        <span class="logo-icon">⚡</span>
        <span class="logo-text">EON<span class="text-green">Marketing</span></span>
      </RouterLink>

      <ul class="nav-links" :class="{ open: menuOpen }">
        <li><RouterLink to="/" @click="menuOpen=false">Home</RouterLink></li>
        <li><RouterLink to="/catalog" @click="menuOpen=false">Products</RouterLink></li>
        <li><RouterLink to="/about" @click="menuOpen=false">About</RouterLink></li>
        <li><RouterLink to="/contact" @click="menuOpen=false">Contact</RouterLink></li>
        <li>
          <RouterLink to="/catalog" class="btn-primary btn-sm" @click="menuOpen=false">View Catalog</RouterLink>
        </li>
      </ul>

      <button class="hamburger" @click="menuOpen = !menuOpen" aria-label="Toggle menu">
        <span></span><span></span><span></span>
      </button>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { RouterLink } from 'vue-router';

const isScrolled = ref(false);
const menuOpen = ref(false);

function onScroll() { isScrolled.value = window.scrollY > 40; }
onMounted(() => window.addEventListener('scroll', onScroll));
onUnmounted(() => window.removeEventListener('scroll', onScroll));
</script>

<style scoped>
.navbar {
  position: fixed; top: 0; left: 0; right: 0; z-index: 900;
  background: rgba(10,10,10,0.7);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid transparent;
  transition: all 0.3s ease;
}
.navbar.scrolled {
  background: rgba(10,10,10,0.95);
  border-bottom-color: var(--border);
  box-shadow: 0 2px 20px rgba(0,0,0,0.4);
}
.nav-inner {
  display: flex; align-items: center; justify-content: space-between;
  height: 70px;
}
.nav-logo {
  display: flex; align-items: center; gap: 0.5rem;
  font-size: 1.3rem; font-weight: 800; color: var(--text-primary);
  text-decoration: none;
}
.logo-icon { font-size: 1.5rem; }
.nav-links {
  display: flex; align-items: center; gap: 0.25rem; list-style: none;
}
.nav-links a {
  color: var(--text-secondary); padding: 0.5rem 0.85rem;
  border-radius: var(--radius); font-weight: 500; font-size: 0.95rem;
  transition: all 0.2s;
}
.nav-links a:hover, .nav-links a.router-link-active { color: var(--green-primary); }
.hamburger {
  display: none; flex-direction: column; gap: 5px;
  background: none; padding: 8px; border-radius: var(--radius);
}
.hamburger span {
  display: block; width: 24px; height: 2px;
  background: var(--text-primary); transition: all 0.3s;
}
@media (max-width: 768px) {
  .hamburger { display: flex; }
  .nav-links {
    display: none; position: absolute; top: 70px; left: 0; right: 0;
    background: var(--bg-secondary); border-bottom: 1px solid var(--border);
    flex-direction: column; padding: 1rem;
    gap: 0.25rem;
  }
  .nav-links.open { display: flex; }
  .nav-links li { width: 100%; }
  .nav-links a { display: block; width: 100%; padding: 0.75rem 1rem; }
}
</style>
