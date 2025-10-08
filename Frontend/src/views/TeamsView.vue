<template>
  <section class="p-6 max-w-7xl mx-auto bg-white">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Teams</h1>
      <p class="text-gray-600 mt-1">Manage your teams and team members</p>
    </div>

    <!-- Refresh Button -->
    <div class="mb-6">
      <button
        @click="loadTeams"
        :disabled="loading"
        class="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white text-sm font-medium rounded-lg hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 disabled:opacity-50"
      >
        <svg class="w-4 h-4" :class="{ 'animate-spin': loading }" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        <span>{{ loading ? 'Loading...' : 'Refresh' }}</span>
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading && teams.length === 0" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
    </div>

    <!-- Teams Grid -->
    <div v-else-if="teams.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="team in teams"
        :key="team.id"
        class="bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow"
      >
        <div class="p-6">
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <h3 class="text-lg font-medium text-gray-900 mb-2">{{ team.description || 'Unnamed Team' }}</h3>

              <!-- Manager Info -->
              <div v-if="team.manager" class="mb-4">
                <p class="text-sm text-gray-500 mb-1">Manager:</p>
                <div class="flex items-center gap-2">
                  <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                    <span class="text-xs font-medium text-blue-600">{{ team.manager.first_name?.[0] || team.manager.username?.[0] || 'M' }}</span>
                  </div>
                  <div>
                    <p class="text-sm font-medium text-gray-900">{{ team.manager.first_name }} {{ team.manager.last_name }}</p>
                    <p class="text-xs text-gray-500">{{ team.manager.email }}</p>
                  </div>
                </div>
              </div>

              <!-- Team Members Count -->
              <div class="mb-4">
                <p class="text-sm text-gray-500 mb-1">Members:</p>
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  {{ team.employees?.length || 0 }} members
                </span>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="flex flex-wrap gap-2 mt-4">
            <button
              v-if="canManageTeam(team)"
              @click="$router.push(`/teams/${team.id}`)"
              class="flex-1 flex items-center justify-center gap-1 px-3 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
              </svg>
              Manage
            </button>

            <button
              v-if="canViewTeamData(team)"
              @click="$router.push(`/teams/${team.id}/data`)"
              class="flex-1 flex items-center justify-center gap-1 px-3 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
              Data
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No teams</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating your first team.</p>
    </div>
  </section>
</template>

<script>
import { teamsApi } from '@/api/teams'
import { usersApi } from '@/api/users'

export default {
  name: 'TeamsView',
  data() {
    return {
      teams: [],
      loading: false
    }
  },
  computed: {
    user() {
      return JSON.parse(localStorage.getItem('currentUser') || '{}')
    },
    userRole() {
      return this.user.role || 'employee'
    },
    isAdmin() {
      return this.userRole === 'admin'
    }
  },
  async created() {
    await this.loadTeams()
  },
  methods: {
    async loadTeams() {
      try {
        this.loading = true
        const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
        const userRole = currentUser.role || 'employee'

        let response
        if (userRole === 'admin') {
          // Admin can see teams they are members of
          response = await teamsApi.list()
          const allTeams = response.data || response || []
          this.teams = allTeams.filter(team =>
            team.employees?.some(emp => emp.id === currentUser.id)
          )
        } else if (userRole === 'manager') {
          // Manager can see teams they manage or are members of
          response = await teamsApi.list()
          const allTeams = response.data || response || []
          this.teams = allTeams.filter(team =>
            team.manager?.id === currentUser.id ||
            team.employees?.some(emp => emp.id === currentUser.id)
          )
        } else {
          // Employee can see teams they're members of
          response = await teamsApi.list()
          const allTeams = response.data || response || []
          this.teams = allTeams.filter(team =>
            team.employees?.some(emp => emp.id === currentUser.id)
          )
        }
      } catch (error) {
        console.error('Error loading teams:', error)
        this.$toast?.error('Failed to load teams')
        this.teams = []
      } finally {
        this.loading = false
      }
    },

    canManageTeam(team) {
      return teamsApi.canManageTeam(team)
    },

    canViewTeamData(team) {
      return teamsApi.canViewTeamData(team)
    }
  }
}
</script>
