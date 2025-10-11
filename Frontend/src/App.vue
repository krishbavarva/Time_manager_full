<template>
  <div id="app">
    <!-- Navbar - Only show for authenticated users -->
    <header v-if="showNavbar" class="bg-white border-b border-gray-200">
      <nav class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center space-x-8">
            <RouterLink v-if="isAdmin" to="/admin/dashboard" class="text-gray-700 hover:text-blue-600 font-medium">Admin Dashboard</RouterLink>
            <RouterLink to="/dashboard" class="text-gray-700 hover:text-blue-600 font-medium">Dashboard</RouterLink>
            <RouterLink v-if="!isAdmin" to="/working-times" class="text-gray-700 hover:text-blue-600 font-medium">Working Times</RouterLink>
            <RouterLink v-if="!isAdmin" to="/clockins" class="text-gray-700 hover:text-blue-600 font-medium">Clockins</RouterLink>
            <RouterLink v-if="!isAdmin" to="/attendance-calendar" class="text-gray-700 hover:text-blue-600 font-medium">Attendance</RouterLink>
            <RouterLink v-if="isAdmin" to="/admin/users" class="text-gray-700 hover:text-blue-600 font-medium">Users</RouterLink>
            <RouterLink v-if="isAdmin" to="/admin/teams" class="text-gray-700 hover:text-blue-600 font-medium">Admin Teams</RouterLink>
            <RouterLink v-if="isAdmin" to="/admin/attendance" class="text-gray-700 hover:text-blue-600 font-medium">Attendance</RouterLink>
            <RouterLink v-if="isAdmin" to="/admin/salary" class="text-gray-700 hover:text-blue-600 font-medium">Salary</RouterLink>
            <RouterLink v-if="isAdmin" to="/admin/complaints" class="text-gray-700 hover:text-blue-600 font-medium">Complaints</RouterLink>
            <RouterLink v-if="isAdmin" to="/admin/leave-requests" class="text-gray-700 hover:text-blue-600 font-medium">Leave Requests</RouterLink>
            <RouterLink v-if="!isAdmin" to="/my-leave-requests" class="text-gray-700 hover:text-blue-600 font-medium">My Leave Requests</RouterLink>
            <RouterLink v-if="!isAdmin" to="/my-complaints" class="text-gray-700 hover:text-blue-600 font-medium">My Complaints</RouterLink>
            <RouterLink v-if="isManager && !isAdmin" to="/teams" class="text-gray-700 hover:text-blue-600 font-medium">Teams</RouterLink>
            <RouterLink v-if="isManager && !isAdmin" to="/manager/team" class="text-gray-700 hover:text-blue-600 font-medium">Team Members</RouterLink>
          </div>
          <div class="flex items-center space-x-4">
            <a href="#" class="text-gray-700 hover:text-red-600 font-medium" @click.prevent="handleLogout">Logout</a>
          </div>
        </div>
      </nav>
    </header>

    <main class="content">
      <RouterView />
    </main>

    <!-- Notification System -->
    <NotificationSystem />

    <!-- Floating Chatbot Button - Only show for authenticated users -->
    <div class="chatbot-float" v-if="showNavbar && $route.path !== '/chat'">
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
import { RouterLink, RouterView, useRoute } from 'vue-router';
import { computed, onMounted, ref } from 'vue';
import NotificationSystem from './components/NotificationSystem.vue';

const currentUser = ref(null);
const route = useRoute();

// Function to load current user from localStorage
const loadCurrentUser = () => {
  try {
    const userData = localStorage.getItem('currentUser');
    if (userData && userData !== 'null' && userData !== '{}') {
      const user = JSON.parse(userData);
      // Validate that it's a proper user object with required fields
      if (user && typeof user === 'object' && user.id && user.email) {
        currentUser.value = user;
      } else {
        currentUser.value = null;
        localStorage.removeItem('currentUser');
      }
    } else {
      currentUser.value = null;
    }
  } catch {
    currentUser.value = null;
    localStorage.removeItem('currentUser');
  }
};

onMounted(() => {
  loadCurrentUser();

  // Listen for storage events to update currentUser when localStorage changes
  window.addEventListener('storage', (e) => {
    if (e.key === 'currentUser') {
      loadCurrentUser();
    }
  });

  // Listen for focus events to check for login state changes
  window.addEventListener('focus', () => {
    loadCurrentUser();
  });
});

// Global method to refresh user state (can be called from other components)
window.refreshUserState = () => {
  loadCurrentUser();
};

const isAuthenticated = computed(() => {
  return currentUser.value !== null &&
         currentUser.value !== undefined &&
         typeof currentUser.value === 'object' &&
         currentUser.value.id &&
         currentUser.value.email;
});

const showNavbar = computed(() => {
  if (!isAuthenticated.value) return false;
  const hiddenRouteNames = new Set(['login', 'signup']);
  return !hiddenRouteNames.has(route.name);
});

const isAdmin = computed(() => {
  return currentUser.value?.role === 'admin';
});

const isManager = computed(() => {
  return ['admin', 'manager'].includes(currentUser.value?.role);
});

const handleLogout = () => {
  localStorage.removeItem('currentUser');
  localStorage.removeItem('authToken');
  // Force a reload to ensure the navbar disappears and user is redirected to login
  window.location.href = '/login';
};
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

/* Global Styles */
body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  line-height: 1.5;
  color: #111827;
  background-color: #f9fafb;
}

#app {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* Top Navigation */
.topbar {
  background-color: #ffffff;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 50;
  border-bottom: 1px solid #e5e7eb;
}

.nav {
  margin: 0 auto;
  padding: 0.75rem 1rem;
  display: flex;
  align-items: center;
  width: 100%;
  gap: 1.5rem;
}

.nav a {
  color: #111827;
  text-decoration: none;
  font-weight: 500;
  font-size: 0.9375rem;
  padding: 0.5rem 0;
  position: relative;
  transition: color 0.2s;
}

.nav a:hover {
  color: #2563eb;
}

.nav a.router-link-active {
  color: #2563eb;
  font-weight: 600;
  position: relative;
}

.nav a.router-link-active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background-color: #2563eb;
}

/* Logout button styles */
.nav .logout-btn {
  background-color: #dc3545;
  color: white !important;
  padding: 0.4rem 1rem !important;
  border-radius: 4px;
  transition: background-color 0.2s;
  margin-left: 1rem;
}

.nav .logout-btn:hover {
  background-color: #dc2626;
}

.nav-links {
  display: flex;
  width: 50%;
  gap: 1.5rem;
  align-items: center;
  flex: 1;
}

.nav-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.content {
  flex: 1;
  background-color: #f9fafb;
  min-height: 100vh;
}

/* Chatbot Styles */
.chatbot-float {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  z-index: 1000;
}

.chatbot-button {
  position: relative;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  border: none;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.4);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
  overflow: visible;
}

.chatbot-button:hover {
  transform: scale(1.1) translateY(-2px);
  box-shadow: 0 8px 20px rgba(79, 70, 229, 0.6);
}

.chatbot-button:active {
  transform: scale(0.95) translateY(-1px);
}

.chatbot-icon {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

.chatbot-pulse {
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  border-radius: 50%;
  border: 2px solid rgba(79, 70, 229, 0.3);
  animation: chatbotPulse 2s infinite;
}

@keyframes chatbotPulse {
  0% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(1.2);
    opacity: 0.5;
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .nav {
    padding: 0.5rem 1rem;
    gap: 1rem;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
  
  .nav a {
    font-size: 0.875rem;
    white-space: nowrap;
  }
  
  .content {
    padding: 1rem 0.75rem;
    min-height: calc(100vh - 2rem);
  }
  
  .chatbot-float {
    bottom: 1.5rem;
    right: 1.5rem;
  }
  
  .chatbot-button {
    width: 50px;
    height: 50px;
  }
  
  .chatbot-icon {
    width: 20px;
    height: 20px;
  }
}
</style>
