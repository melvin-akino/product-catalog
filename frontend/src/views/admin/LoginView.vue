<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-logo">⚡ EON<span class="text-green">Admin</span></div>
      <h2>Sign in</h2>
      <p class="text-secondary">Access the admin dashboard</p>

      <div v-if="error" class="alert alert-error">{{ error }}</div>

      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label>Username</label>
          <input v-model="form.username" type="text" placeholder="admin" required autocomplete="username" />
        </div>
        <div class="form-group">
          <label>Password</label>
          <input v-model="form.password" type="password" placeholder="••••••••" required autocomplete="current-password" />
        </div>
        <button type="submit" class="btn-primary login-btn" :disabled="loading">
          {{ loading ? 'Signing in…' : 'Sign In' }}
        </button>
      </form>

      <RouterLink to="/" class="back-link">← Back to site</RouterLink>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter, RouterLink } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const auth = useAuthStore();
const router = useRouter();
const form = ref({ username: '', password: '' });
const loading = ref(false);
const error = ref('');

async function handleLogin() {
  error.value = '';
  loading.value = true;
  try {
    await auth.login(form.value.username, form.value.password);
    router.push('/admin/dashboard');
  } catch (e) {
    error.value = e.response?.data?.error || 'Invalid credentials. Please try again.';
  }
  loading.value = false;
}
</script>

<style scoped>
.login-page {
  min-height: 100vh; display: flex; align-items: center; justify-content: center;
  padding: 2rem;
  background: radial-gradient(ellipse 70% 60% at 50% 40%, rgba(0,230,118,0.06) 0%, transparent 70%);
}
.login-card {
  width: 100%; max-width: 420px;
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius-lg); padding: 2.5rem;
  box-shadow: var(--shadow);
}
.login-logo { font-size: 1.5rem; font-weight: 800; margin-bottom: 1.5rem; }
.login-card h2 { margin-bottom: 0.25rem; }
.login-card > p { margin-bottom: 1.75rem; }
.login-form { margin-top: 1.5rem; }
.login-btn { width: 100%; margin-top: 0.5rem; font-size: 1rem; padding: 0.9rem; }
.login-btn:disabled { opacity: 0.6; cursor: not-allowed; }
.back-link { display: block; text-align: center; margin-top: 1.25rem; color: var(--text-muted); font-size: 0.875rem; }
.back-link:hover { color: var(--green-primary); }
</style>
