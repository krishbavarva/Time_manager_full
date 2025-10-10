<template>
  <section class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Timesheet Approvals</h1>
            <p class="text-gray-600">Review and approve employee timesheets</p>
          </div>
          <button
            @click="$router.push('/dashboard')"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Back to Dashboard
          </button>
        </div>
      </div>

      <!-- Filter Tabs -->
      <div class="mb-6">
        <div class="border-b border-gray-200">
          <nav class="-mb-px flex space-x-8">
            <button
              @click="activeTab = 'pending'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'pending'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              Pending ({{ pendingCount }})
            </button>
            <button
              @click="activeTab = 'approved'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'approved'
                  ? 'border-green-500 text-green-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              Approved ({{ approvedCount }})
            </button>
            <button
              @click="activeTab = 'rejected'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'rejected'
                  ? 'border-red-500 text-red-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              Rejected ({{ rejectedCount }})
            </button>
          </nav>
        </div>
      </div>

      <!-- Timesheet List -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200">
        <div v-if="loading" class="p-8 text-center text-gray-500">
          Loading timesheets...
        </div>
        
        <div v-else-if="filteredTimesheets.length === 0" class="p-8 text-center text-gray-500">
          No {{ activeTab }} timesheets found
        </div>
        
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Employee</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Scheduled</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actual</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Break</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Overtime</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="timesheet in filteredTimesheets" :key="timesheet.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  User {{ timesheet.user_id }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(timesheet.start) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatHours(timesheet.scheduled_hours) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatHours(timesheet.actual_hours) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatHours(timesheet.break_hours) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatHours(timesheet.overtime_hours) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    :class="[
                      'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                      getStatusClass(timesheet.status)
                    ]"
                  >
                    {{ timesheet.status }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div v-if="timesheet.status === 'pending'" class="flex space-x-2">
                    <button
                      @click="approveTimesheet(timesheet.id)"
                      class="text-green-600 hover:text-green-900"
                    >
                      Approve
                    </button>
                    <button
                      @click="rejectTimesheet(timesheet.id)"
                      class="text-red-600 hover:text-red-900"
                    >
                      Reject
                    </button>
                  </div>
                  <span v-else class="text-gray-400">
                    {{ timesheet.status === 'approved' ? 'Approved' : 'Rejected' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { timesheetApprovalsApi } from '../api/timesheetApprovals'

// Reactive data
const timesheets = ref([])
const loading = ref(false)
const activeTab = ref('pending')

// Computed properties
const filteredTimesheets = computed(() => {
  return timesheets.value.filter(t => t.status === activeTab.value)
})

const pendingCount = computed(() => {
  return timesheets.value.filter(t => t.status === 'pending').length
})

const approvedCount = computed(() => {
  return timesheets.value.filter(t => t.status === 'approved').length
})

const rejectedCount = computed(() => {
  return timesheets.value.filter(t => t.status === 'rejected').length
})

// Lifecycle hook
onMounted(() => {
  loadTimesheets()
})

// Methods
const loadTimesheets = async () => {
  loading.value = true
  try {
    const response = await timesheetApprovalsApi.list()
    timesheets.value = response.data || []
  } catch (error) {
    console.error('Error loading timesheets:', error)
  } finally {
    loading.value = false
  }
}

const approveTimesheet = async (id) => {
  if (confirm('Are you sure you want to approve this timesheet?')) {
    try {
      await timesheetApprovalsApi.approve(id)
      await loadTimesheets()
      alert('Timesheet approved successfully!')
    } catch (error) {
      console.error('Error approving timesheet:', error)
      alert('Failed to approve timesheet. Please try again.')
    }
  }
}

const rejectTimesheet = async (id) => {
  const notes = prompt('Please provide a reason for rejection (optional):')
  if (notes !== null) {
    try {
      await timesheetApprovalsApi.reject(id, notes)
      await loadTimesheets()
      alert('Timesheet rejected successfully!')
    } catch (error) {
      console.error('Error rejecting timesheet:', error)
      alert('Failed to reject timesheet. Please try again.')
    }
  }
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString()
}

const formatHours = (hours) => {
  if (!hours) return '0:00'
  const h = Math.floor(hours)
  const m = Math.round((hours - h) * 60)
  return `${h}:${String(m).padStart(2, '0')}`
}

const getStatusClass = (status) => {
  switch (status) {
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'approved':
      return 'bg-green-100 text-green-800'
    case 'rejected':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}
</script>
