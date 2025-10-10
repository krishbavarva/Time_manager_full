<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="bg-white border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-xl font-semibold text-gray-900">Weekly Timesheet</h1>
            <span class="ml-4 text-sm text-gray-500">{{ currentWeekRange }}</span>
          </div>
          
          <!-- Week Navigation -->
          <div class="flex items-center space-x-4">
            <button
              @click="previousWeek"
              class="p-2 text-gray-400 hover:text-gray-600"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            
            <button
              @click="goToCurrentWeek"
              class="px-3 py-1 text-sm font-medium text-indigo-600 hover:text-indigo-500"
            >
              This Week
            </button>
            
            <button
              @click="nextWeek"
              class="p-2 text-gray-400 hover:text-gray-600"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <!-- User Info -->
      <div class="mb-6">
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-lg font-medium text-gray-900">{{ userInfo.name }}</h2>
              <p class="text-sm text-gray-500">{{ userInfo.role }} • Week {{ currentWeekNumber }}</p>
            </div>
            <div class="text-right">
              <p class="text-sm text-gray-500">Total Hours This Week</p>
              <p class="text-2xl font-bold text-indigo-600">{{ formatTime(totalWeeklyHours) }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Weekly Timesheet Table -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <!-- Table Header -->
        <div class="bg-gray-50 px-6 py-3 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-medium text-gray-900">Weekly Timesheet</h3>
            <div class="flex items-center space-x-4">
              <span class="text-sm text-gray-500">{{ timesheetEntries.length }} day(s)</span>
              <button
                @click="saveTimesheet"
                :disabled="saving"
                class="px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 disabled:opacity-50"
              >
                {{ saving ? 'Saving...' : 'Save Timesheet' }}
              </button>
            </div>
          </div>
        </div>

        <!-- Table Content -->
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Day
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Start Time
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  End Time
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Work Hours
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Comment
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="(entry, index) in timesheetEntries" :key="index" class="hover:bg-gray-50">
                <!-- Day Column -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="flex-shrink-0">
                      <div class="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center">
                        <span class="text-sm font-medium text-indigo-600">{{ entry.dayNumber }}</span>
                      </div>
                    </div>
                    <div class="ml-3">
                      <div class="text-sm font-medium text-gray-900">{{ entry.dayName }}</div>
                      <div class="text-sm text-gray-500">({{ formatTime(entry.totalHours) }})</div>
                    </div>
                  </div>
                </td>

                <!-- Date Column -->
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ formatDate(entry.date) }}
                </td>

                <!-- Start Time Column -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <input
                      v-model="entry.startTime"
                      type="time"
                      @change="calculateWorkHours(entry)"
                      class="block w-24 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                    />
                  </div>
                </td>

                <!-- End Time Column -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <input
                      v-model="entry.endTime"
                      type="time"
                      @change="calculateWorkHours(entry)"
                      class="block w-24 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                    />
                  </div>
                </td>

                <!-- Work Hours Column -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <span class="text-sm font-medium text-gray-900">{{ formatTime(entry.totalHours) }}</span>
                  </div>
                </td>

                <!-- Comment Column -->
                <td class="px-6 py-4">
                  <input
                    v-model="entry.comment"
                    type="text"
                    placeholder="Add comment..."
                    class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                  />
                </td>

                <!-- Status Column -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    :class="getStatusClass(entry.status)"
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  >
                    <svg
                      v-if="entry.status === 'completed'"
                      class="w-3 h-3 mr-1"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                    <svg
                      v-else-if="entry.status === 'pending'"
                      class="w-3 h-3 mr-1 animate-spin"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    {{ getStatusText(entry.status) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Overtime Summary -->
        <div class="bg-orange-50 px-6 py-4 border-t border-orange-200">
          <div class="flex items-center justify-between">
            <p class="text-sm font-medium text-orange-900">Overtime Hours</p>
            <p class="text-2xl font-bold text-orange-600">{{ formatTime(overtimeHours) }}</p>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="mt-6 flex justify-center space-x-4">
        <button
          @click="fillStandardHours"
          class="px-4 py-2 bg-gray-600 text-white text-sm font-medium rounded-md hover:bg-gray-700"
        >
          Fill Standard Hours (9:00-18:00)
        </button>
        <button
          @click="clearAllEntries"
          class="px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-md hover:bg-red-700"
        >
          Clear All
        </button>
        <button
          @click="exportTimesheet"
          class="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700"
        >
          Export PDF
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { workingTimesApi } from '../api/workingTimes'

// Reactive data
const currentWeek = ref(new Date())
const timesheetEntries = ref([])
const saving = ref(false)
const userInfo = ref({})

// Computed properties
const currentWeekRange = computed(() => {
  const start = getWeekStart(currentWeek.value)
  const end = getWeekEnd(currentWeek.value)
  return `${formatDate(start)} - ${formatDate(end)}`
})

const currentWeekNumber = computed(() => {
  const start = getWeekStart(currentWeek.value)
  return getWeekNumber(start)
})

const totalWeeklyHours = computed(() => {
  return timesheetEntries.value.reduce((total, entry) => total + entry.totalHours, 0)
})

const workingDaysCount = computed(() => {
  return timesheetEntries.value.filter(entry => entry.totalHours > 0).length
})

const averageHoursPerDay = computed(() => {
  const workingDays = workingDaysCount.value
  return workingDays > 0 ? (totalWeeklyHours.value / workingDays) : 0
})

const overtimeHours = computed(() => {
  const standardHours = workingDaysCount.value * 8 // 8 hours per day
  return Math.max(0, totalWeeklyHours.value - standardHours)
})

// Methods
const getWeekStart = (date) => {
  const d = new Date(date)
  const day = d.getDay()
  const diff = d.getDate() - day + (day === 0 ? -6 : 1) // Adjust when day is Sunday
  return new Date(d.setDate(diff))
}

const getWeekEnd = (date) => {
  const start = getWeekStart(date)
  const end = new Date(start)
  end.setDate(start.getDate() + 6)
  return end
}

const getWeekNumber = (date) => {
  const start = new Date(date.getFullYear(), 0, 1)
  const days = Math.floor((date - start) / (24 * 60 * 60 * 1000))
  return Math.ceil((days + start.getDay() + 1) / 7)
}

const formatDate = (date) => {
  return date.toLocaleDateString('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

const formatTime = (hours) => {
  if (!hours || hours === 0) return '00:00:00'
  const h = Math.floor(hours)
  const m = Math.floor((hours - h) * 60)
  const s = Math.round(((hours - h) * 60 - m) * 60)
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

const initializeTimesheet = () => {
  const start = getWeekStart(currentWeek.value)
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  
  timesheetEntries.value = []
  
  for (let i = 0; i < 7; i++) {
    const date = new Date(start)
    date.setDate(start.getDate() + i)
    
    timesheetEntries.value.push({
      dayNumber: i + 1,
      dayName: days[i],
      date: date,
      startTime: '',
      endTime: '',
      totalHours: 0,
      comment: '',
      status: 'pending'
    })
  }
}

const calculateWorkHours = (entry) => {
  if (!entry.startTime || !entry.endTime) {
    entry.totalHours = 0
    return
  }
  
  const start = new Date(`2000-01-01T${entry.startTime}`)
  const end = new Date(`2000-01-01T${entry.endTime}`)
  
  if (end < start) {
    // Handle overnight shifts
    end.setDate(end.getDate() + 1)
  }
  
  const diffMs = end - start
  const diffHours = diffMs / (1000 * 60 * 60)
  
  entry.totalHours = Math.max(0, diffHours)
  entry.status = entry.totalHours > 0 ? 'completed' : 'pending'
}

const getStatusClass = (status) => {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800'
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'submitted':
      return 'bg-blue-100 text-blue-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const getStatusText = (status) => {
  switch (status) {
    case 'completed':
      return 'Completed'
    case 'pending':
      return 'Pending'
    case 'submitted':
      return 'Submitted'
    default:
      return 'Unknown'
  }
}

const previousWeek = () => {
  currentWeek.value = new Date(currentWeek.value.getTime() - 7 * 24 * 60 * 60 * 1000)
  initializeTimesheet()
  loadTimesheetData()
}

const nextWeek = () => {
  currentWeek.value = new Date(currentWeek.value.getTime() + 7 * 24 * 60 * 60 * 1000)
  initializeTimesheet()
  loadTimesheetData()
}

const goToCurrentWeek = () => {
  currentWeek.value = new Date()
  initializeTimesheet()
  loadTimesheetData()
}

const loadTimesheetData = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const startDate = getWeekStart(currentWeek.value).toISOString().split('T')[0]
    const endDate = getWeekEnd(currentWeek.value).toISOString().split('T')[0]
    
    const response = await workingTimesApi.list(user.id, startDate, endDate)
    const workingTimes = response.data || []
    
    // Map working times to timesheet entries
    timesheetEntries.value.forEach(entry => {
      const workingTime = workingTimes.find(wt => {
        const wtDate = new Date(wt.start || wt.start_time || wt.startTime)
        return wtDate.toDateString() === entry.date.toDateString()
      })
      
      if (workingTime) {
        const startTime = workingTime.start || workingTime.start_time || workingTime.startTime
        const endTime = workingTime.end || workingTime.end_time || workingTime.endTime
        
        if (startTime) {
          entry.startTime = new Date(startTime).toTimeString().slice(0, 5)
        }
        if (endTime) {
          entry.endTime = new Date(endTime).toTimeString().slice(0, 5)
        }
        
        // Calculate total hours
        if (startTime && endTime) {
          const start = new Date(startTime)
          const end = new Date(endTime)
          const diffMs = end - start
          entry.totalHours = Math.max(0, diffMs / (1000 * 60 * 60))
        }
        
        entry.status = 'completed'
      }
    })
  } catch (error) {
    console.error('Error loading timesheet data:', error)
  }
}

const saveTimesheet = async () => {
  try {
    saving.value = true
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    
    for (const entry of timesheetEntries.value) {
      if (entry.startTime && entry.endTime) {
        const startDateTime = new Date(entry.date)
        const [startHour, startMinute] = entry.startTime.split(':')
        startDateTime.setHours(parseInt(startHour), parseInt(startMinute), 0, 0)
        
        const endDateTime = new Date(entry.date)
        const [endHour, endMinute] = entry.endTime.split(':')
        endDateTime.setHours(parseInt(endHour), parseInt(endMinute), 0, 0)
        
        const workingTimeData = {
          start: startDateTime.toISOString(),
          end: endDateTime.toISOString()
        }
        
        await workingTimesApi.create(user.id, workingTimeData)
      }
    }
    
    alert('Timesheet saved successfully!')
  } catch (error) {
    console.error('Error saving timesheet:', error)
    alert('Failed to save timesheet. Please try again.')
  } finally {
    saving.value = false
  }
}

const fillStandardHours = () => {
  timesheetEntries.value.forEach(entry => {
    if (entry.dayName !== 'Saturday' && entry.dayName !== 'Sunday') {
      entry.startTime = '09:00'
      entry.endTime = '18:00'
      calculateWorkHours(entry)
    }
  })
}

const clearAllEntries = () => {
  if (confirm('Are you sure you want to clear all entries?')) {
    timesheetEntries.value.forEach(entry => {
      entry.startTime = ''
      entry.endTime = ''
      entry.totalHours = 0
      entry.comment = ''
      entry.status = 'pending'
    })
  }
}

const exportTimesheet = () => {
  // TODO: Implement PDF export
  alert('PDF export functionality will be implemented soon!')
}

// Lifecycle
onMounted(() => {
  const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
  userInfo.value = {
    name: `${user.first_name || ''} ${user.last_name || ''}`.trim() || user.username,
    role: user.role || 'employee'
  }
  
  initializeTimesheet()
  loadTimesheetData()
})
</script>
