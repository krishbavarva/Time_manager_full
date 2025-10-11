import { createRouter, createWebHistory } from 'vue-router'

// Lazy-loaded views
const LoginView = () => import('../views/LoginView.vue')
const SignupView = () => import('../views/SignupView.vue')
const DashboardView = () => import('../views/DashboardView.vue')
const WorkingTimesView = () => import('../views/WorkingTimesView.vue')
const ClockinsView = () => import('../views/ClockinsView.vue')
const ChatView = () => import('../views/ChatView.vue')
const AdminUsersView = () => import('../views/AdminUsersView.vue')
const TeamsView = () => import('../views/TeamsView.vue')
const TeamDetailView = () => import('../views/TeamDetailView.vue')
const TeamDataView = () => import('../views/TeamDataView.vue')
const AdminTeamsView = () => import('../views/AdminTeamsView.vue')
const AdminDashboard = () => import('../views/AdminDashboard.vue')
const ManagerTeamView = () => import('../views/ManagerTeamView.vue')
const OvertimeManagementView = () => import('../views/OvertimeManagementView.vue')
const WeeklyTimesheetView = () => import('../views/WeeklyTimesheetView.vue')
const UserScheduleView = () => import('../views/UserScheduleView.vue')
const TimesheetApprovalView = () => import('../views/TimesheetApprovalView.vue')
const AttendanceCalendarView = () => import('../views/AttendanceCalendarView.vue')
const AdminAttendanceView = () => import('../views/AdminAttendanceView.vue')
const AdminSalaryView = () => import('../views/AdminSalaryView.vue')
const AdminComplaintsView = () => import('../views/AdminComplaintsView.vue')
const MyComplaintsView = () => import('../views/MyComplaintsView.vue')
const MyLeaveRequestsView = () => import('../views/MyLeaveRequestsView.vue')
const AdminLeaveRequestsView = () => import('../views/AdminLeaveRequestsView.vue')
const WorkSessionView = () => import('../views/WorkSessionView.vue')
const NotFound = () => import('../views/NotFound.vue')

const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/login', name: 'login', component: LoginView },
  { path: '/dashboard', name: 'dashboard', component: DashboardView },
  { path: '/working-times', name: 'working-times', component: WorkingTimesView },
  { path: '/clockins', name: 'clockins', component: ClockinsView },
  { path: '/chat', name: 'chat', component: ChatView },
  { path: '/admin/users', name: 'admin-users', component: AdminUsersView },
  { path: '/admin/teams', name: 'admin-teams', component: AdminTeamsView },
  { path: '/admin/dashboard', name: 'admin-dashboard', component: AdminDashboard },
  { path: '/teams', name: 'teams', component: TeamsView },
  { path: '/manager/team', name: 'manager-team', component: ManagerTeamView },
  { path: '/teams/:id', name: 'team-detail', component: TeamDetailView },
  { path: '/teams/:id/data', name: 'team-data', component: TeamDataView },
  { path: '/overtime-management', name: 'overtime-management', component: OvertimeManagementView },
  { path: '/weekly-timesheet', name: 'weekly-timesheet', component: WeeklyTimesheetView },
  { path: '/user-schedule', name: 'user-schedule', component: UserScheduleView },
  { path: '/timesheet-approvals', name: 'timesheet-approvals', component: TimesheetApprovalView },
  { path: '/attendance-calendar', name: 'attendance-calendar', component: AttendanceCalendarView },
  { path: '/admin/attendance', name: 'admin-attendance', component: AdminAttendanceView },
  { path: '/admin/salary', name: 'admin-salary', component: AdminSalaryView },
  { path: '/admin/complaints', name: 'admin-complaints', component: AdminComplaintsView },
  { path: '/admin/leave-requests', name: 'admin-leave-requests', component: AdminLeaveRequestsView },
  { path: '/my-complaints', name: 'my-complaints', component: MyComplaintsView },
  { path: '/my-leave-requests', name: 'my-leave-requests', component: MyLeaveRequestsView },
  { path: '/work-session', name: 'work-session', component: WorkSessionView },
  { path: '/users', redirect: '/admin/users' },
  { path: '/signup', redirect: '/admin/users' },
  // Catch-all route for 404 pages
  { path: '/:pathMatch(.*)*', name: 'not-found', component: NotFound }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

// Helper function to validate user authentication
const isUserAuthenticated = () => {
  try {
    const userData = localStorage.getItem('currentUser');
    if (userData && userData !== 'null' && userData !== '{}') {
      const user = JSON.parse(userData);
      // Validate that it's a proper user object with required fields
      return user && typeof user === 'object' && user.id && user.email;
    }
    return false;
  } catch {
    return false;
  }
};

// Navigation guard for authentication
router.beforeEach((to, from, next) => {
  // Define routes that don't require authentication
  const publicRoutes = ['/login', '/signup']

  // Check if the route requires authentication
  if (!publicRoutes.includes(to.path)) {
    if (!isUserAuthenticated()) {
      // Redirect to login if user is not authenticated
      next('/login')
      return
    }

    // Check if route requires admin access
    if (to.path.startsWith('/admin/')) {
      try {
        const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
        const userRole = user.role || 'employee'

        if (userRole !== 'admin') {
          // Redirect non-admin users to dashboard
          next('/dashboard')
          return
        }
      } catch {
        // If we can't parse the user data, redirect to login
        next('/login')
        return
      }
    }

    // Restrict admin access to employee-specific routes
    const employeeOnlyRoutes = [
      '/work-session',
      '/working-times', 
      '/clockins',
      '/attendance-calendar',
      '/weekly-timesheet',
      '/user-schedule',
      '/timesheet-approvals'
    ]
    
    if (employeeOnlyRoutes.includes(to.path)) {
      try {
        const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
        const userRole = user.role || 'employee'

        if (userRole === 'admin') {
          // Redirect admins away from employee-specific routes
          next('/admin/dashboard')
          return
        }
      } catch {
        // If we can't parse the user data, redirect to login
        next('/login')
        return
      }
    }
  }

  next()
})

export default router

