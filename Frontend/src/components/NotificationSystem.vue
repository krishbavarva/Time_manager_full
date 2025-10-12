<template>
  <div class="fixed top-4 right-4 z-50 space-y-2">
    <TransitionGroup name="notification" tag="div">
      <div
        v-for="notification in notifications"
        :key="notification.id"
        :class="[
          'notification-item max-w-2xl w-full bg-white dark:bg-gray-800 shadow-lg rounded-lg pointer-events-auto ring-1 ring-black ring-opacity-5 overflow-hidden',
          getNotificationClasses(notification.type)
        ]"
      >
        <div class="p-4">
          <div class="flex items-start">
            <div class="flex-shrink-0">
              <span class="text-lg">{{ getNotificationIcon(notification.type) }}</span>
            </div>
            <div class="ml-3 w-0 flex-1 pt-0.5">
              <p v-if="notification.title" class="text-sm font-medium text-gray-900 dark:text-gray-100">
                {{ notification.title }}
              </p>
              <p class="text-sm text-gray-500 dark:text-gray-400">
                {{ notification.message }}
              </p>
              <div v-if="notification.actions && notification.actions.length > 0" class="mt-2">
                <div class="flex space-x-2">
                  <button
                    v-for="action in notification.actions"
                    :key="action.label"
                    @click="handleAction(notification, action)"
                    :class="[
                      'text-xs font-medium px-2 py-1 rounded',
                      action.primary 
                        ? 'bg-blue-600 text-white hover:bg-blue-700' 
                        : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                    ]"
                  >
                    {{ action.label }}
                  </button>
                </div>
              </div>
            </div>
            <div class="ml-4 flex-shrink-0 flex">
              <button
                @click="remove(notification.id)"
                class="bg-white dark:bg-gray-800 rounded-md inline-flex text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                <span class="sr-only">Close</span>
                <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
              </button>
            </div>
          </div>
        </div>
        
        <!-- Progress bar for timed notifications -->
        <div v-if="!notification.persistent" class="h-1 bg-gray-200 dark:bg-gray-700">
          <div 
            class="h-full bg-blue-600 transition-all duration-100 ease-linear"
            :style="{ width: getProgressWidth(notification) + '%' }"
          ></div>
        </div>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted } from 'vue'
import { notificationService } from '../services/notificationService'

const notifications = computed(() => notificationService.notifications.value)

const remove = (id) => {
  notificationService.remove(id)
}

const handleAction = (notification, action) => {
  if (action.handler) {
    action.handler(notification)
  }
  if (action.dismiss !== false) {
    remove(notification.id)
  }
}

const getNotificationClasses = (type) => {
  const baseClasses = 'border-l-4'
  switch (type) {
    case 'success':
      return `${baseClasses} border-green-400`
    case 'error':
      return `${baseClasses} border-red-400`
    case 'warning':
      return `${baseClasses} border-yellow-400`
    case 'info':
    default:
      return `${baseClasses} border-blue-400`
  }
}

const getNotificationIcon = (type) => {
  switch (type) {
    case 'success':
      return '✅'
    case 'error':
      return '❌'
    case 'warning':
      return '⚠️'
    case 'info':
    default:
      return 'ℹ️'
  }
}

const getProgressWidth = (notification) => {
  if (notification.persistent) return 100
  
  const elapsed = Date.now() - notification.timestamp.getTime()
  const remaining = Math.max(0, notification.duration - elapsed)
  return (remaining / notification.duration) * 100
}

// Auto-refresh progress bars
let progressInterval = null

onMounted(() => {
  progressInterval = setInterval(() => {
    // Force reactivity update for progress bars
    notifications.value.forEach(n => {
      if (!n.persistent) {
        // Trigger reactivity by accessing the computed value
        const elapsed = Date.now() - n.timestamp.getTime()
        if (elapsed >= n.duration) {
          remove(n.id)
        }
      }
    })
  }, 100)
})

onUnmounted(() => {
  if (progressInterval) {
    clearInterval(progressInterval)
  }
})
</script>

<style scoped>
.notification-item {
  min-width: 450px;
}

@media (max-width: 640px) {
  .notification-item {
    min-width: 320px;
  }
}

.notification-enter-active,
.notification-leave-active {
  transition: all 0.3s ease;
}

.notification-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.notification-leave-to {
  opacity: 0;
  transform: translateX(100%);
}

.notification-move {
  transition: transform 0.3s ease;
}
</style>
