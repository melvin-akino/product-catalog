<template>
  <div>
    <NavBar />
    <div class="page-hero">
      <div class="container">
        <h1>Contact <span class="text-green">Us</span></h1>
        <div class="accent-line" style="margin: 0.75rem auto 0;"></div>
      </div>
    </div>
    <div class="container section">
      <div class="contact-layout">
        <div class="contact-info">
          <div v-if="loading" class="spinner"></div>
          <div v-else class="content-body" v-html="content"></div>
          <div v-if="company" class="company-details">
            <div class="detail-item" v-if="company.address">
              <span class="detail-icon">📍</span>
              <div><strong>Address</strong><p>{{ company.address }}</p></div>
            </div>
            <div class="detail-item" v-if="company.phone">
              <span class="detail-icon">📞</span>
              <div><strong>Mobile</strong><a :href="`tel:${company.phone}`">{{ company.phone }}</a></div>
            </div>
            <div class="detail-item" v-if="company.landline">
              <span class="detail-icon">☎️</span>
              <div><strong>Landline</strong><a :href="`tel:${company.landline}`">{{ company.landline }}</a></div>
            </div>
            <div class="detail-item" v-if="company.email">
              <span class="detail-icon">✉️</span>
              <div><strong>Email</strong><a :href="`mailto:${company.email}`">{{ company.email }}</a></div>
            </div>
          </div>
        </div>

        <div class="contact-form-wrap">
          <h3>Send an Inquiry</h3>
          <div class="accent-line"></div>

          <div class="bdo-payment-banner">
            <img src="/bdo-checkout.jpg" alt="BDO Checkout — We accept Mastercard and VISA" />
          </div>

          <div v-if="formSuccess" class="alert alert-success">
            Thank you! Your message has been sent. We'll be in touch shortly.
          </div>
          <div v-if="formError" class="alert alert-error">{{ formError }}</div>

          <form v-if="!formSuccess" @submit.prevent="submitForm" novalidate>
            <!-- Honeypot — hidden from real users, bots fill it -->
            <div class="hp-field" aria-hidden="true">
              <input v-model="form.honeypot" type="text" name="website" tabindex="-1" autocomplete="off" />
            </div>

            <div class="form-group">
              <label>Full Name *</label>
              <input v-model="form.name" type="text" placeholder="Your name" required />
            </div>
            <div class="form-group">
              <label>Email Address *</label>
              <input v-model="form.email" type="email" placeholder="your@email.com" required />
            </div>
            <div class="form-group">
              <label>Subject</label>
              <input v-model="form.subject" type="text" placeholder="Product inquiry, quote request…" />
            </div>
            <div class="form-group">
              <label>Message *</label>
              <textarea v-model="form.message" rows="5" placeholder="Tell us about your requirements…" required></textarea>
            </div>
            <button type="submit" class="btn-primary" style="width:100%" :disabled="submitting">
              {{ submitting ? 'Sending…' : 'Send Message' }}
            </button>
          </form>
        </div>
      </div>
    </div>
    <AppFooter />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import NavBar from '@/components/NavBar.vue';
import AppFooter from '@/components/AppFooter.vue';
import api, { contentApi, companyApi } from '@/api/index';

const route = useRoute();
const content = ref('');
const company = ref(null);
const loading = ref(true);
const formSuccess = ref(false);
const formError = ref('');
const submitting = ref(false);
const form = ref({ name: '', email: '', subject: route.query.subject || '', message: '', honeypot: '' });

onMounted(async () => {
  try {
    const [c, co] = await Promise.all([contentApi.getPage('contact'), companyApi.get()]);
    content.value = c.data.content_body;
    company.value = co.data;
  } catch {}
  loading.value = false;
});

async function submitForm() {
  formError.value = '';
  submitting.value = true;
  try {
    await api.post('/contact', {
      name: form.value.name,
      email: form.value.email,
      subject: form.value.subject,
      message: form.value.message,
      honeypot: form.value.honeypot,
    });
    formSuccess.value = true;
  } catch (err) {
    const msg = err.response?.data?.error;
    if (err.response?.status === 429) {
      formError.value = 'Too many messages sent. Please try again in an hour.';
    } else {
      formError.value = msg || 'Something went wrong. Please try again.';
    }
  }
  submitting.value = false;
}
</script>

<style scoped>
.contact-layout { display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; }
.content-body { color: var(--text-secondary); line-height: 1.55; margin-bottom: 2rem; font-size: 0.9rem; }
.content-body :deep(h1), .content-body :deep(h2), .content-body :deep(h3) { color: var(--text-primary); margin-bottom: 0.2rem; margin-top: 0.85rem; }
.content-body :deep(p) { margin-bottom: 0.4rem; }
.content-body :deep(p:empty) { margin-bottom: 0.15rem; line-height: 0.5; }
.content-body :deep(ul), .content-body :deep(ol) { margin-left: 1.1rem; margin-bottom: 0.4rem; }
.content-body :deep(li) { margin-bottom: 0.1rem; }
.content-body :deep(a) { color: var(--green-primary); text-decoration: underline; }
.content-body :deep(strong) { color: var(--text-primary); }
.company-details { display: flex; flex-direction: column; gap: 1.25rem; }
.detail-item { display: flex; gap: 1rem; align-items: flex-start; }
.detail-icon { font-size: 1.25rem; margin-top: 0.1rem; }
.detail-item strong { display: block; color: var(--text-primary); margin-bottom: 0.2rem; font-size: 0.9rem; }
.detail-item p, .detail-item a { color: var(--text-secondary); font-size: 0.9rem; }

/* Honeypot field — visually hidden but not display:none (bots bypass that) */
.hp-field {
  position: absolute;
  left: -9999px;
  top: -9999px;
  opacity: 0;
  height: 0;
  overflow: hidden;
}

.bdo-payment-banner {
  margin-bottom: 1.5rem;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid var(--border-color);
}
.bdo-payment-banner img {
  display: block;
  width: 100%;
  height: auto;
}

@media (max-width: 900px) { .contact-layout { grid-template-columns: 1fr; } }
</style>
