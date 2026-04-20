<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-grid">
        <div class="footer-brand">
          <div class="brand-logo">⚡ EON<span class="text-green">Marketing</span></div>
          <p class="tagline">{{ company?.tagline || 'Premium Equipment & Lighting Solutions' }}</p>
          <div class="social-links">
            <a v-for="link in socialLinks" :key="link.link_id" :href="link.url" target="_blank" rel="noopener noreferrer" class="social-btn" :title="link.platform">
              {{ link.platform[0] }}
            </a>
          </div>
        </div>

        <div class="footer-col">
          <h4>Products</h4>
          <ul>
            <li><RouterLink to="/catalog">All Products</RouterLink></li>
            <li><RouterLink to="/catalog?category=equipment">Equipment</RouterLink></li>
            <li><RouterLink to="/catalog?category=lighting">Lighting</RouterLink></li>
            <li><RouterLink to="/catalog?category=accessories">Accessories</RouterLink></li>
          </ul>
        </div>

        <div class="footer-col">
          <h4>Company</h4>
          <ul>
            <li><RouterLink to="/about">About Us</RouterLink></li>
            <li><RouterLink to="/contact">Contact</RouterLink></li>
            <li><RouterLink to="/shipping">Shipping Policy</RouterLink></li>
            <li><RouterLink to="/terms">Terms & Conditions</RouterLink></li>
          </ul>
        </div>

        <div class="footer-col">
          <h4>Contact</h4>
          <ul class="contact-list">
            <li v-if="company?.address">📍 {{ company.address }}</li>
            <li v-if="company?.phone">📞 {{ company.phone }}</li>
            <li v-if="company?.email">✉️ {{ company.email }}</li>
          </ul>
        </div>
      </div>

      <div class="footer-bottom">
        <p>© {{ new Date().getFullYear() }} {{ company?.name || 'EON Marketing' }}. All rights reserved.</p>
        <div class="footer-bottom-links">
          <RouterLink to="/shipping">Shipping</RouterLink>
          <RouterLink to="/terms">Terms</RouterLink>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { RouterLink } from 'vue-router';
import { companyApi, socialApi } from '@/api/index';

const company = ref(null);
const socialLinks = ref([]);

onMounted(async () => {
  try {
    const [c, s] = await Promise.all([companyApi.get(), socialApi.getAll()]);
    company.value = c.data;
    socialLinks.value = s.data;
  } catch {}
});
</script>

<style scoped>
.footer { background: var(--bg-secondary); border-top: 1px solid var(--border); padding: 4rem 0 0; margin-top: auto; }
.footer-grid { display: grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 3rem; padding-bottom: 3rem; }
.brand-logo { font-size: 1.4rem; font-weight: 800; margin-bottom: 0.75rem; }
.tagline { color: var(--text-muted); font-size: 0.9rem; max-width: 260px; line-height: 1.6; }
.social-links { display: flex; gap: 0.5rem; margin-top: 1.25rem; }
.social-btn {
  width: 36px; height: 36px; border-radius: 50%;
  background: var(--bg-card); border: 1px solid var(--border);
  display: flex; align-items: center; justify-content: center;
  color: var(--text-secondary); font-weight: 700; font-size: 0.85rem;
  transition: all 0.2s;
}
.social-btn:hover { background: var(--green-glow); border-color: var(--green-border); color: var(--green-primary); }
.footer-col h4 { color: var(--text-primary); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 1rem; }
.footer-col ul { list-style: none; display: flex; flex-direction: column; gap: 0.6rem; }
.footer-col a { color: var(--text-muted); font-size: 0.9rem; }
.footer-col a:hover { color: var(--green-primary); }
.contact-list li { color: var(--text-muted); font-size: 0.875rem; display: flex; gap: 0.5rem; }
.footer-bottom {
  border-top: 1px solid var(--border); padding: 1.5rem 0;
  display: flex; justify-content: space-between; align-items: center;
  font-size: 0.85rem; color: var(--text-muted);
}
.footer-bottom-links { display: flex; gap: 1.5rem; }
.footer-bottom-links a { color: var(--text-muted); }
.footer-bottom-links a:hover { color: var(--green-primary); }
@media (max-width: 900px) { .footer-grid { grid-template-columns: 1fr 1fr; } }
@media (max-width: 580px) {
  .footer-grid { grid-template-columns: 1fr; gap: 2rem; }
  .footer-bottom { flex-direction: column; gap: 0.75rem; text-align: center; }
}
</style>
