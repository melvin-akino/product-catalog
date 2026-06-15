<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-grid">
        <!-- Brand -->
        <div class="footer-brand">
          <div class="brand-logo">
            <img v-if="logoSrc" :src="logoSrc" :alt="company?.name || 'EON'" class="footer-logo-img" @error="logoSrc = ''" />
            <template v-else>
              <Zap :size="20" class="brand-icon" />
              EON<span class="text-green">.</span>
            </template>
          </div>
          <p class="tagline">{{ company?.tagline || 'Premium Equipment & Lighting Solutions' }}</p>
          <div class="social-links">
            <a
              v-for="link in socialLinks" :key="link.link_id"
              :href="link.url" target="_blank" rel="noopener noreferrer"
              class="social-btn" :title="link.platform"
            >
              <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" v-html="socialIconSvg(link.platform)"></svg>
            </a>
          </div>
        </div>

        <!-- Products -->
        <div class="footer-col">
          <h4>Products</h4>
          <ul>
            <li><RouterLink to="/catalog">All Products</RouterLink></li>
            <li v-for="cat in categories" :key="cat.category_id">
              <RouterLink :to="`/catalog?category=${cat.slug}`">{{ cat.name }}</RouterLink>
            </li>
          </ul>
        </div>

        <!-- Company -->
        <div class="footer-col">
          <h4>Company</h4>
          <ul>
            <li><RouterLink to="/about">About Us</RouterLink></li>
            <li><RouterLink to="/contact">Contact</RouterLink></li>
            <li><RouterLink to="/shipping">Shipping Policy</RouterLink></li>
            <li><RouterLink to="/terms">Terms & Conditions</RouterLink></li>
          </ul>
        </div>

        <!-- Contact -->
        <div class="footer-col">
          <h4>Contact Us</h4>
          <ul class="contact-list">
            <li v-if="company?.address">
              <MapPin :size="14" class="contact-icon" />
              <span>{{ company.address }}</span>
            </li>
            <li v-if="company?.phone">
              <Phone :size="14" class="contact-icon" />
              <span>{{ company.phone }}</span>
            </li>
            <li v-if="company?.email">
              <Mail :size="14" class="contact-icon" />
              <span>{{ company.email }}</span>
            </li>
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
import { Zap, MapPin, Phone, Mail } from 'lucide-vue-next';
import { companyApi, socialApi, categoriesApi } from '@/api/index';

const SOCIAL_ICONS = {
  facebook:  '<path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/>',
  instagram: '<rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/>',
  twitter:   '<path d="M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z"/>',
  x:         '<path d="M18 6L6 18M6 6l12 12"/>',
  youtube:   '<path d="M22.54 6.42a2.78 2.78 0 0 0-1.95-1.96C18.88 4 12 4 12 4s-6.88 0-8.59.46a2.78 2.78 0 0 0-1.95 1.96A29 29 0 0 0 1 12a29 29 0 0 0 .46 5.58A2.78 2.78 0 0 0 3.41 19.54C5.12 20 12 20 12 20s6.88 0 8.59-.46a2.78 2.78 0 0 0 1.95-1.96A29 29 0 0 0 23 12a29 29 0 0 0-.46-5.58z"/><polygon points="9.75 15.02 15.5 12 9.75 8.98 9.75 15.02"/>',
  linkedin:  '<path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z"/><rect x="2" y="9" width="4" height="12"/><circle cx="4" cy="4" r="2"/>',
  tiktok:    '<path d="M9 12a4 4 0 1 0 4 4V4a5 5 0 0 0 5 5"/>',
  carousell: '<path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/>',
};

function socialIconSvg(platform) {
  const key = platform.toLowerCase().replace(/\s+/g, '');
  return SOCIAL_ICONS[key] || '<circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>';
}

const company = ref(null);
const socialLinks = ref([]);
const categories = ref([]);
const logoSrc = ref('');

onMounted(async () => {
  try {
    const [c, s, cats] = await Promise.all([companyApi.get(), socialApi.getAll(), categoriesApi.getAll()]);
    company.value = c.data;
    if (c.data?.logo_active) logoSrc.value = c.data.logo_active;
    socialLinks.value = s.data;
    categories.value = cats.data.slice(0, 4);
  } catch {}
});
</script>

<style scoped>
.footer {
  background: #0d0d0d;
  border-top: 1px solid var(--border);
  padding: 4rem 0 0;
  margin-top: auto;
}
.footer-grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr;
  gap: 3rem;
  padding-bottom: 3rem;
  border-bottom: 1px solid var(--border);
}
.brand-logo {
  display: flex; align-items: center; gap: 0.4rem;
  font-size: 1.4rem; font-weight: 800; letter-spacing: -0.03em;
  margin-bottom: 0.85rem;
}
.footer-logo-img { height: 44px; max-width: 160px; object-fit: contain; }
.brand-icon { color: var(--green-primary); }
.tagline { color: var(--text-muted); font-size: 0.875rem; max-width: 240px; line-height: 1.65; }
.social-links { display: flex; gap: 0.5rem; margin-top: 1.5rem; }
.social-btn {
  width: 34px; height: 34px; border-radius: 8px;
  background: var(--bg-card); border: 1px solid var(--border);
  display: flex; align-items: center; justify-content: center;
  color: var(--text-muted); font-weight: 700; font-size: 0.7rem;
  text-transform: uppercase; letter-spacing: 0.03em;
  transition: all 0.2s;
}
.social-btn:hover { background: var(--green-glow); border-color: var(--green-border); color: var(--green-primary); }

.footer-col h4 {
  color: var(--text-primary); font-size: 0.78rem;
  text-transform: uppercase; letter-spacing: 0.1em;
  font-weight: 600; margin-bottom: 1.1rem;
}
.footer-col ul { list-style: none; display: flex; flex-direction: column; gap: 0.65rem; }
.footer-col a { color: var(--text-muted); font-size: 0.875rem; transition: color 0.2s; }
.footer-col a:hover { color: var(--text-primary); }

.contact-list li {
  display: flex; align-items: flex-start; gap: 0.6rem;
  color: var(--text-muted); font-size: 0.875rem; line-height: 1.5;
}
.contact-icon { flex-shrink: 0; margin-top: 2px; color: var(--green-primary); }

.footer-bottom {
  padding: 1.5rem 0;
  display: flex; justify-content: space-between; align-items: center;
  font-size: 0.82rem; color: var(--text-muted);
}
.footer-bottom-links { display: flex; gap: 1.5rem; }
.footer-bottom-links a { color: var(--text-muted); transition: color 0.2s; }
.footer-bottom-links a:hover { color: var(--green-primary); }

@media (max-width: 900px) { .footer-grid { grid-template-columns: 1fr 1fr; } }
@media (max-width: 560px) {
  .footer-grid { grid-template-columns: 1fr; gap: 2rem; }
  .footer-bottom { flex-direction: column; gap: 0.75rem; text-align: center; }
}
</style>
