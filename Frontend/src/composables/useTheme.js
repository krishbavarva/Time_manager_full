import { ref, computed, watch } from 'vue'

const theme = ref(localStorage.getItem('theme') || 'light')

export function useTheme() {
  const isDark = computed(() => theme.value === 'dark')
  
  const toggleTheme = () => {
    theme.value = theme.value === 'light' ? 'dark' : 'light'
  }
  
  const setTheme = (newTheme) => {
    theme.value = newTheme
  }
  
  // Watch for theme changes and update localStorage and DOM
  watch(theme, (newTheme) => {
    localStorage.setItem('theme', newTheme)
    document.documentElement.classList.toggle('dark', newTheme === 'dark')
  }, { immediate: true })
  
  return {
    theme: computed(() => theme.value),
    isDark,
    toggleTheme,
    setTheme
  }
}
