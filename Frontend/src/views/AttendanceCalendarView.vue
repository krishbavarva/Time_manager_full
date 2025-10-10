<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">My Attendance Calendar</h1>
        <p class="mt-2 text-sm text-gray-600">View your monthly attendance record</p>
      </div>

      <!-- Loading State -->
      <LoadingSpinner v-if="loading" :show="loading" text="Loading attendance data..." size="lg" />

      <!-- Calendar -->
      <div v-else class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <!-- Month Navigation -->
        <div class="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-4">
          <div class="flex items-center justify-between">
            <button
              @click="previousMonth"
              class="p-2 text-white hover:bg-blue-500 rounded-lg transition-colors"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            
            <h2 class="text-2xl font-bold text-white">
              {{ monthName }} {{ currentYear }}
            </h2>
            
            <button
              @click="nextMonth"
              class="p-2 text-white hover:bg-blue-500 rounded-lg transition-colors"
              :disabled="isCurrentMonth"
              :class="{ 'opacity-50 cursor-not-allowed': isCurrentMonth }"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Legend -->
        <div class="bg-gray-50 px-6 py-3 border-b border-gray-200">
          <div class="flex flex-wrap items-center justify-center gap-4 text-sm">
            <div class="flex items-center">
              <div class="w-4 h-4 bg-green-500 rounded mr-2"></div>
              <span class="text-gray-700">Present</span>
            </div>
            <div class="flex items-center">
              <div class="w-4 h-4 bg-red-500 rounded mr-2"></div>
              <span class="text-gray-700">Absent</span>
            </div>
            <div class="flex items-center">
              <div class="w-4 h-4 bg-yellow-500 rounded mr-2"></div>
              <span class="text-gray-700">On Leave</span>
            </div>
            <div class="flex items-center">
              <div class="w-4 h-4 bg-gray-400 rounded mr-2"></div>
              <span class="text-gray-700">Weekend/Holiday</span>
            </div>
            <div class="flex items-center">
              <div class="w-4 h-4 bg-white border-2 border-gray-300 rounded mr-2"></div>
              <span class="text-gray-700">No Data</span>
            </div>
          </div>
        </div>

        <!-- Calendar Grid -->
        <div class="p-6">
          <!-- Day Headers -->
          <div class="grid grid-cols-7 gap-2 mb-2">
            <div
              v-for="day in dayHeaders"
              :key="day"
              class="text-center font-semibold text-gray-700 py-2"
            >
              {{ day }}
            </div>
          </div>

          <!-- Calendar Days -->
          <div class="grid grid-cols-7 gap-2">
            <div
              v-for="day in calendarDays"
              :key="day.key"
              class="relative aspect-square rounded-lg border-2 transition-all duration-200 hover:shadow-md"
              :class="getDayClass(day)"
            >
              <div class="absolute inset-0 flex flex-col items-center justify-center p-2">
                <span class="text-lg font-semibold" :class="getDayTextClass(day)">
                  {{ day.date }}
                </span>
                <span v-if="day.isHoliday" class="text-xs mt-1 text-center font-medium text-gray-700">
                  {{ day.holidayReason }}
                </span>
                <span v-if="day.status" class="text-xs mt-1 font-medium">
                  {{ getStatusLabel(day.status) }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Summary Stats -->
        <div class="bg-gray-50 px-6 py-4 border-t border-gray-200">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="text-center">
              <p class="text-2xl font-bold text-green-600">{{ stats.present }}</p>
              <p class="text-sm text-gray-600">Present Days</p>
            </div>
            <div class="text-center">
              <p class="text-2xl font-bold text-red-600">{{ stats.absent }}</p>
              <p class="text-sm text-gray-600">Absent Days</p>
            </div>
            <div class="text-center">
              <p class="text-2xl font-bold text-yellow-600">{{ stats.onLeave }}</p>
              <p class="text-sm text-gray-600">Leave Days</p>
            </div>
            <div class="text-center">
              <p class="text-2xl font-bold text-blue-600">{{ stats.attendanceRate }}%</p>
              <p class="text-sm text-gray-600">Attendance Rate</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { attendanceApi } from '../api/attendance'
import { clockinsApi } from '../api/clockins'
import LoadingSpinner from '../components/LoadingSpinner.vue'

const loading = ref(true)
const currentMonth = ref(new Date().getMonth())
const currentYear = ref(new Date().getFullYear())
const attendanceData = ref([])
const clockData = ref([])
const holidays = ref([])

const dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

const monthName = computed(() => {
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                  'July', 'August', 'September', 'October', 'November', 'December']
  return months[currentMonth.value]
})

const isCurrentMonth = computed(() => {
  const now = new Date()
  return currentMonth.value === now.getMonth() && currentYear.value === now.getFullYear()
})

const calendarDays = computed(() => {
  const days = []
  const firstDay = new Date(currentYear.value, currentMonth.value, 1)
  const lastDay = new Date(currentYear.value, currentMonth.value + 1, 0)
  const startingDayOfWeek = firstDay.getDay()
  
  // Add empty cells for days before the first of the month
  for (let i = 0; i < startingDayOfWeek; i++) {
    days.push({
      key: `empty-${i}`,
      date: '',
      isEmpty: true
    })
  }
  
  // Add actual days of the month
  for (let date = 1; date <= lastDay.getDate(); date++) {
    const currentDate = new Date(currentYear.value, currentMonth.value, date)
    const dateString = formatDate(currentDate)
    const dayOfWeek = currentDate.getDay()
    
    // Check if it's a weekend
    const isWeekend = dayOfWeek === 0 || dayOfWeek === 6
    
    // Check if it's a holiday
    const holiday = holidays.value.find(h => h.date === dateString)
    
    // Get attendance status
    const attendance = attendanceData.value.find(a => a.date === dateString)
    
    // Get clock data for this date
    const hasClockedIn = clockData.value.some(clock => {
      const clockDate = new Date(clock.time)
      return clockDate.getFullYear() === currentYear.value &&
             clockDate.getMonth() === currentMonth.value &&
             clockDate.getDate() === date
    })
    
    days.push({
      key: `day-${date}`,
      date,
      dateString,
      isWeekend,
      isHoliday: !!holiday,
      holidayReason: holiday?.reason || '',
      status: attendance?.status || (hasClockedIn ? 'present' : null),
      isFuture: currentDate > new Date()
    })
  }
  
  return days
})

const stats = computed(() => {
  const present = attendanceData.value.filter(a => a.status === 'present').length
  const absent = attendanceData.value.filter(a => a.status === 'absent').length
  const onLeave = attendanceData.value.filter(a => a.status === 'on_leave').length
  const total = present + absent
  const attendanceRate = total > 0 ? Math.round((present / total) * 100) : 0
  
  return { present, absent, onLeave, attendanceRate }
})

const getDayClass = (day) => {
  if (day.isEmpty) return 'border-transparent'
  if (day.isFuture) return 'bg-gray-100 border-gray-200'
  if (day.isWeekend || day.isHoliday) return 'bg-gray-400 border-gray-500'
  if (day.status === 'present') return 'bg-green-500 border-green-600'
  if (day.status === 'absent') return 'bg-red-500 border-red-600'
  if (day.status === 'on_leave') return 'bg-yellow-500 border-yellow-600'
  return 'bg-white border-gray-300'
}

const getDayTextClass = (day) => {
  if (day.isEmpty || day.isFuture) return 'text-gray-400'
  if (day.isWeekend || day.isHoliday) return 'text-white'
  if (day.status) return 'text-white'
  return 'text-gray-700'
}

const getStatusLabel = (status) => {
  const labels = {
    present: 'P',
    absent: 'A',
    on_leave: 'L'
  }
  return labels[status] || ''
}

const formatDate = (date) => {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

const previousMonth = () => {
  if (currentMonth.value === 0) {
    currentMonth.value = 11
    currentYear.value--
  } else {
    currentMonth.value--
  }
  loadAttendanceData()
}

const nextMonth = () => {
  if (!isCurrentMonth.value) {
    if (currentMonth.value === 11) {
      currentMonth.value = 0
      currentYear.value++
    } else {
      currentMonth.value++
    }
    loadAttendanceData()
  }
}

const loadAttendanceData = async () => {
  loading.value = true
  try {
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    
    // Calculate date range for the month
    const startDate = new Date(currentYear.value, currentMonth.value, 1)
    const endDate = new Date(currentYear.value, currentMonth.value + 1, 0)
    
    // Load attendance data
    const attendanceResponse = await attendanceApi.list()
    const allAttendance = attendanceResponse.data || []
    
    // Filter for current user and current month
    attendanceData.value = allAttendance.filter(a => {
      if (a.user_id !== currentUser.id) return false
      const aDate = new Date(a.date)
      return aDate >= startDate && aDate <= endDate
    })
    
    // Load clock data for the month
    const startDateStr = startDate.toISOString()
    const endDateStr = endDate.toISOString()
    const clockResponse = await clockinsApi.listByUser(currentUser.id, startDateStr, endDateStr)
    clockData.value = clockResponse.data || []
    
    // For now, holidays are hardcoded (since backend doesn't have holiday API)
    // In production, this would come from an API
    loadHolidays()
    
  } catch (error) {
    console.error('Error loading attendance data:', error)
  } finally {
    loading.value = false
  }
}

const loadHolidays = () => {
  // Hardcoded holidays for demonstration
  // In production, this would come from the backend API
  const year = currentYear.value
  holidays.value = [
    { date: `${year}-01-01`, reason: 'New Year' },
    { date: `${year}-12-25`, reason: 'Christmas' },
    { date: `${year}-12-31`, reason: 'New Year Eve' }
  ]
}

onMounted(() => {
  loadAttendanceData()
})
</script>

