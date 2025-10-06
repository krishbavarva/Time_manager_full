<template>
  <div class="space-y-6">
    <!-- Step 1: Choose a user -->
    <div v-if="!selectedUser">
      <div class="text-center mb-6">
        <h2 class="text-2xl font-bold text-gray-900">Select an account</h2>
        <p class="mt-1 text-sm text-gray-500">Choose an account to continue</p>
      </div>

      <!-- Loading State -->
      <div v-if="usersLoading" class="space-y-4">
        <div v-for="i in 3" :key="`skeleton-${i}`" class="animate-pulse">
          <div class="h-16 bg-gray-100 rounded-lg"></div>
        </div>
      </div>

      <!-- Error State -->
      <div v-else-if="usersError" class="rounded-md bg-red-50 p-4 mb-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-red-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <h3 class="text-sm font-medium text-red-800">{{ usersError }}</h3>
          </div>
        </div>
      </div>

      <!-- User List -->
      <div v-else-if="users && users.length" class="space-y-3">
        <button
          v-for="(u, idx) in users"
          :key="idx"
          @click="selectUser(u)"
          class="w-full flex items-center p-4 rounded-lg border border-gray-200 hover:border-indigo-300 hover:bg-indigo-50 transition-colors duration-200"
        >
          <div class="flex-shrink-0 h-10 w-10 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 font-medium">
            {{ initials(u) }}
          </div>
          <div class="ml-4 text-left flex-1 min-w-0">
            <div class="flex items-center justify-between">
              <p class="text-sm font-medium text-gray-900 truncate">{{ displayName(u) }}</p>
              <span 
                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                :class="{
                  'bg-purple-100 text-purple-800': u.role?.toLowerCase() === 'admin',
                  'bg-blue-100 text-blue-800': u.role?.toLowerCase() === 'user',
                  'bg-gray-100 text-gray-800': !u.role
                }"
              >
                {{ u.role ? u.role.toUpperCase() : 'USER' }}
              </span>
            </div>
            <p class="text-sm text-gray-500 truncate">{{ u.email }}</p>
          </div>
        </button>
      </div>
      
      <!-- Empty State -->
      <div v-else class="text-center py-8">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
        </svg>
        <h3 class="mt-2 text-sm font-medium text-gray-900">No users found</h3>
        <p class="mt-1 text-sm text-gray-500">Get started by creating a new account.</p>
        <div class="mt-6">
          <button
            type="button"
            @click="$emit('switch-page', 'signup')"
            class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            <svg class="-ml-1 mr-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z" clip-rule="evenodd" />
            </svg>
            New Account
          </button>
        </div>
      </div>
    </div>

    <!-- Step 2: Enter password for the selected user -->
    <div v-else>
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-gray-900">Welcome back</h2>
        <button
          type="button"
          @click="selectedUser = null"
          class="text-sm font-medium text-indigo-600 hover:text-indigo-500 focus:outline-none"
        >
          Change user
        </button>
      </div>

      <div class="flex items-center p-4 bg-indigo-50 rounded-lg mb-6">
        <div class="flex-shrink-0 h-12 w-12 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 font-medium text-lg">
          {{ initials(selectedUser) }}
        </div>
        <div class="ml-4">
          <p class="text-sm font-medium text-gray-900">{{ displayName(selectedUser) }}</p>
          <p class="text-sm text-gray-500">{{ selectedUser.email }}</p>
        </div>
      </div>

      <form @submit.prevent="handleSignin" class="space-y-6">
        <div>
          <label for="signin_password" class="block text-sm font-medium text-gray-700 mb-1">
            Password
          </label>
          <div class="mt-1 relative rounded-md shadow-sm">
            <input
              id="signin_password"
              v-model="signinForm.password"
              type="password"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors duration-200"
              placeholder="Enter your password"
            />
            <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
              <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd" />
              </svg>
            </div>
          </div>
          
          <!-- Error Message -->
          <div v-if="loginError" class="mt-1 text-sm text-red-600">
            {{ loginError }}
          </div>
          
          <div class="mt-2 text-right">
            <a href="#" class="text-sm font-medium text-indigo-600 hover:text-indigo-500">
              Forgot password?
            </a>
          </div>
        </div>

        <div>
          <button
            type="submit"
            class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-gradient-to-r from-indigo-600 to-blue-700 hover:from-indigo-700 hover:to-blue-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-200"
            :disabled="!signinForm.password"
            :class="{'opacity-75 cursor-not-allowed': !signinForm.password}"
          >
            <svg class="h-5 w-5 mr-2 -ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
            </svg>
            Sign in
          </button>
        </div>
      </form>
    </div>
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
    initials(user) {
      if (!user) return '??';
      const name = user.first_name || user.username || user.email || '';
      return name
        .split(' ')
        .map(part => part ? part[0].toUpperCase() : '')
        .slice(0, 2)
        .join('');
    },
    displayName(user) {
      if (!user) return 'Unknown User';
      return user.first_name || user.username || user.email || 'User';
    },
    selectUser(user) {
      this.selectedUser = user;
      this.signinForm.password = '';
      // Focus the password input after a short delay to allow the DOM to update
      this.$nextTick(() => {
        const passwordInput = document.getElementById('signin_password');
        if (passwordInput) passwordInput.focus();
      });
    },
    handleSignin() {
      if (!this.selectedUser || !this.signinForm.password) return;
      this.$emit('signin', {
        email: this.selectedUser.email,
        password: this.signinForm.password
      });
    }
  },
  watch: {
    // Clear the password when the selected user changes
    selectedUser() {
      this.signinForm.password = '';
    },
    // Clear the selected user when the users list changes
    users() {
      this.selectedUser = null;
    }
  }
};
</script>

<style scoped>
/* All styles are now handled by Tailwind CSS utility classes */
</style>
