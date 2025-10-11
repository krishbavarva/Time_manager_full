import { http } from './http'

// Salary API service
export const salaryApi = {
  // GET /api/salaries/weekly?week_start=YYYY-MM-DD
  getWeeklySalaries: (weekStart = null) => {
    const params = weekStart ? `?week_start=${weekStart}` : ''
    return http.get(`/api/salaries/weekly${params}`)
  },

  // GET /api/salaries/user/:user_id/weekly?week_start=YYYY-MM-DD
  getUserWeeklySalary: (userId, weekStart = null) => {
    const params = weekStart ? `?week_start=${weekStart}` : ''
    return http.get(`/api/salaries/user/${userId}/weekly${params}`)
  },

  // GET /api/salaries/overtime/:user_id?week_start=YYYY-MM-DD
  getOvertimeDetails: (userId, weekStart = null) => {
    const params = weekStart ? `?week_start=${weekStart}` : ''
    return http.get(`/api/salaries/overtime/${userId}${params}`)
  },

  // POST /api/salaries/overtime/:id/approve
  approveOvertime: (workingTimeId) => {
    return http.post(`/api/salaries/overtime/${workingTimeId}/approve`)
  },

  // POST /api/salaries/overtime/:id/reject
  rejectOvertime: (workingTimeId) => {
    return http.post(`/api/salaries/overtime/${workingTimeId}/reject`)
  }
}

