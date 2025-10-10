<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900">Real-Time Status</h3>
      <div class="flex items-center space-x-2">
        <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
        <span class="text-sm text-gray-500">Live</span>
      </div>
    </div>
    
    <!-- Status Grid - Hidden for employees -->
    <div v-if="userRole !== 'employee'" class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
      <div class="text-center p-4 bg-green-50 rounded-lg">
        <div class="text-2xl font-bold text-green-600">{{ onlineCount }}</div>
        <div class="text-sm text-green-600">Online</div>
      </div>
      
      <div class="text-center p-4 bg-blue-50 rounded-lg">
        <div class="text-2xl font-bold text-blue-600">{{ workingCount }}</div>
        <div class="text-sm text-blue-600">Working</div>
      </div>
      
      <div class="text-center p-4 bg-gray-50 rounded-lg">
        <div class="text-2xl font-bold text-gray-600">{{ offlineCount }}</div>
        <div class="text-sm text-gray-600">Offline</div>
      </div>
    </div>
    
    <!-- Live Activity Feed -->
    <div class="space-y-3">
      <h4 class="font-medium text-gray-900">Recent Activity</h4>
      <div class="space-y-2 max-h-48 overflow-y-auto">
        <div v-for="activity in recentActivities" :key="activity.id" class="flex items-center space-x-3 p-2 bg-gray-50 rounded-lg">
          <div class="flex-shrink-0">
            <div class="w-6 h-6 bg-gray-300 rounded-full flex items-center justify-center">
              <span class="text-xs font-medium text-gray-700">
                {{ activity.user?.first_name?.[0] }}
              </span>
            </div>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm text-gray-900">
              <span class="font-medium">{{ activity.user?.first_name }} {{ activity.user?.last_name }}</span>
              {{ activity.message }}
            </p>
            <p class="text-xs text-gray-500">{{ formatTime(activity.timestamp) }}</p>
          </div>
          <div class="flex-shrink-0">
            <span :class="[
              'px-2 py-1 text-xs font-medium rounded-full',
              activity.type === 'clock_in' ? 'bg-green-100 text-green-800' :
              activity.type === 'clock_out' ? 'bg-red-100 text-red-800' :
              'bg-blue-100 text-blue-800'
            ]">
              {{ activity.type === 'clock_in' ? 'In' : activity.type === 'clock_out' ? 'Out' : 'Activity' }}
            </span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Connection Status -->
    <div class="mt-4 pt-4 border-t border-gray-200">
      <div class="flex items-center justify-between">
        <span class="text-sm text-gray-500">Connection Status</span>
        <div class="flex items-center space-x-2">
          <div :class="[
            'w-2 h-2 rounded-full',
            isConnected ? 'bg-green-400' : 'bg-red-400'
          ]"></div>
          <span class="text-sm font-medium" :class="isConnected ? 'text-green-600' : 'text-red-600'">
            {{ isConnected ? 'Connected' : 'Disconnected' }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { usersApi } from '../api/users'
import { clockinsApi } from '../api/clockins'

const onlineCount = ref(0)
const workingCount = ref(0)
const offlineCount = ref(0)
const isConnected = ref(true)
const recentActivities = ref([])
const allUsers = ref([])

// Computed property for user role
const userRole = computed(() => {
  try {
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    return currentUser.role || 'employee'
  } catch (error) {
    return 'employee'
  }
})

let updateInterval = null

const updateStatus = async () => {
  try {
    isConnected.value = true
    
    // Get current user to determine role-based access
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const userRole = currentUser.role || 'employee'
    
    let usersToShow = []
    
    if (userRole === 'admin') {
      // Admin can see all users except other admins (only employees and managers)
      const usersResponse = await usersApi.list()
      const allUsersData = usersResponse.data || []
      usersToShow = allUsersData.filter(user => user.role !== 'admin')
    } else if (userRole === 'manager') {
      // Manager can see team members (only employees and managers, not admins)
      try {
        const usersResponse = await usersApi.list()
        const allUsersData = usersResponse.data || []
        usersToShow = allUsersData.filter(user => user.role !== 'admin')
      } catch (error) {
        // If manager can't access all users, show only current user if not admin
        if (currentUser.role !== 'admin') {
          usersToShow = [currentUser]
        } else {
          usersToShow = []
        }
      }
    } else {
      // Employee can only see themselves
      usersToShow = [currentUser]
    }
    
    allUsers.value = usersToShow
    
    // Fetch clock-in data for users we can access
    const clockPromises = allUsers.value.map(user => 
      clockinsApi.listByUser(user.id).catch(() => ({ data: [] }))
    )
    const clockResponses = await Promise.all(clockPromises)
    
    // Calculate status for each user
    let online = 0
    let working = 0
    let offline = 0
    
    allUsers.value.forEach((user, index) => {
      const clocks = clockResponses[index]?.data || []
      if (clocks.length > 0) {
        const lastClock = clocks[0] // Most recent clock
        const clockTime = new Date(lastClock.time)
        const hoursSinceLastClock = (Date.now() - clockTime.getTime()) / (1000 * 60 * 60)
        
        if (hoursSinceLastClock < 12) { // Active within last 12 hours
          if (lastClock.status === true) { // Clocked in
            working++
            online++
          } else { // Clocked out recently
            online++
          }
        } else {
          offline++
        }
      } else {
        offline++
      }
    })
    
    onlineCount.value = online
    workingCount.value = working
    offlineCount.value = offline
    
    // Fetch recent clock activities
    await fetchRecentActivities()
    
  } catch (error) {
    console.error('Error updating status:', error)
    isConnected.value = false
    
    // Fallback: show at least the current user's status
    try {
      const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
      if (currentUser.id) {
        allUsers.value = [currentUser]
        const clockResponse = await clockinsApi.listByUser(currentUser.id)
        const clocks = clockResponse.data || []
        
        if (clocks.length > 0) {
          const lastClock = clocks[0]
          onlineCount.value = 1
          workingCount.value = lastClock.status ? 1 : 0
          offlineCount.value = lastClock.status ? 0 : 1
        } else {
          onlineCount.value = 0
          workingCount.value = 0
          offlineCount.value = 1
        }
      }
    } catch (fallbackError) {
      console.error('Fallback error:', fallbackError)
    }
  }
}

const fetchRecentActivities = async () => {
  try {
    const activities = []
    
    // Fetch recent clocks from users we have access to
    const recentUserIds = allUsers.value.slice(0, 10).map(u => u.id)
    
    for (const userId of recentUserIds) {
      try {
        const clocksResponse = await clockinsApi.listByUser(userId)
        const clocks = clocksResponse.data || []
        
        clocks.slice(0, 3).forEach(clock => {
          const user = allUsers.value.find(u => u.id === userId)
          if (user) {
            activities.push({
              id: `${userId}-${clock.id || clock.time}`,
              user: {
                first_name: user.first_name,
                last_name: user.last_name
              },
              message: `${user.first_name} ${user.last_name} ${clock.status ? 'clocked in' : 'clocked out'}`,
              type: clock.status ? 'clock_in' : 'clock_out',
              timestamp: new Date(clock.time)
            })
          }
        })
      } catch (err) {
        // Skip if error fetching for this user
        console.log(`Could not fetch clocks for user ${userId}:`, err)
      }
    }
    
    // Sort by timestamp and keep most recent
    activities.sort((a, b) => b.timestamp - a.timestamp)
    recentActivities.value = activities.slice(0, 10)
    
  } catch (error) {
    console.error('Error fetching recent activities:', error)
    
    // Fallback: show current user's recent activities
    try {
      const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
      if (currentUser.id) {
        const clocksResponse = await clockinsApi.listByUser(currentUser.id)
        const clocks = clocksResponse.data || []
        
        const fallbackActivities = clocks.slice(0, 5).map(clock => ({
          id: `${currentUser.id}-${clock.id || clock.time}`,
          user: {
            first_name: currentUser.first_name,
            last_name: currentUser.last_name
          },
          message: `${currentUser.first_name} ${currentUser.last_name} ${clock.status ? 'clocked in' : 'clocked out'}`,
          type: clock.status ? 'clock_in' : 'clock_out',
          timestamp: new Date(clock.time)
        }))
        
        recentActivities.value = fallbackActivities
      }
    } catch (fallbackError) {
      console.error('Fallback activities error:', fallbackError)
      recentActivities.value = []
    }
  }
}

const formatTime = (timestamp) => {
  const now = new Date()
  const diff = now - timestamp
  const minutes = Math.floor(diff / 60000)
  
  if (minutes < 1) return 'Just now'
  if (minutes < 60) return `${minutes}m ago`
  
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  
  return timestamp.toLocaleDateString()
}

onMounted(() => {
  updateStatus()
  // Update every 30 seconds for real data
  updateInterval = setInterval(updateStatus, 30000)
})

onUnmounted(() => {
  if (updateInterval) {
    clearInterval(updateInterval)
  }
})
</script>
