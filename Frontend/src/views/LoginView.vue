<template>
  <section class="wrap">
    <LoginPage
      :users="users"
      :usersLoading="loading"
      :usersError="error"
      :loginError="loginError"
      @signin="handleSignin"
      @switch-page="onSwitchPage"
    />
  </section>
  
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
  // Backend has no password field, accept any non-empty password
  const user = users.value.find(u => u.email === email)
  if (!user) { loginError.value = 'Invalid email'; return }
  if (!password) { loginError.value = 'Please enter password'; return }
  
  try {
    // Request location permission
    loginError.value = 'Getting your location...';
    await getCurrentLocation();
    
    // Store user data and redirect
    localStorage.setItem('currentUser', JSON.stringify(user));
    router.push('/dashboard');
  } catch (error) {
    console.warn('Location access was not granted, continuing without location data');
    // Continue with login even if location access is denied
    localStorage.setItem('currentUser', JSON.stringify(user));
    router.push('/dashboard');
  } finally {
    loginError.value = '';
  }
}

const onSwitchPage = (page) => {
  if (page === 'signup') router.push('/signup')
}
</script>

<style scoped>
.wrap { max-width: 520px; margin: 3rem auto; padding: 0 1rem; }
</style>
