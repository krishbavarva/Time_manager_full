import { ref } from 'vue'

const notifications = ref([])
let nextId = 1

export const notificationService = {
  notifications: notifications,
  
  add(notification) {
    const id = nextId++
    const newNotification = {
      id,
      type: notification.type || 'info',
      title: notification.title || '',
      message: notification.message || '',
      duration: notification.duration || 5000,
      persistent: notification.persistent || false,
      actions: notification.actions || [],
      timestamp: new Date()
    }
    
    notifications.value.push(newNotification)
    
    // Auto-remove non-persistent notifications
    if (!newNotification.persistent) {
      setTimeout(() => {
        this.remove(id)
      }, newNotification.duration)
    }
    
    return id
  },
  
  remove(id) {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index > -1) {
      notifications.value.splice(index, 1)
    }
  },
  
  clear() {
    notifications.value = []
  },
  
  // Convenience methods
  success(message, options = {}) {
    return this.add({
      type: 'success',
      message,
      ...options
    })
  },
  
  error(message, options = {}) {
    return this.add({
      type: 'error',
      message,
      duration: 8000,
      ...options
    })
  },
  
  warning(message, options = {}) {
    return this.add({
      type: 'warning',
      message,
      duration: 6000,
      ...options
    })
  },
  
  info(message, options = {}) {
    return this.add({
      type: 'info',
      message,
      ...options
    })
  }
}
