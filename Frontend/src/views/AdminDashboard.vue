<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Admin Dashboard</h1>
            <p class="text-gray-600">Global overview of organization performance and activity</p>
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
              <span class="text-2xl">👥</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Total Employees</p>
              <p class="text-2xl font-bold text-gray-900">{{ totalEmployees }}</p>
              <p class="text-xs text-green-600">+12% from last month</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-green-100 rounded-lg">
              <span class="text-2xl">🟢</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Online Now</p>
              <p class="text-2xl font-bold text-gray-900">{{ onlineUsers }}</p>
              <p class="text-xs text-blue-600">{{ onlinePercentage }}% of total</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-purple-100 rounded-lg">
              <span class="text-2xl">⏰</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Avg Work Hours</p>
              <p class="text-2xl font-bold text-gray-900">{{ averageWorkHours }}</p>
              <p class="text-xs text-orange-600">Today</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-orange-100 rounded-lg">
              <span class="text-2xl">📈</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Productivity</p>
              <p class="text-2xl font-bold text-gray-900">{{ Math.round(productivityScore) }}%</p>
              <p class="text-xs text-green-600">+5% this week</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Charts Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Working Hours Chart -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Working Hours Trend</h3>
          <div class="h-64">
            <canvas ref="hoursChart"></canvas>
          </div>
        </div>

        <!-- Team Performance Chart -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Team Performance</h3>
          <div class="h-64">
            <canvas ref="teamChart"></canvas>
          </div>
        </div>
      </div>

      <!-- Top Performers and Alerts -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Top Performers -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Top Performers</h3>
          <div class="space-y-3">
            <div v-for="(performer, index) in topPerformers" :key="performer.id" class="flex items-center space-x-3">
              <div class="flex-shrink-0">
                <span class="text-sm font-medium text-gray-500">#{{ index + 1 }}</span>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-gray-900">{{ performer.name }}</p>
                <p class="text-xs text-gray-500">{{ performer.hours }} hours this week</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Alerts -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Recent Alerts</h3>
          <div class="space-y-3">
            <div v-for="alert in recentAlerts" :key="alert.id" class="flex items-start space-x-3">
              <div class="flex-shrink-0">
                <span :class="[
                  'w-2 h-2 rounded-full mt-2',
                  alert.type === 'warning' ? 'bg-yellow-400' :
                  alert.type === 'error' ? 'bg-red-400' :
                  'bg-green-400'
                ]"></span>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm text-gray-900">{{ alert.message }}</p>
                <p class="text-xs text-gray-500">{{ formatTime(alert.timestamp) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Team Overview -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-semibold text-gray-900">Team Overview</h3>
          <button
            @click="$router.push('/admin/teams')"
            class="text-blue-600 hover:text-blue-800 text-sm font-medium"
          >
            View All Teams →
          </button>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="team in teams" :key="team.id" class="border border-gray-200 rounded-lg p-4">
            <div class="flex items-center justify-between mb-3">
              <h4 class="font-medium text-gray-900">{{ team.name }}</h4>
              <span class="text-sm text-gray-500">{{ team.memberCount }} members</span>
            </div>
            
            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="text-gray-500">Manager:</span>
                <span class="text-gray-900">{{ team.managerName }}</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="text-gray-500">Online:</span>
                <span class="text-green-600">{{ team.onlineCount }}/{{ team.memberCount }}</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="text-gray-500">Avg Hours:</span>
                <span class="text-gray-900">{{ team.averageHours }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { usersApi } from '../api/users'
import { teamsApi } from '../api/teams'
import { chartsApi } from '../api/charts'
import { clockinsApi } from '../api/clockins'
import { workingTimesApi } from '../api/workingTimes'
import Chart from 'chart.js/auto'

// Reactive data
const totalEmployees = ref(0)
const onlineUsers = ref(0)
const averageWorkHours = ref('8:30')
const productivityScore = ref(87)
const topPerformers = ref([])
const recentAlerts = ref([])
const teams = ref([])

// Chart refs
const hoursChart = ref(null)
const teamChart = ref(null)
let hoursChartInstance = null
let teamChartInstance = null

// Computed properties
const onlinePercentage = computed(() => {
  return totalEmployees.value > 0 ? Math.round((onlineUsers.value / totalEmployees.value) * 100) : 0
})


// Lifecycle
onMounted(() => {
  loadDashboardData()
  initializeCharts()
  startLiveUpdates()
})

onUnmounted(() => {
  if (hoursChartInstance) hoursChartInstance.destroy()
  if (teamChartInstance) teamChartInstance.destroy()
})

// Methods
const loadDashboardData = async () => {
  try {
    // Load users
    const usersResponse = await usersApi.list()
    const users = usersResponse.data || []
    totalEmployees.value = users.length

    // Load clock-in data to determine online status
    const clockPromises = users.map(user => 
      clockinsApi.listByUser(user.id).catch(() => ({ data: [] }))
    )
    const clockResponses = await Promise.all(clockPromises)
    
    // Calculate online users (clocked in within last 12 hours)
    let onlineCount = 0
    let totalHours = 0
    
    users.forEach((user, index) => {
      const clocks = clockResponses[index]?.data || []
      if (clocks.length > 0) {
        const lastClock = clocks[0]
        const clockTime = new Date(lastClock.time)
        const hoursSince = (Date.now() - clockTime.getTime()) / (1000 * 60 * 60)
        
        if (hoursSince < 12 && lastClock.status) {
          onlineCount++
        }
      }
    })
    
    onlineUsers.value = onlineCount

    // Load teams with real data
    const teamsResponse = await teamsApi.list()
    const baseTeams = teamsResponse.data || []
    
    teams.value = await Promise.all(baseTeams.map(async (team) => {
      // Get team members by checking if user has team_id matching team.id
      const teamMembers = users.filter(u => u.team_id === team.id)
      
      // Calculate online members for this team
      let teamOnlineCount = 0
      teamMembers.forEach((member, memberIndex) => {
        // Find the user's index in the main users array
        const userIndex = users.findIndex(u => u.id === member.id)
        if (userIndex >= 0) {
          const clocks = clockResponses[userIndex]?.data || []
          if (clocks.length > 0) {
            const lastClock = clocks[0]
            const clockTime = new Date(lastClock.time)
            const hoursSince = (Date.now() - clockTime.getTime()) / (1000 * 60 * 60)
            if (hoursSince < 12 && lastClock.status) {
              teamOnlineCount++
            }
          }
        }
      })
      
      return {
        ...team,
        memberCount: teamMembers.length,
        onlineCount: teamOnlineCount,
        managerName: team.manager_name || 'Manager',
        averageHours: '8:15'
      }
    }))

    // Calculate average work hours
    const workHoursTotal = await calculateTotalWorkHours(users)
    const avgHours = users.length > 0 ? workHoursTotal / users.length : 0
    const hours = Math.floor(avgHours)
    const minutes = Math.round((avgHours - hours) * 60)
    averageWorkHours.value = `${hours}:${minutes.toString().padStart(2, '0')}`

    // Generate sample data
    generateSampleData()
  } catch (error) {
    console.error('Error loading dashboard data:', error)
  }
}

const calculateTotalWorkHours = async (users) => {
  let total = 0
  const today = new Date()
  
  for (const user of users) {
    try {
      const workingTimesResponse = await workingTimesApi.list(
        user.id,
        today.toISOString(),
        today.toISOString()
      )
      const workingTimes = workingTimesResponse.data || []
      
      workingTimes.forEach(wt => {
        if (wt.start && wt.end) {
          const start = new Date(wt.start)
          const end = new Date(wt.end)
          total += (end - start) / (1000 * 60 * 60)
        }
      })
    } catch (err) {
      // Skip on error
    }
  }
  
  return total
}

const generateSampleData = async () => {
  try {
    // Fetch users for top performers calculation
    const usersResponse = await usersApi.list()
    const users = usersResponse.data || []
    
    // Calculate top performers based on real working hours
    const userHours = []
    for (const user of users) {
      try {
        const today = new Date()
        const weekStart = new Date(today.setDate(today.getDate() - today.getDay()))
        const weekEnd = new Date(weekStart)
        weekEnd.setDate(weekStart.getDate() + 6)
        
        const workingTimesResponse = await workingTimesApi.list(
          user.id,
          weekStart.toISOString(),
          weekEnd.toISOString()
        )
        const workingTimes = workingTimesResponse.data || []
        
        let totalHours = 0
        workingTimes.forEach(wt => {
          if (wt.start && wt.end) {
            const start = new Date(wt.start)
            const end = new Date(wt.end)
            totalHours += (end - start) / (1000 * 60 * 60)
          }
        })
        
        if (totalHours > 0) {
          const hours = Math.floor(totalHours)
          const minutes = Math.round((totalHours - hours) * 60)
          userHours.push({
            id: user.id,
            name: `${user.first_name} ${user.last_name}`,
            hours: `${hours}:${minutes.toString().padStart(2, '0')}`,
            totalHours
          })
        }
      } catch (err) {
        // Skip on error
      }
    }
    
    // Sort by total hours and take top 3
    userHours.sort((a, b) => b.totalHours - a.totalHours)
    topPerformers.value = userHours.slice(0, 3)

    // Generate recent alerts (these would come from a notification system in production)
    recentAlerts.value = [
      {
        id: 1,
        type: 'info',
        message: `${users.length} employees currently tracked in system`,
        timestamp: new Date(Date.now() - 30 * 60 * 1000)
      },
      {
        id: 2,
        type: 'warning',
        message: `${onlineUsers.value} employees currently online`,
        timestamp: new Date(Date.now() - 60 * 60 * 1000)
      }
    ]
  } catch (error) {
    console.error('Error generating sample data:', error)
  }
}

const initializeCharts = () => {
  // Working Hours Chart
  if (hoursChart.value) {
    const ctx = hoursChart.value.getContext('2d')
    hoursChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        datasets: [{
          label: 'Scheduled Hours',
          data: [8, 8, 8, 8, 8, 0, 0],
          borderColor: 'rgb(59, 130, 246)',
          backgroundColor: 'rgba(59, 130, 246, 0.1)',
          tension: 0.4
        }, {
          label: 'Actual Hours',
          data: [8.5, 7.5, 8.2, 8.8, 7.2, 0, 0],
          borderColor: 'rgb(16, 185, 129)',
          backgroundColor: 'rgba(16, 185, 129, 0.1)',
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top'
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

  // Team Performance Chart
  if (teamChart.value) {
    const ctx = teamChart.value.getContext('2d')
    teamChartInstance = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Development', 'Marketing', 'Sales', 'Support'],
        datasets: [{
          data: [35, 25, 20, 20],
          backgroundColor: [
            'rgb(59, 130, 246)',
            'rgb(16, 185, 129)',
            'rgb(245, 158, 11)',
            'rgb(239, 68, 68)'
          ]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom'
          }
        }
      }
    })
  }
}

const startLiveUpdates = () => {
  // Simulate real-time updates
  setInterval(() => {
    // Update online users count
    onlineUsers.value = Math.floor(totalEmployees.value * (0.6 + Math.random() * 0.3))
    
    // Add new activity
    const activities = ['Clocked in', 'Clocked out', 'Started break', 'Ended break']
    const names = ['John Doe', 'Jane Smith', 'Mike Johnson', 'Alice Brown']
    
    if (Math.random() > 0.7) {
      liveActivities.value.unshift({
        id: Date.now(),
        user: { first_name: names[Math.floor(Math.random() * names.length)].split(' ')[0] },
        message: activities[Math.floor(Math.random() * activities.length)],
        timestamp: new Date()
      })
      
      // Keep only last 10 activities
      if (liveActivities.value.length > 10) {
        liveActivities.value = liveActivities.value.slice(0, 10)
      }
    }
  }, 5000)
}

const refreshData = () => {
  loadDashboardData()
}

const exportReport = () => {
  // TODO: Implement report export
  alert('Report export functionality will be implemented soon!')
}

const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleTimeString()
}
</script>