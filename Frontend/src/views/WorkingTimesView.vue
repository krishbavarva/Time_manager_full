<template>
  <section>
    <h1>Daily Schedule</h1>
      <div class="card">
        <h2>Set Your Weekly Schedule</h2>
        <p class="hint">Define your regular working hours for each day of the week.</p>
        
        <form class="schedule-form" @submit.prevent="saveSchedule">
          <div v-for="day in daysOfWeek" :key="day" class="day-schedule">
            <label class="day-label">
              <input type="checkbox" v-model="schedule[day].enabled" />
              {{ day }}
            </label>
            <div class="time-inputs" v-if="schedule[day].enabled">
              <input 
                type="time" 
                v-model="schedule[day].startTime"
                :disabled="!schedule[day].enabled"
                required
              />
              <span>to</span>
              <input 
                type="time" 
                v-model="schedule[day].endTime"
                :disabled="!schedule[day].enabled"
                required
              />
            </div>
          </div>
          <div class="form-actions">
            <button type="submit" :disabled="saving">
              {{ saving ? 'Saving...' : 'Save Schedule' }}
            </button>
          </div>
        </form>
      
          <h2>Upcoming Schedule</h2>
          <p v-if="loading">Loading schedule...</p>
          <p v-else-if="Object.keys(upcomingSchedule).length === 0" class="no-data">
            No upcoming schedule. Please set your weekly schedule above.
          </p>
          <div v-else class="upcoming-schedule">
        <div v-for="(item, date) in upcomingSchedule" :key="date" class="schedule-item">
              <div class="schedule-date">
            {{ formatScheduleDate(date) }}
                       <!-- <span v-if="!item.isWithinWorkingHours" class="warning-badge" title="Outside working hours (9 AM - 5 PM)">⚠️</span> -->
              </div>
              <div class="schedule-time">
                {{ formatTime(item.startTime) }} - {{ formatTime(item.endTime) }}
                <span class="schedule-duration">
                  ({{ item.formattedDuration }})
                </span>
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
    // Get the current time for clock-out
    const now = new Date()
    const endTime = now.toISOString()
    
    console.log('Current user ID:', currentUserId.value)
    console.log('Current time:', endTime)
    
    // Get the most recent working time record for the user
    const response = await workingTimesApi.list(currentUserId.value, { 
      end: endTime,
      limit: 1,
      sort: '-start_time'
    })
    
    if (response && response.data && response.data.length > 0) {
      const latestRecord = response.data[0]
      
      // Only update if the record doesn't have an end time (clocked in but not out)
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
    
    // Reset auto clock-out state
    autoClockOutTime.value = null
    showAutoClockOutNotification.value = false
    
  } catch (error) {
    console.error('Clock out failed:', error)
    
    // More detailed error handling
    let errorMessage = 'Failed to clock out. '
    
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
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
      // The request was made but no response was received
      console.error('No response received:', error.request)
      errorMessage += 'No response from server. Please check your connection.'
    } else {
      // Something happened in setting up the request that triggered an Error
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
    
    // Create date range for today (without modifying original date)
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0)
    const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999)
    
    // First, check if user has any clock-in records for today
    const response = await workingTimesApi.list(currentUserId.value, { 
      limit: 1,
      sort: '-start_time',
      start: startOfDay.toISOString(),
      end: endOfDay.toISOString()
    })
    
    // If no records for today or latest record has end_time, user is not clocked in
    const isClockedIn = response?.data?.length > 0 && !response.data[0].end_time
    
    if (!isClockedIn) {
      console.log('User is not clocked in - no alert needed')
      return false
    }
    
    // Check if today is a working day with end time set
    const hasWorkingHours = schedule[today]?.enabled && schedule[today].endTime
    
    if (!hasWorkingHours) {
      console.log('No working hours set for today - no alert')
      return false
    }
    
    // Calculate current time and end time in minutes
    const currentTime = now.getHours() * 60 + now.getMinutes()
    const [endHour, endMinute] = schedule[today].endTime.split(':').map(Number)
    const endTimeInMinutes = endHour * 60 + endMinute
    
    // Show alert if current time is past end time (but don't auto clock out)
    if (currentTime >= endTimeInMinutes) {
      console.log('Working time has ended - showing alert to user')
      
      // Show browser alert to remind user to clock out
      alert('You are still clocked in. Your working time has ended. Please remember to clock out!')
      
      // Show UI notification as well
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
  
  // Access the notification component's show method
  nextTick(() => {
    if (notificationRef.value) {
      notificationRef.value.show()
    }
  })
}

const daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

// Default schedule
const defaultSchedule = daysOfWeek.reduce((acc, day) => {
  acc[day] = { enabled: false, startTime: '09:00', endTime: '17:00' }
  return acc
}, {})

const schedule = reactive(JSON.parse(JSON.stringify(defaultSchedule)))

// Generate upcoming schedule for the next 7 days with working hours info
const upcomingSchedule = computed(() => {
  const result = {}
  const today = new Date()
  
  for (let i = 0; i < 7; i++) {
    const date = new Date(today)
    date.setDate(today.getDate() + i)
    const dayName = daysOfWeek[date.getDay() === 0 ? 6 : date.getDay() - 1] // Convert to 0-6 (Mon-Sun)
    
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
  // If it's already in HH:MM format
  if (typeof time === 'string' && time.match(/^\d{2}:\d{2}$/)) {
    const [hours, minutes] = time.split(':')
    const date = new Date()
    date.setHours(parseInt(hours), parseInt(minutes))
    return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
  }
  
  // Handle ISO date strings
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

// Check if a time is within standard working hours (9 AM to 5 PM)
const isWithinWorkingHours = (time) => {
  if (!time) return false
  try {
    const [hours, minutes] = time.split(':').map(Number)
    const totalMinutes = hours * 60 + minutes
    // Standard working hours: 9:00 AM to 5:00 PM (540 to 1020 in minutes)
    return totalMinutes >= 540 && totalMinutes <= 1020
  } catch (e) {
    console.error('Error checking working hours for time:', time, e)
    return false
  }
}

// Calculate working minutes between two times
const getWorkingMinutes = (start, end) => {
  if (!start || !end) return 0
  
  try {
    const startDate = new Date()
    const startTime = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), ...start.split(':').map(Number))
    const endTime = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), ...end.split(':').map(Number))
    
    // Calculate total minutes (handling overnight)
    const totalMinutes = Math.abs(endTime - startTime) / 60000
    
    // Return the actual time difference in minutes
    return totalMinutes
  } catch (e) {
    console.error('Error calculating working minutes:', { start, end }, e)
    return 0
  }
}

// Format minutes into hours and minutes
const formatDuration = (minutes) => {
  if (minutes <= 0) return '0h 0m'
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  return `${hours}h ${mins}m`
}

const calculateDuration = (start, end) => {
  if (!start || !end) return '--'
  
  // Calculate working minutes between start and end times
  const workingMinutes = getWorkingMinutes(start, end)
  
  // Get total minutes for comparison
  const [startHour, startMinute] = start.split(':').map(Number)
  const [endHour, endMinute] = end.split(':').map(Number)
  let totalMinutes = (endHour * 60 + endMinute) - (startHour * 60 + startMinute)
  if (totalMinutes < 0) totalMinutes += 24 * 60
  
  // If no working minutes, return 0
  if (workingMinutes <= 0) return '0h 0m (outside working hours)'
  
  // If working minutes is less than total minutes, show both
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
    
    // Try to load from localStorage first
    const savedSchedule = localStorage.getItem(`user_${currentUserId.value}_schedule`)
    if (savedSchedule) {
      const parsed = JSON.parse(savedSchedule)
      daysOfWeek.forEach(day => {
        if (parsed[day]) {
          // Only update if the saved value exists for this day
          schedule[day] = { 
            enabled: parsed[day].enabled !== undefined ? parsed[day].enabled : false,
            startTime: parsed[day].startTime || '09:00',
            endTime: parsed[day].endTime || '17:00'
          }
        }
      })
    } else {
      // If no saved schedule, try to fetch from API
      try {
        const response = await workingTimesApi.list(currentUserId.value)
        if (response && response.data) {
          // Process API response if needed
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
  // Prevent default form submission if called from a form
  if (e) {
    e.preventDefault()
  }
  
  saving.value = true
  error.value = ''
  
  try {
    if (!currentUserId.value) {
      throw new Error('User not logged in')
    }
    
    // Validate schedule times
    const invalidDays = daysOfWeek.filter(day => {
      if (!schedule[day].enabled) return false
      const start = schedule[day].startTime
      const end = schedule[day].endTime
      if (!start || !end) return true
      
      const [startHours, startMins] = start.split(':').map(Number)
      const [endHours, endMins] = end.split(':').map(Number)
      
      // Basic validation
      if (isNaN(startHours) || isNaN(startMins) || isNaN(endHours) || isNaN(endMins)) {
        return true
      }
      
      // End time should be after start time
      if (endHours < startHours || (endHours === startHours && endMins <= startMins)) {
        return true
      }
      
      return false
    })
    
    if (invalidDays.length > 0) {
      throw new Error(`Invalid time range for: ${invalidDays.join(', ')}. End time must be after start time.`)
    }
    
    // Create a clean copy for saving
    const scheduleToSave = {}
    daysOfWeek.forEach(day => {
      scheduleToSave[day] = {
        enabled: schedule[day].enabled,
        startTime: schedule[day].startTime,
        endTime: schedule[day].endTime
      }
    })
    
    // Save to localStorage
    localStorage.setItem(`user_${currentUserId.value}_schedule`, JSON.stringify(scheduleToSave))
    
    // In a real app, you would save to the API here
    // await workingTimesApi.update(currentUserId.value, scheduleToSave)
    
    // Show success notification
    showNotification('Schedule saved successfully!', 'success')
  } catch (err) {
    console.error('Failed to save schedule:', err)
    const errorMessage = err.message || 'Failed to save schedule. Please check your input.'
    error.value = errorMessage
    
    // Scroll to error message
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

// Initialize the component
onMounted(async () => {
  try {
    // Get current user from localStorage
    const user = JSON.parse(localStorage.getItem('currentUser') || 'null')
    if (user?.id) {
      currentUserId.value = String(user.id)
      await loadSchedule()
    } else {
      error.value = 'Please log in to manage your schedule'
      return
    }
    
    // Set up auto-save interval
    let lastSavedSchedule = JSON.stringify(schedule)
    const saveInterval = setInterval(() => {
      const currentSchedule = JSON.stringify(schedule)
      if (currentSchedule !== lastSavedSchedule) {
        saveSchedule()
        lastSavedSchedule = currentSchedule
      }
    }, 30000)
    
    // Set up working time alert interval (every minute)
    autoClockOutInterval.value = setInterval(async () => {
      await checkWorkingTimeAlert()
    }, 60000)
    // Initial check
    await checkWorkingTimeAlert()
    
    // Clean up intervals on component unmount
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
.working-times-view {
  background-color: #ffffff;
  color: #000000;
  min-height: 100%;
  padding: 1rem;
}

.card { 
  margin-top: 1rem; 
  padding: 1.5rem; 
  background: #ffffff; 
  border: 1px solid #e5e7eb; 
  border-radius: 8px; 
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

h1 {
  color: #111827;
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

h2 {
  margin: 0 0 1.5rem;
  font-size: 1.25rem;
  font-weight: 600;
  color: #111827;
}

.text-muted {
  color: #6b7280;
  font-size: 0.9375rem;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  font-weight: 500;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary {
  background-color: #2563eb;
  color: white;
  border: 1px solid transparent;
}

.btn-primary:hover {
  background-color: #1d4ed8;
}

.btn-outline {
  background-color: white;
  border: 1px solid #d1d5db;
  color: #374151;
}

.btn-outline:hover {
  background-color: #f9fafb;
  border-color: #9ca3af;
}

.form-group {
  margin-bottom: 1rem;
}

.form-control {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  color: #111827;
  background-color: #ffffff;
}

.form-control:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.border {
  border-color: #e5e7eb;
}

.rounded-lg {
  border-radius: 0.5rem;
}

.text-gray-400 {
  color: #9ca3af;
}

.text-gray-500 {
  color: #000000;
}

.text-blue-600 {
  color: #252525;
}

.hint {
  color: #111111;
  margin-bottom: 1.5rem;
  font-size: 0.9rem;
}

.schedule-form {
  margin-bottom: 2rem;
}

.day-schedule {
  display: flex;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid #2d3748;
}

.day-label {
  display: flex;
  align-items: center;
  width: 120px;
  font-weight: 500;
  color: #000000;
}

.day-label input[type="checkbox"] {
  margin-right: 0.75rem;
}

.time-inputs {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-grow: 1;
}

.time-inputs input[type="time"] {
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  border: 1px solid #374151;
  background: #ffffff;
  color: #000000;
  font-size: 0.9rem;
}

.time-inputs span {
  color: #000000;
  font-size: 0.9rem;
}

.form-actions {
  margin-top: 1.5rem;
  display: flex;
  justify-content: flex-end;
}

.form-actions button {
  padding: 0.6rem 1.5rem;
  background: #2563eb;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s, transform 0.1s;
}

.form-actions button:hover {
  background: #1d4ed8;
  transform: translateY(-1px);
}

.form-actions button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.upcoming-schedule {
  margin-top: 1rem;
  border: 1px solid #2d3748;
  border-radius: 8px;
  overflow: hidden;
}

.schedule-item {
  padding: 1rem;
  display: flex;
  align-items: center;
  border-bottom: 1px solid #252525;
  background: rgba(255, 255, 255, 0.02);
}

.schedule-item:last-child {
  border-bottom: none;
}

.schedule-date {
  width: 40%;
  font-weight: 500;
  color: #000000;
}

.schedule-time {
}

.schedule-duration {
  font-size: 0.9em;
  color: #505050;
  margin-left: 0.5rem;
}

.schedule-duration.overtime {
  color: #ef4444;
  font-weight: 500;
}

.warning-badge {
  margin-left: 0.5rem;
  color: #f59e0b;
  font-size: 0.8em;
  vertical-align: middle;
}

.error { 
  color: #ef4444; 
  margin: 1rem 0;
  background: rgba(239, 68, 68, 0.1);
  border-radius: 6px;
  font-size: 0.9rem;
}

.no-data {
  text-align: center;
  color: #6b7280;
  padding: 2rem;
  font-style: italic;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
  margin: 1rem 0;
}

/* Auto Clock Out Notification */
.auto-clockout-notification {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: #1e293b;
  border-left: 4px solid #f59e0b;
  border-radius: 8px;
  padding: 1rem;
  max-width: 320px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  z-index: 1000;
  animation: slideIn 0.3s ease-out;
}

.notification-content {
  color: #e5e7eb;
}

.notification-actions {
  display: flex;
  gap: 0.75rem;
  margin-top: 0.75rem;
}

.btn-clockout-now {
  padding: 0.4rem 0.75rem;
  background: #f59e0b;
  color: #1f2937;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-clockout-now:hover {
  background: #d97706;
}

.btn-cancel {
  padding: 0.4rem 0.75rem;
  background: transparent;
  color: #9ca3af;
  border: 1px solid #4b5563;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel:hover {
  background: rgba(255, 255, 255, 0.05);
  color: #e5e7eb;
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

