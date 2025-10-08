import { http } from './http'
import { usersApi } from './users'

// Teams API service
export const teamsApi = {
  // GET /api/teams
  list: () => http.get('/api/teams'),

  // GET /api/teams/:id
  get: (id) => http.get(`/api/teams/${id}`),

  // POST /api/teams (admin only)
  create: (team) => http.post('/api/teams', { team }),

  // PUT /api/teams/:id (manager or admin only)
  update: (id, team) => http.put(`/api/teams/${id}`, { team }),

  // DELETE /api/teams/:id
  remove: (id) => http.delete(`/api/teams/${id}`),

  // GET /api/managers/:manager_id/teams
  getByManager: (managerId) => http.get(`/api/managers/${managerId}/teams`),

  // Manager/Admin endpoints - using existing PUT /api/teams/:id endpoint
  // POST /api/teams/:id/employees (modified to use PUT /api/teams/:id)
  addEmployee: async (teamId, employeeId) => {
    // First get the current team
    const teamResponse = await http.get(`/api/teams/${teamId}`)
    const team = teamResponse.data || teamResponse
    const currentEmployees = team.employees || []

    // Add new employee if not already in team
    if (!currentEmployees.find(emp => emp.id === employeeId)) {
      const updatedEmployees = [...currentEmployees.map(emp => emp.id), employeeId]
      return http.put(`/api/teams/${teamId}`, { team: { employee_ids: updatedEmployees } })
    }
    return teamResponse
  },

  // DELETE /api/teams/:id/employees/:employee_id (modified to use PUT /api/teams/:id)
  removeEmployee: async (teamId, employeeId) => {
    // First get the current team
    const teamResponse = await http.get(`/api/teams/${teamId}`)
    const team = teamResponse.data || teamResponse
    const currentEmployees = team.employees || []

    // Remove employee from team
    const updatedEmployees = currentEmployees
      .map(emp => emp.id)
      .filter(id => id !== employeeId)

    return http.put(`/api/teams/${teamId}`, { team: { employee_ids: updatedEmployees } })
  },

  // GET /api/teams/:id/members/data (manager or admin only)
  getTeamMemberData: (teamId) => http.get(`/api/teams/${teamId}/members/data`),

  // Admin-only endpoints - Updated to use existing team update endpoint
  // PUT /api/teams/:id (assign manager)
  assignManager: (teamId, managerId) => http.put(`/api/teams/${teamId}`, { team: { manager_id: managerId } }),

  // DELETE /api/teams/:id (remove manager)
  removeManager: (teamId) => http.put(`/api/teams/${teamId}`, { team: { manager_id: null } }),

  // GET /api/admin/teams/all (admin only) - Updated to use existing route
  getAllTeamsData: () => http.get('/api/teams'),

  // Helper methods for role-based access control
  canCreateTeam: () => usersApi.isAdmin(),

  canManageTeam: (team) => {
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const userRole = currentUser.role || 'employee'

    // Admin can manage all teams
    if (userRole === 'admin') {
      return true
    }

    // Manager can manage teams they manage
    if (userRole === 'manager' && team?.manager?.id === currentUser.id) {
      return true
    }

    // Employee can only view teams they're members of (not manage)
    return false
  },

  canViewTeamData: (team) => {
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const userRole = currentUser.role || 'employee'

    // Admin can view all team data
    if (userRole === 'admin') {
      return true
    }

    // Manager can view data for teams they manage
    if (userRole === 'manager' && team?.manager?.id === currentUser.id) {
      return true
    }

    // Employee can view teams they're members of
    if (userRole === 'employee' && team?.employees?.some(emp => emp.id === currentUser.id)) {
      return true
    }

    return false
  },

  getCurrentUserRole: () => usersApi.getCurrentUserRole()
}
