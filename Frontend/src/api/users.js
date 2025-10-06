import { http } from './http'

// User roles
export const ROLES = {
  ADMIN: 'admin',
  MANAGER: 'manager',
  EMPLOYEE: 'employee'
}

// Users API service (payloads wrapped in { user: { ... } })
export const usersApi = {
  // GET /api/users
  list: (query) => http.get('/api/users', { query }),

  // GET /api/users/:id
  get: (id) => http.get(`/api/users/${id}`),

  // POST /api/users with body { user: { firstname, lastname, username, email, password, role } }
  create: (user) => {
    // Default to employee role if not specified
    const userWithRole = { 
      ...user, 
      role: user.role || ROLES.EMPLOYEE 
    }
    return http.post('/api/users', { user: userWithRole })
  },

  // PUT/PATCH /api/users/:id with body { user: { ...fields } }
  update: (id, user, { method = 'PUT' } = {}) => {
    // Don't allow updating role to higher privilege unless admin
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    if (user.role && currentUser.role !== ROLES.ADMIN) {
      delete user.role
    }
    return method === 'PATCH' 
      ? http.patch(`/api/users/${id}`, { user }) 
      : http.put(`/api/users/${id}`, { user })
  },

  // DELETE /api/users/:id
  remove: (id) => http.delete(`/api/users/${id}`),
  
  // Check if current user has admin role
  isAdmin: () => {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    return user.role === ROLES.ADMIN
  },
  
  // Check if current user has manager role
  isManager: () => {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    return [ROLES.ADMIN, ROLES.MANAGER].includes(user.role)
  },
  
  // Get current user role
  getCurrentUserRole: () => {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    return user.role || ROLES.EMPLOYEE
  }
}
