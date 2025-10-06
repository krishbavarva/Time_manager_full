<template>
  <div class="container mx-auto py-12 px-4 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <div class="text-center">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Time Manager</h1>
        <p class="text-sm text-gray-600">Create your account</p>
      </div>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-white py-8 px-4 shadow-sm border border-gray-200 rounded-lg sm:px-10">
        <form @submit.prevent="onSubmit" class="space-y-6">
          <div>
            <label for="firstName" class="block text-sm font-medium text-gray-700 mb-2">
              First Name
            </label>
            <input
              id="firstName"
              v-model.trim="firstName"
              type="text"
              required
              class="form-control"
              placeholder="Enter your first name"
            >
          </div>

          <div>
            <label for="lastName" class="block text-sm font-medium text-gray-700 mb-2">
              Last Name
            </label>
            <input
              id="lastName"
              v-model.trim="lastName"
              type="text"
              required
              class="form-control"
              placeholder="Enter your last name"
            >
          </div>

          <div>
            <label for="username" class="block text-sm font-medium text-gray-700 mb-2">
              Username
            </label>
            <input
              id="username"
              v-model.trim="username"
              type="text"
              required
              class="form-control"
              placeholder="Choose a username"
            >
          </div>

          <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
              Email Address
            </label>
            <input
              id="email"
              v-model.trim="email"
              type="email"
              required
              class="form-control"
              placeholder="Enter your email"
            >
          </div>

          <div>
            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
              Password
            </label>
            <input
              id="password"
              v-model.trim="password"
              type="password"
              required
              minlength="6"
              class="form-control"
              placeholder="Enter a strong password (min 6 characters)"
            >
            <p class="text-xs text-gray-500 mt-1">Password must be at least 6 characters long</p>
          </div>

          <div>
            <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">
              Confirm Password
            </label>
            <input
              id="confirmPassword"
              v-model.trim="confirmPassword"
              type="password"
              required
              class="form-control"
              placeholder="Confirm your password"
            >
          </div>

          <div>
            <label for="role" class="block text-sm font-medium text-gray-700 mb-2">
              Account Type
            </label>
            <select
              id="role"
              v-model="selectedRole"
              required
              class="form-control"
            >
              <option value="" disabled>Select account type</option>
              <option value="employee">Employee</option>
              <option value="manager">Manager</option>
              <option value="admin">Administrator</option>
            </select>
            <p class="text-xs text-gray-500 mt-1">Managers can manage teams, employees can only track time</p>
          </div>

          <button
            :disabled="loading"
            type="submit"
            class="submit-button"
          >
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
            </svg>
            {{ loading ? 'Creating Account...' : 'Create Account' }}
          </button>

          <div v-if="error" class="error">
            {{ error }}
          </div>

          <div class="text-center">
            <p class="text-sm text-gray-600">
              Already have an account?
              <RouterLink to="/login" class="font-medium text-blue-600 hover:text-blue-500">
                Sign In
              </RouterLink>
            </p>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { usersApi, ROLES } from '../api/users'

const router = useRouter()
const firstName = ref('')
const lastName = ref('')
const username = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const selectedRole = ref('employee') // Default role
const loading = ref(false)
const error = ref('')

const onSubmit = async () => {
  loading.value = true
  error.value = ''

  // Validation
  if (!firstName.value || !lastName.value || !username.value || !email.value || !password.value) {
    error.value = 'Please fill in all required fields'
    loading.value = false
    return
  }

  // Password validation
  if (password.value.length < 6) {
    error.value = 'Password must be at least 6 characters long'
    loading.value = false
    return
  }

  // Check if passwords match
  if (password.value !== confirmPassword.value) {
    error.value = 'Passwords do not match'
    loading.value = false
    return
  }

  try {
    const userData = {
      username: username.value,
      email: email.value,
      first_name: firstName.value,
      last_name: lastName.value,
      password: password.value,
      role: selectedRole.value
    }
    
    console.log('Sending signup request:', { ...userData, password: '***' })
    const res = await usersApi.create(userData)
    console.log('Signup response:', res)
    
    const user = res?.data || res
    if (!user || !user.id) {
      error.value = 'Failed to create user - no user ID returned'
      console.error('API response:', res)
      return
    }
    
    // Don't log in automatically, redirect to login page
    router.push({
      path: '/login',
      query: { registered: 'true' }
    })
  } catch (e) {
    console.error('Signup error:', e)
    error.value = e.message || 'Could not create account. Please try again.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.btn-primary-enhanced svg {
  width: 1.25rem;
  height: 1.25rem;
  flex-shrink: 0;
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

.submit-button svg {
  width: 1.25rem;
  height: 1.25rem;
  flex-shrink: 0;
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
</style>
