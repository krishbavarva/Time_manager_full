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
        <h1 class="text-2xl font-bold text-gray-900">Team Analytics</h1>
      </div>

      <div class="flex gap-3">
        <button
          @click="loadTeamData"
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

    <!-- Team Data -->
    <div v-else-if="teamData" class="space-y-6">
      <!-- Team Summary -->
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
        <div class="p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">{{ teamData.team.description || 'Unnamed Team' }}</h2>

          <!-- Summary Cards -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div class="bg-blue-50 p-4 rounded-lg">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm font-medium text-blue-800">Total Members</p>
                  <p class="text-2xl font-semibold text-blue-900">{{ teamData.members_data?.length || 0 }}</p>
                </div>
              </div>
            </div>

            <div class="bg-green-50 p-4 rounded-lg">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm font-medium text-green-800">Present Today</p>
                  <p class="text-2xl font-semibold text-green-900">{{ todayPresentCount }}</p>
                </div>
              </div>
            </div>

            <div class="bg-orange-50 p-4 rounded-lg">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-6 w-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm font-medium text-orange-800">Total Hours</p>
                  <p class="text-2xl font-semibold text-orange-900">{{ totalTeamHours.toFixed(1) }}h</p>
                </div>
              </div>
            </div>

            <div class="bg-purple-50 p-4 rounded-lg">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm font-medium text-purple-800">Work Sessions</p>
                  <p class="text-2xl font-semibold text-purple-900">{{ totalTeamSessions }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Members Data Table -->
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
        <div class="p-6">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Team Member Performance</h3>

          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Member</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Today's Attendance</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Hours</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sessions</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="memberData in teamData.members_data" :key="memberData.employee.id">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <div class="flex-shrink-0 h-10 w-10">
                        <div class="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                          <span class="text-sm font-medium text-gray-700">
                            {{ memberData.employee.first_name?.[0] || memberData.employee.username?.[0] || 'U' }}
                          </span>
                        </div>
                      </div>
                      <div class="ml-4">
                        <div class="text-sm font-medium text-gray-900">
                          {{ memberData.employee.first_name }} {{ memberData.employee.last_name }}
                        </div>
                        <div class="text-sm text-gray-500">{{ memberData.employee.email }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      {{ memberData.employee.role }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span 
                      class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                      :class="getAttendanceStatusClass(memberData.attendanceStatus)">
                      {{ getAttendanceStatusLabel(memberData.attendanceStatus) }}
                    </span>
                    <div v-if="memberData.attendanceTime" class="text-xs text-gray-500 mt-1">
                      {{ memberData.attendanceTime }}
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ memberData.total_hours?.toFixed(1) || '0.0' }}h
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ memberData.working_times?.length || 0 }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button
                      @click="$router.push(`/users/${memberData.employee.id}/working-times`)"
                      class="text-indigo-600 hover:text-indigo-900"
                    >
                      View Details
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Recent Activity -->
      <div v-if="recentActivity.length > 0" class="bg-white border border-gray-200 rounded-lg shadow-sm">
        <div class="p-6">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Recent Activity</h3>

          <div class="space-y-3">
            <div
              v-for="activity in recentActivity.slice(0, 10)"
              :key="`${activity.user_id}-${activity.date}`"
              class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
            >
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                  <span class="text-xs font-medium text-blue-600">
                    {{ getEmployeeInitials(activity.employee) }}
                  </span>
                </div>
              </div>
              <div class="flex-1">
                <p class="text-sm text-gray-900">
                  <span class="font-medium">{{ activity.employee.first_name }} {{ activity.employee.last_name }}</span>
                  worked {{ activity.hours?.toFixed(1) || '0.0' }} hours on {{ formatDate(activity.date) }}
                </p>
                <p class="text-xs text-gray-500">{{ activity.sessions || 0 }} sessions</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No data available</h3>
      <p class="mt-1 text-sm text-gray-500">Unable to load team data or you don't have permission to view it.</p>
    </div>
  </section>
</template>

<script>
import { teamsApi } from '@/api/teams'
import { attendanceApi } from '@/api/attendance'

export default {
  name: 'TeamDataView',
  data() {
    return {
      teamData: null,
      loading: false,
      todayAttendance: []
    }
  },
  computed: {
    teamId() {
      return this.$route.params.id
    },
    totalTeamHours() {
      if (!this.teamData?.members_data) return 0
      return this.teamData.members_data.reduce((total, member) => total + (member.total_hours || 0), 0)
    },
    totalTeamSessions() {
      if (!this.teamData?.members_data) return 0
      return this.teamData.members_data.reduce((total, member) => total + (member.working_times?.length || 0), 0)
    },
    todayPresentCount() {
      if (!this.teamData?.members_data) return 0
      return this.teamData.members_data.filter(member => member.attendanceStatus === 'present').length
    },
    recentActivity() {
      if (!this.teamData?.members_data) return []

      const activities = []
      this.teamData.members_data.forEach(member => {
        if (member.working_times && member.working_times.length > 0) {
          // Group by date and calculate daily totals
          const dailyTotals = {}
          member.working_times.forEach(wt => {
            const date = new Date(wt.start).toDateString()
            if (!dailyTotals[date]) {
              dailyTotals[date] = { hours: 0, sessions: 0 }
            }
            const hours = (new Date(wt.end) - new Date(wt.start)) / (1000 * 60 * 60)
            dailyTotals[date].hours += hours
            dailyTotals[date].sessions += 1
          })

          Object.entries(dailyTotals).forEach(([date, data]) => {
            activities.push({
              employee: member.employee,
              date,
              hours: data.hours,
              sessions: data.sessions
            })
          })
        }
      })

      return activities.sort((a, b) => new Date(b.date) - new Date(a.date))
    }
  },
  async created() {
    await this.loadTeamData()
  },
  methods: {
    async loadTeamData() {
      try {
        this.loading = true
        
        // Load team basic data
        const teamResponse = await teamsApi.get(this.teamId)
        const team = teamResponse.data || teamResponse
        
        // Load today's attendance
        await this.loadTodayAttendance()
        
        // Build members_data from employees
        const membersData = (team.employees || []).map(employee => {
          const attendance = this.todayAttendance.find(a => a.user_id === employee.id)
          return {
            employee: employee,
            total_hours: 0, // Would need working times to calculate
            working_times: [],
            attendanceStatus: this.getAttendanceStatus(attendance),
            attendanceTime: attendance ? new Date(attendance.inserted_at).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }) : null
          }
        })
        
        this.teamData = {
          team: team,
          members_data: membersData
        }
      } catch (error) {
        console.error('Error loading team data:', error)
        this.$toast?.error('Failed to load team data')
      } finally {
        this.loading = false
      }
    },

    async loadTodayAttendance() {
      try {
        const today = new Date().toISOString().split('T')[0]
        const response = await attendanceApi.list()
        this.todayAttendance = (response.data || []).filter(a => a.date === today)
      } catch (error) {
        console.error('Error loading attendance:', error)
        this.todayAttendance = []
      }
    },

    getAttendanceStatus(attendance) {
      if (!attendance) return 'not_marked'
      return attendance.status // 'present', 'absent', etc.
    },

    getAttendanceStatusClass(status) {
      switch (status) {
        case 'present':
          return 'bg-green-100 text-green-800'
        case 'absent':
          return 'bg-red-100 text-red-800'
        case 'on_leave':
          return 'bg-yellow-100 text-yellow-800'
        case 'not_marked':
          return 'bg-gray-100 text-gray-600'
        default:
          return 'bg-gray-100 text-gray-600'
      }
    },

    getAttendanceStatusLabel(status) {
      switch (status) {
        case 'present':
          return '✓ Present'
        case 'absent':
          return '✗ Absent'
        case 'on_leave':
          return '📅 On Leave'
        case 'not_marked':
          return '- Not Marked'
        default:
          return '- Unknown'
      }
    },

    getEmployeeInitials(employee) {
      return employee.first_name?.[0] || employee.username?.[0] || 'U'
    },

    formatDate(dateString) {
      return new Date(dateString).toLocaleDateString()
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
