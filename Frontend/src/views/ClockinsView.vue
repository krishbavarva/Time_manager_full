<template>
  <section class="clockins-view">
    <div class="page-header">
      <div>
        <h1>Time Tracking</h1>
        <p class="text-muted">Manage your work hours and clock in/out</p>
      </div>
      <div class="date-picker">
        <label for="date-filter" class="text-sm text-gray-600 mr-2">View Date:</label>
        <input 
          type="date" 
          id="date-filter" 
          v-model="selectedDate" 
          :max="today"
          class="form-control text-sm py-1 px-2 border rounded"
          @change="handleDateChange"
        >
      </div>
    </div>
    
    <div class="card">
      <h2 class="mb-4">Clock In/Out</h2>
      <div class="flex flex-wrap items-center gap-4 mb-6">
        <button 
          @click="toggle" 
          class="btn btn-primary"
          :disabled="creating"
        >
          {{ creating ? 'Processing...' : isClockedIn ? 'Clock Out' : 'Clock In' }}
        </button>
        <button 
          type="button" 
          @click="load" 
          class="btn btn-outline"
        >
          Refresh
        </button>
        
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

      <div v-if="filteredClockins.length === 0" class="no-data">
        No clock-in/out records found for {{ formattedSelectedDate }}
      </div>
      <div v-else class="overflow-x-auto">
        <div class="date-display mb-4">
          Showing records for: <strong>{{ formattedSelectedDate }}</strong>
        </div>
        <table class="table">
          <thead>
            <tr>
              <th>Time</th>
              <th>Status</th>
              <th>Location</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredClockins.length === 0">
              <td colspan="3" class="text-center py-4 text-gray-500">
                No clock-in/out records found for {{ formattedSelectedDate }}
              </td>
            </tr>
            <tr v-else v-for="c in filteredClockins" :key="c.id" class="hover:bg-gray-50">
              <td class="whitespace-nowrap">{{ fmtIso(c.time) }}</td>
              <td>
                <span 
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  :class="c.status ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'"
                >
                  {{ c.status ? 'Clocked In' : 'Clocked Out' }}
                </span>
              </td>
              <td class="whitespace-nowrap">
                <a 
                  v-if="c.latitude && c.longitude" 
                  :href="`https://www.google.com/maps?q=${c.latitude},${c.longitude}`" 
                  target="_blank"
                  class="text-blue-600 hover:underline flex items-center"
                  title="View on Google Maps"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" class="location-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  View Location
                </a>
                <span v-else class="text-gray-400 text-sm">No location data</span>
              </td>
            </tr>
            <tr v-if="list.length === 0">
              <td colspan="3" class="text-center py-4 text-gray-500">
                No clock-in records found
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="card mt-6">
      <div class="flex flex-wrap items-center justify-between mb-4">
        <h2>Working Time Summary</h2>
        <div class="flex items-center gap-2">
          <label class="text-sm text-gray-600">Filter by date:</label>
          <input 
            type="date" 
            v-model="chartsDate" 
            @change="loadCharts"
            :max="today"
            class="form-control text-sm py-1 px-2 border rounded"
          />
        </div>
      </div>
      
      <div v-if="chartsLoading" class="p-4 text-center text-gray-500">
        Loading charts...
      </div>
      <div v-else-if="hoursRows.length === 0" class="p-4 text-center text-gray-500">
        No working time data available for the selected period.
      </div>
      <template v-else>
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th class="whitespace-nowrap">Date</th>
                <th class="text-right">Duration</th>
                <th class="text-right">Hours</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="r in hoursRows" :key="r.date" class="hover:bg-gray-50">
                <td class="whitespace-nowrap">{{ r.date }}</td>
                <td class="text-right font-mono">{{ fmtMMSS(r.minutes * 60) }}</td>
                <td class="text-right">{{ (r.minutes / 60).toFixed(1) }}h</td>
              </tr>
              <tr class="font-medium bg-gray-50">
                <td>Total</td>
                <td class="text-right font-mono">
                  {{ fmtMMSS(hoursRows.reduce((sum, r) => sum + (r.minutes * 60), 0)) }}
                </td>
                <td class="text-right">
                  {{ (hoursRows.reduce((sum, r) => sum + r.minutes, 0) / 60).toFixed(1) }}h
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </div>

    <div class="card mt-6">
      <h2>Breaks</h2>
      <div v-if="breaks.length === 0" class="p-4 text-center text-gray-500">
        No break data available.
      </div>
      <template v-else>
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Start</th>
                <th>End</th>
                <th>Minutes</th>
                <th>Duration</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(b, i) in breaks" :key="i" class="hover:bg-gray-50">
                <td class="whitespace-nowrap">{{ fmtIso(b.start) }}</td>
                <td class="whitespace-nowrap">{{ fmtIso(b.end) }}</td>
                <td>{{ (b.seconds ? (b.seconds/60).toFixed(2) : b.minutes) }}</td>
                <td class="whitespace-nowrap">{{ fmtMMSS(b.seconds ?? (b.minutes * 60)) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="chart-box mt-4">
          <canvas ref="breaksCanvas" height="120"></canvas>
        </div>
      </template>
    </div>

    <div class="card mt-6">
      <div class="flex flex-wrap items-center justify-between mb-4">
        <h2>Working Sessions</h2>
        <div class="flex items-center gap-2">
          <label class="text-sm text-gray-600">Filter by date:</label>
          <input 
            type="date" 
            v-model="sessionsDate" 
            @change="filterSessionsByDate"
            :max="today"
            class="form-control text-sm py-1 px-2 border rounded"
          />
        </div>
      </div>
      <div v-if="filteredSessions.length === 0" class="p-4 text-center text-gray-500">
        No session data available for {{ formattedSessionsDate }}.
      </div>
      <template v-else>
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Start</th>
                <th>End</th>
                <th>Minutes</th>
                <th>Duration</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(s, i) in filteredSessions" :key="i" class="hover:bg-gray-50">
                <td class="whitespace-nowrap">{{ fmtIso(s.start) }}</td>
                <td class="whitespace-nowrap">{{ fmtIso(s.end) }}</td>
                <td>{{ (s.seconds ? (s.seconds/60).toFixed(2) : s.minutes) }}</td>
                <td class="whitespace-nowrap">{{ fmtMMSS(s.seconds ?? (s.minutes * 60)) }}</td>
              </tr>
              <tr v-if="filteredSessions.length > 0" class="font-medium bg-gray-50">
                <td colspan="2" class="text-right pr-4">Total Work Time:</td>
                <td>{{ totalWorkMinutes.toFixed(2) }}</td>
                <td class="whitespace-nowrap">{{ fmtMMSS(totalWorkMinutes * 60) }}</td>
              </tr>
              <tr v-if="filteredBreaks.length > 0" class="font-medium bg-gray-50">
                <td colspan="2" class="text-right pr-4">Total Break Time:</td>
                <td>{{ totalBreakMinutes.toFixed(2) }}</td>
                <td class="whitespace-nowrap">{{ fmtMMSS(totalBreakMinutes * 60) }}</td>
              </tr>
              <tr v-if="filteredSessions.length > 0 || filteredBreaks.length > 0" class="font-bold bg-gray-100">
                <td colspan="2" class="text-right pr-4">Total Time (Work + Break):</td>
                <td>{{ (totalWorkMinutes + totalBreakMinutes).toFixed(2) }}</td>
                <td class="whitespace-nowrap">{{ fmtMMSS((totalWorkMinutes + totalBreakMinutes) * 60) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="chart-box mt-4">
          <canvas ref="sessionsCanvas" height="120"></canvas>
        </div>
      </template>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { clockinsApi } from '../api/clockins'
import { chartsApi } from '../api/charts'
import Chart from 'chart.js/auto'

// Get location with fallback to IP-based geolocation
const getLocation = async () => {
  // Try browser geolocation first
  if (navigator.geolocation) {
    try {
      const position = await new Promise((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(resolve, reject, {
          enableHighAccuracy: true,
          timeout: 5000,
          maximumAge: 0
        })
      })
      
      return {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
        source: 'browser_geolocation'
      }
    } catch (error) {
      console.warn('Browser geolocation failed, trying IP-based fallback', error)
    }
  }
  
  // Fallback to IP-based geolocation
  try {
    const response = await fetch('https://ipapi.co/json/')
    if (response.ok) {
      const data = await response.json()
      if (data.latitude && data.longitude) {
        return {
          latitude: parseFloat(data.latitude),
          longitude: parseFloat(data.longitude),
          source: 'ip_geolocation'
        }
      }
    }
  } catch (error) {
    console.error('IP-based geolocation failed', error)
    throw new Error('Could not determine your location. Please enable location access.')
  }
  
  throw new Error('Location services are not available')
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
  
  filteredClockins.value = list.value.filter(clockin => {
    if (!clockin.time) return false
    const clockinDate = new Date(clockin.time).toISOString().split('T')[0]
    return clockinDate === selectedDate.value
  })
}

// Filter sessions and breaks by selected date
const filterSessionsAndBreaks = () => {
  try {
    if (!sessionsDate.value) {
      sessionsDate.value = getTodayDate(); // Default to today if no date selected
    }
    
    // Convert dates to YYYY-MM-DD format for comparison
    const selectedDateStr = sessionsDate.value;
    
    // Filter sessions
    filteredSessions.value = sessions.value.filter(session => {
      if (!session?.start) return false;
      try {
        const sessionDate = new Date(session.start);
        const sessionDateStr = sessionDate.toISOString().split('T')[0];
        return sessionDateStr === selectedDateStr;
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
        return breakDateStr === selectedDateStr;
      } catch (e) {
        console.error('Error parsing break date:', b.start, e);
        return false;
      }
    });
    
    console.log(`Filtered data for ${selectedDateStr}:`);
    console.log('Sessions:', filteredSessions.value);
    console.log('Breaks:', filteredBreaks.value);
    
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

// Compute filtered breaks for the selected date
const filteredBreaks = computed(() => {
  if (!sessionsDate.value) return [];
  return breaks.value.filter(b => {
    if (!b.start) return false;
    const breakDate = new Date(b.start).toISOString().split('T')[0];
    return breakDate === sessionsDate.value;
  });
});

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
    } else {
      isClockedIn.value = false
      currentClockInTime.value = null
      stopTimer()
    }
    
    // Filter clock-ins by the selected date
    filterClockinsByDate()
    
    // Check for active session (only for today)
    if (selectedDate.value === today) {
      const last = list.value[0]
      if (last?.status) {
        startTimer(last.time)
      } else {
        stopTimer()
      }
    } else {
      stopTimer()
    }
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
    updateCharts();
    return; 
  }
  
  // If no date is selected, default to today
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
    updateCharts();
  } catch (error) {
    console.error('Error loading charts data:', error);
    hoursRows.value = [];
    breaks.value = [];
    sessions.value = [];
    filteredSessions.value = [];
    filteredBreaks.value = [];
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
  if (creating.value) return // Prevent multiple clicks
  creating.value = true
  error.value = ''
  
  // Get location with fallback
  let location = { latitude: null, longitude: null }
  
  try {
    const locationData = await getLocation()
    location = {
      latitude: locationData.latitude,
      longitude: locationData.longitude
    }
    console.log('Location data from getLocation():', locationData)
    console.log(`Using location from ${locationData.source}:`, location)
  } catch (err) {
    console.error('Error getting location:', err)
    error.value = `Location error: ${err.message}. Using default location.`
    // Continue with default (null) location
  }
  
  try {
    if (!currentUserId.value) {
      error.value = 'No user ID found. Please refresh the page.'
      return
    }
    
    // Toggle the clock state with actual location data
    const requestData = {
      latitude: location.latitude,
      longitude: location.longitude
    }
    console.log('Sending location data to server:', requestData)
    
    const response = await clockinsApi.toggleForUser(currentUserId.value, requestData)
    console.log('Server response:', response)
    
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
      currentClockInTime.value = now
      startTimer(now)
    } else {
      currentClockInTime.value = null
      stopTimer()
    }
    
    // Refresh data from the server in the background to ensure consistency
    load().catch(err => console.error('Background refresh failed:', err))
    loadCharts().catch(err => console.error('Charts refresh failed:', err))
  } catch (err) {
    console.error('Error toggling clock status:', err)
    // Revert the local state on error
    isClockedIn.value = !isClockedIn.value
  } finally {
    creating.value = false
  }
}

const filterSessionsByDate = () => {
  filterSessionsAndBreaks();
}

onMounted(async () => {
  try {
    const u = JSON.parse(localStorage.getItem('currentUser') || 'null')
    if (u?.id) {
      currentUserId.value = u.id
      await load()
    } else {
      error.value = 'User not authenticated. Please log in again.';
      
      // Initial filtering
      filterSessionsAndBreaks();
    }
  } catch (e) {
    console.error('Failed to load user data:', e)
    error.value = 'Failed to load user data. Please refresh the page.'
  }
})
</script>

<style scoped>
.clockins-view {
  background-color: #ffffff;
  color: #1f2937;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.date-picker {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.card { 
  margin-top: 1.5rem; 
  padding: 1.5rem; 
  background: #ffffff; 
  border: 1px solid #e5e7eb; 
  border-radius: 12px; 
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.table { 
  width: 100%; 
  border-collapse: separate;
  border-spacing: 0;
}

th, td { 
  text-align: left; 
  padding: 0.75rem 1rem; 
  border-bottom: 1px solid #e5e7eb; 
  color: #1f2937;
}

th {
  background-color: #f9fafb;
  font-weight: 600;
  color: #374151;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
}

tr:hover {
  background-color: #f9fafb;
}

.error { 
  color: #dc2626;
  background-color: #fef2f2;
  border-radius: 0.5rem;
}

button { 
  padding: 0.5rem 1rem; 
  border-radius: 8px; 
  font-weight: 500; 
  transition: all 0.2s;
  cursor: pointer;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background: #2563eb; 
  color: white;
  border: 1px solid #2563eb;
}

.btn-primary:hover:not(:disabled) {
  background: #1d4ed8;
  border-color: #1d4ed8;
}

.btn-outline {
  background: white;
  border: 1px solid #d1d5db;
  color: #374151;
}

.btn-outline:hover {
  background: #f9fafb;
  border-color: #9ca3af;
}

.hint { 
  color: #6b7280;
  font-size: 0.875rem;
}

.chart-box { 
  position: relative; 
  height: 200px; 
  margin-top: 1.5rem;
  background: white;
  border-radius: 0.5rem;
  border: 1px solid #e5e7eb;
  padding: 1rem;
}

.text-muted {
  color: #6b7280;
}

.badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
}

.bg-green-100 { background-color: #dcfce7; }
.text-green-800 { color: #166534; }
.bg-gray-100 { background-color: #f3f4f6; }
.text-gray-800 { color: #1f2937; }

.location-icon {
  height: 16px;
  width: 16px;
  margin-right: 0.25rem;
}

.no-data {
  padding: 2rem;
  text-align: center;
  color: #6b7280;
}

.date-display {
  padding: 0.75rem;
  background-color: #f9fafb;
  border-radius: 0.5rem;
  color: #374151;
}

.form-control {
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.form-control:focus {
  outline: none;
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

h1 {
  font-size: 1.875rem;
  font-weight: 700;
  color: #111827;
  margin: 0;
}

h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #111827;
  margin: 0;
}

.overflow-x-auto {
  overflow-x: auto;
}

.whitespace-nowrap {
  white-space: nowrap;
}

.text-center {
  text-align: center;
}

.text-right {
  text-align: right;
}

.text-sm {
  font-size: 0.875rem;
}

.text-gray-600 {
  color: #4b5563;
}

.text-gray-500 {
  color: #6b7280;
}

.text-gray-400 {
  color: #9ca3af;
}

.text-blue-600 {
  color: #2563eb;
}

.text-red-700 {
  color: #b91c1c;
}

.bg-gray-50 {
  background-color: #f9fafb;
}

.bg-red-50 {
  background-color: #fef2f2;
}

.bg-green-500 {
  background-color: #22c55e;
}

.rounded {
  border-radius: 0.375rem;
}

.rounded-lg {
  border-radius: 0.5rem;
}

.rounded-full {
  border-radius: 9999px;
}

.font-medium {
  font-weight: 500;
}

.font-bold {
  font-weight: 700;
}

.font-mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
}

.flex {
  display: flex;
}

.flex-wrap {
  flex-wrap: wrap;
}

.items-center {
  align-items: center;
}

.justify-between {
  justify-content: space-between;
}

.gap-2 {
  gap: 0.5rem;
}

.gap-4 {
  gap: 1rem;
}

.mb-4 {
  margin-bottom: 1rem;
}

.mb-6 {
  margin-bottom: 1.5rem;
}

.mt-4 {
  margin-top: 1rem;
}

.mt-6 {
  margin-top: 1.5rem;
}

.ml-auto {
  margin-left: auto;
}

.mr-2 {
  margin-right: 0.5rem;
}

.p-4 {
  padding: 1rem;
}

.px-2 {
  padding-left: 0.5rem;
  padding-right: 0.5rem;
}

.py-1 {
  padding-top: 0.25rem;
  padding-bottom: 0.25rem;
}

.py-4 {
  padding-top: 1rem;
  padding-bottom: 1rem;
}

.px-4 {
  padding-left: 1rem;
  padding-right: 1rem;
}

.py-2 {
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
}

.pr-4 {
  padding-right: 1rem;
}

.w-3 {
  width: 0.75rem;
}

.h-3 {
  height: 0.75rem;
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.inline-flex {
  display: inline-flex;
}

.hover\:bg-gray-50:hover {
  background-color: #f9fafb;
}

.hover\:underline:hover {
  text-decoration: underline;
}
</style>