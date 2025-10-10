import { http } from './http'

const API_BASE = '/api/timesheet_approvals'

export const timesheetApprovalsApi = {
  // Get all pending timesheet approvals
  list: () => http.get(API_BASE),
  
  // Get single timesheet approval
  get: (id) => http.get(`${API_BASE}/${id}`),
  
  // Approve timesheet
  approve: (id, notes = '') => http.post(`${API_BASE}/${id}/approve`, { notes }),
  
  // Reject timesheet
  reject: (id, notes = '') => http.post(`${API_BASE}/${id}/reject`, { notes })
}
