<template>
  <div>
    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Users</h1>
        <p class="page-sub">Manage admin and viewer accounts</p>
      </div>
      <button class="btn-primary" @click="openCreate">
        <UserPlus :size="15" /> Add User
      </button>
    </div>

    <!-- Alert -->
    <div v-if="alert.msg" class="alert" :class="`alert-${alert.type}`">{{ alert.msg }}</div>

    <!-- Table -->
    <div class="card table-card">
      <div v-if="loading" class="spinner"></div>
      <div v-else-if="!users.length" class="empty-state">
        <Users :size="40" class="empty-icon" />
        <p>No users yet. Add your first user above.</p>
      </div>
      <div v-else class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Email</th>
              <th>Role</th>
              <th>Status</th>
              <th>Created</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="u in users" :key="u.user_id">
              <td>
                <div class="user-cell">
                  <div class="avatar" :class="`avatar-${u.role}`">
                    {{ u.username.slice(0,1).toUpperCase() }}
                  </div>
                  <span class="username">{{ u.username }}</span>
                </div>
              </td>
              <td class="email-cell">{{ u.email }}</td>
              <td>
                <span class="badge" :class="u.role === 'admin' ? 'badge-admin' : 'badge-viewer'">
                  <Shield v-if="u.role === 'admin'" :size="10" />
                  <Eye v-else :size="10" />
                  {{ u.role }}
                </span>
              </td>
              <td>
                <button class="status-toggle" :class="u.status" @click="toggleStatus(u)" title="Toggle status">
                  <span class="status-dot"></span>
                  {{ u.status }}
                </button>
              </td>
              <td class="date-cell">{{ formatDate(u.created_at) }}</td>
              <td>
                <div class="row-actions">
                  <button class="icon-btn" title="Edit" @click="openEdit(u)">
                    <Pencil :size="14" />
                  </button>
                  <button class="icon-btn danger" title="Delete" @click="confirmDelete(u)">
                    <Trash2 :size="14" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create / Edit Modal -->
    <div v-if="modal.open" class="modal-overlay" @click.self="closeModal">
      <div class="modal modal-lg">
        <button class="modal-close" @click="closeModal"><X :size="16" /></button>
        <h3 class="modal-title">{{ modal.editing ? 'Edit User' : 'Add User' }}</h3>

        <form @submit.prevent="submitForm" class="user-form">
          <div class="form-row">
            <div class="form-group">
              <label>Username</label>
              <input v-model="form.username" type="text" placeholder="johndoe" required />
            </div>
            <div class="form-group">
              <label>Email</label>
              <input v-model="form.email" type="email" placeholder="john@example.com" required />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Role</label>
              <select v-model="form.role">
                <option value="viewer">Viewer — read-only access</option>
                <option value="admin">Admin — full access</option>
              </select>
            </div>
            <div class="form-group" v-if="modal.editing">
              <label>Status</label>
              <select v-model="form.status">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>{{ modal.editing ? 'New Password (leave blank to keep current)' : 'Password' }}</label>
            <div class="pw-wrap">
              <input
                v-model="form.password"
                :type="showPw ? 'text' : 'password'"
                :placeholder="modal.editing ? 'Enter new password...' : 'Min 6 characters'"
                :required="!modal.editing"
                autocomplete="new-password"
              />
              <button type="button" class="pw-toggle" @click="showPw = !showPw">
                <EyeOff v-if="showPw" :size="15" />
                <Eye v-else :size="15" />
              </button>
            </div>
          </div>

          <div v-if="formError" class="form-error">{{ formError }}</div>

          <div class="modal-actions">
            <button type="button" class="btn-outline" @click="closeModal">Cancel</button>
            <button type="submit" class="btn-primary" :disabled="submitting">
              <span v-if="submitting">Saving…</span>
              <span v-else>{{ modal.editing ? 'Save Changes' : 'Create User' }}</span>
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete confirmation -->
    <div v-if="deleteTarget" class="modal-overlay" @click.self="deleteTarget = null">
      <div class="modal modal-sm">
        <button class="modal-close" @click="deleteTarget = null"><X :size="16" /></button>
        <div class="delete-icon-wrap"><Trash2 :size="28" /></div>
        <h3 class="modal-title">Delete User?</h3>
        <p class="delete-msg">
          This will permanently remove <strong>{{ deleteTarget.username }}</strong>.
          This action cannot be undone.
        </p>
        <div class="modal-actions">
          <button class="btn-outline" @click="deleteTarget = null">Cancel</button>
          <button class="btn-danger" @click="doDelete" :disabled="submitting">
            {{ submitting ? 'Deleting…' : 'Delete' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import {
  Users, UserPlus, Pencil, Trash2, X,
  Shield, Eye, EyeOff, Search,
} from 'lucide-vue-next';
import { usersApi } from '@/api/index';

const users = ref([]);
const loading = ref(true);
const submitting = ref(false);
const alert = ref({ msg: '', type: 'success' });
const deleteTarget = ref(null);
const showPw = ref(false);
const formError = ref('');

const modal = ref({ open: false, editing: false, id: null });
const form = ref({ username: '', email: '', role: 'viewer', status: 'active', password: '' });

onMounted(fetchUsers);

async function fetchUsers() {
  loading.value = true;
  try {
    const { data } = await usersApi.getAll();
    users.value = data;
  } catch {
    showAlert('Failed to load users.', 'error');
  }
  loading.value = false;
}

function openCreate() {
  form.value = { username: '', email: '', role: 'viewer', status: 'active', password: '' };
  modal.value = { open: true, editing: false, id: null };
  formError.value = '';
  showPw.value = false;
}

function openEdit(u) {
  form.value = { username: u.username, email: u.email, role: u.role, status: u.status, password: '' };
  modal.value = { open: true, editing: true, id: u.user_id };
  formError.value = '';
  showPw.value = false;
}

function closeModal() { modal.value.open = false; }

async function submitForm() {
  formError.value = '';
  submitting.value = true;
  try {
    const payload = { ...form.value };
    if (modal.value.editing && !payload.password) delete payload.password;

    if (modal.value.editing) {
      await usersApi.update(modal.value.id, payload);
      showAlert('User updated successfully.');
    } else {
      await usersApi.create(payload);
      showAlert('User created successfully.');
    }
    closeModal();
    await fetchUsers();
  } catch (err) {
    const msg = err.response?.data?.error || err.response?.data?.errors?.[0]?.msg || 'Something went wrong.';
    formError.value = msg;
  }
  submitting.value = false;
}

async function toggleStatus(u) {
  const newStatus = u.status === 'active' ? 'inactive' : 'active';
  try {
    await usersApi.update(u.user_id, { ...u, status: newStatus, password: undefined });
    u.status = newStatus;
  } catch {
    showAlert('Failed to update status.', 'error');
  }
}

function confirmDelete(u) { deleteTarget.value = u; }

async function doDelete() {
  submitting.value = true;
  try {
    await usersApi.delete(deleteTarget.value.user_id);
    showAlert(`User "${deleteTarget.value.username}" deleted.`);
    deleteTarget.value = null;
    await fetchUsers();
  } catch {
    showAlert('Failed to delete user.', 'error');
  }
  submitting.value = false;
}

function showAlert(msg, type = 'success') {
  alert.value = { msg, type };
  setTimeout(() => { alert.value.msg = ''; }, 4000);
}

function formatDate(str) {
  if (!str) return '—';
  return new Date(str).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}
</script>

<style scoped>
/* ── Page header ────────────────────────────────────────────── */
.page-header {
  display: flex; justify-content: space-between; align-items: flex-start;
  margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem;
}
.page-title { font-size: 1.35rem; font-weight: 800; margin-bottom: 0.2rem; }
.page-sub { color: var(--text-muted); font-size: 0.875rem; }
.btn-primary { display: flex; align-items: center; gap: 0.45rem; }

/* ── Table card ─────────────────────────────────────────────── */
.table-card { padding: 0; overflow: hidden; }
.empty-state { padding: 4rem; text-align: center; color: var(--text-muted); }
.empty-icon { margin: 0 auto 1rem; opacity: 0.4; }

/* ── User cell ──────────────────────────────────────────────── */
.user-cell { display: flex; align-items: center; gap: 0.65rem; }
.avatar {
  width: 32px; height: 32px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 0.8rem; font-weight: 700; flex-shrink: 0;
}
.avatar-admin { background: var(--green-glow); color: var(--green-primary); border: 1px solid var(--green-border); }
.avatar-viewer { background: rgba(255,255,255,0.05); color: var(--text-secondary); border: 1px solid var(--border-light); }
.username { font-weight: 600; font-size: 0.9rem; }
.email-cell { color: var(--text-muted); font-size: 0.875rem; }
.date-cell { color: var(--text-muted); font-size: 0.82rem; white-space: nowrap; }

/* ── Role badge ─────────────────────────────────────────────── */
.badge { display: inline-flex; align-items: center; gap: 0.3rem; padding: 0.2rem 0.65rem; border-radius: 999px; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
.badge-admin { background: var(--green-glow); color: var(--green-primary); border: 1px solid var(--green-border); }
.badge-viewer { background: rgba(255,255,255,0.06); color: var(--text-secondary); border: 1px solid var(--border-light); }

/* ── Status toggle ──────────────────────────────────────────── */
.status-toggle {
  display: inline-flex; align-items: center; gap: 0.4rem;
  font-size: 0.78rem; font-weight: 600; text-transform: capitalize;
  background: none; border-radius: 999px; padding: 0.2rem 0.6rem;
  border: 1px solid; cursor: pointer; transition: all 0.2s;
}
.status-toggle.active { color: var(--green-primary); border-color: var(--green-border); background: var(--green-glow); }
.status-toggle.inactive { color: var(--text-muted); border-color: var(--border); }
.status-dot {
  width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0;
}
.status-toggle.active .status-dot { background: var(--green-primary); }
.status-toggle.inactive .status-dot { background: var(--text-muted); }

/* ── Row actions ────────────────────────────────────────────── */
.row-actions { display: flex; gap: 0.25rem; justify-content: flex-end; }
.icon-btn {
  width: 30px; height: 30px; border-radius: var(--radius);
  background: none; border: 1px solid var(--border);
  color: var(--text-muted); display: flex; align-items: center; justify-content: center;
  transition: all 0.2s;
}
.icon-btn:hover { border-color: var(--border-light); color: var(--text-primary); background: var(--bg-card-hover); }
.icon-btn.danger:hover { color: #ef5350; border-color: rgba(239,83,80,0.4); background: rgba(239,83,80,0.08); }

/* ── Modal ──────────────────────────────────────────────────── */
.modal-sm { max-width: 400px; }
.modal-lg { max-width: 600px; }
.modal-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 1.5rem; }
.user-form { display: flex; flex-direction: column; gap: 0; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }

.pw-wrap { position: relative; }
.pw-wrap input { padding-right: 2.5rem; }
.pw-toggle {
  position: absolute; right: 0.75rem; top: 50%; transform: translateY(-50%);
  background: none; color: var(--text-muted); display: flex; align-items: center;
}
.pw-toggle:hover { color: var(--text-primary); }

.modal-actions { display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 1.5rem; }

/* ── Delete modal ───────────────────────────────────────────── */
.delete-icon-wrap {
  width: 56px; height: 56px; border-radius: 50%;
  background: rgba(239,83,80,0.1); border: 1px solid rgba(239,83,80,0.3);
  display: flex; align-items: center; justify-content: center;
  color: #ef5350; margin: 0 auto 1.25rem;
}
.delete-msg { color: var(--text-secondary); font-size: 0.9rem; text-align: center; margin-bottom: 0; line-height: 1.6; }
.delete-msg strong { color: var(--text-primary); }
.modal-title { text-align: center; }

@media (max-width: 560px) {
  .form-row { grid-template-columns: 1fr; }
  .modal-actions { flex-direction: column-reverse; }
  .modal-actions button { width: 100%; }
}
</style>
