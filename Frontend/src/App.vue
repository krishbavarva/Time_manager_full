<template>
  <div id="app" class="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50">

    <!-- Mobile Menu Button -->
    <button
      v-if="showNavbar && $route.path !== '/login'"
      @click="toggleMobileSidebar"
      class="fixed top-4 left-4 z-50 lg:hidden p-3 bg-white/95 backdrop-blur-md rounded-xl shadow-lg border border-gray-200/50 hover:bg-gray-50 transition-all duration-200"
    >
      <svg class="w-6 h-6 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
      </svg>
    </button>

    <!-- Mobile Sidebar Backdrop -->
    <div
      v-if="showNavbar && $route.path !== '/login' && mobileSidebarOpen"
      @click="closeMobileSidebar"
      class="fixed inset-0 bg-black/50 backdrop-blur-sm z-40 lg:hidden transition-opacity duration-300"
    ></div>

    <!-- Sidebar Navigation - Collapsible & Responsive -->
    <div 
      v-if="showNavbar && $route.path !== '/login'"
      class="fixed inset-y-0 left-0 z-50 bg-white/98 backdrop-blur-xl border-r border-gray-200/60 shadow-2xl transition-all duration-300 ease-in-out"
      :class="[
        sidebarCollapsed ? 'w-20' : 'w-80',
        {
          'transform -translate-x-full lg:translate-x-0': !mobileSidebarOpen,
          'transform translate-x-0': mobileSidebarOpen
        }
      ]"
    >
      <!-- Sidebar Header -->
      <div class="flex items-center justify-between p-4 border-b border-gray-200/50">
        <div v-if="!sidebarCollapsed" class="flex items-center space-x-3">
          <div class="w-10 h-10 rounded-xl overflow-hidden shadow-lg">
            <img 
              src="/chronopulse-logo.png" 
              alt="Timemanager Logo" 
              class="w-full h-full object-cover"
            />
          </div>
          <span class="text-xl font-bold gradient-text">Timemanager</span>
        </div>
        <div v-else class="flex justify-center w-full">
          <div class="w-12 h-12 rounded-xl overflow-hidden shadow-lg ring-2 ring-indigo-100">
            <img 
              src="/chronopulse-logo.png" 
              alt="Timemanager Logo" 
              class="w-full h-full object-cover"
            />
          </div>
        </div>
        <button 
          @click="toggleSidebar"
          class="p-2.5 rounded-xl hover:bg-gray-100 transition-all duration-200 ml-auto group"
          title="Toggle Sidebar"
        >
          <svg class="w-5 h-5 text-gray-600 group-hover:text-indigo-600 transition-colors duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!sidebarCollapsed" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7"/>
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7"/>
          </svg>
        </button>
      </div>

      <!-- User Profile Section -->
      <div v-if="currentUser" class="p-4 border-b border-gray-200/50">
        <div v-if="!sidebarCollapsed" class="flex items-center space-x-4">
          <div class="w-12 h-12 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg">
            {{ currentUser.first_name?.[0] }}{{ currentUser.last_name?.[0] }}
          </div>
          <div class="flex-1">
            <div class="font-semibold text-gray-900">{{ currentUser.first_name }} {{ currentUser.last_name }}</div>
            <div class="text-sm text-gray-600">{{ currentUser.email }}</div>
            <div class="text-xs font-medium px-2 py-1 rounded-full mt-1 inline-block" 
                 :class="{
                   'bg-purple-100 text-purple-700': currentUser.role === 'admin',
                   'bg-blue-100 text-blue-700': currentUser.role === 'manager',
                   'bg-emerald-100 text-emerald-700': currentUser.role === 'employee'
                 }">
              {{ currentUser.role?.toUpperCase() }}
            </div>
          </div>
        </div>
        <div v-else class="flex justify-center">
          <div class="relative group">
            <div class="w-12 h-12 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg ring-2 ring-indigo-100">
              {{ currentUser.first_name?.[0] }}{{ currentUser.last_name?.[0] }}
            </div>
            <!-- Role indicator dot -->
            <div class="absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white" 
                 :class="{
                   'bg-purple-500': currentUser.role === 'admin',
                   'bg-blue-500': currentUser.role === 'manager',
                   'bg-emerald-500': currentUser.role === 'employee'
                 }">
            </div>
          </div>
        </div>
      </div>

      <!-- Navigation Links -->
      <nav class="flex-1 p-4 space-y-3">
        <!-- Admin Links -->
        <div v-if="isAdmin" class="space-y-2">
          <div v-if="!sidebarCollapsed" class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">Admin</div>
          <RouterLink to="/admin/dashboard" class="sidebar-link group" :title="sidebarCollapsed ? 'Admin Dashboard' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
            </svg>
            <span v-if="!sidebarCollapsed">Admin Dashboard</span>
          </RouterLink>
          <RouterLink to="/admin/users" class="sidebar-link group" :title="sidebarCollapsed ? 'Manage Users' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
            </svg>
            <span v-if="!sidebarCollapsed">Manage Users</span>
          </RouterLink>
          <RouterLink to="/admin/teams" class="sidebar-link group" :title="sidebarCollapsed ? 'Manage Teams' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
            </svg>
            <span v-if="!sidebarCollapsed">Manage Teams</span>
          </RouterLink>
          <RouterLink to="/admin/complaints" class="sidebar-link group" :title="sidebarCollapsed ? 'Complaints' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
            </svg>
            <span v-if="!sidebarCollapsed">Complaints</span>
          </RouterLink>
          <RouterLink to="/admin/salary" class="sidebar-link group" :title="sidebarCollapsed ? 'Salary Management' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <span v-if="!sidebarCollapsed">Salary Management</span>
          </RouterLink>
          <RouterLink to="/admin/attendance" class="sidebar-link group" :title="sidebarCollapsed ? 'Attendance' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/>
            </svg>
            <span v-if="!sidebarCollapsed">Attendance</span>
          </RouterLink>
          <RouterLink to="/admin/leave-requests" class="sidebar-link group" :title="sidebarCollapsed ? 'Leave Requests' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
            </svg>
            <span v-if="!sidebarCollapsed">Leave Requests</span>
          </RouterLink>
        </div>

        <!-- General Links -->
        <div class="space-y-2">
          <div v-if="!isAdmin && !sidebarCollapsed" class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">General</div>
          <RouterLink to="/dashboard" class="sidebar-link group" :title="sidebarCollapsed ? 'Dashboard' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
            </svg>
            <span v-if="!sidebarCollapsed">Dashboard</span>
          </RouterLink>
          <RouterLink v-if="!isAdmin" to="/clockins" class="sidebar-link group" :title="sidebarCollapsed ? 'Clock In/Out' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <span v-if="!sidebarCollapsed">Clock In/Out</span>
          </RouterLink>
          <RouterLink v-if="!isAdmin" to="/my-leave-requests" class="sidebar-link group" :title="sidebarCollapsed ? 'My Leave Requests' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
            </svg>
            <span v-if="!sidebarCollapsed">My Leave Requests</span>
          </RouterLink>
        </div>

        <!-- Logout Button -->
        <div class="pt-6 border-t border-gray-200/50 mt-6">
          <button @click="handleLogout" class="sidebar-link group w-full text-red-600 hover:bg-red-50" :title="sidebarCollapsed ? 'Logout' : ''">
            <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
            </svg>
            <span v-if="!sidebarCollapsed">Logout</span>
          </button>
        </div>
      </nav>
    </div>


    <!-- Main Content Area -->
    <main class="min-h-screen p-4 sm:p-6 lg:p-8 transition-all duration-300 ease-in-out pt-16 lg:pt-8" 
          :class="showNavbar && $route.path !== '/login' ? (sidebarCollapsed ? 'lg:ml-20' : 'lg:ml-80') : ''">
      <div class="max-w-7xl mx-auto">
        <RouterView />
      </div>
    </main>

    <!-- Notification System -->
    <NotificationSystem />

    <!-- Floating Chatbot Button -->
    <div v-if="showNavbar && $route.path !== '/chat'" class="fixed bottom-6 right-6 z-40">
      <button @click="$router.push('/chat')" class="chatbot-button-modern group relative" title="AI Assistant - Ask me anything!">
        <div class="absolute inset-0 rounded-full bg-gradient-to-r from-purple-400 to-pink-400 opacity-0 group-hover:opacity-20 transition-opacity duration-300 blur-sm"></div>
        <svg class="w-7 h-7 text-white transition-all duration-300 group-hover:scale-110 group-hover:rotate-12 drop-shadow-lg relative z-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
        </svg>
        <span class="pulse-ring"></span>
        <!-- Tooltip -->
        <div class="absolute right-full mr-3 top-1/2 transform -translate-y-1/2 bg-gray-900 text-white text-sm px-3 py-2 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap pointer-events-none">
          AI Assistant
          <div class="absolute left-full top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-gray-900 border-t-4 border-t-transparent border-b-4 border-b-transparent"></div>
        </div>
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
const sidebarCollapsed = ref(false);
const mobileSidebarOpen = ref(false);

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

const toggleSidebar = () => {
  sidebarCollapsed.value = !sidebarCollapsed.value;
};

const toggleMobileSidebar = () => {
  mobileSidebarOpen.value = !mobileSidebarOpen.value;
};

const closeMobileSidebar = () => {
  mobileSidebarOpen.value = false;
};

const handleLogout = () => {
  localStorage.removeItem('currentUser');
  localStorage.removeItem('authToken');
  // Force a reload to ensure the navbar disappears and user is redirected to login
  window.location.href = '/login';
};
</script>

<style scoped>
/* Navigation Link Styles */
.nav-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: 0.75rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: #374151;
  transition: all 0.2s ease;
  text-decoration: none;
  border: 1px solid transparent;
}

.nav-link:hover {
  background: rgba(99, 102, 241, 0.1);
  color: #6366f1;
  transform: translateY(-1px);
  border-color: rgba(99, 102, 241, 0.2);
  box-shadow: 0 2px 8px rgba(99, 102, 241, 0.15);
}

.nav-link.router-link-active {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: white;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
  border-color: rgba(139, 92, 246, 0.3);
}

/* Logout Button */
.btn-logout {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 0.75rem;
  background: linear-gradient(135deg, #ef4444, #dc2626);
  color: white;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.btn-logout:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
}

/* Modern Chatbot Button */
.chatbot-button-modern {
  position: relative;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
  border: 3px solid rgba(255, 255, 255, 0.2);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 
    0 8px 32px rgba(102, 126, 234, 0.4),
    0 0 0 1px rgba(255, 255, 255, 0.1),
    inset 0 1px 0 rgba(255, 255, 255, 0.2);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  backdrop-filter: blur(10px);
}

.chatbot-button-modern:hover {
  transform: translateY(-6px) scale(1.08);
  box-shadow: 
    0 20px 40px rgba(102, 126, 234, 0.6),
    0 0 0 1px rgba(255, 255, 255, 0.2),
    inset 0 1px 0 rgba(255, 255, 255, 0.3);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 30%, #f093fb 70%, #ffecd2 100%);
}

.chatbot-button-modern:active {
  transform: translateY(-2px) scale(1.02);
  transition: all 0.1s ease;
}

.pulse-ring {
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 3px solid rgba(255, 255, 255, 0.6);
  animation: pulse-animation 3s infinite;
  opacity: 0;
  top: 0;
  left: 0;
  pointer-events: none;
}

@keyframes pulse-animation {
  0% {
    transform: scale(1);
    opacity: 0.8;
  }
  50% {
    transform: scale(1.3);
    opacity: 0.4;
  }
  100% {
    transform: scale(1.8);
    opacity: 0;
  }
}

/* Glass Morphism */
.glass {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.1);
}

/* Gradient Text */
.gradient-text {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* Sidebar Link Styles */
.sidebar-link {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.875rem 1rem;
  border-radius: 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #374151;
  transition: all 0.2s ease;
  text-decoration: none;
  border: 1px solid transparent;
}

.sidebar-link:hover {
  background: rgba(99, 102, 241, 0.1);
  color: #6366f1;
  transform: translateX(4px);
  border-color: rgba(99, 102, 241, 0.2);
}

.sidebar-link.router-link-active {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: white;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
  border-color: rgba(139, 92, 246, 0.3);
}

/* Responsive adjustments */
@media (max-width: 1024px) {
  .nav-link span {
    display: none;
  }
  
  .nav-link {
    padding: 0.5rem;
  }
}
</style>

<style>

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
  
  .chatbot-button-modern {
    width: 56px;
    height: 56px;
    bottom: 1.5rem;
    right: 1.5rem;
  }
  
  .chatbot-button-modern svg {
    width: 1.5rem;
    height: 1.5rem;
  }
}
</style>
