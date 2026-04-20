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
              <div><strong>Phone</strong><a :href="`tel:${company.phone}`">{{ company.phone }}</a></div>
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
          <div v-if="formSuccess" class="alert alert-success">Thank you! We'll be in touch shortly.</div>
          <form @submit.prevent="submitForm">
            <div class="form-group">
              <label>Full Name</label>
              <input v-model="form.name" type="text" placeholder="Your name" required />
            </div>
            <div class="form-group">
              <label>Email Address</label>
              <input v-model="form.email" type="email" placeholder="your@email.com" required />
            </div>
            <div class="form-group">
              <label>Subject</label>
              <input v-model="form.subject" type="text" placeholder="Product inquiry, quote request…" />
            </div>
            <div class="form-group">
              <label>Message</label>
              <textarea v-model="form.message" rows="5" placeholder="Tell us about your requirements…" required></textarea>
            </div>
            <button type="submit" class="btn-primary" style="width:100%">Send Message</button>
          </form>
          <p class="form-note">This opens your email client with a pre-filled message.</p>
        </div>
      </div>
    </div>
    <AppFooter />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import NavBar from '@/components/NavBar.vue';
import AppFooter from '@/components/AppFooter.vue';
import { contentApi, companyApi } from '@/api/index';

const content = ref('');
const company = ref(null);
const loading = ref(true);
const formSuccess = ref(false);
const form = ref({ name: '', email: '', subject: '', message: '' });

onMounted(async () => {
  try {
    const [c, co] = await Promise.all([contentApi.getPage('contact'), companyApi.get()]);
    content.value = c.data.content_body;
    company.value = co.data;
  } catch {}
  loading.value = false;
});

function submitForm() {
  const { name, email, subject, message } = form.value;
  const to = company.value?.email || 'info@eonmarketing.com';
  const sub = encodeURIComponent(subject || `Inquiry from ${name}`);
  const body = encodeURIComponent(`Name: ${name}\nEmail: ${email}\n\n${message}`);
  window.location.href = `mailto:${to}?subject=${sub}&body=${body}`;
  formSuccess.value = true;
}
</script>

<style scoped>
.contact-layout { display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; }
.content-body { color: var(--text-secondary); line-height: 1.8; margin-bottom: 2rem; }
.content-body :deep(h1), .content-body :deep(h2) { color: var(--text-primary); margin-bottom: 0.75rem; }
.company-details { display: flex; flex-direction: column; gap: 1.25rem; }
.detail-item { display: flex; gap: 1rem; align-items: flex-start; }
.detail-icon { font-size: 1.25rem; margin-top: 0.1rem; }
.detail-item strong { display: block; color: var(--text-primary); margin-bottom: 0.2rem; font-size: 0.9rem; }
.detail-item p, .detail-item a { color: var(--text-secondary); font-size: 0.9rem; }
.form-note { margin-top: 0.75rem; font-size: 0.8rem; color: var(--text-muted); text-align: center; }
@media (max-width: 900px) { .contact-layout { grid-template-columns: 1fr; } }
</style>
