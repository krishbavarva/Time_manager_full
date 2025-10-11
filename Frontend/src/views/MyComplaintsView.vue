<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900">My Complaints</h1>
            <p class="mt-2 text-gray-600">View your submitted complaints and admin responses</p>
          </div>
          <button
            @click="$router.push('/dashboard')"
            class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            ← Back to Dashboard
          </button>
        </div>
      </div>

      <!-- Statistics Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-sm font-medium">{{ complaints.length }}</span>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Total Complaints</dt>
                  <dd class="text-lg font-medium text-gray-900">{{ complaints.length }}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-yellow-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-sm font-medium">{{ pendingCount }}</span>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Pending</dt>
                  <dd class="text-lg font-medium text-gray-900">{{ pendingCount }}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-sm font-medium">{{ resolvedCount }}</span>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Resolved</dt>
                  <dd class="text-lg font-medium text-gray-900">{{ resolvedCount }}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-gray-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-sm font-medium">{{ closedCount }}</span>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Closed</dt>
                  <dd class="text-lg font-medium text-gray-900">{{ closedCount }}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center items-center py-12">
        <LoadingSpinner />
      </div>

      <!-- Complaints List -->
      <div v-else-if="complaints.length > 0" class="bg-white shadow overflow-hidden sm:rounded-md">
        <ul class="divide-y divide-gray-200">
          <li v-for="complaint in complaints" :key="complaint.id" class="px-6 py-4">
            <div class="flex items-center justify-between">
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between">
                  <p class="text-sm font-medium text-gray-900 truncate">
                    {{ complaint.complaint }}
                  </p>
                  <div class="ml-2 flex-shrink-0 flex">
                    <span 
                      :class="getStatusBadgeClass(complaint.status)"
                      class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    >
                      {{ complaint.status }}
                    </span>
                  </div>
                </div>
                <div class="mt-2 flex items-center text-sm text-gray-500">
                  <p class="text-xs">
                    Submitted: {{ formatDate(complaint.inserted_at) }}
                  </p>
                </div>
                
                <!-- Admin Response -->
                <div v-if="complaint.admin_response" class="mt-3 p-3 bg-gray-50 rounded-lg">
                  <div class="flex items-center mb-2">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      Admin Response
                    </span>
                    <span class="ml-2 text-xs text-gray-500">
                      {{ formatDate(complaint.updated_at) }}
                    </span>
                  </div>
                  <p class="text-sm text-gray-700">{{ complaint.admin_response }}</p>
                </div>

                <!-- No Response Yet -->
                <div v-else-if="complaint.status === 'pending'" class="mt-3 p-3 bg-yellow-50 rounded-lg">
                  <p class="text-sm text-yellow-700">
                    ⏳ Your complaint is being reviewed. You will receive a response soon.
                  </p>
                </div>
              </div>
            </div>
          </li>
        </ul>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-12">
        <div class="mx-auto h-12 w-12 text-gray-400">
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
          </svg>
        </div>
        <h3 class="mt-2 text-sm font-medium text-gray-900">No complaints</h3>
        <p class="mt-1 text-sm text-gray-500">You haven't submitted any complaints yet.</p>
        <div class="mt-6">
          <button
            @click="$router.push('/dashboard')"
            class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
          >
            Submit a Complaint
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { complaintsApi } from '../api/complaints'
import { notificationService } from '../services/notificationService'
import LoadingSpinner from '../components/LoadingSpinner.vue'

// Reactive data
const loading = ref(true)
const complaints = ref([])

// Computed properties
const pendingCount = computed(() => 
  complaints.value.filter(c => c.status === 'pending').length
)

const resolvedCount = computed(() => 
  complaints.value.filter(c => c.status === 'resolved').length
)

const closedCount = computed(() => 
  complaints.value.filter(c => c.status === 'closed').length
)

// Methods
const loadComplaints = async () => {
  try {
    loading.value = true
    const userId = getCurrentUserId()
    console.log('Loading complaints for user ID:', userId) // Debug log
    
    if (!userId) {
      console.error('No user ID found in localStorage')
      notificationService.error('User not authenticated. Please log in again.')
      complaints.value = []
      return
    }
    
    const response = await complaintsApi.listByUser(userId)
    complaints.value = response.data || []
  } catch (error) {
    console.error('Error loading complaints:', error)
    notificationService.error('Failed to load complaints')
  } finally {
    loading.value = false
  }
}

const getCurrentUserId = () => {
  // Get user ID from localStorage
  const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
  console.log('Current user from localStorage:', user) // Debug log
  return user?.id || user?.user_id
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getStatusBadgeClass = (status) => {
  switch (status) {
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'resolved':
      return 'bg-green-100 text-green-800'
    case 'closed':
      return 'bg-gray-100 text-gray-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

// Lifecycle
onMounted(() => {
  loadComplaints()
})
</script>
