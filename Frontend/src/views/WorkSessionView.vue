<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Work Session</h1>
        <p class="text-gray-600">Start and end your work day with smart time tracking</p>
      </div>

      <!-- Main Work Control Card -->
      <div class="bg-white rounded-xl shadow-lg border border-gray-200 p-8 mb-6">
        <!-- Current Status -->
        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-24 h-24 rounded-full mb-4"
               :class="isWorkingNow ? 'bg-green-100' : 'bg-gray-100'">
            <span class="text-4xl">{{ isWorkingNow ? '🏢' : '🏠' }}</span>
          </div>
          <h2 class="text-2xl font-bold text-gray-900 mb-2">
            {{ isWorkingNow ? 'Currently Working' : 'Not Working' }}
          </h2>
          <p class="text-gray-600">
            {{ currentStatusText }}
          </p>
        </div>

        <!-- Live Timer -->
        <div v-if="isWorkingNow" class="bg-blue-50 rounded-lg p-6 mb-6 text-center">
          <p class="text-sm text-blue-600 font-medium mb-2">Work Duration</p>
          <p class="text-4xl font-bold text-blue-900 font-mono">{{ liveWorkDuration }}</p>
          <p class="text-sm text-blue-600 mt-2">Started at {{ workStartTime }}</p>
        </div>

        <!-- Schedule Info -->
        <div class="bg-gray-50 rounded-lg p-4 mb-6">
          <!-- Flexible Time Badge -->
          <div v-if="currentUser?.flexible_time_enabled" class="mb-3 p-2 bg-blue-100 border border-blue-300 rounded-lg">
            <div class="flex items-center justify-center gap-2">
              <span class="text-lg">⚡</span>
              <span class="text-sm font-medium text-blue-900">Flexible Time Enabled</span>
            </div>
            <p class="text-xs text-blue-700 text-center mt-1">You can work anytime without early/late alerts</p>
          </div>
          
          <div class="grid grid-cols-2 gap-4 text-center">
            <div>
              <p class="text-sm text-gray-500">Scheduled Start</p>
              <p class="text-lg font-bold text-gray-900">{{ scheduledStart }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-500">Scheduled End</p>
              <p class="text-lg font-bold text-gray-900">{{ scheduledEnd }}</p>
            </div>
          </div>
        </div>

        <!-- Work Start/End Buttons -->
        <div class="flex gap-4">
          <button
            v-if="!isWorkingNow"
            @click="handleWorkStart"
            class="flex-1 py-4 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
            :disabled="processing"
          >
            <span class="text-2xl">▶️</span>
            <span>{{ processing ? 'Starting...' : 'Work Start' }}</span>
          </button>

          <button
            v-if="isWorkingNow"
            @click="handleWorkEnd"
            class="flex-1 py-4 bg-red-600 text-white font-bold rounded-lg hover:bg-red-700 transition-colors flex items-center justify-center gap-2"
            :disabled="processing"
          >
            <span class="text-2xl">⏹️</span>
            <span>{{ processing ? 'Ending...' : 'Work End' }}</span>
          </button>
        </div>
      </div>

      <!-- Today's Summary -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Today's Summary</h3>
        <div class="grid grid-cols-3 gap-4">
          <div class="text-center p-4 bg-blue-50 rounded-lg">
            <p class="text-2xl font-bold text-blue-600">{{ todayHours }}</p>
            <p class="text-sm text-blue-600">Total Hours</p>
          </div>
          <div class="text-center p-4 bg-green-50 rounded-lg">
            <p class="text-2xl font-bold text-green-600">{{ regularHours }}</p>
            <p class="text-sm text-green-600">Regular Hours</p>
          </div>
          <div class="text-center p-4 bg-orange-50 rounded-lg">
            <p class="text-2xl font-bold text-orange-600">{{ overtimeHours }}</p>
            <p class="text-sm text-orange-600">Overtime</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Early Arrival Modal -->
    <div v-if="showEarlyArrivalModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl shadow-2xl max-w-md w-full mx-4 p-6">
        <div class="text-center mb-4">
          <span class="text-6xl">🌅</span>
          <h3 class="text-xl font-bold text-gray-900 mt-4">You're Early!</h3>
          <p class="text-gray-600 mt-2">
            Your scheduled start time is {{ scheduledStart }}, but you're starting at {{ actualStartTime }}.
            That's {{ earlyMinutes }} minutes early.
          </p>
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Please provide a reason for early arrival:
          </label>
          <textarea
            v-model="earlyArrivalReason"
            rows="3"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
            placeholder="e.g., Early meeting, catching up on work, etc."
          ></textarea>
        </div>

        <div class="flex gap-3">
          <button
            @click="confirmEarlyStart"
            class="flex-1 py-2 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700"
            :disabled="!earlyArrivalReason.trim()"
          >
            Start Work
          </button>
          <button
            @click="cancelEarlyStart"
            class="flex-1 py-2 bg-gray-200 text-gray-700 font-medium rounded-lg hover:bg-gray-300"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>

    <!-- Late Arrival Modal (After End Time) -->
    <div v-if="showLateArrivalModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl shadow-2xl max-w-md w-full mx-4 p-6">
        <div class="text-center mb-4">
          <span class="text-6xl">⚠️</span>
          <h3 class="text-xl font-bold text-orange-900 mt-4">Starting After Scheduled Hours!</h3>
          <p class="text-orange-700 mt-2">
            Your scheduled work hours are {{ scheduledStart }} - {{ scheduledEnd }}.
            You're starting at {{ actualStartTime }}, which is {{ lateMinutes }} minutes after your scheduled end time.
          </p>
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Please provide a reason for starting after scheduled hours:
          </label>
          <textarea
            v-model="lateArrivalReason"
            rows="3"
            class="w-full px-3 py-2 border border-orange-300 rounded-lg focus:ring-orange-500 focus:border-orange-500"
            placeholder="e.g., Special project, overtime work, urgent task, etc."
          ></textarea>
        </div>

        <div class="bg-orange-50 border border-orange-200 rounded-lg p-3 mb-4">
          <p class="text-sm text-orange-800">
            <strong>Note:</strong> Starting work after your scheduled end time may result in overtime hours being tracked.
          </p>
        </div>

        <div class="flex gap-3">
          <button
            @click="confirmLateStart"
            class="flex-1 py-2 bg-orange-600 text-white font-medium rounded-lg hover:bg-orange-700"
            :disabled="!lateArrivalReason.trim()"
          >
            Start Work
          </button>
          <button
            @click="cancelLateStart"
            class="flex-1 py-2 bg-gray-200 text-gray-700 font-medium rounded-lg hover:bg-gray-300"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>

    <!-- End of Day Alert -->
    <div v-if="showEndOfDayAlert" class="fixed top-4 right-4 bg-orange-100 border-l-4 border-orange-500 p-4 rounded-lg shadow-lg z-50 max-w-md animate-bounce">
      <div class="flex items-start">
        <span class="text-3xl mr-3">⏰</span>
        <div class="flex-1">
          <h4 class="font-bold text-orange-900 mb-1">Time to Clock Out!</h4>
          <p class="text-sm text-orange-800">Your scheduled work hours have ended. Please clock out now.</p>
          <div class="mt-3 flex gap-2">
            <button
              @click="handleWorkEnd"
              class="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded hover:bg-orange-700"
            >
              Clock Out Now
            </button>
            <button
              @click="dismissEndOfDayAlert"
              class="px-4 py-2 bg-white text-orange-600 text-sm font-medium rounded border border-orange-600 hover:bg-orange-50"
            >
              Dismiss
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { clockinsApi } from '../api/clockins'
import { userSchedulesApi } from '../api/userSchedules'
import { workingTimesApi } from '../api/workingTimes'
import { notificationService } from '../services/notificationService'
import emailService from '../services/emailService'
import { formatTimeHHMMSS, formatDateTimeHHMMSS, formatHoursToHHMMSS } from '../utils/timeFormatter'

// Reactive state
const processing = ref(false)
const isWorkingNow = ref(false)
const workStartTime = ref(null)
const workStartDate = ref(null)
const liveSeconds = ref(0)
const todayHours = ref('0:00')
const regularHours = ref('0:00')
const overtimeHours = ref('0:00')
const scheduledStart = ref('09:00')
const scheduledEnd = ref('17:00')
const showEarlyArrivalModal = ref(false)
const showLateArrivalModal = ref(false)
const showEndOfDayAlert = ref(false)
const earlyArrivalReason = ref('')
const lateArrivalReason = ref('')
const actualStartTime = ref('')
const earlyMinutes = ref(0)
const lateMinutes = ref(0)
const endOfDayAlertTimeout = ref(null)
const emailAlertTimeout = ref(null)

let timerInterval = null
let endOfDayCheckInterval = null

// Current user
const currentUser = ref(null)

// Computed properties
const currentStatusText = computed(() => {
  if (isWorkingNow.value) {
    return `You started work at ${workStartTime.value}`
  }
  return 'Click "Work Start" to begin your day'
})

const liveWorkDuration = computed(() => {
  const hours = Math.floor(liveSeconds.value / 3600)
  const minutes = Math.floor((liveSeconds.value % 3600) / 60)
  const seconds = liveSeconds.value % 60
  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
})

// Methods
const loadUserSchedule = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    currentUser.value = user

    const response = await userSchedulesApi.getByUser(user.id)
    const schedules = response.data || []
    
    console.log('Loaded schedules:', schedules)
    
    // Get today's schedule
    const today = new Date()
    const dayName = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][today.getDay()]
    const todaySchedule = schedules.find(s => s.day_of_week.toLowerCase() === dayName)
    
    console.log('Today is:', dayName)
    console.log('Today schedule:', todaySchedule)
    
    if (todaySchedule) {
      // Handle different possible field names from backend
      const startTime = todaySchedule.scheduled_start_time || todaySchedule.start_time
      const endTime = todaySchedule.scheduled_end_time || todaySchedule.end_time
      
      scheduledStart.value = formatTime(startTime)
      scheduledEnd.value = formatTime(endTime)
      
      console.log('Set scheduled start to:', scheduledStart.value)
      console.log('Set scheduled end to:', scheduledEnd.value)
    } else {
      console.log('No schedule found for today, using defaults: 09:00 - 17:00')
    }
  } catch (error) {
    console.error('Error loading user schedule:', error)
    console.log('Using default schedule: 09:00 - 17:00')
    // Ensure we have default values
    scheduledStart.value = '09:00'
    scheduledEnd.value = '17:00'
  }
}

const checkCurrentStatus = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const response = await clockinsApi.listByUser(user.id)
    const clocks = response.data || []
    
    if (clocks.length > 0) {
      const lastClock = clocks[0]
      isWorkingNow.value = lastClock.status === true
      
      if (isWorkingNow.value) {
        workStartDate.value = new Date(lastClock.time)
        workStartTime.value = formatDateTime(lastClock.time)
        startLiveTimer()
      }
    }
    
    await loadTodaySummary()
  } catch (error) {
    console.error('Error checking status:', error)
  }
}

const handleWorkStart = async () => {
  const now = new Date()
  const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
  actualStartTime.value = currentTime
  
  console.log('Current time:', currentTime)
  console.log('Scheduled start:', scheduledStart.value)
  console.log('Scheduled end:', scheduledEnd.value)
  console.log('Flexible time enabled:', currentUser.value?.flexible_time_enabled)
  
  // If user has flexible time permission, skip time validation
  if (currentUser.value?.flexible_time_enabled) {
    console.log('User has flexible time permission - starting work without alerts')
    await startWork()
    return
  }
  
  // Parse scheduled times
  const [schedStartHour, schedStartMin] = scheduledStart.value.split(':').map(Number)
  const [schedEndHour, schedEndMin] = scheduledEnd.value.split(':').map(Number)
  const schedStartTime = schedStartHour * 60 + schedStartMin
  const schedEndTime = schedEndHour * 60 + schedEndMin
  const currTime = now.getHours() * 60 + now.getMinutes()
  
  console.log('Current time (minutes):', currTime)
  console.log('Scheduled start (minutes):', schedStartTime)
  console.log('Scheduled end (minutes):', schedEndTime)
  
  if (currTime < schedStartTime) {
    // User is early (before start time)
    earlyMinutes.value = schedStartTime - currTime
    console.log('Early by', earlyMinutes.value, 'minutes')
    showEarlyArrivalModal.value = true
  } else if (currTime > schedEndTime) {
    // User is late (after end time)
    lateMinutes.value = currTime - schedEndTime
    console.log('Late by', lateMinutes.value, 'minutes')
    showLateArrivalModal.value = true
  } else {
    // Normal start (within scheduled hours)
    console.log('Within scheduled hours, starting work normally')
    await startWork()
  }
}

const confirmEarlyStart = async () => {
  showEarlyArrivalModal.value = false
  
  // Send email notification about early arrival
  if (currentUser.value) {
    await emailService.sendEarlyArrivalNotification(currentUser.value, {
      scheduled_start: scheduledStart.value,
      actual_start: actualStartTime.value,
      early_minutes: earlyMinutes.value,
      reason: earlyArrivalReason.value
    })
  }
  
  await startWork(earlyArrivalReason.value)
  earlyArrivalReason.value = ''
}

const cancelEarlyStart = () => {
  showEarlyArrivalModal.value = false
  earlyArrivalReason.value = ''
}

const confirmLateStart = async () => {
  showLateArrivalModal.value = false
  
  // Send notification about late arrival
  if (currentUser.value) {
    notificationService.warning(`Starting work ${lateMinutes.value} minutes after scheduled end time`)
  }
  
  await startWork(lateArrivalReason.value, true)
  lateArrivalReason.value = ''
}

const cancelLateStart = () => {
  showLateArrivalModal.value = false
  lateArrivalReason.value = ''
}

const startWork = async (reason = null, isLate = false) => {
  processing.value = true
  try {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    
    // Get location
    const location = await getLocation()
    
    // Clock in via API
    await clockinsApi.toggleForUser(user.id, location)
    
    isWorkingNow.value = true
    workStartDate.value = new Date()
    workStartTime.value = formatDateTime(new Date())
    
    startLiveTimer()
    
    notificationService.success('Work started successfully!')
    
    if (reason && !isLate) {
      notificationService.info(`Early start reason recorded: ${reason}`)
    } else if (reason && isLate) {
      notificationService.warning(`Late start reason recorded: ${reason}`)
    }
  } catch (error) {
    console.error('Error starting work:', error)
    notificationService.error('Failed to start work')
  } finally {
    processing.value = false
  }
}

const handleWorkEnd = async () => {
  processing.value = true
  try {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    
    // Get location
    const location = await getLocation()
    
    // Clock out via API
    await clockinsApi.toggleForUser(user.id, location)
    
    // Calculate hours
    const endTime = new Date()
    const duration = (endTime - workStartDate.value) / 1000 / 60 / 60 // hours
    const overtime = Math.max(0, duration - 8)
    
    // Send overtime email if applicable
    if (overtime > 0 && currentUser.value) {
      await emailService.sendOvertimeAlert(currentUser.value, {
        total_hours: formatHours(duration),
        overtime_hours: formatHours(overtime),
        work_start: workStartTime.value,
        work_end: formatDateTime(endTime)
      })
    }
    
    isWorkingNow.value = false
    stopLiveTimer()
    clearEndOfDayAlert()
    
    await loadTodaySummary()
    
    notificationService.success('Work ended successfully!')
    
    if (overtime > 0) {
      notificationService.info(`Overtime recorded: ${formatHours(overtime)}`)
    }
  } catch (error) {
    console.error('Error ending work:', error)
    notificationService.error('Failed to end work')
  } finally {
    processing.value = false
  }
}

const startLiveTimer = () => {
  if (timerInterval) clearInterval(timerInterval)
  
  timerInterval = setInterval(() => {
    const now = new Date()
    liveSeconds.value = Math.floor((now - workStartDate.value) / 1000)
  }, 1000)
}

const stopLiveTimer = () => {
  if (timerInterval) {
    clearInterval(timerInterval)
    timerInterval = null
  }
  liveSeconds.value = 0
}

const checkEndOfDay = () => {
  if (!isWorkingNow.value) return
  
  const now = new Date()
  const [schedHour, schedMin] = scheduledEnd.value.split(':').map(Number)
  const schedEndTime = schedHour * 60 + schedMin
  const currentTime = now.getHours() * 60 + now.getMinutes()
  
  // If it's past scheduled end time and user hasn't clocked out
  if (currentTime >= schedEndTime && !showEndOfDayAlert.value) {
    showEndOfDayAlert.value = true
    
    // Set timeout to send email if no response in 1 minute
    emailAlertTimeout.value = setTimeout(async () => {
      if (isWorkingNow.value && currentUser.value) {
        await emailService.sendForgotClockOutEmail(currentUser.value, {
          clock_in_time: workStartTime.value,
          expected_clock_out: scheduledEnd.value,
          current_time: formatDateTime(new Date())
        })
        notificationService.warning('Clock-out reminder sent to your email')
      }
    }, 60000) // 1 minute
  }
}

const dismissEndOfDayAlert = () => {
  showEndOfDayAlert.value = false
  if (emailAlertTimeout.value) {
    clearTimeout(emailAlertTimeout.value)
    emailAlertTimeout.value = null
  }
}

const clearEndOfDayAlert = () => {
  showEndOfDayAlert.value = false
  if (emailAlertTimeout.value) {
    clearTimeout(emailAlertTimeout.value)
    emailAlertTimeout.value = null
  }
}

const loadTodaySummary = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const today = new Date()
    const startOfDay = new Date(today.setHours(0, 0, 0, 0))
    const endOfDay = new Date(today.setHours(23, 59, 59, 999))
    
    const response = await workingTimesApi.list(user.id, startOfDay.toISOString(), endOfDay.toISOString())
    const workingTimes = response.data || []
    
    let total = 0
    workingTimes.forEach(wt => {
      if (wt.actual_hours) {
        total += wt.actual_hours
      }
    })
    
    const regular = Math.min(total, 8)
    const overtime = Math.max(0, total - 8)
    
    todayHours.value = formatHours(total)
    regularHours.value = formatHours(regular)
    overtimeHours.value = formatHours(overtime)
  } catch (error) {
    console.error('Error loading today summary:', error)
  }
}

const getLocation = () => {
  return new Promise((resolve) => {
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          resolve({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude
          })
        },
        () => {
          resolve({ latitude: null, longitude: null })
        }
      )
    } else {
      resolve({ latitude: null, longitude: null })
    }
  })
}

const formatTime = (timeString) => {
  if (!timeString) return '00:00:00'
  // If it's already in HH:MM:SS format, return as is
  if (timeString.length >= 8) return timeString.substring(0, 8)
  // If it's in HH:MM format, add seconds
  return timeString.substring(0, 5) + ':00'
}

const formatDateTime = (date) => {
  return formatTimeHHMMSS(date)
}

const formatHours = (hours) => {
  return formatHoursToHHMMSS(hours)
}

// Lifecycle
onMounted(async () => {
  await loadUserSchedule()
  await checkCurrentStatus()
  
  // Check end of day every minute
  endOfDayCheckInterval = setInterval(checkEndOfDay, 60000)
  checkEndOfDay() // Check immediately
})

onUnmounted(() => {
  stopLiveTimer()
  if (endOfDayCheckInterval) clearInterval(endOfDayCheckInterval)
  if (emailAlertTimeout.value) clearTimeout(emailAlertTimeout.value)
})
</script>

