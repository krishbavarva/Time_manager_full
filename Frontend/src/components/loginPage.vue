<template>
  <div class="space-y-8">
    <!-- Step 1: Choose a user -->
    <div v-if="!selectedUser">
      <div class="text-center mb-8">
        <div class="mb-6">
          <div class="mx-auto w-16 h-16 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-2xl flex items-center justify-center shadow-xl">
            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
            </svg>
          </div>
        </div>
        <h2 class="text-3xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent mb-2">Welcome to Timemanager</h2>
        <p class="text-gray-600 text-lg">Choose an account to continue</p>
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
      <div v-else-if="users && users.length" class="space-y-4">
        <button
          v-for="(u, idx) in users"
          :key="idx"
          @click="selectUser(u)"
          class="group w-full flex items-center p-6 bg-white/80 backdrop-blur-sm rounded-2xl border border-white/20 shadow-lg hover:shadow-2xl hover:-translate-y-1 transition-all duration-300 relative overflow-hidden"
        >
          <div class="absolute inset-0 bg-gradient-to-r from-indigo-500/5 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          <div class="relative z-10 flex items-center w-full">
            <div 
              class="flex-shrink-0 h-14 w-14 rounded-2xl flex items-center justify-center text-white font-bold text-lg shadow-lg"
              :class="{
                'bg-gradient-to-br from-purple-500 to-purple-600': u.role?.toLowerCase() === 'admin',
                'bg-gradient-to-br from-blue-500 to-blue-600': u.role?.toLowerCase() === 'manager',
                'bg-gradient-to-br from-emerald-500 to-emerald-600': u.role?.toLowerCase() === 'employee',
                'bg-gradient-to-br from-gray-500 to-gray-600': !u.role
              }"
            >
              {{ initials(u) }}
            </div>
            <div class="ml-6 text-left flex-1 min-w-0">
              <div class="flex items-center justify-between mb-1">
                <p class="text-lg font-semibold text-gray-900 truncate">{{ displayName(u) }}</p>
                <span 
                  class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold shadow-sm"
                  :class="{
                    'bg-gradient-to-r from-purple-500 to-purple-600 text-white': u.role?.toLowerCase() === 'admin',
                    'bg-gradient-to-r from-blue-500 to-blue-600 text-white': u.role?.toLowerCase() === 'manager',
                    'bg-gradient-to-r from-emerald-500 to-emerald-600 text-white': u.role?.toLowerCase() === 'employee',
                    'bg-gradient-to-r from-gray-500 to-gray-600 text-white': !u.role
                  }"
                >
                  {{ u.role ? u.role.toUpperCase() : 'USER' }}
                </span>
              </div>
              <p class="text-sm text-gray-600 truncate">{{ u.email }}</p>
            </div>
            <div class="ml-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              <svg class="w-5 h-5 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
              </svg>
            </div>
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
      <div class="flex items-center justify-between mb-8">
        <div>
          <h2 class="text-3xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">Welcome back</h2>
          <p class="text-gray-600 mt-1">Enter your password to continue</p>
        </div>
        <button
          type="button"
          @click="selectedUser = null"
          class="group px-4 py-2 text-sm font-medium text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50 rounded-xl transition-all duration-200 focus:outline-none"
        >
          <svg class="w-4 h-4 inline mr-1 group-hover:-translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
          Change user
        </button>
      </div>

      <div class="flex items-center p-6 bg-white/80 backdrop-blur-sm rounded-2xl border border-white/20 shadow-lg mb-8">
        <div 
          class="flex-shrink-0 h-16 w-16 rounded-2xl flex items-center justify-center text-white font-bold text-xl shadow-lg"
          :class="{
            'bg-gradient-to-br from-purple-500 to-purple-600': selectedUser.role?.toLowerCase() === 'admin',
            'bg-gradient-to-br from-blue-500 to-blue-600': selectedUser.role?.toLowerCase() === 'manager',
            'bg-gradient-to-br from-emerald-500 to-emerald-600': selectedUser.role?.toLowerCase() === 'employee',
            'bg-gradient-to-br from-gray-500 to-gray-600': !selectedUser.role
          }"
        >
          {{ initials(selectedUser) }}
        </div>
        <div class="ml-6">
          <p class="text-lg font-semibold text-gray-900">{{ displayName(selectedUser) }}</p>
          <p class="text-sm text-gray-600">{{ selectedUser.email }}</p>
          <span 
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium mt-2"
            :class="{
              'bg-gradient-to-r from-purple-500 to-purple-600 text-white': selectedUser.role?.toLowerCase() === 'admin',
              'bg-gradient-to-r from-blue-500 to-blue-600 text-white': selectedUser.role?.toLowerCase() === 'manager',
              'bg-gradient-to-r from-emerald-500 to-emerald-600 text-white': selectedUser.role?.toLowerCase() === 'employee',
              'bg-gradient-to-r from-gray-500 to-gray-600 text-white': !selectedUser.role
            }"
          >
            {{ selectedUser.role ? selectedUser.role.toUpperCase() : 'USER' }}
          </span>
        </div>
      </div>

      <form @submit.prevent="handleSignin" class="space-y-8">
        <div>
          <label for="signin_password" class="block text-sm font-semibold text-gray-700 mb-3">
            Password
          </label>
          <div class="relative">
            <input
              id="signin_password"
              v-model="signinForm.password"
              type="password"
              required
              class="w-full px-6 py-4 bg-white/80 backdrop-blur-sm border border-white/20 rounded-2xl shadow-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200 text-lg placeholder-gray-500"
              placeholder="Enter your password"
            />
            <div class="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none">
              <svg class="h-6 w-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
            </div>
          </div>
          
          <!-- Error Message -->
          <div v-if="loginError" class="mt-3 p-3 bg-red-50 border border-red-200 rounded-xl">
            <div class="flex items-center">
              <svg class="w-5 h-5 text-red-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span class="text-sm text-red-700">{{ loginError }}</span>
            </div>
          </div>
          
          <div class="mt-4 text-right">
            <a href="#" class="text-sm font-medium text-indigo-600 hover:text-indigo-700 transition-colors duration-200">
              Forgot password?
            </a>
          </div>
        </div>

        <div>
          <button
            type="submit"
            class="group w-full flex justify-center items-center py-4 px-6 border border-transparent rounded-2xl shadow-xl text-lg font-semibold text-white bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl"
            :disabled="!signinForm.password || signingIn"
            :class="{'opacity-75 cursor-not-allowed': !signinForm.password || signingIn}"
          >
            <svg v-if="!signingIn" class="h-6 w-6 mr-3 group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
            </svg>
            <svg v-else class="animate-spin h-6 w-6 mr-3" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            {{ signingIn ? 'Signing in...' : 'Sign in' }}
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
