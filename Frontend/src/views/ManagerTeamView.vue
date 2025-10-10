<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Team Management</h1>
            <p class="text-gray-600">Manage your team members and view their working data</p>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="refreshData"
              class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
            >
              🔄 Refresh
            </button>
          </div>
        </div>
      </div>

      <!-- Team Statistics -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-blue-100 rounded-lg">
              <span class="text-2xl">👥</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Team Members</p>
              <p class="text-2xl font-bold text-gray-900">{{ teamMembers.length }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-green-100 rounded-lg">
              <span class="text-2xl">🟢</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Online Now</p>
              <p class="text-2xl font-bold text-gray-900">{{ onlineMembers }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-yellow-100 rounded-lg">
              <span class="text-2xl">⏰</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Working Today</p>
              <p class="text-2xl font-bold text-gray-900">{{ workingMembers }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-purple-100 rounded-lg">
              <span class="text-2xl">📊</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Avg Hours Today</p>
              <p class="text-2xl font-bold text-gray-900">{{ averageHoursToday }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Team Members Table -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200">
        <div class="p-6">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Team Members</h3>
          
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Member</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Today's Hours</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Last Clock</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Location</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="member in teamMembers" :key="member.id" class="hover:bg-gray-50">
                  <!-- Member Info -->
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <div class="flex-shrink-0 h-10 w-10">
                        <div class="h-10 w-10 rounded-full bg-gray-300 flex items-center justify-center">
                          <span class="text-sm font-medium text-gray-700">
                            {{ member.first_name?.[0] }}{{ member.last_name?.[0] }}
                          </span>
                        </div>
                      </div>
                      <div class="ml-4">
                        <div class="text-sm font-medium text-gray-900">
                          {{ member.first_name }} {{ member.last_name }}
                        </div>
                        <div class="text-sm text-gray-500">{{ member.email }}</div>
                      </div>
                    </div>
                  </td>

                  <!-- Status -->
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <div
                        :class="[
                          'w-2 h-2 rounded-full mr-2',
                          getMemberStatus(member) === 'online' ? 'bg-green-400' :
                          getMemberStatus(member) === 'working' ? 'bg-blue-400' :
                          'bg-gray-400'
                        ]"
                      ></div>
                      <span class="text-sm text-gray-900">{{ getMemberStatus(member) }}</span>
                    </div>
                  </td>

                  <!-- Today's Hours -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ getMemberHoursToday(member) }}
                  </td>

                  <!-- Last Clock -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ getMemberLastClock(member) }}
                  </td>

                  <!-- Location -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <button
                      v-if="getMemberLocation(member)"
                      @click="viewMemberLocation(member)"
                      class="text-blue-600 hover:text-blue-800"
                    >
                      📍 View
                    </button>
                    <span v-else class="text-gray-400">No location</span>
                  </td>

                  <!-- Actions -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div class="flex items-center space-x-2">
                      <button
                        @click="viewMemberDetails(member)"
                        class="text-blue-600 hover:text-blue-800"
                        title="View Details"
                      >
                        👁️
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Member Details Modal -->
      <div v-if="selectedMember" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
        <div class="relative top-5 mx-auto p-5 border w-full max-w-6xl shadow-lg rounded-md bg-white">
          <div class="mt-3">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-medium text-gray-900">
                {{ selectedMember.first_name }} {{ selectedMember.last_name }} - Team Member Details
              </h3>
              <button @click="selectedMember = null" class="text-gray-400 hover:text-gray-600 text-2xl">
                ✕
              </button>
            </div>
            
            <!-- Date Filter -->
            <div class="mb-6 p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center space-x-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">View Data For:</label>
                  <input
                    v-model="selectedDate"
                    type="date"
                    @input="loadMemberDetailedData"
                    class="px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Quick Select:</label>
                  <select
                    @change="setQuickDate"
                    class="px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="">Select Period</option>
                    <option value="today">Today</option>
                    <option value="yesterday">Yesterday</option>
                    <option value="thisWeek">This Week</option>
                    <option value="lastWeek">Last Week</option>
                    <option value="thisMonth">This Month</option>
                  </select>
                </div>
                <div class="flex items-end">
                  <button
                    @click="loadMemberDetailedData"
                    :disabled="loadingMemberData"
                    class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
                  >
                    {{ loadingMemberData ? 'Loading...' : 'Refresh Data' }}
                  </button>
                </div>
              </div>
            </div>

            <!-- Loading State -->
            <div v-if="loadingMemberData" class="flex justify-center items-center py-8">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>

            <!-- Member Data Content -->
            <div v-else class="space-y-6">
              <!-- Basic Information -->
              <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div class="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Basic Information</h4>
                  <div class="space-y-3">
                    <div>
                      <label class="text-sm text-gray-500">Email</label>
                      <p class="text-sm font-medium">{{ selectedMember.email }}</p>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Username</label>
                      <p class="text-sm font-medium">{{ selectedMember.username }}</p>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Role</label>
                      <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                        {{ selectedMember.role?.toUpperCase() || 'EMPLOYEE' }}
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Working Statistics -->
                <div class="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Working Statistics</h4>
                  <div class="space-y-3">
                    <div>
                      <label class="text-sm text-gray-500">Total Hours (Selected Date)</label>
                      <p class="text-sm font-medium">{{ memberDetailedData.totalHours || '0:00' }}</p>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Current Status</label>
                      <div class="flex items-center">
                        <div
                          :class="[
                            'w-2 h-2 rounded-full mr-2',
                            getMemberStatus(selectedMember) === 'online' ? 'bg-green-400' :
                            getMemberStatus(selectedMember) === 'working' ? 'bg-blue-400' :
                            'bg-gray-400'
                          ]"
                        ></div>
                        <span class="text-sm font-medium">{{ getMemberStatus(selectedMember) }}</span>
                      </div>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Clock Records Today</label>
                      <p class="text-sm font-medium">{{ memberDetailedData.clockRecords?.length || 0 }} entries</p>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Last Clock</label>
                      <p class="text-sm font-medium">{{ memberDetailedData.lastClockTime || 'No records' }}</p>
                    </div>
                  </div>
                </div>

                <!-- Location Information -->
                <div class="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Location Information</h4>
                  <div class="space-y-3">
                    <div v-if="memberDetailedData.lastLocation">
                      <label class="text-sm text-gray-500">Last Known Location</label>
                      <p class="text-sm font-medium">{{ memberDetailedData.lastLocation }}</p>
                    </div>
                    <div v-if="memberDetailedData.lastClockLocation">
                      <label class="text-sm text-gray-500">Last Clock Location</label>
                      <p class="text-sm font-medium">{{ memberDetailedData.lastClockLocation }}</p>
                    </div>
                    <div v-else>
                      <p class="text-sm text-gray-500 italic">No location data available</p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Clock-in/out Records -->
              <div class="bg-white border border-gray-200 rounded-lg p-4">
                <h4 class="font-medium text-gray-900 mb-4">Clock-in/out Records for {{ formatDate(selectedDate) }}</h4>
                <div v-if="memberDetailedData.clockRecords && memberDetailedData.clockRecords.length > 0" class="overflow-x-auto">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date & Time</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Location</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Duration</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <tr v-for="(record, index) in memberDetailedData.clockRecords" :key="record.id">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {{ formatTime(record.time) }}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                          <span
                            :class="[
                              'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                              record.status ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                            ]"
                          >
                            {{ record.status ? 'Clock In' : 'Clock Out' }}
                          </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          <span v-if="record.latitude && record.longitude">
                            {{ record.latitude.toFixed(4) }}, {{ record.longitude.toFixed(4) }}
                          </span>
                          <span v-else class="text-gray-400">No location</span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {{ calculateDuration(record, memberDetailedData.clockRecords, index) }}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else class="text-center py-8 text-gray-500">
                  No clock records found for this date
                </div>
              </div>

              <!-- Working Schedule -->
              <div class="bg-white border border-gray-200 rounded-lg p-4">
                <h4 class="font-medium text-gray-900 mb-4">Working Schedule</h4>
                <div v-if="memberDetailedData.schedule && memberDetailedData.schedule.length > 0" class="overflow-x-auto">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Day</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Scheduled Start</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Scheduled End</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Scheduled Hours</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <tr v-for="schedule in memberDetailedData.schedule" :key="schedule.id">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {{ schedule.day_of_week }}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {{ formatTimeOnly(schedule.scheduled_start_time) }}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {{ formatTimeOnly(schedule.scheduled_end_time) }}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {{ schedule.scheduled_hours }}h
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                          <span
                            :class="[
                              'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                              schedule.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                            ]"
                          >
                            {{ schedule.is_active ? 'Active' : 'Inactive' }}
                          </span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else class="text-center py-8 text-gray-500">
                  No working schedule found
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { usersApi } from '../api/users'
import { teamsApi } from '../api/teams'

// Reactive data
const teamMembers = ref([])
const loading = ref(false)
const selectedMember = ref(null)
const selectedDate = ref(new Date().toISOString().split('T')[0])
const loadingMemberData = ref(false)
const memberDetailedData = ref({
  totalHours: '0:00',
  clockRecords: [],
  schedule: [],
  lastLocation: null,
  lastClockLocation: null,
  lastClockTime: null
})

// Current user
const currentUser = ref(JSON.parse(localStorage.getItem('currentUser') || '{}'))

// Computed properties
const onlineMembers = computed(() => 
  teamMembers.value.filter(member => getMemberStatus(member) === 'online' || getMemberStatus(member) === 'working').length
)

const workingMembers = computed(() => 
  teamMembers.value.filter(member => getMemberStatus(member) === 'working').length
)

const averageHoursToday = computed(() => {
  if (teamMembers.value.length === 0) return '0:00'
  
  const totalHours = teamMembers.value.reduce((total, member) => {
    const hours = getMemberHoursToday(member)
    const [h, m] = hours.split(':').map(Number)
    return total + h + (m / 60)
  }, 0)
  
  const avgHours = totalHours / teamMembers.value.length
  const hours = Math.floor(avgHours)
  const minutes = Math.round((avgHours - hours) * 60)
  return `${hours}:${minutes.toString().padStart(2, '0')}`
})

// Lifecycle
onMounted(() => {
  loadTeamMembers()
})

// Methods
const loadTeamMembers = async () => {
  loading.value = true
  try {
    // Get teams managed by current user
    const teamsResponse = await teamsApi.getByManager(currentUser.value.id)
    const managedTeams = teamsResponse.data || []
    
    // Get all team members
    const allMembers = []
    for (const team of managedTeams) {
      if (team.employees) {
        allMembers.push(...team.employees)
      }
    }
    
    // Remove duplicates
    const uniqueMembers = allMembers.filter((member, index, self) => 
      index === self.findIndex(m => m.id === member.id)
    )
    
    // Enhance member data with clock-in status and working hours
    const enhancedMembers = await Promise.all(uniqueMembers.map(async (member) => {
      try {
        const { clockinsApi } = await import('../api/clockins')
        const { workingTimesApi } = await import('../api/workingTimes')
        
        // Fetch last clock-in status
        const clocksResponse = await clockinsApi.listByUser(member.id).catch(() => ({ data: [] }))
        const clocks = clocksResponse.data || []
        
        if (clocks.length > 0) {
          const lastClock = clocks[0]
          member.last_clock_status = lastClock.status
          member.last_clock_time = lastClock.time
          member.latitude = lastClock.latitude
          member.longitude = lastClock.longitude
        }
        
        // Fetch working hours for today
        const today = new Date()
        const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate())
        const todayEnd = new Date(todayStart)
        todayEnd.setDate(todayEnd.getDate() + 1)
        
        const workingTimesResponse = await workingTimesApi.list(
          member.id,
          todayStart.toISOString(),
          todayEnd.toISOString()
        ).catch(() => ({ data: [] }))
        
        const workingTimes = workingTimesResponse.data || []
        member.total_hours = workingTimes.reduce((total, wt) => {
          if (wt.start && wt.end) {
            const start = new Date(wt.start)
            const end = new Date(wt.end)
            const hours = (end - start) / (1000 * 60 * 60)
            return total + hours
          }
          return total
        }, 0)
        
        return member
      } catch (err) {
        console.error(`Error loading data for member ${member.id}:`, err)
        return member
      }
    }))
    
    teamMembers.value = enhancedMembers
  } catch (err) {
    console.error('Error loading team members:', err)
  } finally {
    loading.value = false
  }
}

const refreshData = () => {
  loadTeamMembers()
}

const getMemberStatus = (member) => {
  if (member.last_clock_status !== undefined) {
    const lastClockTime = member.last_clock_time ? new Date(member.last_clock_time) : null
    if (lastClockTime) {
      const hoursSince = (Date.now() - lastClockTime.getTime()) / (1000 * 60 * 60)
      if (hoursSince < 12) {
        return member.last_clock_status ? 'working' : 'online'
      }
    }
  }
  return 'offline'
}

const getMemberHoursToday = (member) => {
  if (member.total_hours !== undefined) {
    const hours = Math.floor(member.total_hours)
    const minutes = Math.round((member.total_hours - hours) * 60)
    return `${hours}:${minutes.toString().padStart(2, '0')}`
  }
  return '0:00'
}

const getMemberLastClock = (member) => {
  if (member.last_clock_time) {
    const date = new Date(member.last_clock_time)
    return date.toLocaleTimeString('en-US', { 
      hour: '2-digit', 
      minute: '2-digit'
    })
  }
  return 'No records'
}

const getMemberLocation = (member) => {
  if (member.latitude && member.longitude) {
    return `${member.latitude.toFixed(4)}, ${member.longitude.toFixed(4)}`
  }
  return null
}

const viewMemberLocation = (member) => {
  if (member.latitude && member.longitude) {
    const url = `https://www.google.com/maps?q=${member.latitude},${member.longitude}`
    window.open(url, '_blank')
  }
}

const viewMemberDetails = async (member) => {
  selectedMember.value = member
  await loadMemberDetailedData()
}

const loadMemberDetailedData = async () => {
  if (!selectedMember.value) return
  
  loadingMemberData.value = true
  try {
    const { clockinsApi } = await import('../api/clockins')
    const { workingTimesApi } = await import('../api/workingTimes')
    const { userSchedulesApi } = await import('../api/userSchedules')
    
    // Load clock records for selected date
    const startDate = new Date(selectedDate.value + 'T00:00:00')
    const endDate = new Date(selectedDate.value + 'T23:59:59')
    
    const clockResponse = await clockinsApi.listByUser(
      selectedMember.value.id,
      startDate.toISOString(),
      endDate.toISOString()
    ).catch(() => ({ data: [] }))
    
    const clockRecords = clockResponse.data || []
    
    // Load working times for selected date
    const workingTimesResponse = await workingTimesApi.list(
      selectedMember.value.id,
      startDate.toISOString(),
      endDate.toISOString()
    ).catch(() => ({ data: [] }))
    
    const workingTimes = workingTimesResponse.data || []
    
    // Load user schedule
    const scheduleResponse = await userSchedulesApi.listByUser(selectedMember.value.id).catch(() => ({ data: [] }))
    const schedule = scheduleResponse.data || []
    
    // Calculate total hours for the day
    let totalHours = 0
    workingTimes.forEach(wt => {
      if (wt.start && wt.end) {
        const start = new Date(wt.start)
        const end = new Date(wt.end)
        totalHours += (end - start) / (1000 * 60 * 60)
      }
    })
    
    const hours = Math.floor(totalHours)
    const minutes = Math.round((totalHours - hours) * 60)
    
    // Get last location from clock records
    const lastClockRecord = clockRecords.find(record => record.latitude && record.longitude)
    const lastLocation = lastClockRecord ? 
      `${lastClockRecord.latitude.toFixed(4)}, ${lastClockRecord.longitude.toFixed(4)}` : null
    
    // Get last clock time
    const lastClockTime = clockRecords.length > 0 ? 
      formatTime(clockRecords[0].time) : null
    
    memberDetailedData.value = {
      totalHours: `${hours}:${minutes.toString().padStart(2, '0')}`,
      clockRecords: clockRecords.sort((a, b) => new Date(b.time) - new Date(a.time)),
      schedule: schedule,
      lastLocation: lastLocation,
      lastClockLocation: lastLocation,
      lastClockTime: lastClockTime
    }
    
  } catch (error) {
    console.error('Error loading detailed member data:', error)
    memberDetailedData.value = {
      totalHours: '0:00',
      clockRecords: [],
      schedule: [],
      lastLocation: null,
      lastClockLocation: null,
      lastClockTime: null
    }
  } finally {
    loadingMemberData.value = false
  }
}

const setQuickDate = (event) => {
  const value = event.target.value
  const today = new Date()
  
  switch (value) {
    case 'today':
      selectedDate.value = today.toISOString().split('T')[0]
      break
    case 'yesterday':
      const yesterday = new Date(today)
      yesterday.setDate(yesterday.getDate() - 1)
      selectedDate.value = yesterday.toISOString().split('T')[0]
      break
    case 'thisWeek':
      const weekStart = new Date(today)
      weekStart.setDate(today.getDate() - today.getDay())
      selectedDate.value = weekStart.toISOString().split('T')[0]
      break
    case 'lastWeek':
      const lastWeekStart = new Date(today)
      lastWeekStart.setDate(today.getDate() - today.getDay() - 7)
      selectedDate.value = lastWeekStart.toISOString().split('T')[0]
      break
    case 'thisMonth':
      const monthStart = new Date(today.getFullYear(), today.getMonth(), 1)
      selectedDate.value = monthStart.toISOString().split('T')[0]
      break
  }
  
  if (value) {
    loadMemberDetailedData()
  }
}

const formatDate = (dateString) => {
  if (!dateString) return 'No date selected'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
}

const formatTime = (dateString) => {
  if (!dateString) return 'No time'
  const date = new Date(dateString)
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const year = date.getFullYear()
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  const seconds = date.getSeconds().toString().padStart(2, '0')
  return `${month}/${day}/${year}, ${hours}:${minutes}:${seconds}`
}

const formatTimeOnly = (timeString) => {
  if (!timeString) return 'No time'
  return timeString
}

const calculateDuration = (record, allRecords, currentIndex) => {
  if (record.status) {
    // This is a clock-in, find the next clock-out
    const nextClockOut = allRecords.find((r, index) => 
      index > currentIndex && !r.status
    )
    if (nextClockOut) {
      const start = new Date(record.time)
      const end = new Date(nextClockOut.time)
      const duration = (end - start) / (1000 * 60 * 60) // hours
      const hours = Math.floor(duration)
      const minutes = Math.round((duration - hours) * 60)
      return `${hours}:${minutes.toString().padStart(2, '0')}`
    }
    return 'In Progress'
  }
  return '-'
}
</script>
