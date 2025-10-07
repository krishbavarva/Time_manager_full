<template>
  <div id="app">
    <header class="topbar">
      <nav class="nav">
        <div class="nav-links">
          <RouterLink to="/dashboard">Dashboard</RouterLink>
          <RouterLink to="/working-times">Working Times</RouterLink>
          <RouterLink to="/clockins">Clockins</RouterLink>
        </div>
        <div class="nav-actions">
          <a href="#" class="logout-btn" @click.prevent="handleLogout">Logout</a>
        </div>
      </nav>
    </header>

    <main class="content">
      <RouterView />
    </main>

    <!-- Floating Chatbot Button -->
    <div class="chatbot-float" v-if="$route.path !== '/chat'">
      <button @click="$router.push('/chat')" class="chatbot-button" title="Open Chat Assistant">
        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" class="chatbot-icon">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z">
          </path>
        </svg>
        <span class="chatbot-pulse"></span>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, RouterLink, RouterView } from 'vue-router'
import { usersApi } from './api/users'

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

const handleLogout = () => {
  localStorage.removeItem('currentUser')
  localStorage.removeItem('authToken')
  router.push('/login')
}

// Verify password against backend
const verifyPassword = async (email, password) => {
  try {
    const data = await usersApi.login(email, password)
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

const handleSignin = async ({ email, password }) => {
  loginError.value = ''
  loginSuccess.value = false

  if (!email || !password) {
    loginError.value = 'Please enter both email and password'
    return
  }

  try {
    const isAuthenticated = await verifyPassword(email, password)

    if (!isAuthenticated) {
      loginError.value = 'Invalid email or password'
      return
    }

    const user = users.value.find(u => u.email === email)
    if (user) {
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
    }

    loginSuccess.value = true

    setTimeout(() => {
      router.push('/dashboard')
    }, 1500)

  } catch (err) {
    console.error('Login error:', err)
    loginError.value = err.message || 'An error occurred during login. Please try again.'
  }
}
</script>

<style>
/* Full styling same as your previous App.vue */
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body, #app { height: 100vh; width: 100%; overflow-x: hidden; }
#app { display: flex; flex-direction: column; min-height: 100vh; }

.topbar { background-color: #ffffff; box-shadow: 0 1px 3px rgba(0,0,0,0.1); position: sticky; top: 0; z-index: 50; border-bottom: 1px solid #e5e7eb; }
.nav { margin: 0 auto; padding: 0.75rem 1rem; display: flex; align-items: center; gap: 1.5rem; width: 100%; }
.nav-links { display: flex; width: 50%; gap: 1.5rem; align-items: center; flex: 1; }
.nav-actions { display: flex; align-items: center; justify-content: flex-end; }
.nav a { color: #111827; text-decoration: none; font-weight: 500; font-size: 0.9375rem; padding: 0.5rem 0; position: relative; transition: color 0.2s; }
.nav a:hover { color: #2563eb; }
.nav a.router-link-active { color: #2563eb; font-weight: 600; position: relative; }
.nav a.router-link-active::after { content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 2px; background-color: #2563eb; }
.nav .logout-btn { background-color: #dc3545; color: white !important; padding: 0.4rem 1rem !important; border-radius: 4px; transition: background-color 0.2s; margin-left: 1rem; }
.nav .logout-btn:hover { background-color: #bb2d3b; }
.content { flex: 1; padding: 1rem; }

.chatbot-float { position: fixed; bottom: 2rem; right: 2rem; z-index: 1000; }
.chatbot-button { position: relative; width: 60px; height: 60px; border-radius: 50%; background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%); border: none; cursor: pointer; box-shadow: 0 4px 12px rgba(79,70,229,0.4); display: flex; align-items: center; justify-content: center; color: white; font-size: 1.5rem; }
.chatbot-button:hover { transform: scale(1.1) translateY(-2px); box-shadow: 0 8px 20px rgba(79,70,229,0.6); }
.chatbot-icon { width: 24px; height: 24px; stroke-width: 2; }
.chatbot-pulse { position: absolute; top: -2px; left: -2px; right: -2px; bottom: -2px; border-radius: 50%; border: 2px solid rgba(79,70,229,0.3); animation: chatbotPulse 2s infinite; }
@keyframes chatbotPulse { 0% { transform: scale(1); opacity:1; } 50% { transform: scale(1.2); opacity:0.5; } 100% { transform: scale(1); opacity:1; } }
</style>
