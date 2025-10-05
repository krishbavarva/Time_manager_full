import { createRouter, createWebHistory } from 'vue-router'

// Lazy-loaded views
const LoginView = () => import('../views/LoginView.vue')
const SignupView = () => import('../views/SignupView.vue')
const DashboardView = () => import('../views/DashboardView.vue')
const UsersView = () => import('../views/UsersView.vue')
const WorkingTimesView = () => import('../views/WorkingTimesView.vue')
const ClockinsView = () => import('../views/ClockinsView.vue')
const ChatView = () => import('../views/ChatView.vue')
const AdminUsersView = () => import('../views/AdminUsersView.vue')

const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/login', name: 'login', component: LoginView },
  { path: '/dashboard', name: 'dashboard', component: DashboardView },
  { path: '/working-times', name: 'working-times', component: WorkingTimesView },
  { path: '/clockins', name: 'clockins', component: ClockinsView },
  { path: '/chat', name: 'chat', component: ChatView },
  { path: '/admin/users', name: 'admin-users', component: AdminUsersView },
  { path: '/users', redirect: '/admin/users' },
  { path: '/signup', redirect: '/admin/users' }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})


export default router

