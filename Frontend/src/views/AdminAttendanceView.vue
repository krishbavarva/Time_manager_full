<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Admin Attendance Management</h1>
        <p class="mt-2 text-sm text-gray-600">View and manage attendance for all employees and managers</p>
      </div>

      <!-- Loading State -->
      <LoadingSpinner v-if="loading" :show="loading" text="Loading attendance data..." size="lg" />

      <!-- Filters and Controls -->
      <div v-else class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
        <div class="flex flex-wrap items-center gap-4">
          <!-- Month/Year Selector -->
          <div class="flex items-center gap-2">
            <label class="text-sm font-medium text-gray-700">Month:</label>
            <select v-model="selectedMonth" @change="loadAttendanceData" class="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
              <option v-for="(month, index) in months" :key="index" :value="index">{{ month }}</option>
            </select>
          </div>
          
          <div class="flex items-center gap-2">
            <label class="text-sm font-medium text-gray-700">Year:</label>
            <select v-model="selectedYear" @change="loadAttendanceData" class="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
              <option v-for="year in years" :key="year" :value="year">{{ year }}</option>
            </select>
          </div>

          <!-- User Filter -->
          <div class="flex items-center gap-2">
            <label class="text-sm font-medium text-gray-700">User:</label>
            <select v-model="selectedUserId" @change="loadAttendanceData" class="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
              <option value="">All Users</option>
              <option v-for="user in users" :key="user.id" :value="user.id">{{ user.name }} ({{ user.role }})</option>
            </select>
          </div>

          <!-- Status Filter -->
          <div class="flex items-center gap-2">
            <label class="text-sm font-medium text-gray-700">Status:</label>
            <select v-model="selectedStatus" @change="loadAttendanceData" class="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
              <option value="">All Status</option>
              <option value="present">Present</option>
              <option value="absent">Absent</option>
              <option value="pending">Pending</option>
              <option value="on_leave">On Leave</option>
            </select>
          </div>
          
          <!-- View Toggle -->
          <div class="flex items-center gap-2 ml-auto">
            <button 
              @click="viewMode = 'today'"
              :class="viewMode === 'today' ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700'"
              class="px-4 py-2 rounded-lg font-medium transition-colors">
              Today's Status
            </button>
            <button 
              @click="viewMode = 'history'"
              :class="viewMode === 'history' ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700'"
              class="px-4 py-2 rounded-lg font-medium transition-colors">
              History
            </button>
          </div>

          <!-- Refresh Button -->
          <button @click="loadAttendanceData" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
            <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Refresh
          </button>
        </div>
      </div>

      <!-- Summary Stats -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-green-100">
              <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Total Present</p>
              <p class="text-2xl font-bold text-gray-900">{{ stats.present }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-red-100">
              <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Total Absent</p>
              <p class="text-2xl font-bold text-gray-900">{{ stats.absent }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-yellow-100">
              <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">{{ viewMode === 'today' ? 'Pending' : 'On Leave' }}</p>
              <p class="text-2xl font-bold text-gray-900">{{ stats.onLeave }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-blue-100">
              <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Attendance Rate</p>
              <p class="text-2xl font-bold text-gray-900">{{ stats.attendanceRate }}%</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Today's Attendance Status -->
      <div v-if="viewMode === 'today'" class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">Today's Attendance Status</h3>
          <p class="text-sm text-gray-600">{{ todayAttendanceList.length }} employees/managers</p>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Start Time</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Marked At</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in todayAttendanceList" :key="user.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="flex-shrink-0 h-10 w-10">
                      <div class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center">
                        <span class="text-sm font-medium text-white">{{ getUserInitials(user.name) }}</span>
                      </div>
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{{ user.name }}</div>
                      <div class="text-sm text-gray-500">{{ user.email }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                        :class="getRoleClass(user.role)">
                    {{ user.role }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ user.startTime || 'Not Set' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                        :class="getTodayStatusClass(user.todayStatus)">
                    {{ getTodayStatusLabel(user.todayStatus) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ user.markedAt || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button 
                    v-if="user.todayStatus === 'pending'"
                    @click="markAsAbsent(user)"
                    :disabled="markingAbsent[user.id]"
                    class="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50 text-xs">
                    {{ markingAbsent[user.id] ? 'Marking...' : 'Mark Absent' }}
                  </button>
                  <span v-else class="text-gray-400 text-xs">No action needed</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Attendance Table (History) -->
      <div v-else class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">Attendance Records</h3>
          <p class="text-sm text-gray-600">{{ filteredAttendance.length }} records found</p>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Clock In Time</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Clock Out Time</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Work Hours</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="record in paginatedAttendance" :key="record.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="flex-shrink-0 h-10 w-10">
                      <div class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center">
                        <span class="text-sm font-medium text-white">{{ getUserInitials(record.user_name) }}</span>
                      </div>
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{{ record.user_name }}</div>
                      <div class="text-sm text-gray-500">{{ record.user_email }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                        :class="getRoleClass(record.user_role)">
                    {{ record.user_role }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ formatDate(record.date) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                        :class="getStatusClass(record.status)">
                    {{ getStatusLabel(record.status) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ record.clock_in_time || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ record.clock_out_time || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ record.work_hours || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button @click="editAttendance(record)" class="text-blue-600 hover:text-blue-900 mr-3">
                    Edit
                  </button>
                  <button @click="deleteAttendance(record)" class="text-red-600 hover:text-red-900">
                    Delete
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="bg-white px-4 py-3 border-t border-gray-200 sm:px-6">
          <div class="flex items-center justify-between">
            <div class="flex-1 flex justify-between sm:hidden">
              <button @click="previousPage" :disabled="currentPage === 1" 
                      class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                Previous
              </button>
              <button @click="nextPage" :disabled="currentPage === totalPages"
                      class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                Next
              </button>
            </div>
            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
              <div>
                <p class="text-sm text-gray-700">
                  Showing <span class="font-medium">{{ (currentPage - 1) * itemsPerPage + 1 }}</span>
                  to <span class="font-medium">{{ Math.min(currentPage * itemsPerPage, filteredAttendance.length) }}</span>
                  of <span class="font-medium">{{ filteredAttendance.length }}</span> results
                </p>
              </div>
              <div>
                <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px">
                  <button @click="previousPage" :disabled="currentPage === 1"
                          class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                    Previous
                  </button>
                  <button v-for="page in visiblePages" :key="page" @click="currentPage = page"
                          class="relative inline-flex items-center px-4 py-2 border text-sm font-medium"
                          :class="page === currentPage ? 'z-10 bg-blue-50 border-blue-500 text-blue-600' : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'">
                    {{ page }}
                  </button>
                  <button @click="nextPage" :disabled="currentPage === totalPages"
                          class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                    Next
                  </button>
                </nav>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Edit Attendance Modal -->
    <div v-if="showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Edit Attendance</h3>
          
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <select v-model="editingRecord.status" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
              <option value="present">Present</option>
              <option value="absent">Absent</option>
              <option value="on_leave">On Leave</option>
            </select>
          </div>

          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Date</label>
            <input v-model="editingRecord.date" type="date" 
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
          </div>

          <div class="flex justify-end gap-3">
            <button @click="showEditModal = false" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
              Cancel
            </button>
            <button @click="saveAttendance" 
                    class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors">
              Save
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { attendanceApi } from '../api/attendance'
import { usersApi } from '../api/users'
import { clockinsApi } from '../api/clockins'
import { userSchedulesApi } from '../api/userSchedules'
import { notificationService } from '../services/notificationService'
import LoadingSpinner from '../components/LoadingSpinner.vue'

const loading = ref(true)
const attendanceData = ref([])
const users = ref([])
const clockData = ref([])

// Filters
const selectedMonth = ref(new Date().getMonth())
const selectedYear = ref(new Date().getFullYear())
const selectedUserId = ref('')
const selectedStatus = ref('')

// View mode
const viewMode = ref('today') // 'today' or 'history'

// Today's attendance
const todayAttendanceList = ref([])
const markingAbsent = ref({})

// Pagination
const currentPage = ref(1)
const itemsPerPage = 20

// Edit modal
const showEditModal = ref(false)
const editingRecord = ref({})

const months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
]

const years = computed(() => {
  const currentYear = new Date().getFullYear()
  const yearArray = []
  for (let i = currentYear - 2; i <= currentYear + 1; i++) {
    yearArray.push(i)
  }
  return yearArray
})

const filteredAttendance = computed(() => {
  let filtered = attendanceData.value

  // Filter by user
  if (selectedUserId.value) {
    filtered = filtered.filter(record => record.user_id === selectedUserId.value)
  }

  // Filter by status
  if (selectedStatus.value) {
    filtered = filtered.filter(record => record.status === selectedStatus.value)
  }

  return filtered
})

const paginatedAttendance = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredAttendance.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredAttendance.value.length / itemsPerPage)
})

const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value
  
  let start = Math.max(1, current - 2)
  let end = Math.min(total, current + 2)
  
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  
  return pages
})

const stats = computed(() => {
  if (viewMode.value === 'today') {
    // Today's stats
    const present = todayAttendanceList.value.filter(u => u.todayStatus === 'present').length
    const absent = todayAttendanceList.value.filter(u => u.todayStatus === 'absent').length
    const pending = todayAttendanceList.value.filter(u => u.todayStatus === 'pending').length
    const notMarked = todayAttendanceList.value.filter(u => u.todayStatus === 'not_marked').length
    const total = todayAttendanceList.value.length
    const attendanceRate = total > 0 ? Math.round((present / total) * 100) : 0
    
    return { present, absent, onLeave: pending, attendanceRate }
  } else {
    // History stats
    const present = filteredAttendance.value.filter(a => a.status === 'present').length
    const absent = filteredAttendance.value.filter(a => a.status === 'absent').length
    const onLeave = filteredAttendance.value.filter(a => a.status === 'on_leave').length
    const total = present + absent
    const attendanceRate = total > 0 ? Math.round((present / total) * 100) : 0
    
    return { present, absent, onLeave, attendanceRate }
  }
})

const getUserInitials = (name) => {
  if (!name) return '??'
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const getRoleClass = (role) => {
  const classes = {
    admin: 'bg-purple-100 text-purple-800',
    manager: 'bg-blue-100 text-blue-800',
    employee: 'bg-green-100 text-green-800'
  }
  return classes[role] || 'bg-gray-100 text-gray-800'
}

const getStatusClass = (status) => {
  const classes = {
    present: 'bg-green-100 text-green-800',
    absent: 'bg-red-100 text-red-800',
    on_leave: 'bg-yellow-100 text-yellow-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const getStatusLabel = (status) => {
  const labels = {
    present: 'Present',
    absent: 'Absent',
    on_leave: 'On Leave'
  }
  return labels[status] || status
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const loadAttendanceData = async () => {
  loading.value = true
  try {
    // Load all users (employees and managers only, not admins)
    const usersResponse = await usersApi.list()
    users.value = (usersResponse.data || []).filter(user => user.role !== 'admin')

    // Load all attendance data
    const attendanceResponse = await attendanceApi.list()
    const allAttendance = attendanceResponse.data || []

    // Filter attendance for the selected month/year and non-admin users
    const startDate = new Date(selectedYear.value, selectedMonth.value, 1)
    const endDate = new Date(selectedYear.value, selectedMonth.value + 1, 0)
    
    attendanceData.value = allAttendance.filter(a => {
      // Only show attendance for employees and managers
      const user = users.value.find(u => u.id === a.user_id)
      if (!user) return false
      
      const aDate = new Date(a.date)
      return aDate >= startDate && aDate <= endDate
    }).map(record => {
      // Enrich with user data
      const user = users.value.find(u => u.id === record.user_id)
      return {
        ...record,
        user_name: user?.name || 'Unknown',
        user_email: user?.email || 'Unknown',
        user_role: user?.role || 'Unknown'
      }
    })

    // Load clock data for work hours calculation
    await loadClockData()

  } catch (error) {
    console.error('Error loading attendance data:', error)
  } finally {
    loading.value = false
  }
}

const loadClockData = async () => {
  try {
    // Load clock data for all users for the selected month
    const startDate = new Date(selectedYear.value, selectedMonth.value, 1)
    const endDate = new Date(selectedYear.value, selectedMonth.value + 1, 0)
    
    for (const user of users.value) {
      try {
        const clockResponse = await clockinsApi.listByUser(user.id, startDate.toISOString(), endDate.toISOString())
        const userClockData = clockResponse.data || []
        
        // Process clock data and add to attendance records
        processClockDataForUser(user.id, userClockData)
      } catch (error) {
        console.error(`Error loading clock data for user ${user.id}:`, error)
      }
    }
  } catch (error) {
    console.error('Error loading clock data:', error)
  }
}

const processClockDataForUser = (userId, clockData) => {
  // Group clock data by date
  const clockByDate = {}
  
  clockData.forEach(clock => {
    const date = new Date(clock.time).toISOString().split('T')[0]
    if (!clockByDate[date]) {
      clockByDate[date] = []
    }
    clockByDate[date].push(clock)
  })

  // Calculate work hours for each date
  Object.keys(clockByDate).forEach(date => {
    const dayClocks = clockByDate[date].sort((a, b) => new Date(a.time) - new Date(b.time))
    const attendanceRecord = attendanceData.value.find(a => a.user_id === userId && a.date === date)
    
    if (attendanceRecord && dayClocks.length > 0) {
      let clockInTime = null
      let clockOutTime = null
      let workHours = 0
      
      // Find first clock in and last clock out
      for (const clock of dayClocks) {
        if (clock.status === true && !clockInTime) {
          clockInTime = new Date(clock.time)
        } else if (clock.status === false && clockInTime) {
          clockOutTime = new Date(clock.time)
        }
      }
      
      // Calculate work hours
      if (clockInTime && clockOutTime) {
        workHours = (clockOutTime - clockInTime) / (1000 * 60 * 60) // Convert to hours
      }
      
      // Update attendance record with clock data
      attendanceRecord.clock_in_time = clockInTime ? clockInTime.toLocaleTimeString('en-US', { hour12: false }) : null
      attendanceRecord.clock_out_time = clockOutTime ? clockOutTime.toLocaleTimeString('en-US', { hour12: false }) : null
      attendanceRecord.work_hours = workHours > 0 ? workHours.toFixed(2) + 'h' : null
    }
  })
}

const editAttendance = (record) => {
  editingRecord.value = { ...record }
  showEditModal.value = true
}

const saveAttendance = async () => {
  try {
    await attendanceApi.update(editingRecord.value.id, editingRecord.value)
    await loadAttendanceData()
    showEditModal.value = false
  } catch (error) {
    console.error('Error updating attendance:', error)
  }
}

const deleteAttendance = async (record) => {
  if (confirm('Are you sure you want to delete this attendance record?')) {
    try {
      await attendanceApi.delete(record.id)
      await loadAttendanceData()
    } catch (error) {
      console.error('Error deleting attendance:', error)
    }
  }
}

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

// Load today's attendance status with pending logic
const loadTodayAttendance = async () => {
  try {
    // Load all users (employees and managers only, exclude admin)
    const usersResponse = await usersApi.list()
    const allUsers = (usersResponse.data || []).filter(u => u.role !== 'admin')
    
    const today = new Date().toISOString().split('T')[0]
    const now = new Date()
    const currentTime = now.getHours() * 60 + now.getMinutes() // Current time in minutes
    
    // Load today's attendance records
    const attendanceResponse = await attendanceApi.list()
    const todayAttendanceRecords = (attendanceResponse.data || []).filter(a => a.date === today)
    
    // Build today's attendance list
    const attendanceList = await Promise.all(allUsers.map(async (user) => {
      // Get user's schedule for today
      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
      const dayName = dayNames[now.getDay()]
      
      let scheduleStartTime = '09:00' // Default
      try {
        const schedules = await userSchedulesApi.list(user.id)
        const todaySchedule = schedules.data?.find(s => s.day_of_week === dayName)
        if (todaySchedule && todaySchedule.start_time) {
          scheduleStartTime = todaySchedule.start_time
        }
      } catch (error) {
        console.error(`Error loading schedule for user ${user.id}:`, error)
      }
      
      // Parse start time to minutes
      const [startHour, startMinute] = scheduleStartTime.split(':').map(Number)
      const startTimeMinutes = startHour * 60 + startMinute
      const gracePeriodMinutes = startTimeMinutes + 30 // 30 minutes grace period
      
      // Check if user has marked attendance today
      const userAttendance = todayAttendanceRecords.find(a => a.user_id === user.id)
      
      let todayStatus = 'pending'
      let markedAt = null
      
      if (userAttendance) {
        if (userAttendance.status === 'present') {
          todayStatus = 'present'
          markedAt = new Date(userAttendance.inserted_at).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
        } else if (userAttendance.status === 'absent') {
          todayStatus = 'absent'
          markedAt = new Date(userAttendance.inserted_at).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
        }
      } else {
        // No attendance record - check if it's past grace period
        if (currentTime > gracePeriodMinutes) {
          todayStatus = 'pending' // Past grace period, pending admin action
        } else {
          todayStatus = 'not_marked' // Within grace period
        }
      }
      
      return {
        id: user.id,
        name: `${user.first_name || ''} ${user.last_name || ''}`.trim() || user.username || user.email,
        email: user.email,
        role: user.role,
        startTime: scheduleStartTime,
        todayStatus,
        markedAt
      }
    }))
    
    todayAttendanceList.value = attendanceList
  } catch (error) {
    console.error('Error loading today attendance:', error)
    notificationService.error('Failed to load today\'s attendance')
  }
}

// Mark user as absent
const markAsAbsent = async (user) => {
  try {
    markingAbsent.value[user.id] = true
    
    const today = new Date().toISOString().split('T')[0]
    
    // Create absent attendance record
    await attendanceApi.create({
      user_id: user.id,
      date: today,
      status: 'absent'
    })
    
    notificationService.success(`Marked ${user.name} as absent`)
    await loadTodayAttendance()
    await loadAttendanceData()
  } catch (error) {
    console.error('Error marking absent:', error)
    notificationService.error('Failed to mark as absent')
  } finally {
    markingAbsent.value[user.id] = false
  }
}

// Helper functions for today's view
const getTodayStatusClass = (status) => {
  switch (status) {
    case 'present':
      return 'bg-green-100 text-green-800'
    case 'absent':
      return 'bg-red-100 text-red-800'
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'not_marked':
      return 'bg-gray-100 text-gray-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const getTodayStatusLabel = (status) => {
  switch (status) {
    case 'present':
      return 'Present'
    case 'absent':
      return 'Absent'
    case 'pending':
      return 'Pending (Late)'
    case 'not_marked':
      return 'Not Marked Yet'
    default:
      return status
  }
}

onMounted(() => {
  loadAttendanceData()
  loadTodayAttendance()
  
  // Auto-refresh today's attendance every minute
  setInterval(() => {
    if (viewMode.value === 'today') {
      loadTodayAttendance()
    }
  }, 60000)
})
</script>
