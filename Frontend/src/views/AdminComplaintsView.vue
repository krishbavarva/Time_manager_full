<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">📝 Complaints Management</h1>
            <p class="text-gray-600">View and respond to user complaints</p>
          </div>
          <button
            @click="loadComplaints"
            class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
          >
            🔄 Refresh
          </button>
        </div>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
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
              <p class="text-sm font-medium text-gray-500">Resolved</p>
              <p class="text-2xl font-bold text-gray-900">{{ resolvedCount }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-red-100 rounded-lg">
              <span class="text-2xl">🔒</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Closed</p>
              <p class="text-2xl font-bold text-gray-900">{{ closedCount }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-blue-100 rounded-lg">
              <span class="text-2xl">📊</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Total</p>
              <p class="text-2xl font-bold text-gray-900">{{ complaints.length }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Filters -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Status Filter</label>
            <select
              v-model="statusFilter"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Status</option>
              <option value="pending">Pending</option>
              <option value="resolved">Resolved</option>
              <option value="closed">Closed</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Search</label>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search complaints..."
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Sort By</label>
            <select
              v-model="sortBy"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="newest">Newest First</option>
              <option value="oldest">Oldest First</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Complaints List -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <LoadingSpinner v-if="loading" :show="loading" text="Loading complaints..." />

        <div v-else-if="filteredComplaints.length === 0" class="text-center py-12">
          <span class="text-6xl mb-4 block">📭</span>
          <p class="text-gray-500 text-lg">No complaints found</p>
        </div>

        <div v-else class="divide-y divide-gray-200">
          <div
            v-for="complaint in paginatedComplaints"
            :key="complaint.id"
            class="p-6 hover:bg-gray-50 transition-colors"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <!-- Header -->
                <div class="flex items-center space-x-3 mb-2">
                  <span
                    class="px-3 py-1 text-xs font-medium rounded-full"
                    :class="{
                      'bg-yellow-100 text-yellow-800': complaint.status === 'pending',
                      'bg-green-100 text-green-800': complaint.status === 'resolved',
                      'bg-gray-100 text-gray-800': complaint.status === 'closed'
                    }"
                  >
                    {{ complaint.status?.toUpperCase() }}
                  </span>
                  <span class="text-sm text-gray-500">
                    {{ formatDate(complaint.inserted_at) }}
                  </span>
                </div>

                <!-- User Info -->
                <div class="mb-3">
                  <p class="text-sm font-medium text-gray-900">
                    👤 {{ complaint.user_name }}
                  </p>
                  <p class="text-xs text-gray-500">
                    {{ complaint.user_email }} • {{ complaint.user_role }}
                  </p>
                </div>

                <!-- Complaint Text -->
                <div class="mb-3">
                  <p class="text-gray-800 whitespace-pre-wrap">{{ complaint.complaint }}</p>
                </div>

                <!-- Admin Response -->
                <div v-if="complaint.admin_response" class="bg-blue-50 border-l-4 border-blue-400 p-3 rounded">
                  <p class="text-sm font-medium text-blue-900 mb-1">Admin Response:</p>
                  <p class="text-sm text-blue-800">{{ complaint.admin_response }}</p>
                </div>
              </div>

              <!-- Actions -->
              <div class="ml-4 flex flex-col space-y-2">
                <button
                  @click="openResponseModal(complaint)"
                  class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
                >
                  💬 Respond
                </button>
                <button
                  v-if="complaint.status === 'pending'"
                  @click="resolveComplaint(complaint.id)"
                  class="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700"
                >
                  ✅ Resolve
                </button>
                <button
                  @click="deleteComplaint(complaint.id)"
                  class="px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-lg hover:bg-red-700"
                >
                  🗑️ Delete
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="border-t border-gray-200 px-6 py-4 bg-gray-50">
          <div class="flex items-center justify-between">
            <p class="text-sm text-gray-700">
              Showing {{ ((currentPage - 1) * itemsPerPage) + 1 }} to {{ Math.min(currentPage * itemsPerPage, filteredComplaints.length) }} of {{ filteredComplaints.length }} complaints
            </p>
            <div class="flex space-x-2">
              <button
                @click="currentPage--"
                :disabled="currentPage === 1"
                class="px-3 py-1 border border-gray-300 rounded-lg hover:bg-white disabled:opacity-50"
              >
                Previous
              </button>
              <button
                v-for="page in visiblePages"
                :key="page"
                @click="currentPage = page"
                :class="[
                  'px-3 py-1 border rounded-lg',
                  currentPage === page
                    ? 'bg-blue-600 text-white border-blue-600'
                    : 'border-gray-300 hover:bg-white'
                ]"
              >
                {{ page }}
              </button>
              <button
                @click="currentPage++"
                :disabled="currentPage === totalPages"
                class="px-3 py-1 border border-gray-300 rounded-lg hover:bg-white disabled:opacity-50"
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Response Modal -->
    <div
      v-if="showResponseModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="closeResponseModal"
    >
      <div class="bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4">
        <div class="bg-gradient-to-r from-blue-500 to-indigo-500 p-6 rounded-t-xl">
          <h3 class="text-2xl font-bold text-white">Respond to Complaint</h3>
        </div>

        <div class="p-6">
          <!-- Original Complaint -->
          <div class="bg-gray-50 border border-gray-200 rounded-lg p-4 mb-4">
            <p class="text-sm font-medium text-gray-700 mb-2">Original Complaint:</p>
            <p class="text-sm text-gray-600">{{ selectedComplaint?.complaint }}</p>
          </div>

          <!-- Status Selection -->
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Update Status</label>
            <select
              v-model="responseStatus"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="pending">Pending</option>
              <option value="resolved">Resolved</option>
              <option value="closed">Closed</option>
            </select>
          </div>

          <!-- Response Text -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">Your Response</label>
            <textarea
              v-model="responseText"
              rows="4"
              placeholder="Enter your response..."
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 resize-none"
            ></textarea>
          </div>

          <!-- Actions -->
          <div class="flex justify-end space-x-3">
            <button
              @click="closeResponseModal"
              class="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              @click="submitResponse"
              :disabled="submitting || !responseText"
              class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {{ submitting ? 'Submitting...' : 'Submit Response' }}
            </button>
          </div>
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

const loading = ref(true)
const complaints = ref([])
const statusFilter = ref('all')
const searchQuery = ref('')
const sortBy = ref('newest')
const currentPage = ref(1)
const itemsPerPage = 10

// Response Modal
const showResponseModal = ref(false)
const selectedComplaint = ref(null)
const responseText = ref('')
const responseStatus = ref('pending')
const submitting = ref(false)

// Computed
const pendingCount = computed(() => complaints.value.filter(c => c.status === 'pending').length)
const resolvedCount = computed(() => complaints.value.filter(c => c.status === 'resolved').length)
const closedCount = computed(() => complaints.value.filter(c => c.status === 'closed').length)

const filteredComplaints = computed(() => {
  let filtered = complaints.value

  // Status filter
  if (statusFilter.value !== 'all') {
    filtered = filtered.filter(c => c.status === statusFilter.value)
  }

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(c =>
      c.complaint?.toLowerCase().includes(query) ||
      c.user_name?.toLowerCase().includes(query) ||
      c.user_email?.toLowerCase().includes(query)
    )
  }

  // Sort
  filtered = [...filtered].sort((a, b) => {
    const dateA = new Date(a.inserted_at)
    const dateB = new Date(b.inserted_at)
    return sortBy.value === 'newest' ? dateB - dateA : dateA - dateB
  })

  return filtered
})

const totalPages = computed(() => Math.ceil(filteredComplaints.value.length / itemsPerPage))

const paginatedComplaints = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredComplaints.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Methods
const loadComplaints = async () => {
  try {
    loading.value = true
    const response = await complaintsApi.list()
    complaints.value = response.data || []
    notificationService.success('Complaints loaded successfully')
  } catch (error) {
    console.error('Error loading complaints:', error)
    notificationService.error('Failed to load complaints')
  } finally {
    loading.value = false
  }
}

const openResponseModal = (complaint) => {
  selectedComplaint.value = complaint
  responseText.value = complaint.admin_response || ''
  responseStatus.value = complaint.status || 'pending'
  showResponseModal.value = true
}

const closeResponseModal = () => {
  showResponseModal.value = false
  selectedComplaint.value = null
  responseText.value = ''
  responseStatus.value = 'pending'
}

const submitResponse = async () => {
  try {
    submitting.value = true

    await complaintsApi.update(selectedComplaint.value.id, {
      status: responseStatus.value,
      admin_response: responseText.value
    })

    notificationService.success('Response submitted successfully')
    closeResponseModal()
    await loadComplaints()
  } catch (error) {
    console.error('Error submitting response:', error)
    notificationService.error('Failed to submit response')
  } finally {
    submitting.value = false
  }
}

const deleteComplaint = async (id) => {
  if (!confirm('Are you sure you want to delete this complaint? This action cannot be undone.')) {
    return
  }

  try {
    await complaintsApi.delete(id)
    notificationService.success('Complaint deleted successfully')
    await loadComplaints()
  } catch (error) {
    console.error('Error deleting complaint:', error)
    notificationService.error('Failed to delete complaint')
  }
}

const resolveComplaint = async (id) => {
  if (!confirm('Are you sure you want to mark this complaint as resolved?')) {
    return
  }

  try {
    await complaintsApi.update(id, {
      status: 'resolved'
    })
    notificationService.success('Complaint marked as resolved')
    await loadComplaints()
  } catch (error) {
    console.error('Error resolving complaint:', error)
    notificationService.error('Failed to resolve complaint')
  }
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  loadComplaints()
})
</script>

