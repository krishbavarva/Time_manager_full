<template>
  <div class="admin-users">
    <div class="header">
      <h1>User Management</h1>
      <div class="actions">
        <button @click="showAddUser = true" class="btn-primary">
          <span class="icon">+</span> Add User
        </button>
      </div>
    </div>

    <div class="card">
      <div v-if="loading" class="loading">Loading users...</div>
      <div v-else-if="error" class="error">{{ error }}</div>
      <table v-else class="users-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id">
            <td>{{ user.first_name }} {{ user.last_name }}</td>
            <td>{{ user.email }}</td>
            <td>
              <span class="role-badge" :class="user.role?.toLowerCase()">
                {{ user.role?.toUpperCase() || 'USER' }}
              </span>
            </td>
            <td class="actions">
              <button @click="editUser(user)" class="icon-btn" title="Edit">✏️</button>
              <button 
                v-if="currentUser.id !== user.id" 
                @click="confirmDelete(user)" 
                class="icon-btn danger" 
                title="Delete">
                🗑️
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Add/Edit User Modal -->
    <div v-if="showAddUser || editingUser" class="modal-backdrop" @click.self="closeModal">
      <div class="modal">
        <h2>{{ editingUser ? 'Edit User' : 'Add New User' }}</h2>
        <form @submit.prevent="saveUser">
          <div class="form-group">
            <label>First Name</label>
            <input v-model="userForm.first_name" required>
          </div>
          <div class="form-group">
            <label>Last Name</label>
            <input v-model="userForm.last_name" required>
          </div>
          <div class="form-group">
            <label>Email</label>
            <input v-model="userForm.email" type="email" required>
          </div>
          <div class="form-group">
            <label>Username</label>
            <input v-model="userForm.username" required>
          </div>
          <div class="form-group">
            <label>Role</label>
            <select v-model="userForm.role" required>
              <option value="employee">Employee</option>
              <option value="manager">Manager</option>
              <option value="admin">Administrator</option>
            </select>
          </div>
          <div class="form-group">
            <label>Password</label>
            <input v-model="userForm.password" type="password" :required="!editingUser">
            <small v-if="editingUser">Leave blank to keep current password</small>
          </div>
          <div class="form-actions">
            <button type="button" @click="closeModal" class="btn-secondary">Cancel</button>
            <button type="submit" class="btn-primary">
              {{ editingUser ? 'Update' : 'Create' }} User
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="userToDelete" class="modal-backdrop" @click.self="userToDelete = null">
      <div class="modal">
        <h2>Confirm Deletion</h2>
        <p>Are you sure you want to delete user: <strong>{{ userToDelete.first_name }} {{ userToDelete.last_name }}</strong>?</p>
        <div class="form-actions">
          <button @click="userToDelete = null" class="btn-secondary">Cancel</button>
          <button @click="deleteUser" class="btn-danger">Delete</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { usersApi } from '../api/users'
import { useRouter } from 'vue-router'

const router = useRouter()
const users = ref([])
const loading = ref(true)
const error = ref('')
const showAddUser = ref(false)
const editingUser = ref(null)
const userToDelete = ref(null)
const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')

const userForm = ref({
  first_name: '',
  last_name: '',
  email: '',
  username: '',
  role: 'employee',
  password: ''
})

// Load users
const loadUsers = async () => {
  loading.value = true
  try {
    const response = await usersApi.list()
    users.value = Array.isArray(response) ? response : (Array.isArray(response?.data) ? response.data : [])
  } catch (err) {
    error.value = 'Failed to load users. Please try again.'
    console.error('Error loading users:', err)
  } finally {
    loading.value = false
  }
}

// Save or update user
const saveUser = async () => {
  try {
    const userData = { ...userForm.value }
    
    // Remove password if empty (for updates)
    if (editingUser.value && !userData.password) {
      delete userData.password
    }
    
    if (editingUser.value) {
      await usersApi.update(editingUser.value.id, userData)
    } else {
      await usersApi.create(userData)
    }
    
    closeModal()
    loadUsers()
  } catch (err) {
    error.value = err.message || 'Failed to save user. Please try again.'
    console.error('Error saving user:', err)
  }
}

// Delete user
const deleteUser = async () => {
  if (!userToDelete.value) return
  
  try {
    await usersApi.delete(userToDelete.value.id)
    userToDelete.value = null
    loadUsers()
  } catch (err) {
    error.value = 'Failed to delete user. Please try again.'
    console.error('Error deleting user:', err)
  }
}

// Edit user
const editUser = (user) => {
  editingUser.value = user
  userForm.value = {
    first_name: user.first_name,
    last_name: user.last_name,
    email: user.email,
    username: user.username,
    role: user.role || 'employee',
    password: ''
  }
}

// Confirm delete
const confirmDelete = (user) => {
  userToDelete.value = user
}

// Close modal and reset form
const closeModal = () => {
  showAddUser.value = false
  editingUser.value = null
  userForm.value = {
    first_name: '',
    last_name: '',
    email: '',
    username: '',
    role: 'employee',
    password: ''
  }
}

onMounted(() => {
  // Check if user is admin
  if (currentUser.role !== 'admin') {
    router.push('/dashboard')
    return
  }
  
  loadUsers()
})
</script>

<style scoped>
.admin-users {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 24px;
  margin-bottom: 24px;
}

.users-table {
  width: 100%;
  border-collapse: collapse;
}

.users-table th,
.users-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.users-table th {
  font-weight: 600;
  color: #555;
  background-color: #f9fafb;
}

.role-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  text-transform: uppercase;
}

.role-badge.admin {
  background-color: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.role-badge.manager {
  background-color: #eff6ff;
  color: #2563eb;
  border: 1px solid #bfdbfe;
}

.role-badge.employee {
  background-color: #f0fdf4;
  color: #16a34a;
  border: 1px solid #bbf7d0;
}

.actions {
  display: flex;
  gap: 8px;
}

.icon-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.icon-btn:hover {
  background-color: #f3f4f6;
}

.icon-btn.danger:hover {
  background-color: #fee2e2;
  color: #dc2626;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  font-weight: 500;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 14px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 24px;
}

.btn-primary {
  background-color: #2563eb;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.btn-primary:hover {
  background-color: #1d4ed8;
}

.btn-secondary {
  background-color: #f3f4f6;
  color: #4b5563;
  border: 1px solid #d1d5db;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.btn-secondary:hover {
  background-color: #e5e7eb;
}

.btn-danger {
  background-color: #dc2626;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.btn-danger:hover {
  background-color: #b91c1c;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal {
  background: white;
  border-radius: 8px;
  padding: 24px;
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal h2 {
  margin-top: 0;
  margin-bottom: 20px;
  font-size: 1.5rem;
  color: #111827;
}

.loading,
.error {
  padding: 16px;
  text-align: center;
  color: #6b7280;
}

.error {
  color: #dc2626;
}
</style>
