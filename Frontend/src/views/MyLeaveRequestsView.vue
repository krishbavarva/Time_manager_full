<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">My Leave Requests</h1>
            <p class="text-gray-600">
              <span v-if="currentUser.first_name" class="font-medium">
                {{ currentUser.first_name }} {{ currentUser.last_name }}
              </span>
              <span v-if="currentUser.first_name"> - </span>
              Manage your leave requests and track their status
            </p>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="showRequestForm = true"
              class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
            >
              ➕ Submit Leave Request
            </button>
          </div>
        </div>
      </div>

      <!-- Statistics Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-yellow-100 rounded-lg">
              <span class="text-2xl">⏳</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Pending</p>
              <p class="text-2xl font-bold text-gray-900">{{ pendingCount }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-green-100 rounded-lg">
              <span class="text-2xl">✅</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Approved</p>
              <p class="text-2xl font-bold text-gray-900">{{ approvedCount }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-red-100 rounded-lg">
              <span class="text-2xl">❌</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Rejected</p>
              <p class="text-2xl font-bold text-gray-900">{{ rejectedCount }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-blue-100 rounded-lg">
              <span class="text-2xl">📅</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Total Days</p>
              <p class="text-2xl font-bold text-gray-900">{{ totalDays.toFixed(1) }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Filter Bar -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <select
              v-model="statusFilter"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">All Status</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Leave Type</label>
            <select
              v-model="typeFilter"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">All Types</option>
              <option value="sick">Sick Leave</option>
              <option value="vacation">Vacation</option>
              <option value="personal">Personal Leave</option>
              <option value="emergency">Emergency Leave</option>
              <option value="holiday">Holiday</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Date Range</label>
            <input
              v-model="dateFilter"
              type="date"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>
      </div>

      <!-- Leave Requests Table -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-semibold text-gray-900">Leave Requests</h2>
        </div>
        
        <div v-if="loading" class="p-8 text-center text-gray-500">
          Loading leave requests...
        </div>
        
        <div v-else-if="error" class="p-8 text-center text-red-600">
          {{ error }}
        </div>
        
        <div v-else-if="filteredRequests.length === 0" class="p-8 text-center text-gray-500">
          No leave requests found.
        </div>
        
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Leave Type</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date Range</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Duration</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Days</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reason</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="request in filteredRequests" :key="request.id" class="hover:bg-gray-50">
                <!-- Leave Type -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="text-sm font-medium text-gray-900">
                    {{ getLeaveTypeLabel(request.leave_type) }}
                  </span>
                </td>

                <!-- Date Range -->
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  <div>
                    <div>{{ formatDate(request.start_date) }}</div>
                    <div v-if="request.start_date !== request.end_date" class="text-xs text-gray-500">
                      to {{ formatDate(request.end_date) }}
                    </div>
                  </div>
                </td>

                <!-- Duration -->
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ getDurationLabel(request.duration_type) }}
                </td>

                <!-- Total Days -->
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ request.total_days }} day{{ request.total_days !== 1 ? 's' : '' }}
                </td>

                <!-- Status -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    :class="[
                      'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                      getStatusColor(request.status)
                    ]"
                  >
                    {{ getStatusLabel(request.status) }}
                  </span>
                </td>

                <!-- Reason -->
                <td class="px-6 py-4 text-sm text-gray-900 max-w-xs">
                  <div class="truncate" :title="request.reason">
                    {{ request.reason }}
                  </div>
                </td>

                <!-- Actions -->
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div class="flex items-center space-x-2">
                    <button
                      @click="viewRequest(request)"
                      class="text-blue-600 hover:text-blue-800"
                      title="View Details"
                    >
                      👁️
                    </button>
                    <button
                      v-if="request.status === 'pending'"
                      @click="editRequest(request)"
                      class="text-indigo-600 hover:text-indigo-800"
                      title="Edit"
                    >
                      ✏️
                    </button>
                    <button
                      v-if="request.status === 'pending'"
                      @click="deleteRequest(request)"
                      class="text-red-600 hover:text-red-800"
                      title="Delete"
                    >
                      🗑️
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Leave Request Form Modal -->
    <LeaveRequestForm
      v-if="showRequestForm"
      :editing-request="editingRequest"
      :show-modal="showRequestForm"
      @close="closeRequestForm"
      @success="handleRequestSuccess"
    />

    <!-- Request Details Modal -->
    <div v-if="selectedRequest" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-10 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-xl font-medium text-gray-900">Leave Request Details</h3>
            <button @click="selectedRequest = null" class="text-gray-400 hover:text-gray-600 text-2xl">
              ✕
            </button>
          </div>
          
          <div class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Leave Type</label>
                <p class="text-sm text-gray-900">{{ getLeaveTypeLabel(selectedRequest.leave_type) }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Status</label>
                <span
                  :class="[
                    'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                    getStatusColor(selectedRequest.status)
                  ]"
                >
                  {{ getStatusLabel(selectedRequest.status) }}
                </span>
              </div>
            </div>
            
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Start Date</label>
                <p class="text-sm text-gray-900">{{ formatDate(selectedRequest.start_date) }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">End Date</label>
                <p class="text-sm text-gray-900">{{ formatDate(selectedRequest.end_date) }}</p>
              </div>
            </div>
            
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Duration</label>
                <p class="text-sm text-gray-900">{{ getDurationLabel(selectedRequest.duration_type) }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Total Days</label>
                <p class="text-sm text-gray-900">{{ selectedRequest.total_days }} day{{ selectedRequest.total_days !== 1 ? 's' : '' }}</p>
              </div>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700">Reason</label>
              <p class="text-sm text-gray-900">{{ selectedRequest.reason }}</p>
            </div>
            
            <div v-if="selectedRequest.admin_notes">
              <label class="block text-sm font-medium text-gray-700">Admin Notes</label>
              <p class="text-sm text-gray-900">{{ selectedRequest.admin_notes }}</p>
            </div>
            
            <div v-if="selectedRequest.approved_by">
              <label class="block text-sm font-medium text-gray-700">
                {{ selectedRequest.status === 'approved' ? 'Approved by' : 'Processed by' }}
              </label>
              <p class="text-sm text-gray-900">
                {{ selectedRequest.approved_by.first_name }} {{ selectedRequest.approved_by.last_name }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { leaveRequestsApi, getLeaveTypeLabel, getDurationLabel, getStatusLabel, getStatusColor } from '../api/leaveRequests'
import LeaveRequestForm from '../components/LeaveRequestForm.vue'
import { notificationService } from '../services/notificationService'

// Reactive data
const requests = ref([])
const loading = ref(false)
const error = ref('')
const showRequestForm = ref(false)
const editingRequest = ref(null)
const selectedRequest = ref(null)

// Filters
const statusFilter = ref('')
const typeFilter = ref('')
const dateFilter = ref('')

// Current user
const currentUser = ref(JSON.parse(localStorage.getItem('currentUser') || '{}'))

// Computed properties
const filteredRequests = computed(() => {
  let filtered = requests.value

  if (statusFilter.value) {
    filtered = filtered.filter(r => r.status === statusFilter.value)
  }

  if (typeFilter.value) {
    filtered = filtered.filter(r => r.leave_type === typeFilter.value)
  }

  if (dateFilter.value) {
    const filterDate = new Date(dateFilter.value)
    filtered = filtered.filter(r => {
      const startDate = new Date(r.start_date)
      const endDate = new Date(r.end_date)
      return (startDate <= filterDate && filterDate <= endDate) ||
             (startDate.toDateString() === filterDate.toDateString()) ||
             (endDate.toDateString() === filterDate.toDateString())
    })
  }

  return filtered
})

const pendingCount = computed(() => requests.value.filter(r => r.status === 'pending').length)
const approvedCount = computed(() => requests.value.filter(r => r.status === 'approved').length)
const rejectedCount = computed(() => requests.value.filter(r => r.status === 'rejected').length)
const totalDays = computed(() => {
  return requests.value.reduce((total, r) => {
    return total + parseFloat(r.total_days || 0)
  }, 0)
})

// Methods
const loadRequests = async () => {
  if (!currentUser.value.id) return
  
  loading.value = true
  error.value = ''
  
  try {
    const response = await leaveRequestsApi.listByUser(currentUser.value.id)
    requests.value = response.data || []
  } catch (err) {
    console.error('Error loading leave requests:', err)
    error.value = 'Failed to load leave requests'
  } finally {
    loading.value = false
  }
}

const viewRequest = (request) => {
  selectedRequest.value = request
}

const editRequest = (request) => {
  editingRequest.value = request
  showRequestForm.value = true
}

const deleteRequest = async (request) => {
  if (!confirm(`Are you sure you want to delete this leave request?`)) return
  
  try {
    await leaveRequestsApi.remove(request.id)
    await loadRequests()
    notificationService.success('Leave request deleted successfully!')
  } catch (err) {
    console.error('Error deleting leave request:', err)
    notificationService.error('Failed to delete leave request')
  }
}

const closeRequestForm = () => {
  showRequestForm.value = false
  editingRequest.value = null
}

const handleRequestSuccess = () => {
  loadRequests()
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Lifecycle
onMounted(() => {
  loadRequests()
})
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
