<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <!-- Loading State -->
    <LoadingSpinner v-if="loading" :show="loading" text="Loading dashboard data..." size="xl" containerClass="min-h-screen" />
    
    <div v-else class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Dashboard</h1>
            <p class="text-gray-600">
              Welcome back, <span class="font-semibold">{{ user?.username || `${user?.first_name} ${user?.last_name}` }}</span>
              <span 
                class="ml-2 px-2 py-1 text-xs font-medium rounded-full"
                :class="{
                  'bg-purple-100 text-purple-800': userRole === 'admin',
                  'bg-blue-100 text-blue-800': userRole === 'manager',
                  'bg-green-100 text-green-800': userRole === 'employee'
                }"
              >
                {{ userRole?.toUpperCase() }}
              </span>
            </p>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="refreshData"
              class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
            >
              🔄 Refresh
            </button>
            <button
              @click="exportReport"
              class="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700"
            >
              📊 Export Report
            </button>
          </div>
        </div>
      </div>

      <!-- Key Metrics -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-blue-100 rounded-lg">
              <span class="text-2xl">⏰</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Total Work Time</p>
              <p class="text-2xl font-bold text-gray-900">{{ formatActivityTime(totalWorkMin) }}</p>
              <p class="text-xs text-green-600">Today</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-yellow-100 rounded-lg">
              <span class="text-2xl">☕</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Break Time</p>
              <p class="text-2xl font-bold text-gray-900">{{ formatActivityTime(totalBreakMin) }}</p>
              <p class="text-xs text-yellow-600">Today</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-green-100 rounded-lg">
              <span class="text-2xl">📊</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Sessions</p>
              <p class="text-2xl font-bold text-gray-900">{{ allSessions.length }}</p>
              <p class="text-xs text-blue-600">This week</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-purple-100 rounded-lg">
              <span class="text-2xl">🎯</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Productivity</p>
              <p class="text-2xl font-bold text-gray-900">{{ displayProductivityScore }}%</p>
              <p class="text-xs text-purple-600">This week</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Content Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <!-- Real-Time Status -->
        <div class="lg:col-span-1">
          <RealTimeStatus />
        </div>

        <!-- Quick Actions -->
        <div class="lg:col-span-2">
          <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- Employee Actions - Hidden for Admin -->
              <!-- Mark Attendance Button with Timer -->
              <div
                v-if="!isAdmin"
                class="col-span-1 md:col-span-2"
              >
                <div v-if="!attendanceMarked" class="bg-gradient-to-r from-green-50 to-blue-50 rounded-lg border-2 border-green-200 p-6">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center">
                      <span class="text-3xl mr-4">✅</span>
                      <div>
                        <div class="font-semibold text-gray-900 text-lg">Mark Your Attendance</div>
                        <div class="text-sm text-gray-600">Start your workday timer ({{ scheduledHours }} hours)</div>
                      </div>
                    </div>
                    <button
                      @click="markAttendance"
                      :disabled="markingAttendance"
                      class="px-6 py-3 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 disabled:opacity-50 transition-colors"
                    >
                      {{ markingAttendance ? 'Marking...' : 'Mark Present' }}
                    </button>
                  </div>
                </div>

                <div v-else class="bg-gradient-to-r from-green-100 to-blue-100 rounded-lg border-2 border-green-400 p-6">
                  <div class="text-center">
                    <div class="flex items-center justify-center mb-3">
                      <span class="text-3xl mr-3">⏱️</span>
                      <div class="font-bold text-4xl text-gray-900 font-mono">
                        {{ formatTimer(remainingSeconds) }}
                      </div>
                    </div>
                    <div class="text-sm text-gray-700 font-medium">
                      {{ remainingSeconds > 0 ? 'Time remaining in your shift' : '🎉 Shift completed!' }}
                    </div>
                    <div class="text-xs text-gray-600 mt-1">
                      Scheduled: {{ scheduledHours }} hours | Started: {{ attendanceStartTime }}
                    </div>
                  </div>
                </div>
              </div>

              <button
                v-if="!isAdmin"
                @click="$router.push('/clockins')"
                class="flex items-center justify-center p-4 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors"
              >
                <span class="text-2xl mr-3">🕐</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Clock In/Out</div>
                  <div class="text-sm text-gray-500">Manual time tracking</div>
                </div>
              </button>

              <button
                v-if="!isAdmin"
                @click="$router.push('/working-times')"
                class="flex items-center justify-center p-4 bg-green-50 rounded-lg hover:bg-green-100 transition-colors"
              >
                <span class="text-2xl mr-3">📅</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Working Times</div>
                  <div class="text-sm text-gray-500">View your schedule</div>
                </div>
              </button>

              <button
                v-if="!isAdmin"
                @click="$router.push('/user-schedule')"
                class="flex items-center justify-center p-4 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors"
              >
                <span class="text-2xl mr-3">⚙️</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Set Schedule</div>
                  <div class="text-sm text-gray-500">Configure your hours</div>
                </div>
              </button>

              <button
                v-if="!isAdmin"
                @click="$router.push('/weekly-timesheet')"
                class="flex items-center justify-center p-4 bg-orange-50 rounded-lg hover:bg-orange-100 transition-colors"
              >
                <span class="text-2xl mr-3">📊</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Weekly Timesheet</div>
                  <div class="text-sm text-gray-500">Track your hours</div>
                </div>
              </button>

              <button
                v-if="!isAdmin"
                @click="$router.push('/attendance-calendar')"
                class="flex items-center justify-center p-4 bg-indigo-50 rounded-lg hover:bg-indigo-100 transition-colors"
              >
                <span class="text-2xl mr-3">📆</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Attendance Calendar</div>
                  <div class="text-sm text-gray-500">View monthly attendance</div>
                </div>
              </button>

              <!-- Manager Actions -->
              <button
                v-if="isManager"
                @click="$router.push('/teams')"
                class="flex items-center justify-center p-4 bg-indigo-50 rounded-lg hover:bg-indigo-100 transition-colors"
              >
                <span class="text-2xl mr-3">👥</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Manage Teams</div>
                  <div class="text-sm text-gray-500">View team members</div>
                </div>
              </button>

              <button
                v-if="isManager && !isAdmin"
                @click="$router.push('/timesheet-approvals')"
                class="flex items-center justify-center p-4 bg-yellow-50 rounded-lg hover:bg-yellow-100 transition-colors"
              >
                <span class="text-2xl mr-3">✅</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Approve Timesheets</div>
                  <div class="text-sm text-gray-500">Review submissions</div>
                </div>
              </button>

              <!-- Admin Actions -->
              <button
                v-if="isAdmin"
                @click="$router.push('/admin/users')"
                class="flex items-center justify-center p-4 bg-red-50 rounded-lg hover:bg-red-100 transition-colors"
              >
                <span class="text-2xl mr-3">👤</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Manage Users</div>
                  <div class="text-sm text-gray-500">User administration</div>
                </div>
              </button>

              <button
                v-if="isAdmin"
                @click="$router.push('/admin/teams')"
                class="flex items-center justify-center p-4 bg-pink-50 rounded-lg hover:bg-pink-100 transition-colors"
              >
                <span class="text-2xl mr-3">🏢</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Manage Teams</div>
                  <div class="text-sm text-gray-500">Team administration</div>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Charts Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Work Hours Chart -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Work Hours This Week</h3>
          <div class="h-64">
            <canvas ref="workHoursChart"></canvas>
          </div>
        </div>

        <!-- Productivity Chart -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Productivity Trends</h3>
          <div class="h-64">
            <canvas ref="productivityChart"></canvas>
          </div>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-900">Recent Activity</h3>
          <button
            @click="viewAllActivity"
            class="text-blue-600 hover:text-blue-800 text-sm font-medium"
          >
            View All →
          </button>
        </div>
        
        <div class="space-y-3">
          <div v-for="activity in recentActivities" :key="activity.id" class="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                <span class="text-sm font-medium text-gray-700">
                  {{ activity.user?.first_name?.[0] }}
                </span>
              </div>
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900">{{ activity.message }}</p>
              <p class="text-xs text-gray-500">{{ formatActivityTime(activity.timestamp) }}</p>
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
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { usersApi } from '../api/users'
import { workingTimesApi } from '../api/workingTimes'
import { clockinsApi } from '../api/clockins'
import { attendanceApi } from '../api/attendance'
import { userSchedulesApi } from '../api/userSchedules'
import { exportService } from '../services/exportService'
import { notificationService } from '../services/notificationService'
import RealTimeStatus from '../components/RealTimeStatus.vue'
import LoadingSpinner from '../components/LoadingSpinner.vue'
import Chart from 'chart.js/auto'

const router = useRouter()

// Reactive data
const loading = ref(true)
const user = ref(null)
const allSessions = ref([])
const totalWorkMin = ref(0)
const totalBreakMin = ref(0)
const productivityScore = ref(0)
const recentActivities = ref([])

// Attendance Timer
const attendanceMarked = ref(false)
const markingAttendance = ref(false)
const remainingSeconds = ref(0)
const scheduledHours = ref(8)
const attendanceStartTime = ref('')
let timerInterval = null

// Chart refs
const workHoursChart = ref(null)
const productivityChart = ref(null)
let workHoursChartInstance = null
let productivityChartInstance = null

// Computed properties
const userRole = computed(() => user.value?.role || 'employee')
const isAdmin = computed(() => userRole.value === 'admin')
const isManager = computed(() => userRole.value === 'manager' || userRole.value === 'admin')
const displayProductivityScore = computed(() => Math.round(productivityScore.value))

// Attendance Functions
const checkTodayAttendance = async () => {
  try {
    if (!user.value?.id) return
    
    const today = new Date().toISOString().split('T')[0]
    const attendanceResponse = await attendanceApi.list()
    const todayAttendance = attendanceResponse.data?.find(
      a => a.user_id === user.value.id && a.date === today && a.status === 'present'
    )
    
    if (todayAttendance) {
      attendanceMarked.value = true
      // Calculate remaining time
      const startTime = new Date(todayAttendance.inserted_at)
      attendanceStartTime.value = startTime.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
      
      const totalSeconds = scheduledHours.value * 3600
      const elapsedSeconds = Math.floor((Date.now() - startTime.getTime()) / 1000)
      remainingSeconds.value = Math.max(0, totalSeconds - elapsedSeconds)
      
      if (remainingSeconds.value > 0) {
        startTimer()
      }
    }
  } catch (error) {
    console.error('Error checking attendance:', error)
  }
}

const loadScheduledHours = async () => {
  try {
    if (!user.value?.id) return
    
    const today = new Date()
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    const dayName = dayNames[today.getDay()]
    
    const schedules = await userSchedulesApi.list(user.value.id)
    const todaySchedule = schedules.data?.find(s => s.day_of_week === dayName)
    
    if (todaySchedule && todaySchedule.scheduled_hours) {
      scheduledHours.value = todaySchedule.scheduled_hours
    }
  } catch (error) {
    console.error('Error loading schedule:', error)
    scheduledHours.value = 8 // Default to 8 hours
  }
}

const markAttendance = async () => {
  try {
    markingAttendance.value = true
    
    const today = new Date().toISOString().split('T')[0]
    const now = new Date()
    
    // Mark attendance as present
    await attendanceApi.create({
      user_id: user.value.id,
      date: today,
      status: 'present'
    })
    
    attendanceMarked.value = true
    attendanceStartTime.value = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
    remainingSeconds.value = scheduledHours.value * 3600 // Convert hours to seconds
    
    startTimer()
    notificationService.success(`Attendance marked! Timer started for ${scheduledHours.value} hours`)
  } catch (error) {
    console.error('Error marking attendance:', error)
    notificationService.error('Failed to mark attendance')
  } finally {
    markingAttendance.value = false
  }
}

const startTimer = () => {
  if (timerInterval) clearInterval(timerInterval)
  
  timerInterval = setInterval(() => {
    if (remainingSeconds.value > 0) {
      remainingSeconds.value--
    } else {
      clearInterval(timerInterval)
      notificationService.warning('⏰ Time is over! Your shift has ended.')
      
      // Play sound notification if possible
      try {
        const audio = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBSuBzvLZizcIGWi77eeeTRALT6fj8LZjHAU3j9fyz3osBSJ1x/DdkEELFF+06uunVRULRp/g8r1sIgUsgs/y2Yk3CBlou+3nnk0QC0+n4/C2YxwFN4/X8tB6LAUidcfw3ZBCC')
        audio.play().catch(() => {})
      } catch (e) {
        // Ignore audio errors
      }
    }
  }, 1000)
}

const formatTimer = (seconds) => {
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  const secs = seconds % 60
  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}

// Lifecycle
onMounted(() => {
  loadUser()
  loadDashboardData()
  initializeCharts()
  startLiveUpdates()
  loadScheduledHours()
  checkTodayAttendance()
})

onUnmounted(() => {
  if (workHoursChartInstance) workHoursChartInstance.destroy()
  if (productivityChartInstance) productivityChartInstance.destroy()
  if (timerInterval) clearInterval(timerInterval)
})

// Methods
const loadUser = () => {
  try {
    const userData = localStorage.getItem('currentUser')
    if (userData) {
      user.value = JSON.parse(userData)
    }
  } catch (error) {
    console.error('Error loading user:', error)
  }
}

const loadDashboardData = async () => {
  try {
    loading.value = true
    if (!user.value?.id) return

    // Load working times
    const workingTimesResponse = await workingTimesApi.list(user.value.id)
    const workingTimes = workingTimesResponse.data || []
    
    // Load clock-ins
    const clockinsResponse = await clockinsApi.listByUser(user.value.id)
    const clockins = clockinsResponse.data || []
    
    // Calculate totals
    calculateTotals(workingTimes, clockins)
    
    // Load real activities from API
    await loadRecentActivities()
    
  } catch (error) {
    console.error('Error loading dashboard data:', error)
    notificationService.error('Failed to load dashboard data')
  } finally {
    loading.value = false
  }
}

const calculateTotals = (workingTimes, clockins) => {
  // Calculate work and break time from working times
  totalWorkMin.value = workingTimes.reduce((total, wt) => {
    if (wt.start && wt.end) {
      const start = new Date(wt.start)
      const end = new Date(wt.end)
      const diffMs = end - start
      return total + (diffMs / (1000 * 60)) // Convert to minutes
    }
    return total
  }, 0)
  
  // Calculate break time (simplified)
  totalBreakMin.value = Math.max(0, totalWorkMin.value * 0.1) // 10% of work time as break
  
  // Calculate productivity score
  const expectedWorkTime = 8 * 60 // 8 hours in minutes
  productivityScore.value = Math.min(100, Math.round((totalWorkMin.value / expectedWorkTime) * 100))
}

const loadRecentActivities = async () => {
  try {
    if (!user.value?.id) return
    
    // Load recent clock-ins for the user
    const clockinsResponse = await clockinsApi.listByUser(user.value.id)
    const clocks = clockinsResponse.data || []
    
    // Convert clocks to activities
    recentActivities.value = clocks.slice(0, 5).map((clock, index) => ({
      id: clock.id || index,
      user: { first_name: user.value.first_name || 'You' },
      message: `${clock.status ? 'Clocked in' : 'Clocked out'} at ${formatTime(clock.time)}`,
      type: clock.status ? 'clock_in' : 'clock_out',
      timestamp: new Date(clock.time)
    }))
  } catch (error) {
    console.error('Error loading recent activities:', error)
    recentActivities.value = []
  }
}

const formatTime = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
}

const initializeCharts = () => {
  // Work Hours Chart
  if (workHoursChart.value) {
    const ctx = workHoursChart.value.getContext('2d')
    workHoursChartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        datasets: [{
          label: 'Work Hours',
          data: [8, 7.5, 8.5, 8, 7, 0, 0],
          backgroundColor: 'rgba(59, 130, 246, 0.8)',
          borderColor: 'rgb(59, 130, 246)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Hours'
            }
          }
        }
      }
    })
  }

  // Productivity Chart
  if (productivityChart.value) {
    const ctx = productivityChart.value.getContext('2d')
    productivityChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
        datasets: [{
          label: 'Productivity %',
          data: [85, 87, 90, 87],
          borderColor: 'rgb(16, 185, 129)',
          backgroundColor: 'rgba(16, 185, 129, 0.1)',
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 100,
            title: {
              display: true,
              text: 'Productivity %'
            }
          }
        }
      }
    })
  }
}

const startLiveUpdates = () => {
  // Simulate real-time updates
  setInterval(() => {
    // Update productivity score slightly
    productivityScore.value = Math.max(0, Math.min(100, Math.round(productivityScore.value + (Math.random() - 0.5) * 2)))
  }, 10000)
}

const refreshData = () => {
  loadDashboardData()
  notificationService.success('Dashboard data refreshed')
}

const exportReport = () => {
  try {
    const reportData = {
      totalEmployees: 1,
      totalTeams: 1,
      averageWorkHours: totalWorkMin.value / 60,
      productivityScore: Math.round(productivityScore.value)
    }
    
    exportService.exportComprehensiveReport(reportData)
    notificationService.success('Report exported successfully')
  } catch (error) {
    console.error('Error exporting report:', error)
    notificationService.error('Failed to export report')
  }
}

const viewAllActivity = () => {
  // TODO: Navigate to activity page
  notificationService.info('Activity page will be implemented soon')
}

const formatActivityTime = (timestamp) => {
  if (typeof timestamp === 'number') {
    // Format minutes to HH:MM
    const hours = Math.floor(timestamp / 60)
    const minutes = Math.round(timestamp % 60)
    return `${hours}:${minutes.toString().padStart(2, '0')}`
  }
  
  const now = new Date()
  const diff = now - timestamp
  const minutes = Math.floor(diff / 60000)
  
  if (minutes < 1) return 'Just now'
  if (minutes < 60) return `${minutes}m ago`
  
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  
  return timestamp.toLocaleDateString()
}
</script>