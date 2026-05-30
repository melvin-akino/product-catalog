<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-grid">
        <!-- Brand -->
        <div class="footer-brand">
          <div class="brand-logo">
            <Zap :size="20" class="brand-icon" />
            EON<span class="text-green">.</span>
          </div>
          <p class="tagline">{{ company?.tagline || 'Premium Equipment & Lighting Solutions' }}</p>
          <div class="social-links">
            <a
              v-for="link in socialLinks" :key="link.link_id"
              :href="link.url" target="_blank" rel="noopener noreferrer"
              class="social-btn" :title="link.platform"
            >
              {{ link.platform.slice(0, 2) }}
            </a>
          </div>
        </div>

        <!-- Products -->
        <div class="footer-col">
          <h4>Products</h4>
          <ul>
            <li><RouterLink to="/catalog">All Products</RouterLink></li>
            <li><RouterLink to="/catalog?category=equipment">Equipment</RouterLink></li>
            <li><RouterLink to="/catalog?category=lighting">Lighting</RouterLink></li>
            <li><RouterLink to="/catalog?category=accessories">Accessories</RouterLink></li>
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
          <RouterLink to="/admin/login" class="admin-link">Admin</RouterLink>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { RouterLink } from 'vue-router';
import { Zap, MapPin, Phone, Mail } from 'lucide-vue-next';
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
.admin-link { opacity: 0.5; }

@media (max-width: 900px) { .footer-grid { grid-template-columns: 1fr 1fr; } }
@media (max-width: 560px) {
  .footer-grid { grid-template-columns: 1fr; gap: 2rem; }
  .footer-bottom { flex-direction: column; gap: 0.75rem; text-align: center; }
}
</style>
