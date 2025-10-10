import { http } from './http'

// Clocks API service (Phoenix routes): list and toggle per user
export const clockinsApi = {
  // GET /api/clocks/:user_id
  listByUser: (userId, startDate = null, endDate = null) => {
    let url = `/api/clocks/${userId}`
    const params = new URLSearchParams()
    
    if (startDate) {
      params.append('start', startDate)
    }
    if (endDate) {
      params.append('end', endDate)
    }
    
    if (params.toString()) {
      url += '?' + params.toString()
    }
    
    return http.get(url)
  },

  // POST /api/clocks/:user_id -> toggles arrival/departure with optional location data
  toggleForUser: (userId, locationData = {}) => http.post(`/api/clocks/${userId}`, locationData)
}
