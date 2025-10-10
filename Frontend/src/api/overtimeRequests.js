import { http } from './http'

// Overtime Requests API service
export const overtimeRequestsApi = {
  // GET /api/overtime_requests
  list: () => http.get('/api/overtime_requests'),

  // GET /api/overtime_requests/:id
  get: (id) => http.get(`/api/overtime_requests/${id}`),

  // POST /api/overtime_requests
  create: (overtimeRequest) => http.post('/api/overtime_requests', { overtime_request: overtimeRequest }),

  // PUT /api/overtime_requests/:id
  update: (id, overtimeRequest) => http.put(`/api/overtime_requests/${id}`, { overtime_request: overtimeRequest }),

  // DELETE /api/overtime_requests/:id
  delete: (id) => http.delete(`/api/overtime_requests/${id}`),

  // Get overtime requests by user
  getByUser: (userId) => http.get(`/api/overtime_requests?user_id=${userId}`),

  // Get pending overtime requests for managers
  getPending: () => http.get('/api/overtime_requests?status=pending')
}
