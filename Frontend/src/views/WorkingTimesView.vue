<template>
  <section class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Working Times</h1>
            <p class="text-gray-600">View your overtime hours and manage your work schedule</p>
          </div>
          <button
            @click="$router.push('/user-schedule')"           
            class="px-4 py-2 text-sm font-medium text-indigo-600 bg-indigo-50 rounded-lg hover:bg-indigo-100"
          >
            📅 Set My Schedule                                                                                                                                                                                                                                                                                                                                                                                                                  
          </button>
        </div>
      </div>

      <!-- Overtime Summary -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-semibold text-gray-900">Overtime Hours</h2>
          <div class="text-3xl font-bold text-orange-600">{{ formatHours(overtimeHours) }}</div>
            </div>
          </div>

      <!-- Information Note -->
      <div class="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div class="flex items-start">
          <span class="text-2xl mr-3">ℹ️</span>
          <div>
            <h4 class="font-medium text-blue-900 mb-1">How to Update Your Schedule</h4>
            <p class="text-sm text-blue-700">
              This page shows your actual worked hours from clock-in/out records. 
              To set your weekly schedule (preferred working hours), go to <strong>"My Schedule"</strong> page.
            </p>
            <button 
              @click="$router.push('/user-schedule')"
              class="mt-3 px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
            >
              Go to My Schedule →
            </button>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { workingTimesApi } from '../api/workingTimes'

// Reactive data
const currentWeek = ref(new Date())
const weeklySchedule = ref([])
const saving = ref(false)

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
  return weeklySchedule.value.reduce((total, entry) => total + entry.totalHours, 0)
})

const workingDaysCount = computed(() => {
  return weeklySchedule.value.filter(entry => entry.totalHours > 0).length
})

const averageHoursPerDay = computed(() => {
  const workingDays = workingDaysCount.value
  return workingDays > 0 ? (totalWeeklyHours.value / workingDays) : 0
})

const overtimeHours = computed(() => {
  const standardHours = workingDaysCount.value * 8 // 8 hours per day
  return Math.max(0, totalWeeklyHours.value - standardHours)
})

// Helper functions
const formatHours = (hours) => {
  if (!hours || hours === 0) return '00:00:00'
  const h = Math.floor(hours)
  const m = Math.floor((hours - h) * 60)
  const s = Math.round(((hours - h) * 60 - m) * 60)
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

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

const initializeWeeklySchedule = () => {
  const start = getWeekStart(currentWeek.value)
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  
  weeklySchedule.value = []
  
  for (let i = 0; i < 7; i++) {
    const date = new Date(start)
    date.setDate(start.getDate() + i)
    
    weeklySchedule.value.push({
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
  initializeWeeklySchedule()
  loadWeeklyData()
}

const nextWeek = () => {
  currentWeek.value = new Date(currentWeek.value.getTime() + 7 * 24 * 60 * 60 * 1000)
  initializeWeeklySchedule()
  loadWeeklyData()
}

const goToCurrentWeek = () => {
  currentWeek.value = new Date()
  initializeWeeklySchedule()
  loadWeeklyData()
}

const loadWeeklyData = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const startDate = getWeekStart(currentWeek.value).toISOString().split('T')[0]
    const endDate = getWeekEnd(currentWeek.value).toISOString().split('T')[0]
    
    const response = await workingTimesApi.list(user.id, startDate, endDate)
    const workingTimes = response.data || []
    
    // Map working times to weekly schedule
    weeklySchedule.value.forEach(entry => {
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
    console.error('Error loading weekly data:', error)
  }
}

const saveWeeklySchedule = async () => {
  try {
    saving.value = true
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    
    for (const entry of weeklySchedule.value) {
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
    
    alert('Weekly schedule saved successfully!')
  } catch (error) {
    console.error('Error saving weekly schedule:', error)
    alert('Failed to save weekly schedule. Please try again.')
  } finally {
    saving.value = false
  }
}

const fillStandardHours = () => {
  weeklySchedule.value.forEach(entry => {
    if (entry.dayName !== 'Saturday' && entry.dayName !== 'Sunday') {
      entry.startTime = '09:00'
      entry.endTime = '18:00'
      calculateWorkHours(entry)
    }
  })
}

const clearAllEntries = () => {
  if (confirm('Are you sure you want to clear all entries?')) {
    weeklySchedule.value.forEach(entry => {
      entry.startTime = ''
      entry.endTime = ''
      entry.totalHours = 0
      entry.comment = ''
      entry.status = 'pending'
    })
  }
}

const exportSchedule = () => {
  // TODO: Implement PDF export
  alert('PDF export functionality will be implemented soon!')
}

// Lifecycle
onMounted(() => {
  initializeWeeklySchedule()
  loadWeeklyData()
})
</script>