<template>
  <section class="bg-white text-gray-800">
    <div class="flex justify-between items-center mb-8 flex-wrap gap-4">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 m-0">Time Tracking</h1>
        <p class="text-gray-500 text-sm">Manage your work hours and clock in/out</p>
      </div>
      <div class="flex items-center gap-2">
        <label for="date-filter" class="text-sm text-gray-600 mr-2">View Date:</label>
        <input 
          type="date" 
          id="date-filter" 
          v-model="selectedDate" 
          :max="today"
          class="border border-gray-300 rounded-md py-1 px-2 text-sm focus:outline-none focus:border-blue-600 focus:ring focus:ring-blue-600 focus:ring-opacity-10"
          @change="handleDateChange"
        >
      </div>
    </div>
    
    <div class="mt-6 p-6 bg-white border border-gray-200 rounded-xl shadow-sm">
      <div class="bg-blue-50 border border-blue-200 rounded-lg p-3 mb-4">
        <p class="text-sm text-blue-800 font-medium">📋 Official Attendance Tracking</p>
        <p class="text-xs text-blue-700">This is for official clock in/out attendance. Includes early/late arrival alerts and automatic clock-out reminders.</p>
      </div>
      <h2 class="text-xl font-semibold text-gray-900 m-0 mb-4">Clock In/Out (Official Attendance)</h2>
      <div class="flex flex-wrap items-center gap-4 mb-6">
        <button 
          @click="toggle" 
          class="px-4 py-2 rounded-lg font-medium transition-all duration-200 cursor-pointer bg-blue-600 text-white border border-blue-600 hover:bg-blue-700 hover:border-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          :disabled="creating"
        >
          {{ creating ? 'Processing...' : isClockedIn ? 'Clock Out' : 'Clock In' }}
        </button>
        <button 
          type="button" 
          @click="load" 
          class="px-4 py-2 rounded-lg font-medium transition-all duration-200 cursor-pointer bg-white border border-gray-300 text-gray-700 hover:bg-gray-50 hover:border-gray-400"
        >
          Refresh
        </button>
        <button 
          type="button" 
          @click="switchToToday" 
          class="px-4 py-2 rounded-lg font-medium transition-all duration-200 cursor-pointer bg-green-600 text-white border border-green-600 hover:bg-green-700 hover:border-green-700"
        >
          Today
        </button>
                                                                                                                                                                                                                            <!-- <button 
                                                                                                                                                                                                                              type="button" 
                                                                                                                                                                                                                              @click="switchToDataDate" 
                                                                                                                                                                                                                              class="px-4 py-2 rounded-lg font-medium transition-all duration-200 cursor-pointer bg-blue-600 text-white border border-blue-600 hover:bg-blue-700 hover:border-blue-700"
                                                                                                                                                                                                                            >
                                                                                                                                                                                                                              Data Date
                                                                                                                                                                                                                            </button> -->
        <!-- <button 
          type="button" 
          @click="testEmail" 
          class="px-4 py-2 rounded-lg font-medium transition-all duration-200 cursor-pointer bg-orange-600 text-white border border-orange-600 hover:bg-orange-700 hover:border-orange-700"
        >
          Test Email
        </button> -->
        
        <div v-if="runningSince" class="ml-auto flex items-center gap-2 bg-gray-50 px-4 py-2 rounded-lg">
          <div class="w-3 h-3 rounded-full bg-green-500 animate-pulse"></div>
          <span class="text-sm font-medium">Active session:</span>
          <span class="font-mono font-medium">{{ fmtHMS(liveSeconds) }}</span>
          <span class="text-sm text-gray-500">since {{ fmtIso(runningSince) }}</span>
        </div>
      </div>

      <div v-if="loading" class="p-4 text-center text-gray-500">
        Loading clock-in data...
      </div>
      <div v-else-if="error" class="p-4 bg-red-50 text-red-700 rounded-lg mb-6">
        {{ error }}
      </div>

      <div v-if="filteredClockins.length === 0" class="p-8 text-center text-gray-500">
        No clock-in/out records found for {{ formattedSelectedDate }}
      </div>
      <div v-else class="overflow-x-auto">
        <div class="mb-4 p-3 bg-gray-50 rounded-lg text-gray-700">
          Showing records for: <strong>{{ formattedSelectedDate }}</strong>
        </div>
        <table class="w-full border-separate border-spacing-0">
          <thead>
            <tr>
              <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Time</th>
              <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Status</th>
              <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Location</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredClockins.length === 0">
              <td colspan="3" class="text-center py-4 px-4 border-b border-gray-200 text-gray-500">
                No clock-in/out records found for {{ formattedSelectedDate }}
              </td>
            </tr>
            <tr v-else v-for="c in filteredClockins" :key="c.id" class="hover:bg-gray-50">
              <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200 text-gray-800">{{ fmtIso(c.time) }}</td>
              <td class="py-3 px-4 border-b border-gray-200">
                <span 
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  :class="c.status ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'"
                >
                  {{ c.status ? 'Clocked In' : 'Clocked Out' }}
                </span>
              </td>
              <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200">
                <a 
                  v-if="c.latitude && c.longitude" 
                  :href="`https://www.google.com/maps?q=${c.latitude},${c.longitude}`" 
                  target="_blank"
                  class="text-blue-600 hover:underline flex items-center"
                  title="View on Google Maps"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  View Location
                </a>
                <span v-else class="text-gray-400 text-sm">No location data</span>
              </td>
            </tr>
            <tr v-if="list.length === 0">
              <td colspan="3" class="text-center py-4 px-4 border-b border-gray-200 text-gray-500">
                No clock-in records found
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="mt-6 p-6 bg-white border border-gray-200 rounded-xl shadow-sm">
      <div class="flex flex-wrap items-center justify-between mb-4">
        <h2 class="text-xl font-semibold text-gray-900 m-0">Working Time Summary</h2>
        <div class="flex items-center gap-2">
          <label class="text-sm text-gray-600">Filter by date:</label>
          <input 
            type="date" 
            v-model="chartsDate" 
            @change="loadCharts"
            :max="today"
            class="border border-gray-300 rounded-md py-1 px-2 text-sm focus:outline-none focus:border-blue-600 focus:ring focus:ring-blue-600 focus:ring-opacity-10"
          />
        </div>
      </div>
      
      <div v-if="chartsLoading" class="p-4 text-center text-gray-500">
        Loading charts...
      </div>
      <div v-else-if="filteredSessions.length === 0" class="p-4 text-center text-gray-500">
        No working time data available for the selected period.
      </div>
      <template v-else>
        <div class="overflow-x-auto">
          <table class="w-full border-separate border-spacing-0">
            <thead>
              <tr>
                <th class="whitespace-nowrap text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Date</th>
                <th class="text-right py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Duration</th>
                <th class="text-right py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Hours</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="session in filteredSessions" :key="session.start" class="hover:bg-gray-50">
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200 text-gray-800">{{ new Date(session.start).toISOString().split('T')[0] }}</td>
                <td class="text-right font-mono py-3 px-4 border-b border-gray-200 text-gray-800">{{ fmtHMS(session.seconds || 0) }}</td>
                <td class="text-right py-3 px-4 border-b border-gray-200 text-gray-800">{{ ((session.seconds || 0) / 3600).toFixed(1) }}h</td>
              </tr>
              <tr class="font-medium bg-gray-50">
                <td class="py-3 px-4 border-b border-gray-200">Total</td>
                <td class="text-right font-mono py-3 px-4 border-b border-gray-200">
                  {{ fmtHMS(filteredSessions.reduce((sum, s) => sum + (s.seconds || 0), 0)) }}
                </td>
                <td class="text-right py-3 px-4 border-b border-gray-200">
                  {{ (filteredSessions.reduce((sum, s) => sum + (s.seconds || 0), 0) / 3600).toFixed(1) }}h
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </div>

    <div class="mt-6 p-6 bg-white border border-gray-200 rounded-xl shadow-sm">
      <h2 class="text-xl font-semibold text-gray-900 m-0 mb-4">Breaks</h2>
      <div v-if="breaks.length === 0" class="p-4 text-center text-gray-500">
        No break data available.
      </div>
      <template v-else>
        <div class="overflow-x-auto">
          <table class="w-full border-separate border-spacing-0">
            <thead>
              <tr>
                <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Start</th>
                <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">End</th>
                <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Minutes</th>
                <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Duration</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(b, i) in breaks" :key="i" class="hover:bg-gray-50">
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200 text-gray-800">{{ fmtIso(b.start) }}</td>
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200 text-gray-800">{{ fmtIso(b.end) }}</td>
                <td class="py-3 px-4 border-b border-gray-200 text-gray-800">{{ (b.seconds ? (b.seconds/60).toFixed(2) : b.minutes) }}</td>
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200 text-gray-800">{{ fmtHMS(b.seconds ?? (b.minutes * 60)) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="relative h-52 mt-6 bg-white rounded-lg border border-gray-200 p-4">
          <canvas ref="breaksCanvas" height="120"></canvas>
        </div>
      </template>
    </div>

    <div class="mt-6 p-6 bg-white border border-gray-200 rounded-xl shadow-sm">
      <div class="flex flex-wrap items-center justify-between mb-4">
        <h2 class="text-xl font-semibold text-gray-900 m-0">Working Sessions</h2>
        <div class="flex items-center gap-2">
          <label class="text-sm text-gray-600">Filter by date:</label>
          <input 
            type="date" 
            v-model="sessionsDate" 
            @change="filterSessionsByDate"
            :max="today"
            class="border border-gray-300 rounded-md py-1 px-2 text-sm focus:outline-none focus:border-blue-600 focus:ring focus:ring-blue-600 focus:ring-opacity-10"
          />
        </div>
      </div>
      <div v-if="filteredSessions.length === 0" class="p-4 text-center text-gray-500">
        No session data available for {{ formattedSessionsDate }}.
      </div>
      <template v-else>
        <div class="overflow-x-auto">
          <table class="w-full border-separate border-spacing-0">
            <thead>
              <tr>
                <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Start</th>
                <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">End</th>
                <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Minutes</th>
                <th class="text-left py-3 px-4 border-b border-gray-200 bg-gray-50 font-semibold text-gray-700 uppercase text-xs tracking-wider">Duration</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(s, i) in filteredSessions" :key="i" class="hover:bg-gray-50">
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200 text-gray-800">{{ fmtIso(s.start) }}</td>
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200 text-gray-800">{{ fmtIso(s.end) }}</td>
                <td class="py-3 px-4 border-b border-gray-200 text-gray-800">{{ (s.seconds ? (s.seconds/60).toFixed(2) : s.minutes) }}</td>
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200 text-gray-800">{{ fmtHMS(s.seconds ?? (s.minutes * 60)) }}</td>
              </tr>
              <tr v-if="filteredSessions.length > 0" class="font-medium bg-gray-50">
                <td colspan="2" class="text-right pr-4 py-3 px-4 border-b border-gray-200">Total Work Time:</td>
                <td class="py-3 px-4 border-b border-gray-200">{{ totalWorkMinutes.toFixed(2) }}</td>
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200">{{ fmtHMS(totalWorkMinutes * 60) }}</td>
              </tr>
              <tr v-if="filteredBreaks.length > 0" class="font-medium bg-gray-50">
                <td colspan="2" class="text-right pr-4 py-3 px-4 border-b border-gray-200">Total Break Time:</td>
                <td class="py-3 px-4 border-b border-gray-200">{{ totalBreakMinutes.toFixed(2) }}</td>
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200">{{ fmtHMS(totalBreakMinutes * 60) }}</td>
              </tr>
              <tr v-if="filteredSessions.length > 0 || filteredBreaks.length > 0" class="font-bold bg-gray-100">
                <td colspan="2" class="text-right pr-4 py-3 px-4 border-b border-gray-200">Total Time (Work + Break):</td>
                <td class="py-3 px-4 border-b border-gray-200">{{ (totalWorkMinutes + totalBreakMinutes).toFixed(2) }}</td>
                <td class="whitespace-nowrap py-3 px-4 border-b border-gray-200">{{ fmtHMS((totalWorkMinutes + totalBreakMinutes) * 60) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="relative h-52 mt-6 bg-white rounded-lg border border-gray-200 p-4">
          <canvas ref="sessionsCanvas" height="120"></canvas>
        </div>
      </template>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { clockinsApi } from '../api/clockins'
import { chartsApi } from '../api/charts'
import { userSchedulesApi } from '../api/userSchedules'
import { sendEarlyArrivalNotification, sendForgotClockOutEmail } from '../services/emailService'
import Chart from 'chart.js/auto'

// Get location with fallback to IP-based geolocation
const getLocation = async () => {
  // Try browser geolocation first
  if (navigator.geolocation) {
    try {
      console.log('🌍 Requesting browser geolocation...')
      const position = await new Promise((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(
          (pos) => {
            console.log('✅ Browser geolocation successful:', pos.coords)
            resolve(pos)
          },
          (err) => {
            console.warn('❌ Browser geolocation error:', err.message)
            if (err.code === 1) {
              console.warn('User denied geolocation permission')
            } else if (err.code === 2) {
              console.warn('Position unavailable')
            } else if (err.code === 3) {
              console.warn('Geolocation timeout')
            }
            reject(err)
          },
          {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 0
          }
        )
      })
      
      return {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
        accuracy: position.coords.accuracy,
        source: 'browser_geolocation'
      }
    } catch (error) {
      console.warn('⚠️ Browser geolocation failed, trying IP-based fallback', error.message)
    }
  } else {
    console.warn('⚠️ Navigator.geolocation not available in this browser')
  }
  
  // Fallback to IP-based geolocation
  try {
    console.log('🌐 Trying IP-based geolocation...')
    const response = await fetch('https://ipapi.co/json/')
    if (response.ok) {
      const data = await response.json()
      console.log('📍 IP geolocation response:', data)
      if (data.latitude && data.longitude) {
        return {
          latitude: parseFloat(data.latitude),
          longitude: parseFloat(data.longitude),
          city: data.city,
          region: data.region,
          country: data.country_name,
          source: 'ip_geolocation'
        }
      }
    }
  } catch (error) {
    console.error('❌ IP-based geolocation failed', error)
  }
  
  // If all methods fail, return null location with warning
  console.warn('⚠️ All location methods failed, proceeding without location')
  return {
    latitude: null,
    longitude: null,
    source: 'none'
  }
}

const list = ref([])
const filteredClockins = ref([])
const loading = ref(false)
const error = ref('')
const creating = ref(false)
const currentUserId = ref('')
const chartsDate = ref('')
const chartsLoading = ref(false)
const hoursRows = ref([])
const breaks = ref([])
const sessions = ref([])

// Track clock in/out state
const isClockedIn = ref(false)
const currentClockInTime = ref(null)
const filteredSessions = ref([])
const filteredBreaks = ref([])
const sessionsDate = ref('')
const hoursCanvas = ref(null)
const breaksCanvas = ref(null)
const sessionsCanvas = ref(null)
let hoursChart = null
let breaksChart = null
let sessionsChart = null

// Timer state
const runningSince = ref(null)
const liveSeconds = ref(0)
let timer = null
let clockOutAlertTimer = null
let dayCheckTimer = null

// User schedule and alert state
const userSchedules = ref([])
const currentUser = ref(null)

// Get current date in YYYY-MM-DD format
const getTodayDate = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const today = getTodayDate();
const selectedDate = ref(today) // Default to today
const todayFormatted = new Date().toLocaleDateString('en-US', { 
  weekday: 'long', 
  year: 'numeric', 
  month: 'long', 
  day: 'numeric' 
})

// Helper function to get today's schedule
const getTodaysSchedule = () => {
  const now = new Date()
  const dayOfWeek = now.toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase()
  
  return userSchedules.value.find(schedule => {
    return schedule.day_of_week === dayOfWeek && schedule.is_active
  })
}

// Helper function to create DateTime from time string
const createDateTimeFromTime = (timeString) => {
  const today = new Date()
  const [hours, minutes, seconds] = timeString.split(':')
  today.setHours(parseInt(hours), parseInt(minutes), parseInt(seconds || 0), 0)
  return today
}

// Helper function to check if clock in is early
const checkEarlyArrival = (clockInTime, scheduledStartTime) => {
  if (!scheduledStartTime) return false
  
  const clockIn = new Date(clockInTime)
  const scheduled = createDateTimeFromTime(scheduledStartTime)
  
  // Check if clock in is more than 30 minutes early
  const timeDiff = scheduled.getTime() - clockIn.getTime()
  return timeDiff > 30 * 60 * 1000 // 30 minutes in milliseconds
}

// Helper function to check if clock in is late (after scheduled end time)
const checkLateArrival = (clockInTime, scheduledEndTime) => {
  if (!scheduledEndTime) return false
  
  const clockIn = new Date(clockInTime)
  const scheduled = createDateTimeFromTime(scheduledEndTime)
  
  return clockIn.getTime() > scheduled.getTime()
}

// Helper function to show alert and get user reason
const showAlertWithReason = (title, message, type = 'warning') => {
  return new Promise((resolve) => {
    const reason = prompt(`${title}\n\n${message}\n\nPlease provide a reason:`)
    resolve(reason || 'No reason provided')
  })
}

// Helper function to start clock out alert timer
const startClockOutAlert = () => {
  const schedule = getTodaysSchedule()
  if (!schedule || !schedule.scheduled_end_time) return
  
  const scheduledEndTime = createDateTimeFromTime(schedule.scheduled_end_time)
  const now = new Date()
  const timeUntilEnd = scheduledEndTime.getTime() - now.getTime()
  
  console.log('🕐 Setting up clock out alert:', {
    scheduledEnd: scheduledEndTime.toLocaleString(),
    now: now.toLocaleString(),
    timeUntilEnd: `${Math.floor(timeUntilEnd / 1000 / 60)} minutes`
  })
  
  if (timeUntilEnd > 0) {
    // Set timer to show alert at scheduled end time
    clockOutAlertTimer = setTimeout(() => {
      showClockOutAlert()
    }, timeUntilEnd)
  }
}

  // Helper function to show clock out alert
  const showClockOutAlert = () => {
    if (!isClockedIn.value || !currentUser.value) return
    
    const alertMessage = `Your scheduled work hours have ended. Please clock out now.`
    
    if (confirm(`${alertMessage}\n\nClick OK to clock out, or Cancel to continue working.`)) {
      // User wants to clock out
      toggle()
    } else {
      // User chose to continue working, send email AFTER alert response
      console.log('📧 User ignored clock out alert - sending email after 1 minute...')
      setTimeout(() => {
        if (isClockedIn.value) {
          console.log('📧 Sending forgot clock out email AFTER alert...')
          sendForgotClockOutEmailNotification()
        }
      }, 60000) // 1 minute
    }
  }

// Helper function to send forgot clock out email
const sendForgotClockOutEmailNotification = async () => {
  if (!currentUser.value || !currentClockInTime.value) return
  
  try {
    console.log('📧 Preparing to send forgot clock out email...')
    const schedule = getTodaysSchedule()
    const clockInfo = {
      clock_in_time: new Date(currentClockInTime.value).toLocaleTimeString(),
      expected_clock_out: schedule?.scheduled_end_time || 'Not set',
      current_time: new Date().toLocaleTimeString()
    }
    
    console.log('📧 Clock info for email:', clockInfo)
    console.log('📧 Sending to:', currentUser.value.email)
    
    await sendForgotClockOutEmail(currentUser.value, clockInfo)
    console.log('✅ Forgot clock out email sent successfully')
  } catch (error) {
    console.error('❌ Failed to send forgot clock out email:', error)
  }
}
const fmtIso = (iso) => {
  if (!iso) return '--'
  const d = new Date(iso)
  if (isNaN(+d)) return String(iso)
  return d.toLocaleString()
}

const fmtMMSS = (totalSeconds) => {
  const sec = Math.max(0, Math.floor(Number(totalSeconds) || 0))
  const m = Math.floor(sec / 60)
  const s = sec % 60
  return `${m}:${String(s).padStart(2, '0')}`
}

const fmtHMS = (totalSeconds) => {
  const sec = Math.max(0, Math.floor(Number(totalSeconds) || 0))
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  const s = sec % 60
  return `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')}`
}

const startTimer = (fromIso) => {
  stopTimer()
  runningSince.value = fromIso
  const from = Date.parse(fromIso)
  timer = setInterval(() => { 
    liveSeconds.value = Math.max(0, Math.floor((Date.now() - from) / 1000)) 
  }, 1000)
}

const stopTimer = () => {
  if (timer) clearInterval(timer)
  timer = null
  runningSince.value = null
  liveSeconds.value = 0
}

// Computed property to format the selected date for display
const formattedSelectedDate = computed(() => {
  if (!selectedDate.value) return todayFormatted;
  if (selectedDate.value === today) return `Today, ${todayFormatted}`;
  
  const date = new Date(selectedDate.value);
  return date.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });
})

// Handle date change
const handleDateChange = () => {
  // Update the charts date to match the selected date
  if (selectedDate.value) {
    chartsDate.value = selectedDate.value;
    loadCharts(); // Reload charts when date changes
  }
  // Filter the clock-ins for the selected date
  filterClockinsByDate();
}

// Filter clock-ins by selected date
const filterClockinsByDate = () => {
  if (!selectedDate.value) {
    selectedDate.value = today; // Default to today if no date selected
  }
  
  console.log('🔵 Filtering clock-ins for date:', selectedDate.value)
  console.log('🔵 Available clock-ins:', list.value.length)
  
  filteredClockins.value = list.value.filter(clockin => {
    if (!clockin.time) return false
    
    // Convert the clock-in time to the user's local date
    const clockinDate = new Date(clockin.time)
    const localClockinDate = clockinDate.toISOString().split('T')[0]
    
    console.log('🔵 Clock-in time:', clockin.time, '→ Local date:', localClockinDate, 'vs Selected:', selectedDate.value)
    
    return localClockinDate === selectedDate.value
  })
  
  console.log('🔵 Filtered clock-ins count:', filteredClockins.value.length)
}

// Filter sessions and breaks by selected date
const filterSessionsAndBreaks = () => {
  try {
    if (!sessionsDate.value) {
      sessionsDate.value = today; // Default to today
    }
    
    console.log('🔵 Filtering sessions/breaks for date:', sessionsDate.value)
    console.log('🔵 Available sessions:', sessions.value.length)
    console.log('🔵 Available breaks:', breaks.value.length)
    
    // Convert dates to YYYY-MM-DD format for comparison
    const selectedDateStr = sessionsDate.value;
    
    // Filter sessions
    filteredSessions.value = sessions.value.filter(session => {
      if (!session?.start) return false;
      try {
        const sessionDate = new Date(session.start);
        const sessionDateStr = sessionDate.toISOString().split('T')[0];
        const matches = sessionDateStr === selectedDateStr;
        if (matches) {
          console.log('🔵 Matching session found:', session.start, '→', sessionDateStr)
        }
        return matches;
      } catch (e) {
        console.error('Error parsing session date:', session.start, e);
        return false;
      }
    });
    
    // Filter breaks
    filteredBreaks.value = breaks.value.filter(b => {
      if (!b?.start) return false;
      try {
        const breakDate = new Date(b.start);
        const breakDateStr = breakDate.toISOString().split('T')[0];
        const matches = breakDateStr === selectedDateStr;
        if (matches) {
          console.log('🔵 Matching break found:', b.start, '→', breakDateStr)
        }
        return matches;
      } catch (e) {
        console.error('Error parsing break date:', b.start, e);
        return false;
      }
    });
    
    console.log('🔵 Filtered sessions count:', filteredSessions.value.length)
    console.log('🔵 Filtered breaks count:', filteredBreaks.value.length)
    
    
    // Update charts with filtered data
    updateCharts();
  } catch (error) {
    console.error('Error in filterSessionsAndBreaks:', error);
  }
}

// Format sessions date for display
const formattedSessionsDate = computed(() => {
  if (!sessionsDate.value) return 'selected date';
  if (sessionsDate.value === today) return 'today';
  
  const date = new Date(sessionsDate.value);
  return date.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });
});

// filteredBreaks is now a ref, updated in updateFilteredData()

// Compute total work time in minutes
const totalWorkMinutes = computed(() => {
  return filteredSessions.value.reduce((total, session) => {
    const minutes = session.seconds ? (session.seconds / 60) : (session.minutes || 0);
    return total + minutes;
  }, 0);
});

// Compute total break time in minutes
const totalBreakMinutes = computed(() => {
  return filteredBreaks.value.reduce((total, b) => {
    const minutes = b.seconds ? (b.seconds / 60) : (b.minutes || 0);
    return total + minutes;
  }, 0);
});

const load = async () => {
  loading.value = true
  error.value = ''
  
  try {
    if (!currentUserId.value) { 
      list.value = []
      filteredClockins.value = []
      sessions.value = []
      filteredSessions.value = []
      isClockedIn.value = false
      currentClockInTime.value = null
      stopTimer()
      return 
    }
    
    // Load clock-ins for the user
    const res = await clockinsApi.listByUser(currentUserId.value)
    const data = Array.isArray(res?.data) ? res.data : (Array.isArray(res) ? res : [])
    
    // Keep location data as is from the server
    list.value = data
    
    // Update clocked in state based on the most recent record
    if (list.value.length > 0) {
      const lastRecord = list.value[0] // Assuming the list is sorted by time in descending order
      isClockedIn.value = lastRecord.status === true
      if (isClockedIn.value) {
        currentClockInTime.value = lastRecord.time
        startTimer(lastRecord.time)
      } else {
        currentClockInTime.value = null
        stopTimer()
      }
      
      // Only switch to most recent data date if no date is explicitly selected
      // Don't override if user wants to view today's date
      const mostRecentDate = new Date(lastRecord.time).toISOString().split('T')[0]
      if (!selectedDate.value) {
        console.log('🔵 No date selected, switching to most recent data date:', mostRecentDate)
        selectedDate.value = mostRecentDate
        chartsDate.value = mostRecentDate
        sessionsDate.value = mostRecentDate
      } else {
        // Keep the selected date but ensure charts and sessions use the same date
        console.log('🔵 Using selected date:', selectedDate.value)
        chartsDate.value = selectedDate.value
        sessionsDate.value = selectedDate.value
      }
    } else {
      isClockedIn.value = false
      currentClockInTime.value = null
      stopTimer()
    }
    
    // Filter clock-ins by the selected date
    filterClockinsByDate()
  } catch (_) {
    error.value = 'Failed to load clockins'
  } finally {
    loading.value = false
  }
}

const loadCharts = async () => {
  if (!currentUserId.value) { 
    hoursRows.value = []; 
    breaks.value = []; 
    sessions.value = [];
    await nextTick();
    updateCharts();
    return; 
  }
  
  // If no date is selected, use today's date
  if (!chartsDate.value) {
    chartsDate.value = today;
  }
  
  
  // Also update sessions date to match charts date
  if (sessionsDate.value !== chartsDate.value) {
    sessionsDate.value = chartsDate.value;
  }
  
  chartsLoading.value = true;
  try {
    // Load data for the selected date
    const dateFilter = { date: chartsDate.value };
    
    // Load all data in parallel
    const [hoursRes, breaksRes, sessRes] = await Promise.all([
      chartsApi.hoursByUser(currentUserId.value, dateFilter),
      chartsApi.breaksByUser(currentUserId.value, dateFilter),
      chartsApi.sessionsByUser(currentUserId.value, dateFilter)
    ]);
    
    hoursRows.value = Array.isArray(hoursRes?.data) ? hoursRes.data : [];
    breaks.value = Array.isArray(breaksRes?.data) ? breaksRes.data : [];
    sessions.value = Array.isArray(sessRes?.data) ? sessRes.data : [];
    
    
    // Update filtered sessions and breaks
    filterSessionsAndBreaks();
    
    // Wait for DOM to be ready before rendering charts
    await nextTick();
    updateCharts();
  } catch (error) {
    console.error('Error loading charts data:', error);
    hoursRows.value = [];
    breaks.value = [];
    sessions.value = [];
    filteredSessions.value = [];
    filteredBreaks.value = [];
    await nextTick();
    updateCharts();
  } finally {
    chartsLoading.value = false;
  }
}

const updateCharts = () => {
  // Hours by day (mm:ss)
  const labels = hoursRows.value.map(r => r.date)
  const seconds = hoursRows.value.map(r => r.seconds || (r.minutes * 60))
  if (hoursChart) hoursChart.destroy()
  if (hoursCanvas.value) {
    hoursChart = new Chart(hoursCanvas.value.getContext('2d'), {
      type: 'line',
      data: { 
        labels, 
        datasets: [{ 
          label: 'Working Time', 
          data: seconds, 
          borderColor: '#60a5fa', 
          backgroundColor: 'rgba(96,165,250,0.2)', 
          tension: 0.3 
        }] 
      },
      options: { 
        responsive: true, 
        maintainAspectRatio: false,
        scales: {
          y: {
            ticks: {
              callback: function(value) {
                return fmtMMSS(value);
              }
            }
          }
        },
        plugins: { 
          tooltip: { 
            callbacks: { 
              label: (ctx) => ` ${fmtMMSS(ctx.parsed.y)}`
            } 
          } 
        } 
      }
    })
  }

  // Breaks durations over time (mm:ss) using start time label
  const bLabels = breaks.value.map(b => new Date(b.start).toLocaleTimeString())
  const bSeconds = breaks.value.map(b => b.seconds || (b.minutes * 60))
  if (breaksChart) breaksChart.destroy()
  if (breaksCanvas.value) {
    breaksChart = new Chart(breaksCanvas.value.getContext('2d'), {
      type: 'line',
      data: { 
        labels: bLabels, 
        datasets: [{ 
          label: 'Break Duration', 
          data: bSeconds, 
          borderColor: '#f87171', 
          backgroundColor: 'rgba(248,113,113,0.2)', 
          tension: 0.3 
        }] 
      },
      options: { 
        responsive: true, 
        maintainAspectRatio: false,
        scales: {
          y: {
            ticks: {
              callback: function(value) {
                return fmtMMSS(value);
              }
            }
          }
        },
        plugins: { 
          tooltip: { 
            callbacks: { 
              label: (ctx) => ` ${fmtMMSS(ctx.parsed.y)}`
            } 
          } 
        } 
      }
    })
  }

  // Working sessions durations over time (mm:ss) using start time label
  const sLabels = sessions.value.map(s => new Date(s.start).toLocaleTimeString())
  const sSeconds = sessions.value.map(s => s.seconds || (s.minutes * 60))
  if (sessionsChart) sessionsChart.destroy()
  if (sessionsCanvas.value) {
    sessionsChart = new Chart(sessionsCanvas.value.getContext('2d'), {
      type: 'line',
      data: { 
        labels: sLabels, 
        datasets: [{ 
          label: 'Session Duration', 
          data: sSeconds, 
          borderColor: '#34d399', 
          backgroundColor: 'rgba(52,211,153,0.2)', 
          tension: 0.3 
        }] 
      },
      options: { 
        responsive: true, 
        maintainAspectRatio: false,
        scales: {
          y: {
            ticks: {
              callback: function(value) {
                return fmtMMSS(value);
              }
            }
          }
        },
        plugins: { 
          tooltip: { 
            callbacks: { 
              label: (ctx) => ` ${fmtMMSS(ctx.parsed.y)}`
            } 
          } 
        } 
      }
    })
  }
}

const toggle = async () => {
  console.log('🚀🚀🚀 TOGGLE FUNCTION CALLED - NEW VERSION WITH ALERTS! 🚀🚀🚀')
  console.log('🔵 Toggle function called')
  console.log('🔵 Creating state:', creating.value)
  console.log('🔵 Current user ID:', currentUserId.value)
  
  if (creating.value) {
    console.log('🔴 Already creating, returning early')
    return // Prevent multiple clicks
  }
  
  creating.value = true
  error.value = ''
  
  console.log('🔵 Starting toggle process...')
  
  // Get location with fallback
  let location = { latitude: null, longitude: null }
  let locationSource = 'none'
  
  const locationData = await getLocation()
  location = {
    latitude: locationData.latitude,
    longitude: locationData.longitude
  }
  locationSource = locationData.source
  
  console.log('📍 Location data from getLocation():', locationData)
  console.log(`📍 Using location from ${locationData.source}:`, location)
  
  // Show location status to user
  if (locationSource === 'browser_geolocation') {
    console.log('✅ Using precise GPS location')
  } else if (locationSource === 'ip_geolocation') {
    console.log('⚠️ Using approximate location based on IP address')
    error.value = 'Using approximate location (IP-based). For precise location, enable GPS in your browser.'
    setTimeout(() => {
      if (error.value.includes('approximate location')) {
        error.value = ''
      }
    }, 5000)
  } else {
    console.log('❌ No location data available')
    error.value = 'Location not available. Clock in/out will proceed without location data.'
    setTimeout(() => {
      if (error.value.includes('Location not available')) {
        error.value = ''
      }
    }, 5000)
  }
  
  try {
    if (!currentUserId.value) {
      console.log('🔴 No user ID found!')
      error.value = 'No user ID found. Please refresh the page.'
      return
    }
    
    console.log('🔵 User ID found:', currentUserId.value)
    
    // Toggle the clock state with actual location data
    const requestData = {
      latitude: location.latitude,
      longitude: location.longitude
    }
    console.log('🔵 Sending location data to server:', requestData)
    
    console.log('🔵 Making API call to clockinsApi.toggleForUser...')
    const response = await clockinsApi.toggleForUser(currentUserId.value, requestData)
    console.log('🔵 Server response received:', response)
    
    // Log the response data for debugging
    if (response && response.data) {
      console.log('Response data:', response.data)
      console.log('Clock record:', response.data)
      
      // Check if location data is in the response
      if (response.data.latitude && response.data.longitude) {
        console.log('Location data in response:', {
          latitude: response.data.latitude,
          longitude: response.data.longitude
        })
      } else {
        console.warn('No location data in response')
      }
    }
    
    // Update local state immediately for better UX
    const now = new Date().toISOString()
    const newStatus = !isClockedIn.value
    
    // Use the server response data if available, otherwise use the location we sent
    const responseData = response?.data || {}
    
    // Create the new record
    const newRecord = {
      id: responseData.id || `temp-${Date.now()}`,
      time: responseData.time || now,
      status: responseData.status !== undefined ? responseData.status : newStatus,
      user_id: currentUserId.value,
      // Use location from response if available, otherwise use what we sent
      latitude: responseData.latitude !== undefined ? responseData.latitude : location.latitude,
      longitude: responseData.longitude !== undefined ? responseData.longitude : location.longitude
    }
    
    // Update the lists immediately
    list.value = [newRecord, ...list.value]
    filterClockinsByDate()  // Update filtered clock-ins
    isClockedIn.value = newStatus
    
    // Handle timers and current clock in time
    if (newStatus) {
      console.log('🟢 Clock In - Starting session')
      currentClockInTime.value = now
      startTimer(now)
      
      // Check for early/late arrival and show alerts
      const schedule = getTodaysSchedule()
      const today = new Date().toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase()
      
      console.log('🔍 Current day:', today)
      console.log('🔍 All schedules:', userSchedules.value)
      console.log('🔍 Schedule found for today:', schedule)
      console.log('🔍 Current user:', currentUser.value)
      
      if (schedule && schedule.scheduled_start_time) {
        console.log('✅ Schedule has start time:', schedule.scheduled_start_time)
        
        // Check for early arrival
        const isEarly = checkEarlyArrival(now, schedule.scheduled_start_time)
        console.log('🕐 Is early arrival?', isEarly)
        
        if (isEarly) {
          const scheduledStart = createDateTimeFromTime(schedule.scheduled_start_time)
          console.log('🌅 EARLY ARRIVAL DETECTED!')
          
          const reason = await showAlertWithReason(
            '🌅 Early Arrival Detected',
            `You're clocking in early today!\n\nScheduled start: ${scheduledStart.toLocaleTimeString()}\nActual start: ${new Date(now).toLocaleTimeString()}`
          )
          
          console.log('📝 User reason:', reason)
          
          // Send early arrival email notification AFTER alert
          console.log('📧 Sending early arrival email AFTER alert response...')
          try {
            const scheduledStartTime = createDateTimeFromTime(schedule.scheduled_start_time)
            const arrivalInfo = {
              scheduled_start: scheduledStartTime.toLocaleTimeString(),
              actual_start: new Date(now).toLocaleTimeString(),
              early_minutes: Math.floor((scheduledStartTime.getTime() - new Date(now).getTime()) / (1000 * 60)),
              reason: reason
            }
            
            console.log('📧 Email data:', arrivalInfo)
            await sendEarlyArrivalNotification(currentUser.value, arrivalInfo)
            console.log('✅ Early arrival email sent successfully AFTER alert')
          } catch (error) {
            console.error('❌ Failed to send early arrival email:', error)
          }
        }
        
        // Check for late arrival (after scheduled end time)
        if (schedule.scheduled_end_time) {
          const isLate = checkLateArrival(now, schedule.scheduled_end_time)
          console.log('🕐 Is late arrival?', isLate)
          
          if (isLate) {
            const scheduledEnd = createDateTimeFromTime(schedule.scheduled_end_time)
            console.log('⚠️ LATE ARRIVAL DETECTED!')
            
            const reason = await showAlertWithReason(
              '⚠️ Late Clock In',
              `You're clocking in after your scheduled end time!\n\nScheduled end: ${scheduledEnd.toLocaleTimeString()}\nActual clock in: ${new Date(now).toLocaleTimeString()}`
            )
            console.log('📝 Late clock in reason:', reason)
            
            // Send late arrival email notification AFTER alert
            console.log('📧 Sending late arrival email AFTER alert response...')
            try {
              const lateArrivalInfo = {
                scheduled_end: scheduledEnd.toLocaleTimeString(),
                actual_clock_in: new Date(now).toLocaleTimeString(),
                reason: reason
              }
              
              console.log('📧 Late arrival email data:', lateArrivalInfo)
              
              // Send late arrival email using the same function
              await sendEarlyArrivalNotification(currentUser.value, {
                scheduled_start: 'Late Clock In',
                actual_start: new Date(now).toLocaleTimeString(),
                early_minutes: Math.floor((new Date(now).getTime() - scheduledEnd.getTime()) / (1000 * 60)),
                reason: reason
              })
              console.log('✅ Late arrival email sent successfully')
            } catch (error) {
              console.error('❌ Failed to send late arrival email:', error)
            }
          }
        }
        
        // Start clock out alert timer
        startClockOutAlert()
      } else {
        console.log('⚠️ No schedule found for today or missing start time')
        console.log('⚠️ Cannot set up alerts without schedule')
        console.log('ℹ️ Please set up your work schedule to enable email alerts')
      }
    } else {
      console.log('🔴 Clock Out - Ending session')
      currentClockInTime.value = null
      stopTimer()
      
      // Clear clock out alert timer when clocking out
      if (clockOutAlertTimer) {
        clearTimeout(clockOutAlertTimer)
        clockOutAlertTimer = null
      }
    }
    
    // Refresh data from the server in the background to ensure consistency
    // Add a small delay to ensure the server has processed the clock out
    setTimeout(() => {
      load().catch(err => console.error('Background refresh failed:', err))
      loadCharts().catch(err => console.error('Charts refresh failed:', err))
    }, 500)
  } catch (err) {
    console.error('🔴 Error toggling clock status:', err)
    console.error('🔴 Error details:', {
      message: err.message,
      status: err.status,
      body: err.body
    })
    // Revert the local state on error
    isClockedIn.value = !isClockedIn.value
  } finally {
    console.log('🔵 Setting creating state to false')
    creating.value = false
  }
}

const filterSessionsByDate = () => {
  filterSessionsAndBreaks();
}

const switchToToday = () => {
  // Get fresh today's date in case day has changed
  const freshToday = getTodayDate()
  console.log('🔵 Switching to today:', freshToday)
  selectedDate.value = freshToday
  chartsDate.value = freshToday
  sessionsDate.value = freshToday
  handleDateChange()
}

// Function to check if we need to update to today's date
const checkAndUpdateToToday = () => {
  const freshToday = getTodayDate()
  if (selectedDate.value !== freshToday) {
    console.log('🔵 Day has changed, updating to today:', freshToday)
    selectedDate.value = freshToday
    chartsDate.value = freshToday
    sessionsDate.value = freshToday
    handleDateChange()
  }
}

const switchToDataDate = () => {
  if (list.value.length > 0) {
    const mostRecentDate = new Date(list.value[0].time).toISOString().split('T')[0]
    console.log('🔵 Switching to data date:', mostRecentDate)
    selectedDate.value = mostRecentDate
    chartsDate.value = mostRecentDate
    sessionsDate.value = mostRecentDate
    handleDateChange()
  }
}

// Load user schedules
const loadUserSchedules = async () => {
  try {
    if (currentUserId.value) {
      const response = await userSchedulesApi.listByUser(currentUserId.value)
      userSchedules.value = response.data || []
      console.log('User schedules loaded:', userSchedules.value)
    }
  } catch (error) {
    console.error('Failed to load user schedules:', error)
  }
}

// Test email function
const testEmail = async () => {
  console.log('🧪 TEST EMAIL BUTTON CLICKED')
  try {
    const testUser = {
      first_name: 'Test',
      last_name: 'User',
      email: 'krish.bavarva114999@marwadiuniversity.ac.in'
    }
    const testArrivalInfo = {
      scheduled_start: '09:00:00',
      actual_start: new Date().toLocaleTimeString(),
      early_minutes: 30,
      reason: 'Manual test email - button clicked'
    }
    
    console.log('📧 Sending test email...')
    await sendEarlyArrivalNotification(testUser, testArrivalInfo)
    console.log('✅ Test email sent successfully')
  } catch (error) {
    console.error('❌ Test email failed:', error)
  }
}

onMounted(async () => {
  console.log('🔵 ClockinsView mounted')
  console.log('🔵 Today date:', today)
  try {
    const userString = localStorage.getItem('currentUser')
    console.log('🔵 Raw user data from localStorage:', userString)
    
    const u = JSON.parse(userString || 'null')
    console.log('🔵 Parsed user data:', u)
    
    if (u?.id) {
      console.log('🔵 User ID found, setting currentUserId:', u.id)
      currentUserId.value = u.id
      currentUser.value = u
      
      // Initialize dates to today - this should be respected
      selectedDate.value = today
      chartsDate.value = today
      sessionsDate.value = today
      console.log('🔵 Initialized dates to today:', today)
      
      await load()
      await loadUserSchedules() // Load user schedules for alerts
      
      // Wait for DOM to ensure canvas elements are ready
      await nextTick()
      await loadCharts() // Load sessions and breaks data with charts
      
      // Set up periodic check for day changes (every 5 minutes)
      dayCheckTimer = setInterval(checkAndUpdateToToday, 5 * 60 * 1000)
    } else {
      console.log('🔴 No user ID found in localStorage')
      error.value = 'User not authenticated. Please log in again.';
      
      // Initial filtering
      filterSessionsAndBreaks();
    }
  } catch (e) {
    console.error('🔴 Failed to load user data:', e)
    error.value = 'Failed to load user data. Please refresh the page.'
  }
})

// Cleanup timers when component unmounts
onUnmounted(() => {
  if (timer) clearInterval(timer)
  if (clockOutAlertTimer) clearTimeout(clockOutAlertTimer)
  if (dayCheckTimer) clearInterval(dayCheckTimer)
})
</script>

<style scoped>
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
</style>