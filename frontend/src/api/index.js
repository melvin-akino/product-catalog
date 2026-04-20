import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401 || err.response?.status === 403) {
      localStorage.removeItem('admin_token');
      if (window.location.pathname.startsWith('/admin') && window.location.pathname !== '/admin/login') {
        window.location.href = '/admin/login';
      }
    }
    return Promise.reject(err);
  }
);

export default api;

export const productsApi = {
  getAll: (params) => api.get('/products', { params }),
  getById: (id) => api.get(`/products/${id}`),
  create: (data) => api.post('/products', data),
  update: (id, data) => api.put(`/products/${id}`, data),
  delete: (id) => api.delete(`/products/${id}`),
};

export const categoriesApi = {
  getAll: () => api.get('/categories'),
  create: (data) => api.post('/categories', data),
  update: (id, data) => api.put(`/categories/${id}`, data),
  delete: (id) => api.delete(`/categories/${id}`),
};

export const contentApi = {
  getPage: (page) => api.get(`/site-content/${page}`),
  updatePage: (page, data) => api.put(`/site-content/${page}`, data),
  getAll: () => api.get('/site-content'),
};

export const companyApi = {
  get: () => api.get('/company-info'),
  update: (data) => api.put('/company-info', data),
};

export const socialApi = {
  getAll: () => api.get('/social-links'),
  getAllAdmin: () => api.get('/social-links/all'),
  create: (data) => api.post('/social-links', data),
  update: (id, data) => api.put(`/social-links/${id}`, data),
  delete: (id) => api.delete(`/social-links/${id}`),
};

export const seoApi = {
  getAll: () => api.get('/seo'),
  getPage: (page) => api.get(`/seo/${page}`),
  create: (data) => api.post('/seo', data),
  update: (id, data) => api.put(`/seo/${id}`, data),
};

export const authApi = {
  login: (data) => api.post('/auth/login', data),
  verify: () => api.post('/auth/verify'),
};

export const uploadApi = {
  uploadImages: (files) => {
    const form = new FormData();
    files.forEach(f => form.append('images', f));
    return api.post('/upload', form, { headers: { 'Content-Type': 'multipart/form-data' } });
  },
};
