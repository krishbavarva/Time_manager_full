/**
 * Consistent time formatting utilities for the entire application
 * All times are formatted as HH:MM:SS
 */

/**
 * Format a Date object or datetime string to HH:MM:SS
 * @param {Date|string} dateTime - Date object or ISO string
 * @returns {string} Time in HH:MM:SS format
 */
export const formatTimeHHMMSS = (dateTime) => {
  if (!dateTime) return '00:00:00'
  
  const date = dateTime instanceof Date ? dateTime : new Date(dateTime)
  
  if (isNaN(date.getTime())) return '00:00:00'
  
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  const seconds = date.getSeconds().toString().padStart(2, '0')
  
  return `${hours}:${minutes}:${seconds}`
}

/**
 * Format a Date object or datetime string to full date and time
 * @param {Date|string} dateTime - Date object or ISO string
 * @returns {string} DateTime in MM/DD/YYYY, HH:MM:SS format
 */
export const formatDateTimeHHMMSS = (dateTime) => {
  if (!dateTime) return ''
  
  const date = dateTime instanceof Date ? dateTime : new Date(dateTime)
  
  if (isNaN(date.getTime())) return ''
  
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const year = date.getFullYear()
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  const seconds = date.getSeconds().toString().padStart(2, '0')
  
  return `${month}/${day}/${year}, ${hours}:${minutes}:${seconds}`
}

/**
 * Format hours (decimal) to HH:MM:SS
 * @param {number} hours - Hours as decimal (e.g., 8.5)
 * @returns {string} Time in HH:MM:SS format
 */
export const formatHoursToHHMMSS = (hours) => {
  if (!hours || hours === 0) return '00:00:00'
  
  const h = Math.floor(hours)
  const remainingMinutes = (hours - h) * 60
  const m = Math.floor(remainingMinutes)
  const s = Math.round((remainingMinutes - m) * 60)
  
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

/**
 * Format minutes (integer) to HH:MM:SS
 * @param {number} minutes - Minutes as integer
 * @returns {string} Time in HH:MM:SS format
 */
export const formatMinutesToHHMMSS = (minutes) => {
  if (!minutes || minutes === 0) return '00:00:00'
  
  const h = Math.floor(minutes / 60)
  const m = Math.floor(minutes % 60)
  const s = Math.round(((minutes % 60) - m) * 60)
  
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

/**
 * Format time for display (time only, no date)
 * @param {string} timeString - Time string from backend (e.g., "09:00:00" or "09:00")
 * @returns {string} Time in HH:MM:SS format
 */
export const formatBackendTime = (timeString) => {
  if (!timeString) return '00:00:00'
  
  const parts = timeString.split(':')
  const hours = parts[0]?.padStart(2, '0') || '00'
  const minutes = parts[1]?.padStart(2, '0') || '00'
  const seconds = parts[2]?.padStart(2, '0') || '00'
  
  return `${hours}:${minutes}:${seconds}`
}

/**
 * Calculate duration between two dates in HH:MM:SS format
 * @param {Date|string} startTime - Start datetime
 * @param {Date|string} endTime - End datetime
 * @returns {string} Duration in HH:MM:SS format
 */
export const calculateDuration = (startTime, endTime) => {
  const start = startTime instanceof Date ? startTime : new Date(startTime)
  const end = endTime instanceof Date ? endTime : new Date(endTime)
  
  if (isNaN(start.getTime()) || isNaN(end.getTime())) return '00:00:00'
  
  const durationMs = end - start
  const durationSeconds = Math.floor(durationMs / 1000)
  
  const hours = Math.floor(durationSeconds / 3600)
  const minutes = Math.floor((durationSeconds % 3600) / 60)
  const seconds = durationSeconds % 60
  
  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
}

/**
 * Get current time in HH:MM:SS format
 * @returns {string} Current time in HH:MM:SS format
 */
export const getCurrentTimeHHMMSS = () => {
  return formatTimeHHMMSS(new Date())
}

/**
 * Parse HH:MM:SS string to total seconds
 * @param {string} timeString - Time in HH:MM:SS format
 * @returns {number} Total seconds
 */
export const parseHHMMSSToSeconds = (timeString) => {
  if (!timeString) return 0
  
  const parts = timeString.split(':')
  const hours = parseInt(parts[0] || 0)
  const minutes = parseInt(parts[1] || 0)
  const seconds = parseInt(parts[2] || 0)
  
  return hours * 3600 + minutes * 60 + seconds
}

/**
 * Parse HH:MM:SS string to total hours (decimal)
 * @param {string} timeString - Time in HH:MM:SS format
 * @returns {number} Total hours as decimal
 */
export const parseHHMMSSToHours = (timeString) => {
  const totalSeconds = parseHHMMSSToSeconds(timeString)
  return totalSeconds / 3600
}

export default {
  formatTimeHHMMSS,
  formatDateTimeHHMMSS,
  formatHoursToHHMMSS,
  formatMinutesToHHMMSS,
  formatBackendTime,
  calculateDuration,
  getCurrentTimeHHMMSS,
  parseHHMMSSToSeconds,
  parseHHMMSSToHours
}

