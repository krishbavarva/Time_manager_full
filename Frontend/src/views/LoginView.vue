<template>
  <div class="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 flex items-center justify-center p-4 relative overflow-hidden">
    <!-- Background decoration -->
    <div class="absolute inset-0 overflow-hidden">
      <div class="absolute -top-40 -right-40 w-80 h-80 bg-gradient-to-br from-indigo-400/20 to-purple-400/20 rounded-full blur-3xl"></div>
      <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-gradient-to-br from-purple-400/20 to-pink-400/20 rounded-full blur-3xl"></div>
    </div>
    
    <div class="w-full max-w-md relative z-10">
      <!-- Logo and Title -->
      <div class="text-center mb-8">
        <div class="mx-auto w-20 h-20 rounded-3xl overflow-hidden mb-6 shadow-2xl">
          <img 
            src="/chronopulse-logo.png" 
            alt="Timemanager Logo" 
            class="w-full h-full object-cover"
          />
        </div>
        <h1 class="text-4xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent mb-3">Timemanager</h1>
        <p class="text-gray-600 text-lg">Sign in to access your dashboard</p>
        
        <!-- Success Message -->
        <div v-if="loginSuccess" class="mt-4 p-4 bg-green-50 border border-green-200 rounded-lg">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-green-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-green-800">
                Welcome back, {{ loginUser?.first_name || loginUser?.username || 'User' }}!
              </p>
              <p v-if="loginUser?.role" class="text-sm text-green-700 mt-1">
                Role: {{ loginUser.role.toUpperCase() }}
              </p>
              <p class="text-sm text-green-700 mt-2">
                <span class="inline-flex items-center">
                  <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-green-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Redirecting...
                </span>
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Login Card -->
      <div class="bg-white/80 backdrop-blur-sm rounded-3xl shadow-2xl border border-white/20 overflow-hidden">
        <div class="p-8">
          <!-- Modern Login Form -->
          <div class="space-y-6">
            <!-- Email/Username Field -->
            <div>
              <label for="login_identifier" class="block text-sm font-semibold text-gray-700 mb-3">
                Email or Username
              </label>
              <div class="relative">
                <input
                  id="login_identifier"
                  v-model="loginForm.identifier"
                  type="text"
                  required
                  class="w-full px-6 py-4 bg-white/80 backdrop-blur-sm border border-white/20 rounded-2xl shadow-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200 text-lg placeholder-gray-500"
                  placeholder="Enter your email or username"
                />
                <div class="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none">
                  <svg class="h-6 w-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                  </svg>
                </div>
              </div>
            </div>

            <!-- Password Field -->
            <div>
              <label for="login_password" class="block text-sm font-semibold text-gray-700 mb-3">
                Password
              </label>
              <div class="relative">
                <input
                  id="login_password"
                  v-model="loginForm.password"
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
            </div>

            <!-- Error Message -->
            <div v-if="loginError" class="p-3 bg-red-50 border border-red-200 rounded-xl">
              <div class="flex items-center">
                <svg class="w-5 h-5 text-red-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                <span class="text-sm text-red-700">{{ loginError }}</span>
              </div>
            </div>

            <!-- Login Button -->
            <div>
              <button
                type="submit"
                @click="handleSignin"
                class="group w-full flex justify-center items-center py-4 px-6 border border-transparent rounded-2xl shadow-xl text-lg font-semibold text-white bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl"
                :disabled="!loginForm.identifier || !loginForm.password || signingIn"
                :class="{'opacity-75 cursor-not-allowed': !loginForm.identifier || !loginForm.password || signingIn}"
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

            <!-- Demo Credentials -->
            <div class="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-xl">
              <h4 class="text-sm font-semibold text-blue-800 mb-2">Demo Credentials:</h4>
              <div class="space-y-1 text-xs text-blue-700">
                <div><strong>Admin:</strong> admin@gmail.com / admin123</div>
                <div><strong>Employee:</strong> krishbavarva168@gmail.com / 123456</div>
                <div><strong>Manager:</strong> manager@gmail.com / manager123</div>
              </div>
            </div>

            <!-- Forgot Password Link -->
            <div class="text-center">
              <a href="#" class="text-sm font-medium text-indigo-600 hover:text-indigo-700 transition-colors duration-200">
                Forgot your password?
              </a>
            </div>
          </div>
        </div>
        
        <!-- Footer -->
        <div class="bg-gradient-to-r from-gray-50/80 to-gray-100/80 backdrop-blur-sm px-6 py-4 border-t border-white/20">
          <p class="text-xs text-center text-gray-600">
            By signing in, you agree to our
            <a href="#" class="text-indigo-600 hover:text-indigo-500 font-medium">Terms</a> and
            <a href="#" class="text-indigo-600 hover:text-indigo-500 font-medium">Privacy Policy</a>.
          </p>
        </div>
      </div>
      
      <!-- Sign up link -->
      <!-- <div class="mt-6 text-center">
        <p class="text-sm text-gray-600">
          Don't have an account? 
          <a href="#" @click.prevent="onSwitchPage('signup')" class="font-medium text-indigo-600 hover:text-indigo-500">
            Sign up for free
          </a>
        </p>
      </div> -->
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { usersApi } from '../api/users'
import { http } from '../api/http'

const router = useRouter()
const loginError = ref('')
const loginSuccess = ref(false)
const loginUser = ref(null)
const signingIn = ref(false)

// Login form data
const loginForm = ref({
  identifier: '', // email or username
  password: ''
})

const handleSignin = async () => {
  loginError.value = ''
  loginSuccess.value = false
  signingIn.value = true
  
  if (!loginForm.value.identifier || !loginForm.value.password) {
    loginError.value = 'Please enter both email/username and password'
    signingIn.value = false
    return
  }
  
  try {
    const isAuthenticated = await verifyPassword(loginForm.value.identifier, loginForm.value.password)
    
    if (!isAuthenticated) {
      loginError.value = 'Invalid email/username or password'
      signingIn.value = false
      return
    }
    
    // Get user data from the authentication response
    const userData = await getUserData(loginForm.value.identifier)
    
    if (userData) {
      localStorage.setItem('currentUser', JSON.stringify(userData))
      loginUser.value = userData
      
      // Refresh the global user state immediately
      if (window.refreshUserState) {
        window.refreshUserState()
      }
    }
    
    loginSuccess.value = true
    setTimeout(() => router.push('/dashboard'), 1500)
    
  } catch (err) {
    console.error('Login error:', err)
    loginError.value = err.message || 'An error occurred during login. Please try again.'
  } finally {
    signingIn.value = false
  }
}

// ✅ Use http client for API call
const verifyPassword = async (identifier, password) => {
  try {
    const response = await http.post('/api/sessions', { email: identifier, password })

    // Store the token in localStorage
    if (response?.data?.token) {
      localStorage.setItem('authToken', response.data.token)
      return true
    }

    return false
  } catch (error) {
    console.error('Authentication error:', error)
    throw error
  }
}

// Get user data by email or username
const getUserData = async (identifier) => {
  try {
    // First try to get all users and find by email or username
    const response = await usersApi.list()
    const users = Array.isArray(response) ? response : (Array.isArray(response?.data) ? response.data : [])
    
    // Find user by email or username
    const user = users.find(u => 
      u.email === identifier || 
      u.username === identifier ||
      u.email?.toLowerCase() === identifier.toLowerCase() ||
      u.username?.toLowerCase() === identifier.toLowerCase()
    )
    
    if (user) {
      return {
        id: user.id,
        email: user.email,
        username: user.username,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role
      }
    }
    
    return null
  } catch (error) {
    console.error('Failed to get user data:', error)
    throw error
  }
}
</script>
