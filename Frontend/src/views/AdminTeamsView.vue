<template>
  <section class="p-6 max-w-7xl mx-auto bg-white">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Admin Team Management</h1>
        <p class="text-gray-600 mt-1">Manage all teams, assign managers, and view comprehensive data</p>
      </div>

      <div class="flex gap-3">
        <button
          @click="showCreateModal = true"
          class="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          Create Team
        </button>
        <button
          @click="loadAllTeamsData"
          :disabled="loading"
          class="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white text-sm font-medium rounded-lg hover:bg-gray-700 disabled:opacity-50"
        >
          <svg class="w-4 h-4" :class="{ 'animate-spin': loading }" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          {{ loading ? 'Loading...' : 'Refresh' }}
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
    </div>

    <!-- Admin Statistics -->
    <div v-else-if="allTeamsData && allTeamsData.length > 0" class="space-y-6">
      <!-- Summary Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="bg-blue-50 p-4 rounded-lg">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-blue-800">Total Teams</p>
              <p class="text-2xl font-semibold text-blue-900">{{ allTeamsData.length }}</p>
            </div>
          </div>
        </div>

        <div class="bg-green-50 p-4 rounded-lg">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-green-800">Total Members</p>
              <p class="text-2xl font-semibold text-green-900">{{ totalMembers }}</p>
            </div>
          </div>
        </div>

        <div class="bg-purple-50 p-4 rounded-lg">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-purple-800">Managers</p>
              <p class="text-2xl font-semibold text-purple-900">{{ totalManagers }}</p>
            </div>
          </div>
        </div>

        <div class="bg-yellow-50 p-4 rounded-lg">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <svg class="h-6 w-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-yellow-800">Total Hours</p>
              <p class="text-2xl font-semibold text-yellow-900">{{ totalHours.toFixed(1) }}h</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Teams Table -->
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
        <div class="p-6">
          <h3 class="text-lg font-medium text-gray-900 mb-4">All Teams</h3>

          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Team</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Managers</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Members</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Hours</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="teamData in allTeamsData" :key="teamData.id">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm font-medium text-gray-900">{{ teamData.description || 'Unnamed Team' }}</div>
                    <div class="text-sm text-gray-500">ID: {{ teamData.id }}</div>
                  </td>
                  <td class="px-6 py-4">
                    <div v-if="getTeamManagers(teamData).length > 0" class="space-y-1">
                      <div v-for="manager in getTeamManagers(teamData)" :key="manager.id" class="text-sm text-gray-900">
                        {{ manager.first_name }} {{ manager.last_name }}
                      </div>
                    </div>
                    <div v-else class="text-sm text-gray-500 italic">No managers assigned</div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ teamData.employees?.length || 0 }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <!-- Hours calculation disabled - API doesn't provide total_hours data -->
                    N/A
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div class="flex flex-wrap gap-1">
                      <button
                        @click="$router.push(`/teams/${teamData.id}`)"
                        class="text-indigo-600 hover:text-indigo-900 text-xs px-2 py-1"
                        title="Manage Team"
                      >
                        Manage
                      </button>
                      <button
                        @click="$router.push(`/teams/${teamData.id}/data`)"
                        class="text-green-600 hover:text-green-900 text-xs px-2 py-1"
                        title="View Data"
                      >
                        Data
                      </button>
                      <button
                        @click="showEditTeamModal(teamData)"
                        class="text-blue-600 hover:text-blue-900 text-xs px-2 py-1"
                        title="Edit Team"
                      >
                        Edit
                      </button>
                      <button
                        @click="showManageEmployeesModal(teamData, teamData.employees)"
                        class="text-purple-600 hover:text-purple-900 text-xs px-2 py-1"
                        title="Manage Members"
                      >
                        Members
                      </button>
                      <button
                        @click="showAssignManagersModal(teamData)"
                        class="text-orange-600 hover:text-orange-900 text-xs px-2 py-1"
                        title="Assign Managers"
                      >
                        Assign
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No teams found</h3>
      <p class="mt-1 text-sm text-gray-500">No teams have been created yet.</p>
    </div>

    <!-- Assign Manager Modal -->
    <div v-if="showManagerModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Assign Manager</h3>

          <form @submit.prevent="assignManager" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Team</label>
              <p class="text-sm text-gray-900 bg-gray-50 p-2 rounded">{{ selectedTeam?.description || 'Unnamed Team' }}</p>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Select Manager</label>
              <select
                v-model="selectedManagerId"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="">Select a manager</option>
                <option v-for="manager in availableManagers" :key="manager.id" :value="manager.id">
                  {{ manager.first_name }} {{ manager.last_name }} ({{ manager.username }})
                </option>
              </select>
            </div>

            <div class="flex justify-end space-x-3 pt-4">
              <button
                type="button"
                @click="closeManagerModal"
                class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                :disabled="assigning"
                class="px-4 py-2 bg-blue-600 border border-transparent rounded-md text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
              >
                {{ assigning ? 'Assigning...' : 'Assign Manager' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Create Team Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Create New Team</h3>

          <form @submit.prevent="createTeam" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Team Name</label>
              <input
                v-model="newTeam.description"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="Enter team name"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Manager</label>
              <select
                v-model="newTeam.manager_id"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="">Select a manager</option>
                <option v-for="manager in availableManagers" :key="manager.id" :value="manager.id">
                  {{ manager.first_name }} {{ manager.last_name }} ({{ manager.username }})
                </option>
              </select>
            </div>

            <div class="flex justify-end space-x-3 pt-4">
              <button
                type="button"
                @click="closeCreateModal"
                class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                :disabled="creating"
                class="px-4 py-2 bg-indigo-600 border border-transparent rounded-md text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
              >
                {{ creating ? 'Creating...' : 'Create Team' }}
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
  name: 'AdminTeamsView',
  data() {
    return {
      allTeamsData: null,
      availableManagers: [],
      availableEmployees: [],
      loading: false,
      assigning: false,
      creating: false,
      editing: false,
      managingEmployees: false,
      showManagerModal: false,
      showCreateModal: false,
      showEditModal: false,
      showManageEmployeesModal: false,
      showAssignManagersModal: false,
      selectedTeam: null,
      selectedManagerId: '',
      selectedManagers: [],
      selectedEmployees: [],
      newTeam: {
        description: '',
        manager_id: ''
      },
      editTeam: {
        id: '',
        description: ''
      }
    }
  },
  
  computed: {
    totalMembers() {
      if (!this.allTeamsData) return 0
      return this.allTeamsData.reduce((total, teamData) => total + (teamData.employees?.length || 0), 0)
    },
    totalManagers() {
      if (!this.allTeamsData) return 0
      return this.allTeamsData.filter(teamData => teamData.manager).length
    },
    totalHours() {
      // Hours calculation disabled - API doesn't provide total_hours data
      return 0
    }
  },
  async created() {
    await this.loadAllTeamsData()
    await this.loadAvailableManagers()
    await this.loadAvailableEmployees()
  },
  methods: {
    async loadAllTeamsData() {
      try {
        this.loading = true
        const response = await teamsApi.getAllTeamsData()
        // Backend returns { data: [...] } structure, extract the data array
        this.allTeamsData = response.data || []
      } catch (error) {
        console.error('Error loading teams data:', error)
        this.$toast?.error('Failed to load teams data')
        this.allTeamsData = []
      } finally {
        this.loading = false
      }
    },
    
    async loadAvailableManagers() {
      try {
        const response = await usersApi.list()
        this.availableManagers = (response.data || []).filter(user => ['admin', 'manager'].includes(user.role))
      } catch (error) {
        console.error('Error loading managers:', error)
      }
    },

    calculateTeamHours(members) {
      if (!members) return 0
      return members.reduce((total, member) => total + (member.total_hours || 0), 0)
    },

    getTeamManagers(teamData) {
      // For now, return the single manager if exists
      // This can be extended to support multiple managers
      return teamData.manager ? [teamData.manager] : []
    },

    showAssignManagerModal(team) {
      this.selectedTeam = team
      this.selectedManagerId = team.manager?.id || ''
      this.showManagerModal = true
    },

    closeManagerModal() {
      this.showManagerModal = false
      this.selectedTeam = null
      this.selectedManagerId = ''
    },

    closeCreateModal() {
      this.showCreateModal = false
      this.newTeam = { description: '', manager_id: '' }
    },

    showEditTeamModal(team) {
      this.selectedTeam = team
      this.editTeam = {
        id: team.id,
        description: team.description || ''
      }
      this.showEditModal = true
    },

    closeEditModal() {
      this.showEditModal = false
      this.selectedTeam = null
      this.editTeam = { id: '', description: '' }
    },

    showManageEmployeesModal(team, currentMembers) {
      this.selectedTeam = team
      this.selectedEmployees = currentMembers ? currentMembers.map(member => member.id) : []
      this.showManageEmployeesModal = true
    },

    closeManageEmployeesModal() {
      this.showManageEmployeesModal = false
      this.selectedTeam = null
      this.selectedEmployees = []
    },

    showAssignManagersModal(team) {
      this.selectedTeam = team
      this.selectedManagers = team.manager ? [team.manager.id] : []
      this.showAssignManagersModal = true
    },

    closeAssignManagersModal() {
      this.showAssignManagersModal = false
      this.selectedTeam = null
      this.selectedManagers = []
    },

    async createTeam() {
      try {
        this.creating = true
        await teamsApi.create(this.newTeam)
        this.closeCreateModal()
        await this.loadAllTeamsData()
        this.$toast?.success('Team created successfully')
      } catch (error) {
        console.error('Error creating team:', error)
        this.$toast?.error('Failed to create team')
      } finally {
        this.creating = false
      }
    },

    async editTeam() {
      try {
        this.editing = true
        await teamsApi.update(this.editTeam.id, { description: this.editTeam.description })
        this.closeEditModal()
        await this.loadAllTeamsData()
        this.$toast?.success('Team updated successfully')
      } catch (error) {
        console.error('Error updating team:', error)
        this.$toast?.error('Failed to update team')
      } finally {
        this.editing = false
      }
    },

    async manageEmployees() {
      try {
        this.managingEmployees = true
        // For now, this is a placeholder - would need backend API to support bulk employee management
        this.closeManageEmployeesModal()
        await this.loadAllTeamsData()
        this.$toast?.success('Employee management updated')
      } catch (error) {
        console.error('Error managing employees:', error)
        this.$toast?.error('Failed to update employees')
      } finally {
        this.managingEmployees = false
      }
    },

    async assignManagers() {
      try {
        this.assigning = true
        // For now, this assigns the first selected manager as the primary manager
        const managerId = this.selectedManagers.length > 0 ? this.selectedManagers[0] : null
        if (managerId) {
          await teamsApi.assignManager(this.selectedTeam.id, managerId)
        } else {
          await teamsApi.removeManager(this.selectedTeam.id)
        }
        this.closeAssignManagersModal()
        await this.loadAllTeamsData()
        this.$toast?.success('Manager assignment updated')
      } catch (error) {
        console.error('Error assigning managers:', error)
        this.$toast?.error('Failed to assign managers')
      } finally {
        this.assigning = false
      }
    },

    async assignManager() {
      try {
        this.assigning = true
        if (this.selectedManagerId) {
          await teamsApi.assignManager(this.selectedTeam.id, this.selectedManagerId)
        } else {
          await teamsApi.removeManager(this.selectedTeam.id)
        }
        this.closeManagerModal()
        await this.loadAllTeamsData()
        this.$toast?.success('Manager assignment updated')
      } catch (error) {
        console.error('Error assigning manager:', error)
        this.$toast?.error('Failed to assign manager')
      } finally {
        this.assigning = false
      }
    }
  }
}
</script>
