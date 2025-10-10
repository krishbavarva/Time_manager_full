<template>
  <section class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-5xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Daily Schedule</h1>
        <p class="text-gray-600">Manage your weekly working hours and view upcoming schedule</p>
      </div>

      <!-- Set Weekly Schedule Card -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
        <div class="mb-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-2">Set Your Weekly Schedule</h2>
          <p class="text-sm text-gray-600">Define your regular working hours for each day of the week.</p>
        </div>
        
        <form @submit.prevent="saveSchedule">
          <!-- Days Schedule List -->
          <div class="space-y-1 mb-6">
            <div 
              v-for="day in daysOfWeek" 
              :key="day" 
              class="flex flex-col sm:flex-row sm:items-center py-4 border-b border-gray-200 last:border-b-0 gap-3"
            >
              <!-- Day Checkbox -->
              <label class="flex items-center min-w-[140px] font-medium text-gray-900 cursor-pointer">
                <input 
                  type="checkbox" 
                  v-model="schedule[day].enabled" 
                  class="w-4 h-4 text-blue-600 bg-white border-gray-300 rounded focus:ring-2 focus:ring-blue-500 mr-3 cursor-pointer"
                />
                <span class="select-none">{{ day }}</span>
              </label>
              
              <!-- Time Inputs -->
              <div 
                v-if="schedule[day].enabled" 
                class="flex items-center gap-3 flex-1 sm:ml-4"
              >
                <input 
                  type="time" 
                  v-model="schedule[day].startTime"
                  :disabled="!schedule[day].enabled"
                  required
                  class="flex-1 py-2 px-3 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors disabled:bg-gray-100 disabled:cursor-not-allowed"
                />
                <span class="text-gray-500 text-sm font-medium">to</span>
                <input 
                  type="time" 
                  v-model="schedule[day].endTime"
                  :disabled="!schedule[day].enabled"
                  required
                  class="flex-1 py-2 px-3 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors disabled:bg-gray-100 disabled:cursor-not-allowed"
                />
              </div>
            </div>
          </div>

          <!-- Save Button -->
          <div class="flex justify-end pt-4">
            <button 
              type="submit" 
              :disabled="saving" 
              class="px-6 py-2.5 bg-blue-600 text-white font-medium rounded-lg transition-all duration-200 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:bg-blue-600 shadow-sm"
            >
              <span v-if="saving" class="flex items-center gap-2">
                <svg class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Saving...
              </span>
              <span v-else>Save Schedule</span>
            </button>
          </div>
        </form>
      </div>

      <!-- Upcoming Schedule Card -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="mb-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-2">Upcoming Schedule</h2>
          <p class="text-sm text-gray-600">Your scheduled working hours for the next 7 days</p>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="flex justify-center items-center py-12">
          <div class="flex items-center gap-3 text-gray-500">
            <svg class="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <span>Loading schedule...</span>
          </div>
        </div>

        <!-- Empty State -->
        <div 
          v-else-if="Object.keys(upcomingSchedule).length === 0" 
          class="text-center py-12"
        >
          <svg class="mx-auto h-12 w-12 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          <p class="text-gray-600 text-sm">No upcoming schedule</p>
          <p class="text-gray-500 text-xs mt-1">Please set your weekly schedule above</p>
        </div>

        <!-- Schedule List -->
        <div v-else class="space-y-2">
          <div 
            v-for="(item, date) in upcomingSchedule" 
            :key="date" 
            class="flex flex-col sm:flex-row sm:items-center sm:justify-between p-4 rounded-lg border border-gray-200 hover:border-blue-300 hover:bg-blue-50/50 transition-all duration-150 gap-2"
          >
            <!-- Date -->
            <div class="flex items-center gap-2">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <span class="font-medium text-gray-900">{{ formatScheduleDate(date) }}</span>
            </div>
            
            <!-- Time & Duration -->
            <div class="flex items-center gap-4 sm:ml-auto">
              <div class="flex items-center gap-2 text-gray-700">
                <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="text-sm font-medium">{{ formatTime(item.startTime) }} - {{ formatTime(item.endTime) }}</span>
              </div>
              <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                {{ item.formattedDuration }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
  
  <!-- Notification Component -->
  <Notification 
    v-if="notification.show"
    ref="notificationRef"
    :message="notification.message"
    :type="notification.type"
    :duration="notification.duration"
    @close="notification.show = false"
  />
</template>

<script setup>
import { ref, onMounted, reactive, computed, nextTick, onBeforeUnmount } from 'vue'
import { workingTimesApi } from '../api/workingTimes'
import Notification from '../components/Notification.vue'

const loading = ref(false)
const saving = ref(false)
const error = ref('')
const currentUserId = ref('')
const notification = reactive({
  show: false,
  message: '',
  duration: 3000
})

const notificationRef = ref(null)
const autoClockOutInterval = ref(null)
const handleAutoClockOut = async () => {
  try {
    console.log('Starting manual clock out process...')
    const now = new Date()
    const endTime = now.toISOString()
    
    console.log('Current user ID:', currentUserId.value)
    console.log('Current time:', endTime)
    
    const response = await workingTimesApi.list(currentUserId.value, { 
      end: endTime,
      limit: 1,
      sort: '-start_time'
    })
    
    if (response && response.data && response.data.length > 0) {
      const latestRecord = response.data[0]
      
      if (!latestRecord.end_time) {
        await workingTimesApi.update(
          latestRecord.id, 
          { end_time: endTime }, 
          { method: 'PATCH' }
        )
        showNotification('You have been successfully clocked out.', 'success')
        showAutoClockOutNotification.value = false
      } else {
        showNotification('You are already clocked out.', 'info')
      }
    } else {
      showNotification('No active working time record found.', 'info')
    }
    
    autoClockOutTime.value = null
    showAutoClockOutNotification.value = false
    
  } catch (error) {
    console.error('Clock out failed:', error)
    
    let errorMessage = 'Failed to clock out. '
    
    if (error.response) {
      console.error('Response data:', error.response.data)
      console.error('Status code:', error.response.status)
      
      if (error.response.status === 401) {
        errorMessage += 'Authentication failed. Please log in again.'
      } else if (error.response.status === 404) {
        errorMessage += 'Working time record not found.'
      } else if (error.response.data && error.response.data.error) {
        errorMessage += error.response.data.error
      } else {
        errorMessage += `Server responded with status ${error.response.status}`
      }
    } else if (error.request) {
      console.error('No response received:', error.request)
      errorMessage += 'No response from server. Please check your connection.'
    } else {
      console.error('Error:', error.message)
      errorMessage += error.message || 'An unknown error occurred.'
    }
    
    showNotification(errorMessage, 'error', 5000)
  }
}

const checkWorkingTimeAlert = async () => {
  try {
    const now = new Date()
    const today = now.toLocaleDateString('en-US', { weekday: 'long' })
    
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0)
    const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999)
    
    const response = await workingTimesApi.list(currentUserId.value, { 
      limit: 1,
      sort: '-start_time',
      start: startOfDay.toISOString(),
      end: endOfDay.toISOString()
    })
    
    const isClockedIn = response?.data?.length > 0 && !response.data[0].end_time
    
    if (!isClockedIn) {
      console.log('User is not clocked in - no alert needed')
      return false
    }
    
    const hasWorkingHours = schedule[today]?.enabled && schedule[today].endTime
    
    if (!hasWorkingHours) {
      console.log('No working hours set for today - no alert')
      return false
    }
    
    const currentTime = now.getHours() * 60 + now.getMinutes()
    const [endHour, endMinute] = schedule[today].endTime.split(':').map(Number)
    const endTimeInMinutes = endHour * 60 + endMinute
    
    if (currentTime >= endTimeInMinutes) {
      console.log('Working time has ended - showing alert to user')
      
      alert('You are still clocked in. Your working time has ended. Please remember to clock out!')
      
      showNotification('Your working time has ended. Please remember to clock out!', 'warning', 10000)
      
      return true
    }
    
    console.log('Working time has not ended yet')
    return false
  } catch (error) {
    console.error('Error in working time alert check:', error)
    return false
  }
}

const showNotification = (message, type = 'success', duration = 3000) => {
  notification.message = message
  notification.type = type
  notification.duration = duration
  notification.show = true
  
  nextTick(() => {
    if (notificationRef.value) {
      notificationRef.value.show()
    }
  })
}

const daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

const defaultSchedule = daysOfWeek.reduce((acc, day) => {
  acc[day] = { enabled: false, startTime: '09:00', endTime: '17:00' }
  return acc
}, {})

const schedule = reactive(JSON.parse(JSON.stringify(defaultSchedule)))

const upcomingSchedule = computed(() => {
  const result = {}
  const today = new Date()
  
  for (let i = 0; i < 7; i++) {
    const date = new Date(today)
    date.setDate(today.getDate() + i)
    const dayName = daysOfWeek[date.getDay() === 0 ? 6 : date.getDay() - 1]
    
    if (schedule[dayName]?.enabled) {
      const dateStr = date.toISOString().split('T')[0]
      const start = schedule[dayName].startTime
      const end = schedule[dayName].endTime
      const workingMinutes = getWorkingMinutes(start, end)
      
      result[dateStr] = {
        startTime: start,
        endTime: end,
        workingMinutes: workingMinutes,
        isWithinWorkingHours: isWithinWorkingHours(start) && isWithinWorkingHours(end),
        formattedDuration: formatDuration(workingMinutes)
      }
    }
  }
  
  return result
})

const formatDate = (date) => {
  if (!date) return '--'
  const d = new Date(date)
  if (isNaN(+d)) return String(date)
  return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
}

const formatTime = (time) => {
  if (!time) return '--'
  if (typeof time === 'string' && time.match(/^\d{2}:\d{2}$/)) {
    const [hours, minutes] = time.split(':')
    const date = new Date()
    date.setHours(parseInt(hours), parseInt(minutes))
    return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
  }
  
  const d = new Date(time)
  if (isNaN(+d)) return String(time)
  return d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
}

const formatScheduleDate = (dateStr) => {
  const date = new Date(dateStr)
  const today = new Date()
  const tomorrow = new Date(today)
  tomorrow.setDate(tomorrow.getDate() + 1)
  
  if (date.toDateString() === today.toDateString()) return 'Today'
  if (date.toDateString() === tomorrow.toDateString()) return 'Tomorrow'
  
  return date.toLocaleDateString('en-US', { 
    weekday: 'long', 
    month: 'short', 
    day: 'numeric' 
  })
}

const isWithinWorkingHours = (time) => {
  if (!time) return false
  try {
    const [hours, minutes] = time.split(':').map(Number)
    const totalMinutes = hours * 60 + minutes
    return totalMinutes >= 540 && totalMinutes <= 1020
  } catch (e) {
    console.error('Error checking working hours for time:', time, e)
    return false
  }
}

const getWorkingMinutes = (start, end) => {
  if (!start || !end) return 0
  
  try {
    const startDate = new Date()
    const startTime = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), ...start.split(':').map(Number))
    const endTime = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), ...end.split(':').map(Number))
    
    const totalMinutes = Math.abs(endTime - startTime) / 60000
    
    return totalMinutes
  } catch (e) {
    console.error('Error calculating working minutes:', { start, end }, e)
    return 0
  }
}

const formatDuration = (minutes) => {
  if (minutes <= 0) return '0:00:00'
  const hours = Math.floor(minutes / 60)
  const mins = Math.floor(minutes % 60)
  const secs = Math.floor((minutes * 60) % 60)
  return `${hours.toString().padStart(1, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}

const calculateDuration = (start, end) => {
  if (!start || !end) return '--'
  
  const workingMinutes = getWorkingMinutes(start, end)
  
  const [startHour, startMinute] = start.split(':').map(Number)
  const [endHour, endMinute] = end.split(':').map(Number)
  let totalMinutes = (endHour * 60 + endMinute) - (startHour * 60 + startMinute)
  if (totalMinutes < 0) totalMinutes += 24 * 60
  
  if (workingMinutes <= 0) return '0:00:00 (outside working hours)'
  
  if (workingMinutes < totalMinutes) {
    return `${formatDuration(workingMinutes)} (of ${formatDuration(totalMinutes)})`
  }
  
  return formatDuration(workingMinutes)
}

const loadSchedule = async () => {
  loading.value = true
  error.value = ''
  try {
    if (!currentUserId.value) return
    
    const savedSchedule = localStorage.getItem(`user_${currentUserId.value}_schedule`)
    if (savedSchedule) {
      const parsed = JSON.parse(savedSchedule)
      daysOfWeek.forEach(day => {
        if (parsed[day]) {
          schedule[day] = { 
            enabled: parsed[day].enabled !== undefined ? parsed[day].enabled : false,
            startTime: parsed[day].startTime || '09:00',
            endTime: parsed[day].endTime || '17:00'
          }
        }
      })
    } else {
      try {
        const response = await workingTimesApi.list(currentUserId.value)
        if (response && response.data) {
          console.log('Fetched schedule from API:', response.data)
        }
      } catch (apiError) {
        console.warn('Could not fetch schedule from API, using default:', apiError)
      }
    }
  } catch (err) {
    console.error('Failed to load schedule:', err)
    error.value = 'Failed to load schedule'
  } finally {
    loading.value = false
  }
}

const saveSchedule = async (e) => {
  if (e) {
    e.preventDefault()
  }
  
  saving.value = true
  error.value = ''
  
  try {
    if (!currentUserId.value) {
      throw new Error('User not logged in')
    }
    
    const invalidDays = daysOfWeek.filter(day => {
      if (!schedule[day].enabled) return false
      const start = schedule[day].startTime
      const end = schedule[day].endTime
      if (!start || !end) return true
      
      const [startHours, startMins] = start.split(':').map(Number)
      const [endHours, endMins] = end.split(':').map(Number)
      
      if (isNaN(startHours) || isNaN(startMins) || isNaN(endHours) || isNaN(endMins)) {
        return true
      }
      
      if (endHours < startHours || (endHours === startHours && endMins <= startMins)) {
        return true
      }
      
      return false
    })
    
    if (invalidDays.length > 0) {
      throw new Error(`Invalid time range for: ${invalidDays.join(', ')}. End time must be after start time.`)
    }
    
    const scheduleToSave = {}
    daysOfWeek.forEach(day => {
      scheduleToSave[day] = {
        enabled: schedule[day].enabled,
        startTime: schedule[day].startTime,
        endTime: schedule[day].endTime
      }
    })
    
    localStorage.setItem(`user_${currentUserId.value}_schedule`, JSON.stringify(scheduleToSave))
    
    showNotification('Schedule saved successfully!', 'success')
  } catch (err) {
    console.error('Failed to save schedule:', err)
    const errorMessage = err.message || 'Failed to save schedule. Please check your input.'
    error.value = errorMessage
    
    await nextTick()
    const errorEl = document.querySelector('.error')
    if (errorEl) {
      errorEl.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }
    
    showNotification(errorMessage, 'error', 5000)
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  try {
    const user = JSON.parse(localStorage.getItem('currentUser') || 'null')
    if (user?.id) {
      currentUserId.value = String(user.id)
      await loadSchedule()
    } else {
      error.value = 'Please log in to manage your schedule'
      return
    }
    
    let lastSavedSchedule = JSON.stringify(schedule)
    const saveInterval = setInterval(() => {
      const currentSchedule = JSON.stringify(schedule)
      if (currentSchedule !== lastSavedSchedule) {
        saveSchedule()
        lastSavedSchedule = currentSchedule
      }
    }, 30000)
    
    autoClockOutInterval.value = setInterval(async () => {
      await checkWorkingTimeAlert()
    }, 60000)
    await checkWorkingTimeAlert()
    
    onBeforeUnmount(() => {
      clearInterval(saveInterval)
      if (autoClockOutInterval.value) {
        clearInterval(autoClockOutInterval.value)
      }
    })
  } catch (error) {
    console.error('Error loading user data:', error)
    error.value = 'Failed to load user data. Please refresh the page.'
    
    showNotification('Failed to load schedule', 'error')
  }
})
</script>

<style scoped>
.warning-badge {
  margin-left: 0.5rem;
  color: #f59e0b;
  font-size: 0.8em;
  vertical-align: middle;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@media (max-width: 768px) {
  .day-schedule {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .time-inputs {
    width: 100%;
    margin-left: 1.75rem;
  }
  
  .time-inputs input[type="time"] {
    flex-grow: 1;
  }
  
  .form-actions button {
    width: 100%;
  }
  
  .schedule-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .schedule-date {
    width: 100%;
    padding-bottom: 0.25rem;
    border-bottom: 1px solid #2d3748;
  }
}
</style>