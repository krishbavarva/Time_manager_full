import { http } from './http'

export const leaveRequestsApi = {
  // Get all leave requests (admin only)
  list: () => http.get('/api/leave_requests'),

  // Get leave requests for a specific user
  listByUser: (userId) => http.get(`/api/leave_requests/user/${userId}`),

  // Get a specific leave request
  get: (id) => http.get(`/api/leave_requests/${id}`),

  // Create a new leave request
  create: (leaveRequest) => http.post('/api/leave_requests', { leave_request: leaveRequest }),

  // Update a leave request (only pending requests by the user)
  update: (id, leaveRequest) => http.put(`/api/leave_requests/${id}`, { leave_request: leaveRequest }),

  // Approve a leave request (admin only)
  approve: (id, adminNotes = null) => 
    http.post(`/api/leave_requests/${id}/approve`, { leave_request: { admin_notes: adminNotes } }),

  // Reject a leave request (admin only)
  reject: (id, adminNotes = null) => 
    http.post(`/api/leave_requests/${id}/reject`, { leave_request: { admin_notes: adminNotes } }),

  // Delete a leave request (only pending requests by the user)
  remove: (id) => http.delete(`/api/leave_requests/${id}`)
}

// Leave request types
export const LEAVE_TYPES = {
  SICK: 'sick',
  VACATION: 'vacation', 
  PERSONAL: 'personal',
  EMERGENCY: 'emergency',
  HOLIDAY: 'holiday'
}

// Duration types
export const DURATION_TYPES = {
  FULL_DAY: 'full_day',
  HALF_DAY_MORNING: 'half_day_morning',
  HALF_DAY_AFTERNOON: 'half_day_afternoon'
}

// Status types
export const STATUS_TYPES = {
  PENDING: 'pending',
  APPROVED: 'approved',
  REJECTED: 'rejected'
}

// Helper functions
export const getLeaveTypeLabel = (type) => {
  const labels = {
    [LEAVE_TYPES.SICK]: 'Sick Leave',
    [LEAVE_TYPES.VACATION]: 'Vacation',
    [LEAVE_TYPES.PERSONAL]: 'Personal Leave',
    [LEAVE_TYPES.EMERGENCY]: 'Emergency Leave',
    [LEAVE_TYPES.HOLIDAY]: 'Holiday'
  }
  return labels[type] || type
}

export const getDurationLabel = (duration) => {
  const labels = {
    [DURATION_TYPES.FULL_DAY]: 'Full Day',
    [DURATION_TYPES.HALF_DAY_MORNING]: 'Half Day (Morning)',
    [DURATION_TYPES.HALF_DAY_AFTERNOON]: 'Half Day (Afternoon)'
  }
  return labels[duration] || duration
}

export const getStatusLabel = (status) => {
  const labels = {
    [STATUS_TYPES.PENDING]: 'Pending',
    [STATUS_TYPES.APPROVED]: 'Approved',
    [STATUS_TYPES.REJECTED]: 'Rejected'
  }
  return labels[status] || status
}

export const getStatusColor = (status) => {
  const colors = {
    [STATUS_TYPES.PENDING]: 'bg-yellow-100 text-yellow-800',
    [STATUS_TYPES.APPROVED]: 'bg-green-100 text-green-800',
    [STATUS_TYPES.REJECTED]: 'bg-red-100 text-red-800'
  }
  return colors[status] || 'bg-gray-100 text-gray-800'
}