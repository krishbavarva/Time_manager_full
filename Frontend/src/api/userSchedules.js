import { http } from './http'

const API_BASE = '/api/user_schedules'

export const userSchedulesApi = {
  // Get all user schedules for current user
  list: (userId) => http.get(`${API_BASE}?user_id=${userId}`),
  
  // Get user schedules for specific user (admin/manager)
  listByUser: (userId) => http.get(`${API_BASE}/user/${userId}`),
  
  // Get user schedules by user ID (alias for convenience)
  getByUser: (userId) => http.get(`${API_BASE}/user/${userId}`),
  
  // Get single user schedule
  get: (id) => http.get(`${API_BASE}/${id}`),
  
  // Create new user schedule (data should include user_id)
  create: (data) => http.post(API_BASE, { user_schedule: data }),
  
  // Update user schedule
  update: (id, data) => http.put(`${API_BASE}/${id}`, { user_schedule: data }),
  
  // Delete user schedule
  remove: (id) => http.delete(`${API_BASE}/${id}`)
}
