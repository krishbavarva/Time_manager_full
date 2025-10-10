<template>
  <section class="p-6 max-w-7xl mx-auto bg-white">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Overtime Management</h1>
      <p class="text-gray-600 mt-1">Manage overtime requests and approvals</p>
    </div>

    <!-- Employee Overtime Request Form -->
    <div v-if="userRole === 'employee'" class="card mb-6">
      <h2 class="text-xl font-semibold text-gray-900 mb-4">Request Overtime</h2>
      <form @submit.prevent="submitOvertimeRequest" class="space-y-4">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Date</label>
            <input 
              v-model="overtimeForm.date" 
              type="date" 
              required 
              class="form-control"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Hours</label>
            <input 
              v-model.number="overtimeForm.hours" 
              type="number" 
              min="0.5" 
              step="0.5" 
              required 
              class="form-control"
            />
          </div>
        </div>
        
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Reason</label>
          <textarea 
            v-model="overtimeForm.reason" 
            required 
            rows="3" 
            class="form-control"
            placeholder="Please provide a reason for overtime work"
          ></textarea>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Project/Task</label>
          <input 
            v-model="overtimeForm.project" 
            type="text" 
            class="form-control"
            placeholder="Optional: specify project or task"
          />
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
      <h2 class="text-xl font-semibold text-gray-900 mb-4">Pending Overtime Approvals</h2>
      <div v-if="pendingRequests.length === 0" class="text-gray-500 text-center py-4">
        No pending overtime requests
      </div>
      <div v-else class="space-y-4">
        <div v-for="request in pendingRequests" :key="request.id" class="border border-gray-200 rounded-lg p-4">
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <h3 class="font-medium text-gray-900">{{ request.user?.first_name }} {{ request.user?.last_name }}</h3>
              <p class="text-sm text-gray-600">{{ request.hours }} hours on {{ request.date }}</p>
              <p class="text-sm text-gray-500" v-if="request.project">Project: {{ request.project }}</p>
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

    <!-- Overtime History -->
    <div class="card">
      <h2 class="text-xl font-semibold text-gray-900 mb-4">Overtime History</h2>
      <div v-if="loading" class="text-center py-4">Loading...</div>
      <div v-else-if="overtimeRequests.length === 0" class="text-gray-500 text-center py-4">
        No overtime requests found
      </div>
      <div v-else>
        <table class="table">
          <thead>
            <tr>
              <th>Date</th>
              <th>Hours</th>
              <th>Project</th>
              <th>Status</th>
              <th>Reason</th>
              <th v-if="isManager">Employee</th>
              <th v-if="isManager">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="request in overtimeRequests" :key="request.id">
              <td>{{ request.date }}</td>
              <td>{{ request.hours }}</td>
              <td>{{ request.project || 'N/A' }}</td>
              <td>
                <span class="badge" :class="getStatusClass(request.status)">
                  {{ request.status }}
                </span>
              </td>
              <td>{{ request.reason }}</td>
              <td v-if="isManager">{{ request.user?.first_name }} {{ request.user?.last_name }}</td>
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
import { overtimeRequestsApi } from '../api/overtimeRequests'

const overtimeRequests = ref([])
const pendingRequests = ref([])
const loading = ref(false)
const submitting = ref(false)
const processing = ref(false)
const error = ref('')

const overtimeForm = ref({
  date: '',
  hours: 1,
  reason: '',
  project: ''
})

const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
const userRole = computed(() => currentUser.role?.toLowerCase() || 'employee')
const isManager = computed(() => ['admin', 'manager'].includes(userRole.value))

const loadOvertimeRequests = async () => {
  loading.value = true
  try {
    const response = await overtimeRequestsApi.list()
    overtimeRequests.value = response.data || []
    
    if (isManager.value) {
      pendingRequests.value = overtimeRequests.value.filter(req => req.status === 'pending')
    }
  } catch (err) {
    error.value = 'Failed to load overtime requests'
    console.error('Error loading overtime requests:', err)
  } finally {
    loading.value = false
  }
}

const submitOvertimeRequest = async () => {
  submitting.value = true
  try {
    const requestData = {
      ...overtimeForm.value,
      user_id: currentUser.id
    }
    
    await overtimeRequestsApi.create(requestData)
    resetForm()
    await loadOvertimeRequests()
  } catch (err) {
    error.value = err.response?.data?.error || 'Failed to submit overtime request'
    console.error('Error submitting overtime request:', err)
  } finally {
    submitting.value = false
  }
}

const approveRequest = async (requestId) => {
  processing.value = true
  try {
    await overtimeRequestsApi.update(requestId, { 
      status: 'approved',
      approved_by_id: currentUser.id 
    })
    await loadOvertimeRequests()
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
    await overtimeRequestsApi.update(requestId, { 
      status: 'rejected',
      approved_by_id: currentUser.id 
    })
    await loadOvertimeRequests()
  } catch (err) {
    error.value = 'Failed to reject request'
    console.error('Error rejecting request:', err)
  } finally {
    processing.value = false
  }
}

const resetForm = () => {
  overtimeForm.value = {
    date: '',
    hours: 1,
    reason: '',
    project: ''
  }
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

onMounted(loadOvertimeRequests)
</script>

<style scoped>
/* No scoped styles needed, using Tailwind utilities */
</style>
