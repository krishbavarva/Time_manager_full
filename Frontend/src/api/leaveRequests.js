import { http } from './http'

// Leave Requests API service
export const leaveRequestsApi = {
  // GET /api/leave_requests
  list: () => http.get('/api/leave_requests'),

  // GET /api/leave_requests/:id
  get: (id) => http.get(`/api/leave_requests/${id}`),

  // POST /api/leave_requests
  create: (leaveRequest) => http.post('/api/leave_requests', { leave_request: leaveRequest }),

  // PUT /api/leave_requests/:id
  update: (id, leaveRequest) => http.put(`/api/leave_requests/${id}`, { leave_request: leaveRequest }),

  // DELETE /api/leave_requests/:id
  delete: (id) => http.delete(`/api/leave_requests/${id}`),

  // Get leave requests by user
  getByUser: (userId) => http.get(`/api/leave_requests?user_id=${userId}`),

  // Get pending leave requests for managers
  getPending: () => http.get('/api/leave_requests?status=pending')
}
