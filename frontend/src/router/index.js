import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const routes = [
  // Client-facing
  { path: '/', name: 'home', component: () => import('@/views/HomeView.vue') },
  { path: '/catalog', name: 'catalog', component: () => import('@/views/CatalogView.vue') },
  { path: '/catalog/:id', name: 'product-detail', component: () => import('@/views/ProductDetailView.vue') },
  { path: '/about', name: 'about', component: () => import('@/views/AboutView.vue') },
  { path: '/contact', name: 'contact', component: () => import('@/views/ContactView.vue') },
  { path: '/shipping', name: 'shipping', component: () => import('@/views/ShippingView.vue') },
  { path: '/terms', name: 'terms', component: () => import('@/views/TermsView.vue') },

  // Admin
  { path: '/admin/login', name: 'admin-login', component: () => import('@/views/admin/LoginView.vue') },
  {
    path: '/admin',
    component: () => import('@/views/admin/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: '', redirect: '/admin/dashboard' },
      { path: 'dashboard', name: 'admin-dashboard', component: () => import('@/views/admin/DashboardView.vue') },
      { path: 'products', name: 'admin-products', component: () => import('@/views/admin/ProductsView.vue') },
      { path: 'categories', name: 'admin-categories', component: () => import('@/views/admin/CategoriesView.vue') },
      { path: 'content', name: 'admin-content', component: () => import('@/views/admin/ContentEditorView.vue') },
      { path: 'company', name: 'admin-company', component: () => import('@/views/admin/CompanyInfoView.vue') },
      { path: 'social', name: 'admin-social', component: () => import('@/views/admin/SocialLinksView.vue') },
      { path: 'seo', name: 'admin-seo', component: () => import('@/views/admin/SEOManagerView.vue') },
    ],
  },

  { path: '/:pathMatch(.*)*', redirect: '/' },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    return savedPosition || { top: 0 };
  },
});

router.beforeEach(async (to, from, next) => {
  if (to.meta.requiresAuth) {
    const auth = useAuthStore();
    const valid = await auth.verifyToken();
    if (!valid) return next('/admin/login');
  }
  next();
});

export default router;
