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
              Password (for display only)
            </label>
            <input
              id="password"
              v-model.trim="password"
              type="password"
              class="form-control"
              placeholder="Enter a password"
            >
          </div>

          <button
            :disabled="loading"
            type="submit"
            class="btn-primary-enhanced"
          >
            {{ loading ? 'Creating Account...' : '<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
        </svg>Create Account' }}
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
import { usersApi } from '../api/users'

const router = useRouter()
const firstName = ref('')
const lastName = ref('')
const username = ref('')
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const onSubmit = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await usersApi.create({ username: username.value, email: email.value })
    const user = res?.data || res
    if (!user || !user.id) {
      error.value = 'Failed to create user'
      return
    }
    const withNames = { ...user, first_name: firstName.value, last_name: lastName.value }
    localStorage.setItem('currentUser', JSON.stringify(withNames))
    router.push('/dashboard')
  } catch (e) {
    error.value = 'Could not create account'
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
</style>
