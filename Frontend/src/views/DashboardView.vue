<template>
  <div class="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50">
    <!-- Loading State -->
    <LoadingSpinner v-if="loading" :show="loading" text="Loading dashboard data..." size="xl" containerClass="min-h-screen" />
    
    <div v-else class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Modern Page Header - Responsive -->
      <div class="mb-8 sm:mb-12">
        <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0">
          <div class="space-y-2">
            <h1 class="text-2xl sm:text-3xl lg:text-4xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
              Dashboard
            </h1>
            <div class="flex flex-col sm:flex-row sm:items-center sm:space-x-3 space-y-2 sm:space-y-0">
              <p class="text-gray-600 text-sm sm:text-base lg:text-lg">
                Welcome back, 
                <span class="font-semibold text-gray-900">
                  {{ user?.username || `${user?.first_name} ${user?.last_name}` }}
                </span>
              </p>
              <div 
                class="px-3 py-1 text-xs sm:text-sm font-medium rounded-full shadow-sm w-fit"
                :class="{
                  'bg-gradient-to-r from-purple-500 to-purple-600 text-white': userRole === 'admin',
                  'bg-gradient-to-r from-blue-500 to-blue-600 text-white': userRole === 'manager',
                  'bg-gradient-to-r from-green-500 to-green-600 text-white': userRole === 'employee'
                }"
              >
                {{ userRole?.toUpperCase() }}
              </div>
            </div>
          </div>
          <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
            <button
              @click="refreshData"
              class="group px-4 sm:px-6 py-2.5 sm:py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white text-sm font-semibold rounded-xl hover:from-blue-600 hover:to-blue-700 transform hover:-translate-y-1 transition-all duration-200 shadow-lg hover:shadow-xl"
            >
              <svg class="w-4 h-4 inline mr-2 group-hover:rotate-180 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
              </svg>
              Refresh
            </button>
            <button
              @click="exportReport"
              class="group px-4 sm:px-6 py-2.5 sm:py-3 bg-gradient-to-r from-emerald-500 to-emerald-600 text-white text-sm font-semibold rounded-xl hover:from-emerald-600 hover:to-emerald-700 transform hover:-translate-y-1 transition-all duration-200 shadow-lg hover:shadow-xl"
            >
              <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
              </svg>
              <span class="hidden sm:inline">Export Report</span>
              <span class="sm:hidden">Export</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Beautiful Key Metrics Cards - Responsive -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 lg:gap-8 mb-8 sm:mb-12">
        <!-- Total Work Time Card -->
        <div class="group bg-white/80 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-4 sm:p-6 lg:p-8 hover:shadow-2xl hover:-translate-y-2 transition-all duration-300 relative overflow-hidden">
          <div class="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-indigo-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          <div class="relative z-10">
            <div class="flex items-center justify-between mb-4">
              <div class="p-4 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl shadow-lg">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
              </div>
              <div class="text-right">
                <p class="text-xs font-medium text-gray-500 uppercase tracking-wider">Today</p>
                <div class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
              </div>
            </div>
            <h3 class="text-sm font-semibold text-gray-600 mb-2">Total Work Time</h3>
            <p class="text-3xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">{{ formatActivityTime(totalWorkMin) }}</p>
          </div>
        </div>

        <!-- Break Time Card -->
        <div class="group bg-white/80 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-4 sm:p-6 lg:p-8 hover:shadow-2xl hover:-translate-y-2 transition-all duration-300 relative overflow-hidden">
          <div class="absolute inset-0 bg-gradient-to-br from-orange-500/10 to-amber-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          <div class="relative z-10">
            <div class="flex items-center justify-between mb-4">
              <div class="p-4 bg-gradient-to-br from-orange-500 to-amber-500 rounded-2xl shadow-lg">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
                </svg>
              </div>
              <div class="text-right">
                <p class="text-xs font-medium text-gray-500 uppercase tracking-wider">Today</p>
                <div class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
              </div>
            </div>
            <h3 class="text-sm font-semibold text-gray-600 mb-2">Break Time</h3>
            <p class="text-3xl font-bold bg-gradient-to-r from-orange-600 to-amber-600 bg-clip-text text-transparent">{{ formatActivityTime(totalBreakMin) }}</p>
          </div>
        </div>

        <!-- Sessions Card -->
        <div class="group bg-white/80 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-4 sm:p-6 lg:p-8 hover:shadow-2xl hover:-translate-y-2 transition-all duration-300 relative overflow-hidden">
          <div class="absolute inset-0 bg-gradient-to-br from-emerald-500/10 to-green-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          <div class="relative z-10">
            <div class="flex items-center justify-between mb-4">
              <div class="p-4 bg-gradient-to-br from-emerald-500 to-green-500 rounded-2xl shadow-lg">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                </svg>
              </div>
              <div class="text-right">
                <p class="text-xs font-medium text-gray-500 uppercase tracking-wider">Today</p>
                <div class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
              </div>
            </div>
            <h3 class="text-sm font-semibold text-gray-600 mb-2">Sessions</h3>
            <p class="text-3xl font-bold bg-gradient-to-r from-emerald-600 to-green-600 bg-clip-text text-transparent">{{ allSessions.length }}</p>
          </div>
        </div>

        <!-- Productivity Card -->
        <div class="group bg-white/80 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-4 sm:p-6 lg:p-8 hover:shadow-2xl hover:-translate-y-2 transition-all duration-300 relative overflow-hidden">
          <div class="absolute inset-0 bg-gradient-to-br from-purple-500/10 to-pink-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          <div class="relative z-10">
            <div class="flex items-center justify-between mb-4">
              <div class="p-4 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl shadow-lg">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
              </div>
              <div class="text-right">
                <p class="text-xs font-medium text-gray-500 uppercase tracking-wider">Today</p>
                <div class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
              </div>
            </div>
            <h3 class="text-sm font-semibold text-gray-600 mb-2">Productivity</h3>
            <p class="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">{{ displayProductivityScore }}%</p>
          </div>
        </div>
      </div>

      <!-- Main Content Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12">
        <!-- Real-Time Status -->
        <div class="lg:col-span-1">
          <div class="bg-white/80 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-6 hover:shadow-2xl transition-all duration-300">
            <RealTimeStatus />
          </div>
        </div>

        <!-- Quick Actions - Responsive -->
        <div class="lg:col-span-2">
          <div class="bg-white/80 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-4 sm:p-6 lg:p-8 hover:shadow-2xl transition-all duration-300">
            <div class="flex items-center mb-4 sm:mb-6">
              <div class="p-2 sm:p-3 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl shadow-lg mr-3 sm:mr-4">
                <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                </svg>
              </div>
              <h3 class="text-xl sm:text-2xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">Quick Actions</h3>
            </div>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
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

              <button
                v-if="!isAdmin"
                @click="showComplaintForm = true"
                class="flex items-center justify-center p-4 bg-red-50 rounded-lg hover:bg-red-100 transition-colors"
              >
                <span class="text-2xl mr-3">📝</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">Submit Complaint</div>
                  <div class="text-sm text-gray-500">Report an issue</div>
                </div>
              </button>

              <button
                v-if="!isAdmin"
                @click="$router.push('/my-complaints')"
                class="flex items-center justify-center p-4 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors"
              >
                <span class="text-2xl mr-3">💬</span>
                <div class="text-left">
                  <div class="font-medium text-gray-900">My Complaints</div>
                  <div class="text-sm text-gray-500">View responses</div>
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
          <div class="h-64 relative">
            <canvas ref="workHoursChart" class="w-full h-full"></canvas>
            <div v-if="!workHoursChart" class="absolute inset-0 flex items-center justify-center text-gray-500">
              <div class="text-center">
                <div class="text-4xl mb-2">📊</div>
                <div class="text-sm">Loading chart...</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Productivity Chart -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Productivity Trends</h3>
          <div class="h-64 relative">
            <canvas ref="productivityChart" class="w-full h-full"></canvas>
            <div v-if="!productivityChart" class="absolute inset-0 flex items-center justify-center text-gray-500">
              <div class="text-center">
                <div class="text-4xl mb-2">📈</div>
                <div class="text-sm">Loading chart...</div>
              </div>
            </div>
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

    <!-- Complaint Form Modal -->
    <ComplaintForm v-if="showComplaintForm" @close="showComplaintForm = false" @submitted="handleComplaintSubmitted" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
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
import ComplaintForm from '../components/ComplaintForm.vue'
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

// Complaint Form
const showComplaintForm = ref(false)

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
    
    // Auto-trigger clock-in when marking attendance
    try {
      await clockinsApi.toggleForUser(user.value.id, true) // true = clock in
      console.log('Auto clock-in triggered after marking attendance')
    } catch (clockError) {
      console.error('Error auto clocking in:', clockError)
      // Don't fail the attendance marking if clock-in fails
    }
    
    attendanceMarked.value = true
    attendanceStartTime.value = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
    remainingSeconds.value = scheduledHours.value * 3600 // Convert hours to seconds
    
    startTimer()
    notificationService.success(`Attendance marked and clocked in! Timer started for ${scheduledHours.value} hours`)
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
onMounted(async () => {
  loadUser()
  await loadDashboardData()
  await nextTick() // Ensure DOM is ready
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
  // Get today's date
  const today = new Date()
  const todayStr = today.toISOString().split('T')[0] // YYYY-MM-DD format
  
  // Filter working times to only include today's data
  const todayWorkingTimes = workingTimes.filter(wt => {
    if (!wt.start) return false
    const workDate = new Date(wt.start).toISOString().split('T')[0]
    return workDate === todayStr
  })
  
  // Filter clockins to only include today's data for sessions count
  const todayClockins = clockins.filter(clockin => {
    if (!clockin.time) return false
    const clockinDate = new Date(clockin.time).toISOString().split('T')[0]
    return clockinDate === todayStr
  })
  
  // Calculate work time only from today's working times
  totalWorkMin.value = todayWorkingTimes.reduce((total, wt) => {
    if (wt.start && wt.end) {
      const start = new Date(wt.start)
      const end = new Date(wt.end)
      const diffMs = end - start
      return total + (diffMs / (1000 * 60)) // Convert to minutes
    }
    return total
  }, 0)
  
  // Calculate break time (simplified) - only for today
  totalBreakMin.value = Math.max(0, totalWorkMin.value * 0.1) // 10% of work time as break
  
  // Calculate today's sessions (clock in/out pairs)
  const todaySessions = []
  let currentSession = null
  
  todayClockins.forEach(clockin => {
    if (clockin.status === true) { // Clock in
      currentSession = { start: clockin.time, end: null }
    } else if (clockin.status === false && currentSession) { // Clock out
      currentSession.end = clockin.time
      todaySessions.push(currentSession)
      currentSession = null
    }
  })
  
  // If there's an open session (clocked in but not out), count it
  if (currentSession) {
    todaySessions.push(currentSession)
  }
  
  allSessions.value = todaySessions
  
  // Calculate productivity score based on today's work
  const expectedWorkTime = 8 * 60 // 8 hours in minutes
  productivityScore.value = Math.min(100, Math.round((totalWorkMin.value / expectedWorkTime) * 100))
  
  // Debug logging
  console.log('📊 Dashboard Time Calculation:')
  console.log('Today:', todayStr)
  console.log('Total working times:', workingTimes.length)
  console.log('Today working times:', todayWorkingTimes.length)
  console.log('Total clockins:', clockins.length)
  console.log('Today clockins:', todayClockins.length)
  console.log('Today sessions:', todaySessions.length)
  console.log('Today work minutes:', totalWorkMin.value)
  console.log('Today work hours:', (totalWorkMin.value / 60).toFixed(2))
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
  console.log('Initializing charts...')
  
  // Work Hours Chart
  if (workHoursChart.value) {
    console.log('Creating work hours chart...')
    try {
      const ctx = workHoursChart.value.getContext('2d')
      
      // Destroy existing chart if it exists
      if (workHoursChartInstance) {
        workHoursChartInstance.destroy()
      }
      
      workHoursChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          datasets: [{
            label: 'Work Hours',
            data: [8, 7.5, 8.5, 8, 7, 0, 0],
            backgroundColor: [
              'rgba(59, 130, 246, 0.8)',
              'rgba(59, 130, 246, 0.8)',
              'rgba(59, 130, 246, 0.8)',
              'rgba(59, 130, 246, 0.8)',
              'rgba(59, 130, 246, 0.8)',
              'rgba(156, 163, 175, 0.5)',
              'rgba(156, 163, 175, 0.5)'
            ],
            borderColor: 'rgb(59, 130, 246)',
            borderWidth: 2,
            borderRadius: 6,
            borderSkipped: false
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
      console.log('Work hours chart created successfully')
    } catch (error) {
      console.error('Error creating work hours chart:', error)
    }
  } else {
    console.log('Work hours chart canvas not found')
  }

  // Productivity Chart
  if (productivityChart.value) {
    console.log('Creating productivity chart...')
    try {
      const ctx = productivityChart.value.getContext('2d')
      
      // Destroy existing chart if it exists
      if (productivityChartInstance) {
        productivityChartInstance.destroy()
      }
      
      productivityChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
        datasets: [{
          label: 'Productivity %',
          data: [85, 87, 90, 87],
          borderColor: 'rgb(16, 185, 129)',
          backgroundColor: 'rgba(16, 185, 129, 0.1)',
          borderWidth: 3,
          pointBackgroundColor: 'rgb(16, 185, 129)',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 6,
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
      console.log('Productivity chart created successfully')
    } catch (error) {
      console.error('Error creating productivity chart:', error)
    }
  } else {
    console.log('Productivity chart canvas not found')
  }
}

const startLiveUpdates = () => {
  // Simulate real-time updates
  setInterval(() => {
    // Update productivity score slightly
    productivityScore.value = Math.max(0, Math.min(100, Math.round(productivityScore.value + (Math.random() - 0.5) * 2)))
  }, 10000)
}

const refreshData = async () => {
  await loadDashboardData()
  await nextTick() // Ensure DOM is ready
  initializeCharts() // Re-initialize charts
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

const handleComplaintSubmitted = () => {
  notificationService.success('Your complaint has been submitted successfully!')
  showComplaintForm.value = false
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