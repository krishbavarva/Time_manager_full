<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" @click.self="$emit('close')">
    <div class="relative top-10 mx-auto p-5 border w-full max-w-4xl shadow-lg rounded-md bg-white dark:bg-gray-800">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Location Tracking</h3>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
          ✕
        </button>
      </div>
      
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Map Container -->
        <div class="bg-gray-100 dark:bg-gray-700 rounded-lg h-96 flex items-center justify-center">
          <div class="text-center">
            <div class="text-4xl mb-2">🗺️</div>
            <p class="text-gray-600 dark:text-gray-400">Interactive Map</p>
            <p class="text-sm text-gray-500 dark:text-gray-500">Location tracking will be implemented with a mapping service</p>
          </div>
        </div>
        
        <!-- Location List -->
        <div class="space-y-4">
          <h4 class="font-medium text-gray-900 dark:text-gray-100">Team Locations</h4>
          
          <div class="space-y-3 max-h-80 overflow-y-auto">
            <div v-for="user in users" :key="user.id" class="flex items-center space-x-3 p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-gray-300 dark:bg-gray-600 rounded-full flex items-center justify-center">
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    {{ user.first_name?.[0] }}{{ user.last_name?.[0] }}
                  </span>
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-gray-900 dark:text-gray-100">
                  {{ user.first_name }} {{ user.last_name }}
                </p>
                <p class="text-xs text-gray-500 dark:text-gray-400">
                  {{ user.location || 'Location not available' }}
                </p>
              </div>
              <div class="flex-shrink-0">
                <div
                  :class="[
                    'w-2 h-2 rounded-full',
                    user.status === 'online' ? 'bg-green-400' :
                    user.status === 'working' ? 'bg-blue-400' :
                    'bg-gray-400'
                  ]"
                ></div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Location Controls -->
      <div class="mt-6 flex justify-between items-center">
        <div class="flex items-center space-x-4">
          <button
            @click="refreshLocations"
            class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700"
          >
            🔄 Refresh Locations
          </button>
          <button
            @click="exportLocations"
            class="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700"
          >
            📤 Export Locations
          </button>
        </div>
        
        <div class="text-sm text-gray-500 dark:text-gray-400">
          Last updated: {{ lastUpdated }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const emit = defineEmits(['close'])

const users = ref([])
const lastUpdated = ref(new Date().toLocaleTimeString())

const loadUsers = async () => {
  // TODO: Load users with location data from API
  users.value = [
    {
      id: 1,
      first_name: 'John',
      last_name: 'Doe',
      location: 'New York, NY',
      status: 'working'
    },
    {
      id: 2,
      first_name: 'Jane',
      last_name: 'Smith',
      location: 'San Francisco, CA',
      status: 'online'
    },
    {
      id: 3,
      first_name: 'Mike',
      last_name: 'Johnson',
      location: 'Chicago, IL',
      status: 'offline'
    }
  ]
}

const refreshLocations = () => {
  lastUpdated.value = new Date().toLocaleTimeString()
  loadUsers()
}

const exportLocations = () => {
  // TODO: Implement location export
  alert('Location export functionality will be implemented soon!')
}

onMounted(() => {
  loadUsers()
})
</script>
