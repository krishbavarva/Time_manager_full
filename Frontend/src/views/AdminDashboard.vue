<template>
  <section class="p-6 max-w-7xl mx-auto bg-white">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6 p-4 bg-gray-50 rounded-lg">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Admin Dashboard</h1>
        <p class="text-gray-600 mt-1">View and manage employee working sessions</p>
      </div>

      <!-- Date Filters -->
      <div class="flex flex-wrap gap-3">
        <button
          v-for="filter in dateFilters"
          :key="filter.key"
          @click="setDateFilter(filter.key)"
          :class="[
            'px-4 py-2 text-sm font-medium rounded-lg transition-colors',
            selectedDateFilter === filter.key
              ? 'bg-indigo-600 text-white'
              : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50'
          ]"
        >
          {{ filter.label }}
        </button>
      </div>
    </div>

    <!-- User Search Section -->
    <div class="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
      <div class="p-6">
        <h2 class="text-lg font-medium text-gray-900 mb-4">Search Users</h2>

        <!-- Search Bar -->
        <div class="flex gap-4 mb-4">
          <div class="flex-1">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search by name, username, or email..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              @input="searchUsers"
            />
          </div>
          <select
            v-model="selectedRole"
            @change="searchUsers"
            class="px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
          >
            <option value="">All Roles</option>
            <option value="admin">Admin</option>
            <option value="manager">Manager</option>
            <option value="employee">Employee</option>
          </select>
        </div>

        <!-- User Selection -->
        <div v-if="filteredUsers.length > 0" class="border border-gray-200 rounded-md max-h-48 overflow-y-auto">
          <div
            v-for="user in filteredUsers.slice(0, 10)"
            :key="user.id"
            @click="selectUser(user)"
            :class="[
              'p-3 cursor-pointer hover:bg-gray-50 transition-colors',
              selectedUser?.id === user.id ? 'bg-indigo-50 border-indigo-200' : 'border-gray-100'
            ]"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                  <span class="text-xs font-medium text-blue-600">
                    {{ user.first_name?.[0] || user.username?.[0] || 'U' }}
                  </span>
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900">
                    {{ user.first_name && user.last_name
                        ? `${user.first_name} ${user.last_name}`
                        : user.username || 'Unknown User' }}
                  </p>
                  <p class="text-xs text-gray-500">{{ user.email }}</p>
                </div>
              </div>
              <span :class="[
                'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                user.role === 'admin' ? 'bg-red-100 text-red-800' :
                user.role === 'manager' ? 'bg-blue-100 text-blue-800' :
                'bg-green-100 text-green-800'
              ]">
                {{ user.role }}
              </span>
            </div>
          </div>
        </div>

        <!-- No users found -->
        <div v-else-if="searchQuery && !loadingUsers" class="text-center py-4 text-gray-500">
          No users found matching "{{ searchQuery }}"
        </div>
      </div>
    </div>

    <!-- Selected User Info -->
    <div v-if="selectedUser" class="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
      <div class="p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Selected User</h3>
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-indigo-100 rounded-full flex items-center justify-center">
            <span class="text-lg font-medium text-indigo-600">
              {{ selectedUser.first_name?.[0] || selectedUser.username?.[0] || 'U' }}
            </span>
          </div>
          <div class="flex-1">
            <h4 class="text-xl font-semibold text-gray-900">
              {{ selectedUser.first_name && selectedUser.last_name
                  ? `${selectedUser.first_name} ${selectedUser.last_name}`
                  : selectedUser.username || 'Unknown User' }}
            </h4>
            <p class="text-gray-600">{{ selectedUser.email }}</p>
            <span :class="[
              'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium mt-2',
              selectedUser.role === 'admin' ? 'bg-red-100 text-red-800' :
              selectedUser.role === 'manager' ? 'bg-blue-100 text-blue-800' :
              'bg-green-100 text-green-800'
            ]">
              {{ selectedUser.role }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Working Sessions Table -->
    <div v-if="selectedUser" class="bg-white border border-gray-200 rounded-lg shadow-sm">
      <div class="p-6">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-medium text-gray-900">Working Sessions</h3>
          <div class="flex items-center gap-2 text-sm text-gray-500">
            <span>{{ filteredSessions.length }} sessions</span>
            <span>•</span>
            <button
              @click="exportData"
              class="text-indigo-600 hover:text-indigo-900"
            >
              Export CSV
            </button>
          </div>
        </div>

        <!-- Loading State -->
        <div v-if="loadingSessions" class="flex justify-center items-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
        </div>

        <!-- Sessions Table -->
        <div v-else-if="filteredSessions.length > 0" class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th
                  @click="sortBy('start')"
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                >
                  <div class="flex items-center gap-1">
                    Date
                    <svg v-if="sortField === 'start'" :class="['w-4 h-4', sortDirection === 'desc' ? 'rotate-180' : '']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16l-4-4m0 0l4-4m-4 4h18" />
                    </svg>
                  </div>
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Clock In
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Clock Out
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total Hours
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Break Time
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="session in paginatedSessions" :key="session.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ formatDate(session.start) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ formatTime(session.start) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ session.end ? formatTime(session.end) : 'In Progress' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ calculateTotalHours(session) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ calculateBreakTime(session) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="[
                    'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                    session.end ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                  ]">
                    {{ session.end ? 'Completed' : 'In Progress' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Empty State -->
        <div v-else class="text-center py-8">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">No working sessions</h3>
          <p class="mt-1 text-sm text-gray-500">No working sessions found for the selected period.</p>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="flex items-center justify-between mt-6">
          <div class="text-sm text-gray-700">
            Showing {{ ((currentPage - 1) * pageSize) + 1 }} to {{ Math.min(currentPage * pageSize, filteredSessions.length) }} of {{ filteredSessions.length }} results
          </div>
          <div class="flex gap-2">
            <button
              @click="currentPage = Math.max(1, currentPage - 1)"
              :disabled="currentPage === 1"
              class="px-3 py-1 text-sm border border-gray-300 rounded-md disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Previous
            </button>
            <button
              v-for="page in visiblePages"
              :key="page"
              @click="currentPage = page"
              :class="[
                'px-3 py-1 text-sm border rounded-md',
                page === currentPage
                  ? 'bg-indigo-600 text-white border-indigo-600'
                  : 'border-gray-300 hover:bg-gray-50'
              ]"
            >
              {{ page }}
            </button>
            <button
              @click="currentPage = Math.min(totalPages, currentPage + 1)"
              :disabled="currentPage === totalPages"
              class="px-3 py-1 text-sm border border-gray-300 rounded-md disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Next
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- No User Selected State -->
    <div v-else class="text-center py-12">
      <svg class="mx-auto h-16 w-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">Select a User</h3>
      <p class="mt-1 text-sm text-gray-500">Search and select a user to view their working sessions.</p>
    </div>
  </section>
</template>

<script>
import { usersApi } from '@/api/users'
import { workingTimeApi } from '@/api/workingTimes'

export default {
  name: 'AdminDashboard',
  data() {
    return {
      // Users
      allUsers: [],
      filteredUsers: [],
      selectedUser: null,
      searchQuery: '',
      selectedRole: '',
      loadingUsers: false,

      // Working Sessions
      workingSessions: [],
      loadingSessions: false,

      // Date Filters
      selectedDateFilter: 'all',
      dateFilters: [
        { key: 'all', label: 'All Time' },
        { key: 'today', label: 'Today' },
        { key: 'week', label: 'This Week' },
        { key: 'month', label: 'This Month' }
      ],

      // Pagination
      currentPage: 1,
      pageSize: 10,

      // Sorting
      sortField: 'start',
      sortDirection: 'desc'
    }
  },
  computed: {
    filteredSessions() {
      let sessions = [...this.workingSessions]

      // Apply date filter
      if (this.selectedDateFilter !== 'all') {
        sessions = this.filterSessionsByDate(sessions, this.selectedDateFilter)
      }

      // Apply sorting
      return this.sortSessions(sessions)
    },
    totalPages() {
      return Math.ceil(this.filteredSessions.length / this.pageSize)
    },
    paginatedSessions() {
      const start = (this.currentPage - 1) * this.pageSize
      const end = start + this.pageSize
      return this.filteredSessions.slice(start, end)
    },
    visiblePages() {
      const total = this.totalPages
      const current = this.currentPage
      const delta = 2

      const range = []
      const rangeWithDots = []

      for (let i = Math.max(2, current - delta); i <= Math.min(total - 1, current + delta); i++) {
        range.push(i)
      }

      if (current - delta > 2) {
        rangeWithDots.push(1, '...')
      } else {
        rangeWithDots.push(1)
      }

      rangeWithDots.push(...range)

      if (current + delta < total - 1) {
        rangeWithDots.push('...', total)
      } else if (total > 1) {
        rangeWithDots.push(total)
      }

      return rangeWithDots
    }
  },
  async created() {
    await this.loadUsers()
  },
  methods: {
    async loadUsers() {
      try {
        this.loadingUsers = true
        const response = await usersApi.list()
        this.allUsers = response.data || []
        this.filteredUsers = this.allUsers
      } catch (error) {
        console.error('Error loading users:', error)
        this.$toast?.error('Failed to load users')
      } finally {
        this.loadingUsers = false
      }
    },

    searchUsers() {
      let filtered = this.allUsers

      // Filter by search query
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase()
        filtered = filtered.filter(user =>
          (user.first_name && user.first_name.toLowerCase().includes(query)) ||
          (user.last_name && user.last_name.toLowerCase().includes(query)) ||
          user.username.toLowerCase().includes(query) ||
          user.email.toLowerCase().includes(query)
        )
      }

      // Filter by role
      if (this.selectedRole) {
        filtered = filtered.filter(user => user.role === this.selectedRole)
      }

      this.filteredUsers = filtered
    },

    async selectUser(user) {
      this.selectedUser = user
      this.currentPage = 1
      await this.loadWorkingSessions()
    },

    async loadWorkingSessions() {
      if (!this.selectedUser) return

      try {
        this.loadingSessions = true
        const response = await workingTimeApi.getByUser(this.selectedUser.id)
        this.workingSessions = response.data || []
      } catch (error) {
        console.error('Error loading working sessions:', error)
        this.$toast?.error('Failed to load working sessions')
        this.workingSessions = []
      } finally {
        this.loadingSessions = false
      }
    },

    setDateFilter(filter) {
      this.selectedDateFilter = filter
      this.currentPage = 1
    },

    filterSessionsByDate(sessions, filter) {
      const now = new Date()
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())

      switch (filter) {
        case 'today':
          return sessions.filter(session => {
            const sessionDate = new Date(session.start)
            return sessionDate >= today && sessionDate < new Date(today.getTime() + 24 * 60 * 60 * 1000)
          })
        case 'week':
          const weekStart = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000)
          return sessions.filter(session => new Date(session.start) >= weekStart)
        case 'month':
          const monthStart = new Date(today.getFullYear(), today.getMonth(), 1)
          return sessions.filter(session => new Date(session.start) >= monthStart)
        default:
          return sessions
      }
    },

    sortSessions(sessions) {
      return sessions.sort((a, b) => {
        let aVal = a[this.sortField]
        let bVal = b[this.sortField]

        if (this.sortField === 'start' || this.sortField === 'end') {
          aVal = new Date(aVal)
          bVal = new Date(bVal)
        }

        if (this.sortDirection === 'desc') {
          return bVal > aVal ? 1 : -1
        } else {
          return aVal > bVal ? 1 : -1
        }
      })
    },

    sortBy(field) {
      if (this.sortField === field) {
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc'
      } else {
        this.sortField = field
        this.sortDirection = 'desc'
      }
    },

    calculateTotalHours(session) {
      if (!session.end) return 'In Progress'

      const start = new Date(session.start)
      const end = new Date(session.end)
      const diffMs = end - start
      const diffHours = diffMs / (1000 * 60 * 60)

      return `${diffHours.toFixed(2)}h`
    },

    calculateBreakTime(session) {
      // For now, return 0 as break time calculation would need additional data
      // This could be enhanced if break time data is available in the API
      return '0.00h'
    },

    formatDate(dateString) {
      const date = new Date(dateString)
      return date.toLocaleDateString()
    },

    formatTime(dateString) {
      const date = new Date(dateString)
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    },

    exportData() {
      // CSV export functionality could be added here
      this.$toast?.info('Export functionality coming soon')
    }
  }
}
</script>
