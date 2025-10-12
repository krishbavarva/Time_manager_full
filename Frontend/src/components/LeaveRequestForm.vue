<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-10 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
      <div class="mt-3">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-medium text-gray-900">
            {{ editingRequest ? 'Edit Leave Request' : 'Submit Leave Request' }}
          </h3>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600 text-2xl">
            ✕
          </button>
        </div>
        
        <form @submit.prevent="submitRequest" class="space-y-6">
          <!-- Leave Type -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Leave Type *</label>
            <select
              v-model="form.leave_type"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">Select Leave Type</option>
              <option value="sick">Sick Leave</option>
              <option value="vacation">Vacation</option>
              <option value="personal">Personal Leave</option>
              <option value="emergency">Emergency Leave</option>
              <option value="holiday">Holiday</option>
            </select>
          </div>

          <!-- Date Range -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Start Date *</label>
              <input
                v-model="form.start_date"
                type="date"
                required
                :min="today"
                @change="updateEndDate"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">End Date *</label>
              <input
                v-model="form.end_date"
                type="date"
                required
                :min="form.start_date || today"
                @change="updateDuration"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
          </div>

          <!-- Duration Type -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Duration *</label>
            <div class="space-y-2">
              <label class="flex items-center">
                <input
                  v-model="form.duration_type"
                  type="radio"
                  value="full_day"
                  class="mr-2"
                />
                <span>Full Day</span>
              </label>
              <label class="flex items-center">
                <input
                  v-model="form.duration_type"
                  type="radio"
                  value="half_day_morning"
                  class="mr-2"
                />
                <span>Half Day (Morning)</span>
              </label>
              <label class="flex items-center">
                <input
                  v-model="form.duration_type"
                  type="radio"
                  value="half_day_afternoon"
                  class="mr-2"
                />
                <span>Half Day (Afternoon)</span>
              </label>
            </div>
          </div>

          <!-- Total Days Display -->
          <div v-if="totalDays > 0" class="bg-blue-50 border border-blue-200 rounded-lg p-3">
            <div class="flex items-center">
              <span class="text-sm font-medium text-blue-800">
                Total Leave Days: {{ totalDays }}
              </span>
            </div>
          </div>

          <!-- Reason -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Reason *</label>
            <textarea
              v-model="form.reason"
              required
              rows="4"
              placeholder="Please provide a detailed reason for your leave request (minimum 10 characters)"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            ></textarea>
            <p class="text-xs text-gray-500 mt-1">
              {{ form.reason.length }}/500 characters
            </p>
          </div>

          <!-- Action Buttons -->
          <div class="flex justify-end space-x-3 pt-4 border-t">
            <button
              type="button"
              @click="closeModal"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="submitting || !isFormValid"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ submitting ? 'Submitting...' : (editingRequest ? 'Update Request' : 'Submit Request') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { leaveRequestsApi } from '../api/leaveRequests'
import { notificationService } from '../services/notificationService'

const props = defineProps({
  editingRequest: {
    type: Object,
    default: null
  },
  showModal: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'success'])

const form = ref({
  leave_type: '',
  start_date: '',
  end_date: '',
  duration_type: 'full_day',
  reason: ''
})

const submitting = ref(false)
const today = new Date().toISOString().split('T')[0]

// Computed properties
const totalDays = computed(() => {
  if (!form.value.start_date || !form.value.end_date) return 0
  
  const start = new Date(form.value.start_date)
  const end = new Date(form.value.end_date)
  const diffTime = end - start
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1
  
  if (form.value.duration_type === 'full_day') {
    return diffDays
  } else {
    return diffDays * 0.5
  }
})

const isFormValid = computed(() => {
  return form.value.leave_type &&
         form.value.start_date &&
         form.value.end_date &&
         form.value.reason &&
         form.value.reason.length >= 10 &&
         form.value.reason.length <= 500
})

// Methods
const updateEndDate = () => {
  if (form.value.start_date && !form.value.end_date) {
    form.value.end_date = form.value.start_date
  }
}

const updateDuration = () => {
  // Auto-set duration based on date range if needed
  if (form.value.start_date === form.value.end_date && form.value.duration_type === 'full_day') {
    // Keep full day for single day requests
  }
}

const submitRequest = async () => {
  if (!isFormValid.value) return
  
  submitting.value = true
  try {
    if (props.editingRequest) {
      await leaveRequestsApi.update(props.editingRequest.id, form.value)
      notificationService.success('Leave request updated successfully!')
    } else {
      await leaveRequestsApi.create(form.value)
      notificationService.success('Leave request submitted successfully!')
    }
    
    emit('success')
    closeModal()
  } catch (error) {
    console.error('Error submitting leave request:', error)
    notificationService.error('Failed to submit leave request. Please try again.')
  } finally {
    submitting.value = false
  }
}

const closeModal = () => {
  emit('close')
}

const resetForm = () => {
  form.value = {
    leave_type: '',
    start_date: '',
    end_date: '',
    duration_type: 'full_day',
    reason: ''
  }
}

// Watch for editing request changes
watch(() => props.editingRequest, (newRequest) => {
  if (newRequest) {
    form.value = {
      leave_type: newRequest.leave_type,
      start_date: newRequest.start_date,
      end_date: newRequest.end_date,
      duration_type: newRequest.duration_type,
      reason: newRequest.reason
    }
  } else {
    resetForm()
  }
}, { immediate: true })

// Watch for modal close
watch(() => props.showModal, (show) => {
  if (!show) {
    resetForm()
  }
})
</script>

<style scoped>
/* Custom styles for radio buttons */
input[type="radio"] {
  accent-color: #2563eb;
}
</style>
