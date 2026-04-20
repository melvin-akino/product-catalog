import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { authApi } from '@/api/index';

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('admin_token') || null);
  const user = ref(null);

  const isAuthenticated = computed(() => !!token.value);

  async function login(username, password) {
    const { data } = await authApi.login({ username, password });
    token.value = data.token;
    user.value = { username: data.username, role: data.role };
    localStorage.setItem('admin_token', data.token);
    return data;
  }

  function logout() {
    token.value = null;
    user.value = null;
    localStorage.removeItem('admin_token');
  }

  async function verifyToken() {
    if (!token.value) return false;
    try {
      const { data } = await authApi.verify();
      if (data.valid) {
        user.value = data.user;
        return true;
      }
      logout();
      return false;
    } catch {
      logout();
      return false;
    }
  }

  return { token, user, isAuthenticated, login, logout, verifyToken };
});
