<template>
  <Teleport to="body">
    <div class="modal-overlay" @click.self="$emit('close')">
      <div class="modal inquire-modal">
        <button class="modal-close" @click="$emit('close')">✕</button>
        <div class="modal-header">
          <h2>Inquire About This Product</h2>
          <p class="modal-subtitle">{{ productName }}</p>
        </div>

        <div class="contact-options">
          <a :href="`mailto:${email}?subject=Product Inquiry: ${productName}`" class="contact-option">
            <div class="option-icon">✉️</div>
            <div class="option-info">
              <strong>Email Us</strong>
              <span>{{ email }}</span>
            </div>
          </a>

          <a :href="`tel:${phone}`" class="contact-option">
            <div class="option-icon">📞</div>
            <div class="option-info">
              <strong>Call Us</strong>
              <span>{{ phone }}</span>
            </div>
          </a>

          <a :href="whatsappLink" target="_blank" rel="noopener noreferrer" class="contact-option">
            <div class="option-icon">💬</div>
            <div class="option-info">
              <strong>WhatsApp / Chat</strong>
              <span>Message us directly</span>
            </div>
          </a>
        </div>

        <p class="modal-note">
          Our team will respond within 24 hours with pricing, availability, and shipping information.
        </p>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { companyApi } from '@/api/index';

defineProps({ productName: { type: String, default: 'this product' } });
defineEmits(['close']);

const company = ref({});
onMounted(async () => {
  try { const { data } = await companyApi.get(); company.value = data; } catch {}
});

const email = computed(() => company.value.email || 'info@eonmarketing.com');
const phone = computed(() => company.value.phone || '+1 (555) 000-0000');
const whatsappLink = computed(() => {
  const num = phone.value.replace(/\D/g, '');
  return `https://wa.me/${num}`;
});
</script>

<style scoped>
.inquire-modal { max-width: 520px; }
.modal-header { margin-bottom: 1.5rem; }
.modal-header h2 { font-size: 1.4rem; margin-bottom: 0.3rem; }
.modal-subtitle { color: var(--green-primary); font-weight: 600; font-size: 0.95rem; }
.contact-options { display: flex; flex-direction: column; gap: 0.75rem; }
.contact-option {
  display: flex; align-items: center; gap: 1rem;
  padding: 1rem 1.25rem; border-radius: var(--radius);
  border: 1px solid var(--border-light);
  background: var(--bg-secondary);
  color: var(--text-primary); text-decoration: none;
  transition: all 0.2s;
}
.contact-option:hover { border-color: var(--green-border); background: var(--green-glow); color: var(--text-primary); }
.option-icon { font-size: 1.5rem; }
.option-info { display: flex; flex-direction: column; }
.option-info strong { font-size: 0.95rem; }
.option-info span { font-size: 0.82rem; color: var(--text-muted); }
.modal-note { margin-top: 1.25rem; font-size: 0.82rem; color: var(--text-muted); line-height: 1.6; border-top: 1px solid var(--border); padding-top: 1rem; }
</style>
