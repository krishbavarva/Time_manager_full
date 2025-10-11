<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click.self="$emit('close')">
    <div class="bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
      <!-- Header -->
      <div class="bg-gradient-to-r from-red-500 to-pink-500 p-6 rounded-t-xl">
        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <span class="text-4xl mr-3">📝</span>
            <h2 class="text-2xl font-bold text-white">Submit a Complaint</h2>
          </div>
          <button @click="$emit('close')" class="text-white hover:text-gray-200 text-2xl font-bold">
            ×
          </button>
        </div>
        <p class="text-white text-sm mt-2">Let us know about any issues or concerns you have</p>
      </div>

      <!-- Body -->
      <div class="p-6">
        <form @submit.prevent="submitComplaint">
          <!-- Complaint Type -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Complaint Type
            </label>
            <select
              v-model="complaintType"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent"
            >
              <option value="">Select a type</option>
              <option value="workplace">Workplace Issue</option>
              <option value="schedule">Schedule Concern</option>
              <option value="payment">Payment Issue</option>
              <option value="harassment">Harassment/Discrimination</option>
              <option value="technical">Technical Problem</option>
              <option value="other">Other</option>
            </select>
          </div>

          <!-- Complaint Details -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Describe Your Complaint
            </label>
            <textarea
              v-model="complaintText"
              rows="6"
              placeholder="Please provide as much detail as possible..."
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent resize-none"
              required
            ></textarea>
            <p class="text-xs text-gray-500 mt-1">
              Minimum 10 characters • {{ complaintText.length }}/1000
            </p>
          </div>

          <!-- Anonymous Option -->
          <div class="mb-6">
            <label class="flex items-center">
              <input
                type="checkbox"
                v-model="isAnonymous"
                class="w-4 h-4 text-red-600 border-gray-300 rounded focus:ring-red-500"
              />
              <span class="ml-2 text-sm text-gray-700">Submit anonymously</span>
            </label>
          </div>

          <!-- Actions -->
          <div class="flex justify-end space-x-3">
            <button
              type="button"
              @click="$emit('close')"
              class="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="submitting || complaintText.length < 10"
              class="px-6 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 font-medium disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ submitting ? 'Submitting...' : 'Submit Complaint' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { complaintsApi } from '../api/complaints'
import { notificationService } from '../services/notificationService'

const emit = defineEmits(['close', 'submitted'])

const complaintType = ref('')
const complaintText = ref('')
const isAnonymous = ref(false)
const submitting = ref(false)

const submitComplaint = async () => {
  if (complaintText.value.length < 10) {
    notificationService.error('Please provide more details (at least 10 characters)')
    return
  }

  try {
    submitting.value = true
    
    const user = JSON.parse(localStorage.getItem('currentUser'))
    if (!user?.id) {
      notificationService.error('User not found. Please login again.')
      return
    }

    const complaintContent = `[${complaintType.value || 'Other'}] ${complaintText.value}`
    
    await complaintsApi.create({
      user_id: user.id,
      complaint: complaintContent
    })

    notificationService.success('Complaint submitted successfully! We will review it soon.')
    emit('submitted')
    emit('close')
  } catch (error) {
    console.error('Error submitting complaint:', error)
    notificationService.error('Failed to submit complaint. Please try again.')
  } finally {
    submitting.value = false
  }
}
</script>

