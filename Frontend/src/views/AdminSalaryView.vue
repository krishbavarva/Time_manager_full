<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Salary Management</h1>
        <p class="mt-2 text-sm text-gray-600">Manage employee and manager weekly salaries and overtime approvals</p>
      </div>

      <!-- Week Selector -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
        <div class="flex flex-wrap items-center gap-4">
          <div class="flex items-center gap-2">
            <label class="text-sm font-medium text-gray-700">Week Starting:</label>
            <input
              v-model="selectedWeekStart"
              type="date"
              @change="loadSalaryData"
              class="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          
          <div class="flex gap-2">
            <button
              @click="previousWeek"
              class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors">
              ← Previous Week
            </button>
            <button
              @click="currentWeek"
              class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
              Current Week
            </button>
            <button
              @click="nextWeek"
              class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors">
              Next Week →
            </button>
          </div>

          <button
            @click="loadSalaryData"
            :disabled="loading"
            class="ml-auto px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 transition-colors">
            <svg v-if="loading" class="animate-spin h-4 w-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            {{ loading ? 'Loading...' : 'Refresh' }}
          </button>
        </div>
        
        <div class="mt-4 text-sm text-gray-600">
          Showing week: <span class="font-semibold">{{ formatWeekRange(selectedWeekStart) }}</span>
        </div>
      </div>

      <!-- Summary Stats -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-blue-100">
              <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Total Employees</p>
              <p class="text-2xl font-bold text-gray-900">{{ salaryData.length }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-green-100">
              <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Total Payroll</p>
              <p class="text-2xl font-bold text-gray-900">€{{ totalPayroll.toFixed(2) }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-orange-100">
              <svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Pending Overtime</p>
              <p class="text-2xl font-bold text-gray-900">{{ totalPendingOvertime.toFixed(1) }}h</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-purple-100">
              <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Approved Overtime</p>
              <p class="text-2xl font-bold text-gray-900">{{ totalApprovedOvertime.toFixed(1) }}h</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Salary Table -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">Weekly Salary Breakdown</h3>
          <p class="text-sm text-gray-600">{{ salaryData.length }} employees/managers</p>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Employee</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Hourly Rate</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Base Hours</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Overtime (P/A)</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Base Salary</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Overtime Pay</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Salary</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="salary in salaryData" :key="salary.user_id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="flex-shrink-0 h-10 w-10">
                      <div class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center">
                        <span class="text-sm font-medium text-white">{{ getInitials(salary.user_name) }}</span>
                      </div>
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{{ salary.user_name }}</div>
                      <div class="text-sm text-gray-500">{{ salary.user_email }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                        :class="getRoleClass(salary.user_role)">
                    {{ salary.user_role }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  €{{ salary.hourly_rate.toFixed(2) }}/h
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ salary.base_hours }}h
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm">
                    <span class="text-yellow-600 font-medium">{{ salary.pending_overtime_hours }}h</span>
                    <span class="text-gray-400"> / </span>
                    <span class="text-green-600 font-medium">{{ salary.approved_overtime_hours }}h</span>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  €{{ salary.base_salary.toFixed(2) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-green-600">
                  €{{ salary.overtime_pay.toFixed(2) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900">
                  €{{ salary.total_salary.toFixed(2) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button
                    v-if="salary.pending_overtime_hours > 0 || salary.approved_overtime_hours > 0"
                    @click="openOvertimeModal(salary)"
                    class="text-blue-600 hover:text-blue-900">
                    View Overtime
                  </button>
                  <span v-else class="text-gray-400">No overtime</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Overtime Details Modal -->
    <div v-if="showOvertimeModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-full max-w-4xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-xl font-medium text-gray-900">
              Overtime Details - {{ selectedSalary?.user_name }}
            </h3>
            <button @click="closeOvertimeModal" class="text-gray-400 hover:text-gray-600 text-2xl">
              ✕
            </button>
          </div>

          <!-- Loading -->
          <div v-if="loadingOvertime" class="text-center py-8">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
            <p class="mt-2 text-gray-600">Loading overtime details...</p>
          </div>

          <!-- Overtime Details Table -->
          <div v-else>
            <div v-if="overtimeDetails.length > 0">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Hours</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Overtime</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="detail in overtimeDetails" :key="detail.id" class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ formatDate(detail.date) }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ detail.scheduled_hours }}h / {{ detail.actual_hours }}h
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-orange-600">
                      +{{ detail.overtime_hours }}h
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                            :class="getStatusClass(detail.status)">
                        {{ detail.status }}
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div v-if="detail.status === 'pending'" class="flex gap-2">
                        <button
                          @click="approveOvertimeEntry(detail.id)"
                          :disabled="approvingOvertime[detail.id]"
                          class="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50">
                          {{ approvingOvertime[detail.id] ? 'Approving...' : 'Approve' }}
                        </button>
                        <button
                          @click="rejectOvertimeEntry(detail.id)"
                          :disabled="rejectingOvertime[detail.id]"
                          class="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50">
                          {{ rejectingOvertime[detail.id] ? 'Rejecting...' : 'Reject' }}
                        </button>
                      </div>
                      <span v-else class="text-gray-500">{{ detail.status }}</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center py-8 text-gray-500">
              No overtime entries found for this week.
            </div>
          </div>

          <div class="mt-6 flex justify-end">
            <button
              @click="closeOvertimeModal"
              class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700">
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { salaryApi } from '../api/salary'
import { notificationService } from '../services/notificationService'

const loading = ref(false)
const salaryData = ref([])
const selectedWeekStart = ref('')
const showOvertimeModal = ref(false)
const selectedSalary = ref(null)
const overtimeDetails = ref([])
const loadingOvertime = ref(false)
const approvingOvertime = ref({})
const rejectingOvertime = ref({})

// Computed
const totalPayroll = computed(() => {
  return salaryData.value.reduce((sum, s) => sum + s.total_salary, 0)
})

const totalPendingOvertime = computed(() => {
  return salaryData.value.reduce((sum, s) => sum + s.pending_overtime_hours, 0)
})

const totalApprovedOvertime = computed(() => {
  return salaryData.value.reduce((sum, s) => sum + s.approved_overtime_hours, 0)
})

// Initialize
onMounted(() => {
  currentWeek()
  loadSalaryData()
})

// Methods
const getMonday = (date) => {
  const d = new Date(date)
  const day = d.getDay()
  const diff = d.getDate() - day + (day === 0 ? -6 : 1) // adjust when day is sunday
  return new Date(d.setDate(diff))
}

const currentWeek = () => {
  const monday = getMonday(new Date())
  selectedWeekStart.value = monday.toISOString().split('T')[0]
}

const previousWeek = () => {
  const current = new Date(selectedWeekStart.value)
  current.setDate(current.getDate() - 7)
  selectedWeekStart.value = current.toISOString().split('T')[0]
  loadSalaryData()
}

const nextWeek = () => {
  const current = new Date(selectedWeekStart.value)
  current.setDate(current.getDate() + 7)
  selectedWeekStart.value = current.toISOString().split('T')[0]
  loadSalaryData()
}

const formatWeekRange = (startDate) => {
  if (!startDate) return ''
  const start = new Date(startDate)
  const end = new Date(start)
  end.setDate(end.getDate() + 6)
  
  return `${start.toLocaleDateString()} - ${end.toLocaleDateString()}`
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('en-US', { 
    weekday: 'short', 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  })
}

const getInitials = (name) => {
  if (!name) return '??'
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const getRoleClass = (role) => {
  const classes = {
    manager: 'bg-blue-100 text-blue-800',
    employee: 'bg-green-100 text-green-800'
  }
  return classes[role] || 'bg-gray-100 text-gray-800'
}

const getStatusClass = (status) => {
  const classes = {
    pending: 'bg-yellow-100 text-yellow-800',
    approved: 'bg-green-100 text-green-800',
    rejected: 'bg-red-100 text-red-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const loadSalaryData = async () => {
  try {
    loading.value = true
    const response = await salaryApi.getWeeklySalaries(selectedWeekStart.value)
    salaryData.value = response.data || []
  } catch (error) {
    console.error('Error loading salary data:', error)
    notificationService.error('Failed to load salary data')
  } finally {
    loading.value = false
  }
}

const openOvertimeModal = async (salary) => {
  selectedSalary.value = salary
  showOvertimeModal.value = true
  await loadOvertimeDetails(salary.user_id)
}

const closeOvertimeModal = () => {
  showOvertimeModal.value = false
  selectedSalary.value = null
  overtimeDetails.value = []
}

const loadOvertimeDetails = async (userId) => {
  try {
    loadingOvertime.value = true
    const response = await salaryApi.getOvertimeDetails(userId, selectedWeekStart.value)
    overtimeDetails.value = response.data || []
  } catch (error) {
    console.error('Error loading overtime details:', error)
    notificationService.error('Failed to load overtime details')
  } finally {
    loadingOvertime.value = false
  }
}

const approveOvertimeEntry = async (workingTimeId) => {
  try {
    approvingOvertime.value[workingTimeId] = true
    await salaryApi.approveOvertime(workingTimeId)
    notificationService.success('Overtime approved!')
    
    // Reload data
    await loadOvertimeDetails(selectedSalary.value.user_id)
    await loadSalaryData()
  } catch (error) {
    console.error('Error approving overtime:', error)
    notificationService.error('Failed to approve overtime')
  } finally {
    approvingOvertime.value[workingTimeId] = false
  }
}

const rejectOvertimeEntry = async (workingTimeId) => {
  try {
    rejectingOvertime.value[workingTimeId] = true
    await salaryApi.rejectOvertime(workingTimeId)
    notificationService.success('Overtime rejected')
    
    // Reload data
    await loadOvertimeDetails(selectedSalary.value.user_id)
    await loadSalaryData()
  } catch (error) {
    console.error('Error rejecting overtime:', error)
    notificationService.error('Failed to reject overtime')
  } finally {
    rejectingOvertime.value[workingTimeId] = false
  }
}
</script>

