<template>
  <section class="p-6 max-w-7xl mx-auto bg-white">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Leave Management</h1>
      <p class="text-gray-600 mt-1">Manage your leave requests and approvals</p>
    </div>

    <!-- Employee Leave Request Form -->
    <div v-if="userRole === 'employee'" class="card mb-6">
      <h2 class="text-xl font-semibold text-gray-900 mb-4">Request Leave</h2>
      <form @submit.prevent="submitLeaveRequest" class="space-y-4">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Leave Type</label>
            <select v-model="leaveForm.leave_type" required class="form-control">
              <option value="">Select Leave Type</option>
              <option value="vacation">Vacation</option>
              <option value="sick">Sick Leave</option>
              <option value="personal">Personal</option>
              <option value="emergency">Emergency</option>
              <option value="maternity">Maternity</option>
              <option value="paternity">Paternity</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Total Days</label>
            <input 
              v-model.number="leaveForm.total_days" 
              type="number" 
              min="1" 
              required 
              class="form-control"
            />
          </div>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Start Date</label>
            <input 
              v-model="leaveForm.start_date" 
              type="date" 
              required 
              class="form-control"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">End Date</label>
            <input 
              v-model="leaveForm.end_date" 
              type="date" 
              required 
              class="form-control"
            />
          </div>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Reason</label>
          <textarea 
            v-model="leaveForm.reason" 
            required 
            rows="3" 
            class="form-control"
            placeholder="Please provide a reason for your leave request"
          ></textarea>
        </div>

        <div class="flex items-center">
          <input 
            v-model="leaveForm.is_paid" 
            type="checkbox" 
            id="is_paid" 
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500"
          />
          <label for="is_paid" class="ml-2 text-sm text-gray-700">Paid Leave</label>
        </div>

        <div class="flex justify-end space-x-3">
          <button type="button" @click="resetForm" class="btn-secondary">Reset</button>
          <button type="submit" :disabled="submitting" class="btn-primary">
            {{ submitting ? 'Submitting...' : 'Submit Request' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Manager Approval Section -->
    <div v-if="isManager" class="card mb-6">
      <h2 class="text-xl font-semibold text-gray-900 mb-4">Pending Approvals</h2>
      <div v-if="pendingRequests.length === 0" class="text-gray-500 text-center py-4">
        No pending leave requests
      </div>
      <div v-else class="space-y-4">
        <div v-for="request in pendingRequests" :key="request.id" class="border border-gray-200 rounded-lg p-4">
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <h3 class="font-medium text-gray-900">{{ request.user?.first_name }} {{ request.user?.last_name }}</h3>
              <p class="text-sm text-gray-600">{{ request.leave_type }} - {{ request.total_days }} days</p>
              <p class="text-sm text-gray-500">{{ request.start_date }} to {{ request.end_date }}</p>
              <p class="text-sm text-gray-700 mt-2">{{ request.reason }}</p>
            </div>
            <div class="flex space-x-2">
              <button 
                @click="approveRequest(request.id)" 
                class="btn-success px-3 py-1"
                :disabled="processing"
              >
                Approve
              </button>
              <button 
                @click="rejectRequest(request.id)" 
                class="btn-danger px-3 py-1"
                :disabled="processing"
              >
                Reject
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Leave History -->
    <div class="card">
      <h2 class="text-xl font-semibold text-gray-900 mb-4">Leave History</h2>
      <div v-if="loading" class="text-center py-4">Loading...</div>
      <div v-else-if="leaveRequests.length === 0" class="text-gray-500 text-center py-4">
        No leave requests found
      </div>
      <div v-else>
        <table class="table">
          <thead>
            <tr>
              <th>Type</th>
              <th>Start Date</th>
              <th>End Date</th>
              <th>Days</th>
              <th>Status</th>
              <th>Reason</th>
              <th v-if="isManager">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="request in leaveRequests" :key="request.id">
              <td>
                <span class="badge" :class="getLeaveTypeClass(request.leave_type)">
                  {{ request.leave_type }}
                </span>
              </td>
              <td>{{ request.start_date }}</td>
              <td>{{ request.end_date }}</td>
              <td>{{ request.total_days }}</td>
              <td>
                <span class="badge" :class="getStatusClass(request.status)">
                  {{ request.status }}
                </span>
              </td>
              <td>{{ request.reason }}</td>
              <td v-if="isManager">
                <div v-if="request.status === 'pending'" class="flex space-x-2">
                  <button @click="approveRequest(request.id)" class="btn-success px-2 py-1 text-xs">Approve</button>
                  <button @click="rejectRequest(request.id)" class="btn-danger px-2 py-1 text-xs">Reject</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { leaveRequestsApi } from '../api/leaveRequests'
import { usersApi } from '../api/users'

const leaveRequests = ref([])
const pendingRequests = ref([])
const loading = ref(false)
const submitting = ref(false)
const processing = ref(false)
const error = ref('')

const leaveForm = ref({
  leave_type: '',
  start_date: '',
  end_date: '',
  total_days: 1,
  reason: '',
  is_paid: true
})

const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
const userRole = computed(() => currentUser.role?.toLowerCase() || 'employee')
const isManager = computed(() => ['admin', 'manager'].includes(userRole.value))

const loadLeaveRequests = async () => {
  loading.value = true
  try {
    const response = await leaveRequestsApi.list()
    leaveRequests.value = response.data || []
    
    if (isManager.value) {
      pendingRequests.value = leaveRequests.value.filter(req => req.status === 'pending')
    }
  } catch (err) {
    error.value = 'Failed to load leave requests'
    console.error('Error loading leave requests:', err)
  } finally {
    loading.value = false
  }
}

const submitLeaveRequest = async () => {
  submitting.value = true
  try {
    const requestData = {
      ...leaveForm.value,
      user_id: currentUser.id
    }
    
    await leaveRequestsApi.create(requestData)
    resetForm()
    await loadLeaveRequests()
  } catch (err) {
    error.value = err.response?.data?.error || 'Failed to submit leave request'
    console.error('Error submitting leave request:', err)
  } finally {
    submitting.value = false
  }
}

const approveRequest = async (requestId) => {
  processing.value = true
  try {
    await leaveRequestsApi.update(requestId, { 
      status: 'approved',
      approved_by_id: currentUser.id 
    })
    await loadLeaveRequests()
  } catch (err) {
    error.value = 'Failed to approve request'
    console.error('Error approving request:', err)
  } finally {
    processing.value = false
  }
}

const rejectRequest = async (requestId) => {
  processing.value = true
  try {
    await leaveRequestsApi.update(requestId, { 
      status: 'rejected',
      approved_by_id: currentUser.id 
    })
    await loadLeaveRequests()
  } catch (err) {
    error.value = 'Failed to reject request'
    console.error('Error rejecting request:', err)
  } finally {
    processing.value = false
  }
}

const resetForm = () => {
  leaveForm.value = {
    leave_type: '',
    start_date: '',
    end_date: '',
    total_days: 1,
    reason: '',
    is_paid: true
  }
}

const getLeaveTypeClass = (type) => {
  const classes = {
    vacation: 'bg-blue-100 text-blue-800',
    sick: 'bg-red-100 text-red-800',
    personal: 'bg-yellow-100 text-yellow-800',
    emergency: 'bg-orange-100 text-orange-800',
    maternity: 'bg-pink-100 text-pink-800',
    paternity: 'bg-purple-100 text-purple-800'
  }
  return classes[type] || 'bg-gray-100 text-gray-800'
}

const getStatusClass = (status) => {
  const classes = {
    pending: 'bg-yellow-100 text-yellow-800',
    approved: 'bg-green-100 text-green-800',
    rejected: 'bg-red-100 text-red-800',
    cancelled: 'bg-gray-100 text-gray-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

onMounted(loadLeaveRequests)
</script>

<style scoped>
/* No scoped styles needed, using Tailwind utilities */
</style>
