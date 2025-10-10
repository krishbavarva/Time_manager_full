<template>
  <section class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-4xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">My Schedule</h1>
            <p class="text-gray-600">Set your weekly working schedule</p>
          </div>
          <button
            @click="$router.push('/dashboard')"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Back to Dashboard
          </button>
        </div>
      </div>

      <!-- Weekly Schedule Form -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Weekly Schedule</h2>
        
        <div class="space-y-4">
          <div v-for="(day, index) in weeklySchedule" :key="day.day_of_week" 
               class="flex items-center space-x-4 p-4 border border-gray-200 rounded-lg">
            <div class="w-24">
              <label class="text-sm font-medium text-gray-700 capitalize">
                {{ day.day_of_week }}
              </label>
            </div>
            
            <div class="flex items-center space-x-2">
              <input
                type="checkbox"
                v-model="day.is_active"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <span class="text-sm text-gray-600">Working day</span>
            </div>
            
            <div v-if="day.is_active" class="flex items-center space-x-2">
              <div>
                <label class="block text-xs text-gray-500 mb-1">Start Time</label>
                <input
                  type="time"
                  v-model="day.scheduled_start_time"
                  class="w-32 px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label class="block text-xs text-gray-500 mb-1">End Time</label>
                <input
                  type="time"
                  v-model="day.scheduled_end_time"
                  class="w-32 px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label class="block text-xs text-gray-500 mb-1">Hours</label>
                <input
                  type="number"
                  v-model="day.scheduled_hours"
                  step="0.5"
                  min="0"
                  max="24"
                  class="w-20 px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>
            
            <div v-else class="text-sm text-gray-500">
              Non-working day
            </div>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end space-x-3">
          <button
            @click="resetSchedule"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Reset
          </button>
          <button
            @click="saveSchedule"
            :disabled="saving"
            class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
          >
            {{ saving ? 'Saving...' : 'Save Schedule' }}
          </button>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
        <div class="flex flex-wrap gap-3">
          <button
            @click="setStandardSchedule"
            class="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700"
          >
            Set Standard Schedule (9 AM - 5 PM)
          </button>
          <button
            @click="setFlexibleSchedule"
            class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700"
          >
            Set Flexible Schedule (8 AM - 6 PM)
          </button>
          <button
            @click="clearAllSchedules"
            class="px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-md hover:bg-red-700"
          >
            Clear All Schedules
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { userSchedulesApi } from '../api/userSchedules'

// Reactive data
const weeklySchedule = ref([])
const saving = ref(false)
const userId = ref(null)

// Days of the week
const daysOfWeek = [
  'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
]

// Lifecycle hook
onMounted(() => {
  // Get user from localStorage
  const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
  if (user && user.id) {
    userId.value = user.id
    initializeSchedule()
    loadExistingSchedules()
  } else {
    console.error('User not found in localStorage')
  }
})

// Methods
const initializeSchedule = () => {
  weeklySchedule.value = daysOfWeek.map(day => ({
    day_of_week: day,
    scheduled_start_time: '09:00',
    scheduled_end_time: '17:00',
    scheduled_hours: 8.0,
    is_active: day !== 'saturday' && day !== 'sunday'
  }))
}

const loadExistingSchedules = async () => {
  if (!userId.value) return
  
  try {
    const response = await userSchedulesApi.list(userId.value)
    const existingSchedules = response.data || []
    
    // Update weekly schedule with existing data
    weeklySchedule.value.forEach(day => {
      const existing = existingSchedules.find(s => s.day_of_week === day.day_of_week)
      if (existing) {
        day.scheduled_start_time = existing.scheduled_start_time || '09:00'
        day.scheduled_end_time = existing.scheduled_end_time || '17:00'
        day.scheduled_hours = existing.scheduled_hours || 8.0
        day.is_active = existing.is_active !== false
        day.id = existing.id
      }
    })
  } catch (error) {
    console.error('Error loading existing schedules:', error)
  }
}

const saveSchedule = async () => {
  if (!userId.value) {
    alert('User ID not found. Please log in again.')
    return
  }
  
  saving.value = true
  try {
    for (const day of weeklySchedule.value) {
      if (day.is_active) {
        const scheduleData = {
          user_id: userId.value,
          day_of_week: day.day_of_week,
          scheduled_start_time: day.scheduled_start_time,
          scheduled_end_time: day.scheduled_end_time,
          scheduled_hours: parseFloat(day.scheduled_hours),
          is_active: true
        }
        
        if (day.id) {
          await userSchedulesApi.update(day.id, scheduleData)
        } else {
          await userSchedulesApi.create(scheduleData)
        }
      } else if (day.id) {
        // Deactivate existing schedule
        await userSchedulesApi.update(day.id, { is_active: false })
      }
    }
    
    alert('Schedule saved successfully!')
  } catch (error) {
    console.error('Error saving schedule:', error)
    alert('Failed to save schedule. Please try again.')
  } finally {
    saving.value = false
  }
}

const resetSchedule = () => {
  initializeSchedule()
}

const setStandardSchedule = () => {
  weeklySchedule.value.forEach(day => {
    if (day.day_of_week !== 'saturday' && day.day_of_week !== 'sunday') {
      day.scheduled_start_time = '09:00'
      day.scheduled_end_time = '17:00'
      day.scheduled_hours = 8.0
      day.is_active = true
    } else {
      day.is_active = false
    }
  })
}

const setFlexibleSchedule = () => {
  weeklySchedule.value.forEach(day => {
    if (day.day_of_week !== 'saturday' && day.day_of_week !== 'sunday') {
      day.scheduled_start_time = '08:00'
      day.scheduled_end_time = '18:00'
      day.scheduled_hours = 10.0
      day.is_active = true
    } else {
      day.is_active = false
    }
  })
}

const clearAllSchedules = () => {
  if (confirm('Are you sure you want to clear all schedules?')) {
    weeklySchedule.value.forEach(day => {
      day.is_active = false
    })
  }
}
</script>
