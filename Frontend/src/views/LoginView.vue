<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <!-- Logo and Title -->
      <div class="text-center mb-8">
        <div class="mx-auto w-16 h-16 bg-indigo-600 rounded-2xl flex items-center justify-center mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Time Manager</h1>
        <p class="text-gray-600">Sign in to access your dashboard</p>
        
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
      <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="p-8">
          <LoginPage
            :users="users"
            :usersLoading="loading"
            :usersError="error"
            :loginError="loginError"
            @signin="handleSignin"
            @switch-page="onSwitchPage"
          />
        </div>
        
        <!-- Footer -->
        <div class="bg-gray-50 px-6 py-4 border-t border-gray-200">
          <p class="text-xs text-center text-gray-500">
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
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { usersApi } from '../api/users'
import LoginPage from '../components/loginPage.vue'
import { getCurrentLocation } from '../utils/geolocation'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const loginError = ref('')
const loginSuccess = ref(false)
const loginUser = ref(null)
const users = ref([])

onMounted(async () => {
  loading.value = true
  try {
    const res = await usersApi.list()
    users.value = Array.isArray(res) ? res : (Array.isArray(res?.data) ? res.data : [])
  } catch (_) {
    error.value = 'Failed to load users'
  } finally {
    loading.value = false
  }
})

const handleSignin = async ({ email, password }) => {
  loginError.value = ''
  loginSuccess.value = false
  
  if (!email || !password) {
    loginError.value = 'Please enter both email and password'
    return
  }
  
  try {
    // Verify password with the backend and get user data
    const isAuthenticated = await verifyPassword(email, password)
    
    if (!isAuthenticated) {
      loginError.value = 'Invalid email or password'
      return
    }
    
    // Find user in the local users list (or fetch fresh user data from the server)
    const user = users.value.find(u => u.email === email)
    
    if (user) {
      // Store user data (without sensitive information)
      const userData = {
        id: user.id,
        email: user.email,
        username: user.username,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role
      }
      
      localStorage.setItem('currentUser', JSON.stringify(userData))
      loginUser.value = userData
      
      // Refresh the global user state immediately
      if (window.refreshUserState) {
        window.refreshUserState()
      }
    }
    
    loginSuccess.value = true
    
    // Redirect to dashboard after a short delay
    setTimeout(() => {
      router.push('/dashboard')
    }, 1500)
    
  } catch (err) {
    console.error('Login error:', err)
    loginError.value = err.message || 'An error occurred during login. Please try again.'
  }
}

const verifyPassword = async (email, password) => {
  try {
    const response = await fetch('/api/sessions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    })

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error || 'Authentication failed')
    }

    const data = await response.json()
    
    // Store the token in localStorage
    if (data.data && data.data.token) {
      localStorage.setItem('authToken', data.data.token)
      return true
    }
    
    return false
  } catch (error) {
    console.error('Authentication error:', error)
    throw error
  }
}

const onSwitchPage = (page) => {
  if (page === 'signup') router.push('/signup')
}
</script>
