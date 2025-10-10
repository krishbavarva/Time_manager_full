                                                                                                                                                                                                                                                                                                                <template>
  <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100">Advanced Search & Filters</h3>
      <button
        @click="clearFilters"
        class="text-sm text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300"
      >
        Clear All
      </button>
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <!-- Search Input -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Search</label>
        <div class="relative">
          <input
            v-model="filters.search"                                                                                                                                 
            type="text"
            placeholder="Search..."
            class="w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
          />
          <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <span class="text-gray-400">🔍</span>
          </div>
        </div>
      </div>
      
      <!-- Role Filter -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Role</label>
        <select
          v-model="filters.role"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
        >
          <option value="">All Roles</option>
          <option value="admin">Admin</option>
          <option value="manager">Manager</option>
          <option value="employee">Employee</option>
        </select>
      </div>
      
      <!-- Team Filter -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Team</label>
        <select
          v-model="filters.team"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
        >
          <option value="">All Teams</option>
          <option v-for="team in teams" :key="team.id" :value="team.id">{{ team.name }}</option>
        </select>
      </div>
      
      <!-- Status Filter -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Status</label>
        <select
          v-model="filters.status"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
        >
          <option value="">All Status</option>
          <option value="online">Online</option>
          <option value="offline">Offline</option>
          <option value="working">Working</option>
          <option value="break">On Break</option>
        </select>
      </div>
    </div>
    
    <!-- Advanced Filters -->
    <div class="mt-4">
      <button
        @click="showAdvanced = !showAdvanced"
        class="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
      >
        {{ showAdvanced ? 'Hide' : 'Show' }} Advanced Filters
      </button>
      
      <div v-if="showAdvanced" class="mt-4 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <!-- Date Range -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Date Range</label>
          <div class="grid grid-cols-2 gap-2">
            <input
              v-model="filters.dateFrom"
              type="date"
              class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
            />
            <input
              v-model="filters.dateTo"
              type="date"
              class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
            />
          </div>
        </div>
        
        <!-- Work Hours Range -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Work Hours</label>
          <div class="grid grid-cols-2 gap-2">
            <input
              v-model="filters.hoursMin"
              type="number"
              placeholder="Min"
              class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
            />
            <input
              v-model="filters.hoursMax"
              type="number"
              placeholder="Max"
              class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
            />
          </div>
        </div>
        
        <!-- Location Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Location</label>
          <input
            v-model="filters.location"
            type="text"
            placeholder="City, State..."
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-gray-100"
          />
        </div>
      </div>
    </div>
    
    <!-- Filter Results Summary -->
    <div v-if="hasActiveFilters" class="mt-4 p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
      <div class="flex items-center justify-between">
        <div class="text-sm text-gray-600 dark:text-gray-400">
          {{ getFilterSummary() }}
        </div>
        <button
          @click="applyFilters"
          class="px-3 py-1 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700"
        >
          Apply Filters
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const emit = defineEmits(['filter', 'clear'])

const props = defineProps({
  teams: {
    type: Array,
    default: () => []
  }
})

const showAdvanced = ref(false)

const filters = ref({
  search: '',
  role: '',
  team: '',
  status: '',
  dateFrom: '',
  dateTo: '',
  hoursMin: '',
  hoursMax: '',
  location: ''
})

const hasActiveFilters = computed(() => {
  return Object.values(filters.value).some(value => value !== '')
})

const getFilterSummary = () => {
  const activeFilters = []
  
  if (filters.value.search) activeFilters.push(`Search: "${filters.value.search}"`)
  if (filters.value.role) activeFilters.push(`Role: ${filters.value.role}`)
  if (filters.value.team) activeFilters.push(`Team: ${filters.value.team}`)
  if (filters.value.status) activeFilters.push(`Status: ${filters.value.status}`)
  if (filters.value.dateFrom) activeFilters.push(`From: ${filters.value.dateFrom}`)
  if (filters.value.dateTo) activeFilters.push(`To: ${filters.value.dateTo}`)
  if (filters.value.hoursMin) activeFilters.push(`Min Hours: ${filters.value.hoursMin}`)
  if (filters.value.hoursMax) activeFilters.push(`Max Hours: ${filters.value.hoursMax}`)
  if (filters.value.location) activeFilters.push(`Location: ${filters.value.location}`)
  
  return activeFilters.length > 0 ? activeFilters.join(', ') : 'No filters applied'
}

const clearFilters = () => {
  filters.value = {
    search: '',
    role: '',
    team: '',
    status: '',
    dateFrom: '',
    dateTo: '',
    hoursMin: '',
    hoursMax: '',
    location: ''
  }
  emit('clear')
}

const applyFilters = () => {
  emit('filter', { ...filters.value })
}

// Watch for filter changes and auto-apply
watch(filters, () => {
  applyFilters()
}, { deep: true })
</script>
