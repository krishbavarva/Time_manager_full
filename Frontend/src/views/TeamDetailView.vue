<template>
  <section class="p-6 max-w-7xl mx-auto bg-white">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-4">
        <button
          @click="goBackToTeams"
          class="flex items-center gap-2 text-gray-600 hover:text-gray-900"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Back to Teams
        </button>
        <div class="h-6 w-px bg-gray-300"></div>
        <h1 class="text-2xl font-bold text-gray-900">Team Management</h1>
      </div>

      <div v-if="canManageTeam" class="flex gap-3">
        <button
          v-if="canManageTeam"
          @click="showEditModal = true"
          class="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
          </svg>
          Edit Team
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
    </div>

    <!-- Team Details -->
    <div v-else-if="team" class="space-y-6">
      <!-- Team Info Card -->
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
        <div class="p-6">
          <div class="flex items-start justify-between mb-6">
            <div>
              <h2 class="text-xl font-semibold text-gray-900">{{ team.description || 'Unnamed Team' }}</h2>
              <p class="text-sm text-gray-500 mt-1">Team ID: {{ team.id }}</p>
            </div>

            <!-- Team Status -->
            <div class="flex items-center gap-2">
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                {{ team.employees?.length || 0 }} members
              </span>
            </div>
          </div>

          <!-- Manager Info -->
          <div v-if="team.manager" class="mb-6">
            <h3 class="text-sm font-medium text-gray-900 mb-3">Team Manager</h3>
            <div class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
              <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                <span class="text-sm font-medium text-blue-600">{{ team.manager.first_name?.[0] || team.manager.username?.[0] || 'M' }}</span>
              </div>
              <div>
                <p class="text-sm font-medium text-gray-900">
                  {{ team.manager.first_name && team.manager.last_name
                      ? `${team.manager.first_name} ${team.manager.last_name}`
                      : team.manager.username || 'Unknown Manager' }}
                </p>
                <p class="text-sm text-gray-500">{{ team.manager.email }}</p>
              </div>
              <div class="ml-auto">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  Manager
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Team Members Section -->
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
        <div class="p-6">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-lg font-medium text-gray-900">Team Members</h3>
            <button
              v-if="canManageTeam"
              @click="showAddMemberModal = true"
              class="flex items-center gap-2 px-3 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              Add Member
            </button>
          </div>

          <!-- Members List -->
          <div v-if="team.employees && team.employees.length > 0" class="space-y-3">
            <div
              v-for="employee in team.employees"
              :key="employee.id"
              class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
            >
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                  <span class="text-xs font-medium text-green-600">{{ employee.first_name?.[0] || employee.username?.[0] || 'E' }}</span>
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900">
                    {{ employee.first_name && employee.last_name 
                        ? `${employee.first_name} ${employee.last_name}`
                        : employee.username || 'Unknown Employee' }}
                  </p>
                  <p class="text-sm text-gray-500">{{ employee.email }}</p>
                </div>
              </div>

              <div class="flex items-center gap-2">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  Employee
                </span>
                <button
                  v-if="canManageTeam"
                  @click="removeEmployee(employee.id)"
                  class="p-1 text-red-600 hover:text-red-900 hover:bg-red-50 rounded"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
          </div>

          <!-- Empty Members State -->
          <div v-else class="text-center py-8">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">No team members</h3>
            <p class="mt-1 text-sm text-gray-500">Add employees to get started.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">Team not found</h3>
      <p class="mt-1 text-sm text-gray-500">The team you're looking for doesn't exist or you don't have permission to view it.</p>
    </div>

    <!-- Edit Team Modal -->
    <div v-if="showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Edit Team</h3>

          <form @submit.prevent="updateTeam" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Team Name</label>
              <input
                v-model="editTeam.description"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="Enter team name"
              />
            </div>

            <div class="flex justify-end space-x-3 pt-4">
              <button
                type="button"
                @click="showEditModal = false"
                class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                :disabled="updating"
                class="px-4 py-2 bg-indigo-600 border border-transparent rounded-md text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
              >
                {{ updating ? 'Updating...' : 'Update Team' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Add Member Modal -->
    <div v-if="showAddMemberModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Add Team Member</h3>

          <form @submit.prevent="addEmployee" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Select Employee</label>
              <select
                v-model="newEmployeeId"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="">Select an employee</option>
                <option v-for="employee in availableEmployees" :key="employee.id" :value="employee.id">
                  {{ employee.first_name && employee.last_name 
                      ? `${employee.first_name} ${employee.last_name}`
                      : employee.username || 'Unknown Employee' }} ({{ employee.username }})
                </option>
              </select>
            </div>

            <div class="flex justify-end space-x-3 pt-4">
              <button
                type="button"
                @click="showAddMemberModal = false"
                class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                :disabled="addingMember"
                class="px-4 py-2 bg-green-600 border border-transparent rounded-md text-sm font-medium text-white hover:bg-green-700 disabled:opacity-50"
              >
                {{ addingMember ? 'Adding...' : 'Add Member' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import { teamsApi } from '@/api/teams'
import { usersApi } from '@/api/users'

export default {
  name: 'TeamDetailView',
  data() {
    return {
      team: null,
      availableEmployees: [],
      loading: false,
      updating: false,
      addingMember: false,
      showEditModal: false,
      showAddMemberModal: false,
      editTeam: {
        description: ''
      },
      newEmployeeId: ''
    }
  },
  computed: {
    teamId() {
      return this.$route.params.id
    },
    user() {
      return JSON.parse(localStorage.getItem('currentUser') || '{}')
    },
    userRole() {
      return this.user.role || 'employee'
    },
    canManageTeam() {
      return this.team && teamsApi.canManageTeam(this.team)
    }
  },
  async created() {
    await this.loadTeam()
    await this.loadAvailableEmployees()
  },
  methods: {
    async loadTeam() {
      try {
        this.loading = true
        console.log('Loading team with ID:', this.teamId)
        const response = await teamsApi.get(this.teamId)
        console.log('Team API response:', response)

        // Extract team data from response (handle both direct object and {data: object} formats)
        const teamData = response.data || response
        console.log('Team data extracted:', teamData)

        this.team = teamData
        console.log('Team loaded successfully:', this.team)
      } catch (error) {
        console.error('Error loading team:', error)
        this.$toast?.error('Failed to load team')
        this.team = null
      } finally {
        this.loading = false
      }
    },

    async loadAvailableEmployees() {
      try {
        const response = await usersApi.list()
        const allUsers = response.data || response || []

        // Get current team employees (only if team is loaded and has employees)
        const currentEmployeeIds = []
        if (this.team && this.team.employees && Array.isArray(this.team.employees)) {
          this.team.employees.forEach(emp => {
            if (emp && emp.id) {
              currentEmployeeIds.push(emp.id)
            }
          })
        }

        // Filter to show only employees not already in the team
        this.availableEmployees = allUsers.filter(user =>
          user.role === 'employee' &&
          !currentEmployeeIds.includes(user.id)
        )
      } catch (error) {
        console.error('Error loading employees:', error)
        this.availableEmployees = []
      }
    },

    async updateTeam() {
      try {
        this.updating = true
        await teamsApi.update(this.teamId, this.editTeam)
        this.showEditModal = false
        await this.loadTeam()
        this.$toast?.success('Team updated successfully')
      } catch (error) {
        console.error('Error updating team:', error)
        this.$toast?.error('Failed to update team')
      } finally {
        this.updating = false
      }
    },

    async addEmployee() {
      try {
        this.addingMember = true
        await teamsApi.addEmployee(this.teamId, this.newEmployeeId)
        this.showAddMemberModal = false
        this.newEmployeeId = ''
        await this.loadTeam()
        await this.loadAvailableEmployees() // Refresh available employees list
        this.$toast?.success('Member added successfully')
      } catch (error) {
        console.error('Error adding member:', error)
        this.$toast?.error('Failed to add member')
      } finally {
        this.addingMember = false
      }
    },

    async removeEmployee(employeeId) {
      if (confirm('Are you sure you want to remove this member from the team?')) {
        try {
          await teamsApi.removeEmployee(this.teamId, employeeId)
          await this.loadTeam()
          await this.loadAvailableEmployees() // Refresh available employees list
          this.$toast?.success('Member removed successfully')
        } catch (error) {
          console.error('Error removing member:', error)
          this.$toast?.error('Failed to remove member')
        }
      }
    },

    goBackToTeams() {
      const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
      const userRole = currentUser.role || 'employee'

      if (userRole === 'admin') {
        this.$router.push('/admin/teams')
      } else {
        this.$router.push('/teams')
      }
    }
  }
}
</script>
