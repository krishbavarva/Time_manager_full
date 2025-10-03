<template>
  <div class="page-transition">
    <h2 class="title">Sign In</h2>

    <!-- Step 1: Choose a user -->
    <div v-if="!selectedUser" class="users-list">
      <p class="hint">Choose your user</p>

      <div v-if="usersLoading" class="loading">Loading users…</div>
      <p v-else-if="usersError" class="error-message">{{ usersError }}</p>
      <template v-else>
        <div v-if="users && users.length" class="user-chips">
          <button
            v-for="(u, idx) in users"
            :key="idx"
            class="user-chip"
            @click="selectUser(u)"
          >
            {{ displayName(u) }}
            <span class="email">{{ u.email }}</span>
          </button>
        </div>
        <p v-else class="hint">No users found.</p>
      </template>

      <p class="link-text">Don't have an account? <a href="#" @click.prevent="$emit('switch-page', 'signup')" class="link-anchor">Sign Up</a></p>
    </div>

    <!-- Step 2: Enter password for the selected user -->
    <form v-else @submit.prevent="handleSignin">
      <div class="selected-user">
        <span class="avatar">{{ initials(selectedUser) }}</span>
        <div class="user-meta">
          <div class="name">{{ displayName(selectedUser) }}</div>
          <div class="email">{{ selectedUser.email }}</div>
        </div>
        <button type="button" class="change-user" @click="selectedUser = null">Change</button>
      </div>
      <div class="input-group">
        <label class="input-label" for="signin_password">Password</label>
        <input class="input-field" type="password" id="signin_password" v-model="signinForm.password" required>
        <p v-if="loginError" class="error-message">{{ loginError }}</p>
      </div>
      <button type="submit" class="submit-button">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path>
        </svg>
        Sign In
      </button>
    </form>
  </div>
</template>

<script>
export default {
  name: 'LoginPage',
  props: {
    users: {
      type: Array,
      default: () => []
    },
    usersLoading: {
      type: Boolean,
      default: false
    },
    usersError: {
      type: String,
      default: ''
    },
    loginError: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      selectedUser: null,
      signinForm: {
        password: ''
      }
    };
  },
  methods: {
    initials(u) {
      const base = (u.username || u.email || '')
      const parts = String(base).split(/[\s._-]+/).filter(Boolean)
      if (parts.length >= 2) return `${parts[0][0] || ''}${parts[1][0] || ''}`.toUpperCase()
      return String(base).slice(0, 2).toUpperCase()
    },
    displayName(u) {
      return u.username || u.email || 'User'
    },
    selectUser(u) {
      this.selectedUser = u
      this.signinForm.password = ''
    },
    handleSignin() {
      if (!this.selectedUser) return
      this.$emit('signin', { email: this.selectedUser.email, password: this.signinForm.password });
    }
  }
};
</script>

<style scoped>
.page-transition {
  transition: opacity 0.5s ease-in-out;
}
.title {
  font-size: 1.875rem;
  font-weight: bold;
  margin-bottom: 1.5rem;
  text-align: center;
  color: #111827;
}
.input-group {
  margin-bottom: 1rem;
}
.input-label {
  display: block;
  color: #374151;
  font-size: 0.875rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}
.input-field {
  width: 100%;
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  background-color: #ffffff;
  color: #111827;
  border: 1px solid #d1d5db;
  transition: all 0.3s ease;
  font-size: 1rem;
}
.input-field:focus {
  border-color: #2563eb;
  outline: none;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}
.error-message {
  color: #dc2626;
  font-size: 0.75rem;
  margin-top: 0.5rem;
}
.submit-button {
  width: 100%;
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  color: #ffffff;
  font-weight: bold;
  padding: 0.75rem 1.5rem;
  border-radius: 0.5rem;
  border: 2px solid transparent;
  font-size: 1rem;
  transition: all 0.3s ease;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  background-size: 200% 200%;
  animation: gradientShift 3s ease-in-out infinite;
}

.submit-button::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  background: linear-gradient(45deg,
    #2563eb,
    #1d4ed8,
    #3b82f6,
    #60a5fa,
    #2563eb,
    #1d4ed8
  );
  border-radius: 0.75rem;
  z-index: -1;
  animation: glowingBorder 2s linear infinite;
  background-size: 400% 400%;
}

.submit-button::after {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  background: linear-gradient(45deg,
    transparent 30%,
    rgba(255, 255, 255, 0.3) 50%,
    transparent 70%
  );
  border-radius: 0.75rem;
  z-index: -1;
  animation: lightningMove 1.5s ease-in-out infinite;
  opacity: 0.8;
}

.submit-button:hover {
  background-position: right center;
  transform: translateY(-2px) scale(1.02);
  box-shadow: 0 8px 16px rgba(37, 99, 235, 0.3);
}

.submit-button:hover::before {
  animation-duration: 1s;
}

.submit-button:hover::after {
  animation-duration: 1s;
  opacity: 1;
}

.submit-button:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.3), 0 4px 8px rgba(37, 99, 235, 0.2);
}

.submit-button:disabled {
  background: #9ca3af;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
  animation: none;
}

.submit-button:disabled::before,
.submit-button:disabled::after {
  animation: none;
  opacity: 0.5;
}

@keyframes gradientShift {
  0%, 100% {
    background-position: left center;
  }
  50% {
    background-position: right center;
  }
}

@keyframes glowingBorder {
  0%, 100% {
    background-position: 0% 50%;
    opacity: 0.8;
  }
  50% {
    background-position: 100% 50%;
    opacity: 1;
  }
}

@keyframes lightningMove {
  0% {
    background-position: -200% 0;
    opacity: 0;
  }
  50% {
    opacity: 0.8;
  }
  100% {
    background-position: 200% 0;
    opacity: 0;
  }
}
.link-text {
  margin-top: 1rem;
  text-align: center;
  color: #6b7280;
}
.link-anchor {
  color: #2563eb;
  text-decoration: none;
  font-weight: 500;
}
.link-anchor:hover {
  color: #1d4ed8;
  text-decoration: underline;
}

/* Additional styles for user picker */
.users-list { margin-top: 0.5rem; }
.hint { color: #6b7280; font-size: 0.875rem; }
.loading { color: #6b7280; }
.user-chips { display: flex; flex-direction: column; gap: 0.5rem; }
.user-chip {
  width: 100%;
  text-align: left;
  background-color: #ffffff;
  color: #111827;
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  border: 1px solid #e5e7eb;
  transition: all 0.2s ease;
  cursor: pointer;
  font-size: 0.875rem;
}
.user-chip:hover {
  background-color: #f9fafb;
  border-color: #d1d5db;
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
.user-chip .email {
  display: block;
  font-size: 0.75rem;
  color: #6b7280;
  margin-top: 0.25rem;
}

.selected-user {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background-color: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  padding: 0.75rem;
  margin-bottom: 1rem;
}
.selected-user .avatar {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 9999px;
  background-color: #2563eb;
  color: #ffffff;
  font-weight: 700;
  font-size: 0.875rem;
}
.selected-user .user-meta .name {
  color: #111827;
  font-weight: 600;
  font-size: 0.875rem;
}
.selected-user .user-meta .email {
  color: #6b7280;
  font-size: 0.75rem;
}
.selected-user .change-user {
  color: #2563eb;
  font-size: 0.875rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  transition: all 0.2s ease;
}
.submit-button svg {
  width: 1.25rem;
  height: 1.25rem;
  flex-shrink: 0;
}
</style>
