<template>
  <div v-if="show" class="flex items-center justify-center" :class="containerClass">
    <div class="relative">
      <!-- Spinner -->
      <div 
        class="animate-spin rounded-full border-t-2 border-b-2"
        :class="[sizeClass, colorClass]"
      ></div>
      <!-- Center dot -->
      <div 
        class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 rounded-full"
        :class="dotClass"
      ></div>
    </div>
    <span v-if="text" class="ml-3 text-sm font-medium" :class="textColorClass">
      {{ text }}
    </span>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: true
  },
  size: {
    type: String,
    default: 'md', // xs, sm, md, lg, xl
    validator: (value) => ['xs', 'sm', 'md', 'lg', 'xl'].includes(value)
  },
  color: {
    type: String,
    default: 'blue' // blue, green, red, orange, purple, gray
  },
  text: {
    type: String,
    default: ''
  },
  containerClass: {
    type: String,
    default: 'p-4'
  }
})

const sizeClass = computed(() => {
  const sizes = {
    xs: 'w-4 h-4 border-2',
    sm: 'w-6 h-6 border-2',
    md: 'w-8 h-8 border-2',
    lg: 'w-12 h-12 border-3',
    xl: 'w-16 h-16 border-4'
  }
  return sizes[props.size]
})

const dotClass = computed(() => {
  const sizes = {
    xs: 'w-1 h-1',
    sm: 'w-1.5 h-1.5',
    md: 'w-2 h-2',
    lg: 'w-3 h-3',
    xl: 'w-4 h-4'
  }
  const colors = {
    blue: 'bg-blue-600',
    green: 'bg-green-600',
    red: 'bg-red-600',
    orange: 'bg-orange-600',
    purple: 'bg-purple-600',
    gray: 'bg-gray-600'
  }
  return `${sizes[props.size]} ${colors[props.color]}`
})

const colorClass = computed(() => {
  const colors = {
    blue: 'border-blue-600',
    green: 'border-green-600',
    red: 'border-red-600',
    orange: 'border-orange-600',
    purple: 'border-purple-600',
    gray: 'border-gray-600'
  }
  return colors[props.color]
})

const textColorClass = computed(() => {
  const colors = {
    blue: 'text-blue-600',
    green: 'text-green-600',
    red: 'text-red-600',
    orange: 'text-orange-600',
    purple: 'text-purple-600',
    gray: 'text-gray-600'
  }
  return colors[props.color]
})
</script>

