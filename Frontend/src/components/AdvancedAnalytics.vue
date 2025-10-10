<template>
  <div class="space-y-6">
    <!-- Analytics Header -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100">Advanced Analytics</h3>
        <div class="flex items-center space-x-2">
          <select
            v-model="selectedPeriod"
            class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
          >
            <option value="week">This Week</option>
            <option value="month">This Month</option>
            <option value="quarter">This Quarter</option>
            <option value="year">This Year</option>
          </select>
          <button
            @click="refreshAnalytics"
            class="px-3 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700"
          >
            🔄 Refresh
          </button>
        </div>
      </div>
      
      <!-- Key Metrics -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="text-center p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ totalHours }}</div>
          <div class="text-sm text-blue-600 dark:text-blue-400">Total Hours</div>
        </div>
        <div class="text-center p-4 bg-green-50 dark:bg-green-900/20 rounded-lg">
          <div class="text-2xl font-bold text-green-600 dark:text-green-400">{{ productivity }}%</div>
          <div class="text-sm text-green-600 dark:text-green-400">Productivity</div>
        </div>
        <div class="text-center p-4 bg-yellow-50 dark:bg-yellow-900/20 rounded-lg">
          <div class="text-2xl font-bold text-yellow-600 dark:text-yellow-400">{{ overtimeHours }}</div>
          <div class="text-sm text-yellow-600 dark:text-yellow-400">Overtime</div>
        </div>
        <div class="text-center p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
          <div class="text-2xl font-bold text-purple-600 dark:text-purple-400">{{ attendance }}%</div>
          <div class="text-sm text-purple-600 dark:text-purple-400">Attendance</div>
        </div>
      </div>
    </div>

    <!-- Charts Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Work Hours Trend -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <h4 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Work Hours Trend</h4>
        <div class="h-64">
          <canvas ref="workHoursChart"></canvas>
        </div>
      </div>

      <!-- Team Performance -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <h4 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Team Performance</h4>
        <div class="h-64">
          <canvas ref="teamPerformanceChart"></canvas>
        </div>
      </div>

      <!-- Productivity Distribution -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <h4 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Productivity Distribution</h4>
        <div class="h-64">
          <canvas ref="productivityChart"></canvas>
        </div>
      </div>

      <!-- Attendance Heatmap -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <h4 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Attendance Heatmap</h4>
        <div class="h-64">
          <canvas ref="attendanceChart"></canvas>
        </div>
      </div>
    </div>

    <!-- Detailed Analytics Table -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
      <h4 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Detailed Analytics</h4>
      
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Metric</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Current</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Previous</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Change</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Trend</th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="metric in analyticsData" :key="metric.name">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-gray-100">
                {{ metric.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                {{ metric.current }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ metric.previous }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm">
                <span :class="[
                  'px-2 py-1 text-xs font-medium rounded-full',
                  metric.change > 0 ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400' :
                  metric.change < 0 ? 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400' :
                  'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
                ]">
                  {{ metric.change > 0 ? '+' : '' }}{{ metric.change }}%
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                <span v-if="metric.change > 0">📈</span>
                <span v-else-if="metric.change < 0">📉</span>
                <span v-else>➡️</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import Chart from 'chart.js/auto'

const selectedPeriod = ref('week')
const totalHours = ref('40:30')
const productivity = ref(87)
const overtimeHours = ref('2:15')
const attendance = ref(95)

// Chart refs
const workHoursChart = ref(null)
const teamPerformanceChart = ref(null)
const productivityChart = ref(null)
const attendanceChart = ref(null)

let workHoursChartInstance = null
let teamPerformanceChartInstance = null
let productivityChartInstance = null
let attendanceChartInstance = null

const analyticsData = ref([
  { name: 'Average Work Hours', current: '8:15', previous: '8:00', change: 3.1 },
  { name: 'Productivity Score', current: '87%', previous: '85%', change: 2.4 },
  { name: 'Overtime Hours', current: '2:15', previous: '1:45', change: 28.6 },
  { name: 'Attendance Rate', current: '95%', previous: '92%', change: 3.3 },
  { name: 'Break Time', current: '1:00', previous: '1:15', change: -20.0 },
  { name: 'Team Collaboration', current: '4.2', previous: '4.0', change: 5.0 }
])

const initializeCharts = () => {
  // Work Hours Trend Chart
  if (workHoursChart.value) {
    const ctx = workHoursChart.value.getContext('2d')
    workHoursChartInstance = new Chart(ctx, {
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
  if (teamPerformanceChart.value) {
    const ctx = teamPerformanceChart.value.getContext('2d')
    teamPerformanceChartInstance = new Chart(ctx, {
      type: 'radar',
      data: {
        labels: ['Productivity', 'Attendance', 'Collaboration', 'Punctuality', 'Quality'],
        datasets: [{
          label: 'Team Average',
          data: [85, 92, 78, 88, 90],
          borderColor: 'rgb(59, 130, 246)',
          backgroundColor: 'rgba(59, 130, 246, 0.2)',
          pointBackgroundColor: 'rgb(59, 130, 246)'
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
          r: {
            beginAtZero: true,
            max: 100
          }
        }
      }
    })
  }

  // Productivity Distribution Chart
  if (productivityChart.value) {
    const ctx = productivityChart.value.getContext('2d')
    productivityChartInstance = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['High Productivity', 'Medium Productivity', 'Low Productivity'],
        datasets: [{
          data: [60, 30, 10],
          backgroundColor: [
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

  // Attendance Heatmap Chart
  if (attendanceChart.value) {
    const ctx = attendanceChart.value.getContext('2d')
    attendanceChartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
        datasets: [{
          label: 'Attendance Rate',
          data: [95, 92, 98, 95],
          backgroundColor: [
            'rgba(16, 185, 129, 0.8)',
            'rgba(245, 158, 11, 0.8)',
            'rgba(16, 185, 129, 0.8)',
            'rgba(16, 185, 129, 0.8)'
          ],
          borderColor: [
            'rgb(16, 185, 129)',
            'rgb(245, 158, 11)',
            'rgb(16, 185, 129)',
            'rgb(16, 185, 129)'
          ],
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
            max: 100,
            title: {
              display: true,
              text: 'Attendance %'
            }
          }
        }
      }
    })
  }
}

const refreshAnalytics = () => {
  // Simulate data refresh
  productivity.value = Math.floor(Math.random() * 20) + 80
  attendance.value = Math.floor(Math.random() * 10) + 90
}

// Watch for period changes
watch(selectedPeriod, () => {
  refreshAnalytics()
})

onMounted(() => {
  initializeCharts()
})

onUnmounted(() => {
  if (workHoursChartInstance) workHoursChartInstance.destroy()
  if (teamPerformanceChartInstance) teamPerformanceChartInstance.destroy()
  if (productivityChartInstance) productivityChartInstance.destroy()
  if (attendanceChartInstance) attendanceChartInstance.destroy()
})
</script>
