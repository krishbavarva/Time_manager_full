<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Leave Request Management</h1>
            <p class="text-gray-600">Review and manage employee leave requests</p>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="loadRequests"
              class="px-4 py-2 bg-gray-600 text-white text-sm font-medium rounded-lg hover:bg-gray-700"
            >
              🔄 Refresh
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
              <span class="text-2xl">👥</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Total Requests</p>
              <p class="text-2xl font-bold text-gray-900">{{ requests.length }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Filter Bar -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
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
            <label class="block text-sm font-medium text-gray-700 mb-2">Employee</label>
            <input
              v-model="employeeFilter"
              type="text"
              placeholder="Search by name..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            />
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
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Employee</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Leave Type</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date Range</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Duration</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Days</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Submitted</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="request in filteredRequests" :key="request.id" class="hover:bg-gray-50">
                <!-- Employee -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="flex-shrink-0 h-10 w-10">
                      <div class="h-10 w-10 rounded-full bg-gray-300 flex items-center justify-center">
                        <span class="text-sm font-medium text-gray-700">
                          {{ request.user?.first_name?.[0] }}{{ request.user?.last_name?.[0] }}
                        </span>
                      </div>
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">
                        {{ request.user?.first_name }} {{ request.user?.last_name }}
                      </div>
                      <div class="text-sm text-gray-500">{{ request.user?.email }}</div>
                    </div>
                  </div>
                </td>

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

                <!-- Submitted -->
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ formatDateTime(request.inserted_at) }}
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
                      @click="approveRequest(request)"
                      class="text-green-600 hover:text-green-800"
                      title="Approve"
                    >
                      ✅
                    </button>
                    <button
                      v-if="request.status === 'pending'"
                      @click="rejectRequest(request)"
                      class="text-red-600 hover:text-red-800"
                      title="Reject"
                    >
                      ❌
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

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
                <label class="block text-sm font-medium text-gray-700">Employee</label>
                <p class="text-sm text-gray-900">
                  {{ selectedRequest.user?.first_name }} {{ selectedRequest.user?.last_name }}
                </p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <p class="text-sm text-gray-900">{{ selectedRequest.user?.email }}</p>
              </div>
            </div>
            
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
              <p class="text-sm text-gray-900 bg-gray-50 p-3 rounded-md">{{ selectedRequest.reason }}</p>
            </div>
            
            <div v-if="selectedRequest.admin_notes">
              <label class="block text-sm font-medium text-gray-700">Admin Notes</label>
              <p class="text-sm text-gray-900 bg-blue-50 p-3 rounded-md">{{ selectedRequest.admin_notes }}</p>
            </div>
            
            <div v-if="selectedRequest.approved_by">
              <label class="block text-sm font-medium text-gray-700">
                {{ selectedRequest.status === 'approved' ? 'Approved by' : 'Processed by' }}
              </label>
              <p class="text-sm text-gray-900">
                {{ selectedRequest.approved_by.first_name }} {{ selectedRequest.approved_by.last_name }}
                <span class="text-gray-500">on {{ formatDateTime(selectedRequest.updated_at) }}</span>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Approve/Reject Modal -->
    <div v-if="showActionModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            {{ actionType === 'approve' ? 'Approve Leave Request' : 'Reject Leave Request' }}
          </h3>
          
          <div class="mb-4">
            <p class="text-sm text-gray-600">
              {{ actionType === 'approve' ? 'Approve' : 'Reject' }} leave request for 
              <strong>{{ pendingAction?.user?.first_name }} {{ pendingAction?.user?.last_name }}</strong>?
            </p>
          </div>
          
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Admin Notes (Optional)</label>
            <textarea
              v-model="adminNotes"
              rows="3"
              :placeholder="actionType === 'approve' ? 'Add any notes about the approval...' : 'Provide reason for rejection...'"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            ></textarea>
          </div>
          
          <div class="flex justify-end space-x-3">
            <button
              @click="closeActionModal"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              @click="confirmAction"
              :class="[
                'px-4 py-2 text-sm font-medium text-white rounded-md',
                actionType === 'approve' 
                  ? 'bg-green-600 hover:bg-green-700' 
                  : 'bg-red-600 hover:bg-red-700'
              ]"
            >
              {{ actionType === 'approve' ? 'Approve' : 'Reject' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { leaveRequestsApi, getLeaveTypeLabel, getDurationLabel, getStatusLabel, getStatusColor } from '../api/leaveRequests'
import { notificationService } from '../services/notificationService'

// Reactive data
const requests = ref([])
const loading = ref(false)
const error = ref('')

// Filters
const statusFilter = ref('')
const typeFilter = ref('')
const employeeFilter = ref('')
const dateFilter = ref('')

// Modal state
const selectedRequest = ref(null)
const showActionModal = ref(false)
const actionType = ref('')
const pendingAction = ref(null)
const adminNotes = ref('')

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

  if (employeeFilter.value) {
    const searchTerm = employeeFilter.value.toLowerCase()
    filtered = filtered.filter(r => {
      const fullName = `${r.user?.first_name || ''} ${r.user?.last_name || ''}`.toLowerCase()
      return fullName.includes(searchTerm)
    })
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

// Methods
const loadRequests = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const response = await leaveRequestsApi.list()
    requests.value = response.data || []
  } catch (err) {
    console.error('Error loading leave requests:', err)
    error.value = 'Failed to load leave requests'
    notificationService.error('Failed to load leave requests')
  } finally {
    loading.value = false
  }
}

const viewRequest = (request) => {
  selectedRequest.value = request
}

const approveRequest = (request) => {
  actionType.value = 'approve'
  pendingAction.value = request
  adminNotes.value = ''
  showActionModal.value = true
}

const rejectRequest = (request) => {
  actionType.value = 'reject'
  pendingAction.value = request
  adminNotes.value = ''
  showActionModal.value = true
}

const closeActionModal = () => {
  showActionModal.value = false
  actionType.value = ''
  pendingAction.value = null
  adminNotes.value = ''
}

const confirmAction = async () => {
  if (!pendingAction.value) return
  
  try {
    if (actionType.value === 'approve') {
      await leaveRequestsApi.approve(pendingAction.value.id, adminNotes.value)
      notificationService.success('Leave request approved successfully!')
    } else {
      await leaveRequestsApi.reject(pendingAction.value.id, adminNotes.value)
      notificationService.success('Leave request rejected successfully!')
    }
    
    await loadRequests()
    closeActionModal()
  } catch (err) {
    console.error(`Error ${actionType.value}ing leave request:`, err)
    notificationService.error(`Failed to ${actionType.value} leave request`)
  }
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

const formatDateTime = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Lifecycle
onMounted(() => {
  // Check if user is admin
  if (currentUser.value.role !== 'admin') {
    error.value = 'Access denied. Admin privileges required.'
    return
  }
  
  loadRequests()
})
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
