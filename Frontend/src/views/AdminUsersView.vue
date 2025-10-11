<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Employee Management</h1>
            <p class="text-gray-600">Manage employees, managers, and teams across the organization</p>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="exportUsers"
              class="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700"
            >
              📤 Export CSV
            </button>
            <button
              @click="showAddUser = true"
              class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
            >
              ➕ Add Employee
            </button>
          </div>
        </div>
      </div>

      <!-- Search and Filter Bar -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Search</label>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search by name, email..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Role</label>
            <select
              v-model="roleFilter"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">All Roles</option>
              <option value="employee">Employee</option>
              <option value="manager">Manager</option>
              <option value="admin">Admin</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Team</label>
            <select
              v-model="teamFilter"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">All Teams</option>
              <option v-for="team in teams" :key="team.id" :value="team.description">{{ team.description || 'Unnamed Team' }}</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <select
              v-model="statusFilter"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">All Status</option>
              <option value="clocked_in">Clocked In</option>
              <option value="clocked_out">Clocked Out</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Global Statistics -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-blue-100 rounded-lg">
              <span class="text-2xl">👥</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Total Employees</p>
              <p class="text-2xl font-bold text-gray-900">{{ totalEmployees }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-green-100 rounded-lg">
              <span class="text-2xl">👨‍💼</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Managers</p>
              <p class="text-2xl font-bold text-gray-900">{{ totalManagers }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-purple-100 rounded-lg">
              <span class="text-2xl">🏢</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Teams</p>
              <p class="text-2xl font-bold text-gray-900">{{ totalTeams }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center">
            <div class="p-3 bg-orange-100 rounded-lg">
              <span class="text-2xl">🟢</span>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Clocked In</p>
              <p class="text-2xl font-bold text-gray-900">{{ clockedInUsers }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Users Table -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-semibold text-gray-900">Employee Directory</h2>
        </div>
        
        <div v-if="loading" class="p-8 text-center text-gray-500">
          Loading employees...
        </div>
        
        <div v-else-if="error" class="p-8 text-center text-red-600">
          {{ error }}
        </div>
        
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Employee</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Team</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Working Hours</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Location</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in filteredUsers" :key="user.id" class="hover:bg-gray-50">
                <!-- Employee Info -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="flex-shrink-0 h-10 w-10">
                      <div class="h-10 w-10 rounded-full bg-gray-300 flex items-center justify-center">
                        <span class="text-sm font-medium text-gray-700">
                          {{ user.first_name?.[0] }}{{ user.last_name?.[0] }}
                        </span>
                      </div>
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">
                        {{ user.first_name }} {{ user.last_name }}
                      </div>
                      <div class="text-sm text-gray-500">{{ user.email }}</div>
                    </div>
                  </div>
                </td>

                <!-- Role -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    :class="[
                      'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                      user.role === 'admin' ? 'bg-red-100 text-red-800' :
                      user.role === 'manager' ? 'bg-blue-100 text-blue-800' :
                      'bg-green-100 text-green-800'
                    ]"
                  >
                    {{ user.role?.toUpperCase() || 'EMPLOYEE' }}
                  </span>
                </td>

                <!-- Team -->
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ getUserTeam(user) }}
                </td>

                <!-- Status -->
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div
                      :class="[
                        'w-2 h-2 rounded-full mr-2',
                        getUserStatus(user) === 'clocked_in' ? 'bg-green-400' : 'bg-gray-400'
                      ]"
                    ></div>
                    <span class="text-sm text-gray-900 capitalize">{{ getUserStatus(user).replace('_', ' ') }}</span>
                  </div>
                </td>

                <!-- Working Hours -->
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ getUserWorkingHours(user) }}
                </td>

                <!-- Location -->
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  <button
                    v-if="getUserLocation(user)"
                    @click="showLocation(user)"
                    class="text-blue-600 hover:text-blue-800"
                  >
                    📍 View Location
                  </button>
                  <span v-else class="text-gray-400">No location</span>
                </td>

                <!-- Actions -->
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div class="flex items-center space-x-2">
                    <button
                      @click="viewUserDetails(user)"
                      class="text-blue-600 hover:text-blue-800"
                      title="View Details"
                    >
                      👁️
                    </button>
                    <button
                      @click="editUser(user)"
                      class="text-indigo-600 hover:text-indigo-800"
                      title="Edit"
                    >
                      ✏️
                    </button>
                    <button
                      v-if="currentUser.id !== user.id"
                      @click="confirmDelete(user)"
                      class="text-red-600 hover:text-red-800"
                      title="Delete"
                    >
                      🗑️
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Add/Edit User Modal -->
      <div v-if="showAddUser || editingUser" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
        <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
          <div class="mt-3">
            <h3 class="text-lg font-medium text-gray-900 mb-4">
              {{ editingUser ? 'Edit Employee' : 'Add New Employee' }}
            </h3>
            
            <form @submit.prevent="saveUser" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">First Name</label>
                <input
                  v-model="userForm.first_name"
                  type="text"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Last Name</label>
                <input
                  v-model="userForm.last_name"
                  type="text"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input
                  v-model="userForm.email"
                  type="email"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                <input
                  v-model="userForm.username"
                  type="text"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <div class="relative">
                  <input
                    v-model="userForm.password"
                    :type="showPassword ? 'text' : 'password'"
                    required
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 pr-10"
                  />
                  <button
                    type="button"
                    @click="showPassword = !showPassword"
                    class="absolute inset-y-0 right-0 pr-3 flex items-center"
                  >
                    {{ showPassword ? '🙈' : '👁️' }}
                  </button>
                </div>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                <select
                  v-model="userForm.role"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="employee">employee</option>
                  <option value="manager">manager</option>
                  <option value="admin">admin</option>
                </select>
              </div>
              
              <div class="flex justify-end space-x-3 pt-4">
                <button
                  type="button"
                  @click="closeModal"
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  :disabled="saving"
                  class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                  {{ saving ? 'Saving...' : (editingUser ? 'Update' : 'Create') }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- User Details Modal -->
      <div v-if="selectedUser" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
        <div class="relative top-5 mx-auto p-5 border w-full max-w-6xl shadow-lg rounded-md bg-white">
          <div class="mt-3">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-medium text-gray-900">
                {{ selectedUser.first_name }} {{ selectedUser.last_name }} - Complete Details
              </h3>
              <button @click="selectedUser = null" class="text-gray-400 hover:text-gray-600 text-2xl">
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
                    @input="loadUserDetailedData"
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
                    @click="loadUserDetailedData"
                    :disabled="loadingUserData"
                    class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
                  >
                    {{ loadingUserData ? 'Loading...' : 'Refresh Data' }}
                  </button>
                </div>
              </div>
            </div>

            <!-- Loading State -->
            <div v-if="loadingUserData" class="flex justify-center items-center py-8">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>

            <!-- User Data Content -->
            <div v-else class="space-y-6">
              <!-- Basic Information -->
              <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div class="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Basic Information</h4>
                  <div class="space-y-3">
                    <div>
                      <label class="text-sm text-gray-500">Email</label>
                      <p class="text-sm font-medium">{{ selectedUser.email }}</p>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Username</label>
                      <p class="text-sm font-medium">{{ selectedUser.username }}</p>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Role</label>
                      <span
                        :class="[
                          'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                          selectedUser.role === 'admin' ? 'bg-red-100 text-red-800' :
                          selectedUser.role === 'manager' ? 'bg-blue-100 text-blue-800' :
                          'bg-green-100 text-green-800'
                        ]"
                      >
                        {{ selectedUser.role?.toUpperCase() || 'EMPLOYEE' }}
                      </span>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Team</label>
                      <p class="text-sm font-medium">{{ getUserTeam(selectedUser) }}</p>
                    </div>
                  </div>
                </div>

                <!-- Working Statistics -->
                <div class="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Working Statistics</h4>
                  <div class="space-y-3">
                    <div>
                      <label class="text-sm text-gray-500">Total Hours (Selected Date)</label>
                      <p class="text-sm font-medium">{{ userDetailedData.totalHours || '0:00' }}</p>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Current Status</label>
                      <div class="flex items-center">
                        <div
                          :class="[
                            'w-2 h-2 rounded-full mr-2',
                            getUserStatus(selectedUser) === 'clocked_in' ? 'bg-green-400' : 'bg-gray-400'
                          ]"
                        ></div>
                        <span class="text-sm font-medium capitalize">{{ getUserStatus(selectedUser).replace('_', ' ') }}</span>
                      </div>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Clock Records Today</label>
                      <p class="text-sm font-medium">{{ userDetailedData.clockRecords?.length || 0 }} entries</p>
                    </div>
                    <div>
                      <label class="text-sm text-gray-500">Last Clock</label>
                      <p class="text-sm font-medium">{{ userDetailedData.lastClockTime || 'No records' }}</p>
                    </div>
                  </div>
                </div>

                <!-- Permissions & Settings -->
                <div class="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Permissions</h4>
                  <div class="space-y-3">
                    <div class="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                      <div class="flex-1">
                        <label class="font-medium text-gray-900">Flexible Work Time</label>
                        <p class="text-xs text-gray-600 mt-1">
                          Allow user to work outside scheduled hours without alerts
                        </p>
                      </div>
                      <button
                        @click="toggleFlexibleTime(selectedUser)"
                        class="ml-4 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                        :class="selectedUser.flexible_time_enabled ? 'bg-blue-600' : 'bg-gray-200'"
                      >
                        <span
                          class="pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                          :class="selectedUser.flexible_time_enabled ? 'translate-x-5' : 'translate-x-0'"
                        ></span>
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Location Information -->
                <div class="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-4">Location Information</h4>
                  <div class="space-y-3">
                    <div v-if="userDetailedData.lastLocation">
                      <label class="text-sm text-gray-500">Last Known Location</label>
                      <p class="text-sm font-medium">{{ userDetailedData.lastLocation }}</p>
                    </div>
                    <div v-if="userDetailedData.lastClockLocation">
                      <label class="text-sm text-gray-500">Last Clock Location</label>
                      <p class="text-sm font-medium">{{ userDetailedData.lastClockLocation }}</p>
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
                <div v-if="userDetailedData.clockRecords && userDetailedData.clockRecords.length > 0" class="overflow-x-auto">
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
                      <tr v-for="(record, index) in userDetailedData.clockRecords" :key="record.id">
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
                          {{ calculateDuration(record, userDetailedData.clockRecords, index) }}
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
                <div v-if="userDetailedData.schedule && userDetailedData.schedule.length > 0" class="overflow-x-auto">
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
                      <tr v-for="schedule in userDetailedData.schedule" :key="schedule.id">
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
const users = ref([])
const teams = ref([])
const loading = ref(false)
const error = ref('')
const saving = ref(false)
const showAddUser = ref(false)
const editingUser = ref(null)
const selectedUser = ref(null)
const showPassword = ref(false)
const selectedDate = ref(new Date().toISOString().split('T')[0])
const loadingUserData = ref(false)
const userDetailedData = ref({
  totalHours: '0:00',
  clockRecords: [],
  schedule: [],
  lastLocation: null,
  lastClockLocation: null,
  lastClockTime: null
})

// Search and filters
const searchQuery = ref('')
const roleFilter = ref('')
const teamFilter = ref('')
const statusFilter = ref('')

// User form
const userForm = ref({
  first_name: '',
  last_name: '',
  email: '',
  username: '',
  password: '',
  role: 'employee'
})

// Current user
const currentUser = ref(JSON.parse(localStorage.getItem('currentUser') || '{}'))

// Computed properties
const filteredUsers = computed(() => {
  return users.value.filter(user => {
    const matchesSearch = !searchQuery.value || 
      `${user.first_name} ${user.last_name}`.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      user.email.toLowerCase().includes(searchQuery.value.toLowerCase())
    
    const matchesRole = !roleFilter.value || user.role === roleFilter.value
    const matchesTeam = !teamFilter.value || getUserTeam(user) === teamFilter.value
    const matchesStatus = !statusFilter.value || getUserStatus(user) === statusFilter.value
    
    return matchesSearch && matchesRole && matchesTeam && matchesStatus
  })
})

const totalEmployees = computed(() => users.value.filter(u => u.role === 'employee').length)
const totalManagers = computed(() => users.value.filter(u => u.role === 'manager').length)
const totalTeams = computed(() => teams.value.length)
const clockedInUsers = computed(() => users.value.filter(u => getUserStatus(u) === 'clocked_in').length)

// Lifecycle
onMounted(() => {
  loadUsers()
  loadTeams()
})

// Methods
const loadUsers = async () => {
  loading.value = true
  try {
    const response = await usersApi.list()
    const baseUsers = response.data || []
    
    // Enhance user data with clock-in status and working hours
    const enhancedUsers = await Promise.all(baseUsers.map(async (user) => {
      try {
        // Import clockins and working times APIs
        const { clockinsApi } = await import('../api/clockins')
        const { workingTimesApi } = await import('../api/workingTimes')
        
        // Fetch last clock-in status
        const clocksResponse = await clockinsApi.listByUser(user.id).catch(() => ({ data: [] }))
        const clocks = clocksResponse.data || []
        
        if (clocks.length > 0) {
          const lastClock = clocks[0]
          user.last_clock_status = lastClock.status
          user.last_clock_time = lastClock.time
          user.latitude = lastClock.latitude
          user.longitude = lastClock.longitude
        }
        
        // Fetch working hours for current week
        const today = new Date()
        const weekStart = new Date(today.setDate(today.getDate() - today.getDay()))
        const weekEnd = new Date(weekStart)
        weekEnd.setDate(weekStart.getDate() + 6)
        
        const workingTimesResponse = await workingTimesApi.list(
          user.id,
          weekStart.toISOString(),
          weekEnd.toISOString()
        ).catch(() => ({ data: [] }))
        
        const workingTimes = workingTimesResponse.data || []
        user.total_hours = workingTimes.reduce((total, wt) => {
          if (wt.start && wt.end) {
            const start = new Date(wt.start)
            const end = new Date(wt.end)
            const hours = (end - start) / (1000 * 60 * 60)
            return total + hours
          }
          return total
        }, 0)
        
        return user
      } catch (err) {
        console.error(`Error loading data for user ${user.id}:`, err)
        return user
      }
    }))
    
    users.value = enhancedUsers
  } catch (err) {
    error.value = 'Failed to load users'
    console.error('Error loading users:', err)
  } finally {
    loading.value = false
  }
}

const loadTeams = async () => {
  try {
    const response = await teamsApi.list()
    teams.value = response.data || []
  } catch (err) {
    console.error('Error loading teams:', err)
  }
}

const saveUser = async () => {
  saving.value = true
  try {
    if (editingUser.value) {
      await usersApi.update(editingUser.value.id, userForm.value)
    } else {
      await usersApi.create(userForm.value)
    }
    
    await loadUsers()
    closeModal()
  } catch (err) {
    error.value = 'Failed to save user'
    console.error('Error saving user:', err)
  } finally {
    saving.value = false
  }
}

const editUser = (user) => {
  console.log('Edit user clicked:', user)
  editingUser.value = user
  userForm.value = {
    first_name: user.first_name || '',
    last_name: user.last_name || '',
    email: user.email || '',
    username: user.username || '',
    password: '',
    role: user.role || 'employee'
  }
  showAddUser.value = false
  console.log('editingUser set to:', editingUser.value)
}

const viewUserDetails = async (user) => {
  console.log('View user details clicked:', user)
  selectedUser.value = user
  console.log('selectedUser set to:', selectedUser.value)
  await loadUserDetailedData()
}

const confirmDelete = (user) => {
  if (confirm(`Are you sure you want to delete ${user.first_name} ${user.last_name}?`)) {
    deleteUser(user)
  }
}

const deleteUser = async (user) => {
  try {
    await usersApi.remove(user.id)
    await loadUsers()
  } catch (err) {
    error.value = 'Failed to delete user'
    console.error('Error deleting user:', err)
  }
}

const toggleFlexibleTime = async (user) => {
  try {
    const newValue = !user.flexible_time_enabled
    
    // Update user via API
    await usersApi.update(user.id, {
      flexible_time_enabled: newValue
    })
    
    // Update local data
    user.flexible_time_enabled = newValue
    
    // Reload users to ensure sync
    await loadUsers()
    
    // Show notification
    if (newValue) {
      alert(`✅ Flexible time enabled for ${user.first_name} ${user.last_name}\n\nThis user can now work outside scheduled hours without early/late arrival alerts.`)
    } else {
      alert(`⚠️ Flexible time disabled for ${user.first_name} ${user.last_name}\n\nThis user will now receive alerts for early/late arrivals.`)
    }
  } catch (err) {
    console.error('Error toggling flexible time:', err)
    alert('Failed to update flexible time permission. Please try again.')
  }
}

const closeModal = () => {
  showAddUser.value = false
  editingUser.value = null
  userForm.value = {
    first_name: '',
    last_name: '',
    email: '',
    username: '',
    password: '',
    role: 'employee'
  }
  showPassword.value = false
}

const exportUsers = () => {
  // TODO: Implement CSV export
  alert('CSV export functionality will be implemented soon!')
}

const showLocation = (user) => {
  // TODO: Implement location view
  alert(`Location view for ${user.first_name} ${user.last_name} will be implemented soon!`)
}

// Helper functions
const getUserTeam = (user) => {
  console.log('Getting team for user:', user.id, user.first_name, user.last_name)
  console.log('Available teams:', teams.value)
  
  // Check if user is a manager of any team
  const managedTeam = teams.value.find(team => team.manager?.id === user.id)
  if (managedTeam) {
    console.log('Found managed team:', managedTeam.description)
    return managedTeam.description || 'Unnamed Team'
  }
  
  // Check if user is an employee of any team
  const employeeTeam = teams.value.find(team => 
    team.employees && team.employees.some(emp => emp.id === user.id)
  )
  if (employeeTeam) {
    console.log('Found employee team:', employeeTeam.description)
    return employeeTeam.description || 'Unnamed Team'
  }
  
  console.log('No team found, returning Unassigned')
  return 'Unassigned'
}

const getUserStatus = (user) => {
  // Check user's most recent clock-in status
  // Check if user is currently clocked in based on last clock status
  if (user.last_clock_status !== undefined) {
    const lastClockTime = user.last_clock_time ? new Date(user.last_clock_time) : null
    if (lastClockTime) {
      const hoursSince = (Date.now() - lastClockTime.getTime()) / (1000 * 60 * 60)
      // Only consider status if it's within last 12 hours
      if (hoursSince < 12) {
        return user.last_clock_status ? 'clocked_in' : 'clocked_out'
      }
    }
  }
  return 'clocked_out'
}

const getUserWorkingHours = (user) => {
  // Get total working hours from working times data
  // This would be fetched from the backend in a real implementation
  if (user.total_hours !== undefined) {
    const hours = Math.floor(user.total_hours)
    const minutes = Math.round((user.total_hours - hours) * 60)
    return `${hours}:${minutes.toString().padStart(2, '0')}`
  }
  return '0:00'
}

const getUserLocation = (user) => {
  // Get last known location from clock-in data
  if (user.last_location) {
    return user.last_location
  }
  if (user.latitude && user.longitude) {
    return `${user.latitude.toFixed(2)}, ${user.longitude.toFixed(2)}`
  }
  return null
}

// New methods for detailed user data
const loadUserDetailedData = async () => {
  if (!selectedUser.value) return
  
  console.log('Loading detailed data for date:', selectedDate.value)
  loadingUserData.value = true
  try {
    const { clockinsApi } = await import('../api/clockins')
    const { workingTimesApi } = await import('../api/workingTimes')
    const { userSchedulesApi } = await import('../api/userSchedules')
    
    // Load clock records for selected date
    const startDate = new Date(selectedDate.value + 'T00:00:00')
    const endDate = new Date(selectedDate.value + 'T23:59:59')
    
    const clockResponse = await clockinsApi.listByUser(
      selectedUser.value.id,
      startDate.toISOString(),
      endDate.toISOString()
    ).catch(() => ({ data: [] }))
    
    const clockRecords = clockResponse.data || []
    console.log('Clock records for date:', selectedDate.value, clockRecords)
    
    // Load working times for selected date
    const workingTimesResponse = await workingTimesApi.list(
      selectedUser.value.id,
      startDate.toISOString(),
      endDate.toISOString()
    ).catch(() => ({ data: [] }))
    
    const workingTimes = workingTimesResponse.data || []
    
    // Load user schedule
    const scheduleResponse = await userSchedulesApi.listByUser(selectedUser.value.id).catch(() => ({ data: [] }))
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
    
    userDetailedData.value = {
      totalHours: `${hours}:${minutes.toString().padStart(2, '0')}`,
      clockRecords: clockRecords.sort((a, b) => new Date(b.time) - new Date(a.time)),
      schedule: schedule,
      lastLocation: lastLocation,
      lastClockLocation: lastLocation,
      lastClockTime: lastClockTime
    }
    
  } catch (error) {
    console.error('Error loading detailed user data:', error)
    userDetailedData.value = {
      totalHours: '0:00',
      clockRecords: [],
      schedule: [],
      lastLocation: null,
      lastClockLocation: null,
      lastClockTime: null
    }
  } finally {
    loadingUserData.value = false
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
    loadUserDetailedData()
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