import { http } from './http'

export const complaintsApi = {
  // Get all complaints (admin only)
  list() {
    return http.get('/api/complaints')
  },

  // Get complaints for a specific user
  listByUser(userId) {
    return http.get(`/api/complaints/user/${userId}`)
  },

  // Create a new complaint
  create(complaintData) {
    return http.post('/api/complaints', complaintData)
  },

  // Update a complaint (admin response)
  update(id, updateData) {
    return http.put(`/api/complaints/${id}`, updateData)
  },

  // Delete a complaint
  delete(id) {
    return http.delete(`/api/complaints/${id}`)
  }
}

