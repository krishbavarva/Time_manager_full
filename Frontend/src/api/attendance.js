import { http } from './http'

// Attendance API service
export const attendanceApi = {
  // GET /api/attendance
  list: () => http.get('/api/attendance'),

  // GET /api/attendance/:id
  get: (id) => http.get(`/api/attendance/${id}`),

  // POST /api/attendance
  create: (attendance) => http.post('/api/attendance', { attendance }),

  // PUT /api/attendance/:id
  update: (id, attendance) => http.put(`/api/attendance/${id}`, { attendance }),

  // DELETE /api/attendance/:id
  delete: (id) => http.delete(`/api/attendance/${id}`)
}
