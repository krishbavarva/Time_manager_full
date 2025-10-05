<template>
  <section class="p-6 max-w-7xl mx-auto bg-white">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6 p-4 bg-gray-50 rounded-lg">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p v-if="user" class="text-gray-600 mt-1">
          Welcome, <b class="text-gray-800">{{ user.username || [user.first_name, user.last_name].filter(Boolean).join(' ') }}</b>
          <span 
            class="ml-2 px-2 py-0.5 text-xs font-medium rounded-full"
            :class="{
              'bg-purple-100 text-purple-800': userRole === 'admin',
              'bg-blue-100 text-blue-800': userRole === 'manager',
              'bg-green-100 text-green-800': userRole === 'employee'
            }"
          >
            {{ userRole }}
          </span>
        </p>
      </div>
      
      <div class="flex flex-wrap gap-3">
        <span class="px-3 py-1.5 bg-white border border-gray-200 rounded-lg shadow-sm text-sm">
          <span class="text-gray-500">Work</span>
          <span class="ml-1 font-medium text-gray-900">{{ totalWorkMin }}m ({{ totalWorkMin * 60 }}s)</span>
        </span>
        
        <span class="px-3 py-1.5 bg-white border border-yellow-100 rounded-lg shadow-sm text-sm">
          <span class="text-yellow-700">Break</span>
          <span class="ml-1 font-medium text-yellow-900">{{ totalBreakMin }}m ({{ totalBreakMin * 60 }}s)</span>
        </span>
        
        <span class="px-3 py-1.5 bg-white border border-blue-100 rounded-lg shadow-sm text-sm">
          <span class="text-blue-700">Sessions</span>
          <span class="ml-1 font-medium text-blue-900">{{ allSessions.length }}</span>
        </span>
        
        <!-- Admin/Manager Actions -->
        <button 
          v-if="isAdmin" 
          @click="$router.push('/admin/users')"
          class="flex items-center gap-1.5 px-3 py-1.5 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          <span>👥</span>
          <span>Manage Users</span>
        </button>
        
        <button 
          v-if="isManager" 
          @click="$router.push('/team')"
          class="flex items-center gap-1.5 px-3 py-1.5 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <span>👥</span>
          <span>My Team</span>
        </button>
        
        <button 
          @click="openProfile" 
          class="px-3 py-1.5 text-sm font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
        >
          Edit Profile
        </button>
      </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6 mb-6">
      <h2 class="text-lg font-semibold text-gray-900 mb-4">Today's Sessions</h2>
      <p v-if="loading" class="text-gray-600">Loading…</p>
      <p v-if="error" class="text-red-600">{{ error }}</p>
      <div v-if="!loading && sessions.length === 0" class="text-gray-500">No sessions recorded today.</div>
      <table v-if="!loading && sessions.length" class="min-w-full divide-y divide-gray-200">
        <thead>
          <tr>
            <th>Start</th>
            <th>End</th>
            <th>Duration</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(s, i) in sessions" :key="i">
            <td>{{ s.start }}</td>
            <td>{{ s.end }}</td>
            <td>{{ s.duration }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="card">
      <h2>Working Time (Line)</h2>
      <div v-if="hoursRows.length === 0" class="hint">No working time yet.</div>
      <template v-else>
        <table class="table">
          <thead>
            <tr><th>Date</th><th>Minutes</th><th>mm:ss</th><th>Hours</th></tr>
          </thead>
          <tbody>
            <tr v-for="r in hoursRows" :key="r.date">
              <td>{{ r.date }}</td>
              <td>{{ (r.seconds / 60).toFixed(2) }}</td>
              <td>{{ fmtMMSS(r.seconds) }}</td>
              <td>{{ r.hours }}</td>
            </tr>
          </tbody>
        </table>
        <div class="chart-box"><canvas ref="hoursCanvas" height="120"></canvas></div>
      </template>
    </div>

    <div class="card">
      <h2>Breaks vs Work (Doughnut)</h2>
      <div class="chart-box"><canvas ref="pieCanvas" height="120"></canvas></div>
      <div class="hint">Breaks and total session minutes from your history.</div>
    </div>

    <div class="card">
      <h2>Working Sessions (Scatter)</h2>
      <div v-if="allSessions.length === 0" class="hint">No sessions yet.</div>
      <div v-else class="chart-box"><canvas ref="scatterCanvas" height="120"></canvas></div>
    </div>
  </section>
  
  <!-- Edit Profile Modal -->
  <div v-if="showProfile" class="modal-backdrop" @click.self="showProfile=false">
    <div class="modal">
      <h3>Edit Profile</h3>
      <div class="form">
        <div class="form-group">
          <label>Username</label>
          <input v-model.trim="profile.username" type="text" class="form-control" />
        </div>
        <div class="form-group">
          <label>First name</label>
          <input v-model.trim="profile.first_name" type="text" class="form-control" />
        </div>
        <div class="form-group">
          <label>Last name</label>
          <input v-model.trim="profile.last_name" type="text" class="form-control" />
        </div>
        
        <!-- Role Selection (Admin only) -->
        <div v-if="isAdmin" class="form-group">
          <label>Role</label>
          <select v-model="profile.role" class="form-control" :disabled="!isAdmin">
            <option v-for="role in Object.values(ROLES)" :key="role" :value="role">
              {{ role.charAt(0).toUpperCase() + role.slice(1) }}
            </option>
          </select>
        </div>
        
        <div v-if="error" class="error-message">{{ error }}</div>
      </div>
            <div class="actions">
        <div class="action-buttons">
          <button class="ghost" @click="showProfile=false" :disabled="saving">
            Cancel
          </button>
          <button @click="saveProfile" :disabled="saving">
            {{ saving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
        <div class="danger-zone">
          <h4>Danger Zone</h4>
          <button 
            class="danger" 
            @click="confirmDelete" 
            :disabled="saving"
            title="Permanently delete your account">
            🗑️ Delete My Account
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { workingTimesApi } from '../api/workingTimes'
import { usersApi, ROLES } from '../api/users'
import { chartsApi } from '../api/charts'
import Chart from 'chart.js/auto'

const router = useRouter()
const user = ref(null)
const saving = ref(false)
const error = ref('')
const profileError = ref('')
const sessions = ref([])
const hoursRows = ref([])
const allSessions = ref([])
const totalWorkMin = ref(0)
const totalBreakMin = ref(0)
const hoursCanvas = ref(null)
const pieCanvas = ref(null)
const scatterCanvas = ref(null)
let hoursChart = null
let pieChart = null
let scatterChart = null

// Edit profile modal state
const showProfile = ref(false)
const showDeleteConfirm = ref(false)
const profile = ref({ username: '', first_name: '', last_name: '' })

const loadToday = async () => {
  if (!user.value?.id) return
  loading.value = true
  error.value = ''
  try {
    const data = await workingTimesApi.list(user.value.id)
    const list = Array.isArray(data) ? data : (Array.isArray(data?.data) ? data.data : [])

    // Build today's local date components
    const now = new Date()
    const y = now.getFullYear()
    const m = now.getMonth()
    const d = now.getDate()
    const isTodayLocal = (iso) => {
      if (!iso) return false
      const t = new Date(iso)
      return t.getFullYear() === y && t.getMonth() === m && t.getDate() === d
    }

    const todays = list.filter(w => isTodayLocal(w.start || w.start_time || w.startTime))

    sessions.value = todays.map(w => {
      const startIso = w.start || w.start_time || w.startTime
      const endIso = w.end || w.end_time || w.endTime
      const startTs = startIso ? Date.parse(startIso) : null
      const endTs = endIso ? Date.parse(endIso) : null
      const durSec = startTs && endTs ? Math.max(0, Math.floor((endTs - startTs) / 1000)) : 0
      const minutes = Math.floor(durSec / 60)
      const seconds = durSec % 60
      const fmt = (ts) => ts ? new Date(ts).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '--:--'
      return { start: fmt(startTs), end: fmt(endTs), duration: `${minutes}m ${String(seconds).padStart(2,'0')}s` }
    })
  } catch (_) {
    error.value = 'Failed to load today\'s sessions'
  } finally {
    loading.value = false
  }
}

const fmtIso = (iso) => {
  if (!iso) return '--'
  const d = new Date(iso)
  if (isNaN(+d)) return String(iso)
  return d.toLocaleString()
}

const fmtMMSS = (totalSeconds) => {
  const sec = Math.max(0, Math.floor(Number(totalSeconds) || 0))
  const m = Math.floor(sec / 60)
  const s = sec % 60
  return `${m}:${String(s).padStart(2, '0')}`
}

const secondsBetween = (startIso, endIso) => {
  const a = startIso ? Date.parse(startIso) : NaN
  const b = endIso ? Date.parse(endIso) : NaN
  if (Number.isNaN(a) || Number.isNaN(b)) return 0
  return Math.max(0, Math.floor((b - a) / 1000))
}

const loadCharts = async () => {
  if (!user.value?.id) return
  // Hours by day
  const hoursRes = await chartsApi.hoursByUser(user.value.id)
  hoursRows.value = Array.isArray(hoursRes?.data) ? hoursRes.data : []

  // Sessions list (for scatter)
  const sessRes = await chartsApi.sessionsByUser(user.value.id)
  allSessions.value = Array.isArray(sessRes?.data) ? sessRes.data : []

  // Breaks list
  const breaksRes = await chartsApi.breaksByUser(user.value.id)
  const breaks = Array.isArray(breaksRes?.data) ? breaksRes.data : []

  // Compute totals for badges
  totalWorkMin.value = hoursRows.value.reduce((a, r) => a + (r.minutes || 0), 0)
  totalBreakMin.value = breaks.reduce((a, b) => a + (b.minutes || 0), 0)

  updateCharts(breaks)
}

const updateCharts = (breaks) => {
  // Bar chart for hours by day (minutes)
  const labels = hoursRows.value.map(r => r.date)
  const minutes = hoursRows.value.map(r => r.minutes)
  if (hoursChart) hoursChart.destroy()
  if (hoursCanvas.value) {
    hoursChart = new Chart(hoursCanvas.value.getContext('2d'), {
      type: 'bar',
      data: { labels, datasets: [{ label: 'Minutes Worked', data: minutes, borderColor: '#60a5fa', backgroundColor: 'rgba(96,165,250,0.5)' }] },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          tooltip: { callbacks: { label: (ctx) => ` ${ctx.parsed.y}m (${fmtMMSS(ctx.parsed.y * 60)})` } },
          legend: { position: 'bottom' }
        },
        scales: { y: { beginAtZero: true, ticks: { callback: v => `${v}m` } } }
      }
    })
  }

  // Pie chart: Work vs Break (minutes)
  const totalWorkMin = minutes.reduce((a,b)=>a+b,0)
  const totalBreakMin = breaks.reduce((a,b)=>a + (b.minutes||0), 0)
  if (pieChart) pieChart.destroy()
  if (pieCanvas.value) {
    pieChart = new Chart(pieCanvas.value.getContext('2d'), {
      type: 'doughnut',
      data: { labels: ['Work', 'Break'], datasets: [{ data: [totalWorkMin, totalBreakMin], backgroundColor: ['#34d399','#f87171'], borderWidth: 0 }] },
      options: {
        cutout: '60%',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' },
          tooltip: { callbacks: { label: (ctx) => ` ${ctx.formattedValue}m (${fmtMMSS(ctx.parsed * 60)})` } }
        }
      }
    })
  }

  // Scatter chart: each session (x = start time index, y = minutes)
  const points = allSessions.value.map((s, i) => ({ x: i + 1, y: s.minutes }))
  if (scatterChart) scatterChart.destroy()
  if (scatterCanvas.value) {
    scatterChart = new Chart(scatterCanvas.value.getContext('2d'), {
      type: 'scatter',
      data: { datasets: [{ label: 'Session Minutes', data: points, backgroundColor: '#93c5fd' }] },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { tooltip: { callbacks: { label: (ctx) => ` ${ctx.raw.y}m (${fmtMMSS(ctx.raw.y * 60)})` } }, legend: { display: false } },
        scales: { x: { title: { display: true, text: 'Session #' } }, y: { beginAtZero: true, title: { display: true, text: 'Minutes' } } }
      }
    })
  }
}

onMounted(() => {
  try { user.value = JSON.parse(localStorage.getItem('currentUser') || 'null') } catch { user.value = null }
  if (user.value) profile.value = { username: user.value.username || '', first_name: user.value.first_name || '', last_name: user.value.last_name || '' }
  loadToday()
  loadCharts()
})

const openProfile = () => {
  if (!user.value) return
  profile.value = { 
    username: user.value.username || '', 
    first_name: user.value.first_name || '', 
    last_name: user.value.last_name || '',
    role: user.value.role || ROLES.EMPLOYEE
  }
  showProfile.value = true
  error.value = ''
  saving.value = false
}

// Role-based computed properties
const userRole = computed(() => {
  if (!user.value) return ''
  return user.value.role || ROLES.EMPLOYEE
})

const isAdmin = computed(() => userRole.value === ROLES.ADMIN)
const isManager = computed(() => [ROLES.ADMIN, ROLES.MANAGER].includes(userRole.value))

// Handle user logout
const handleLogout = () => {
  localStorage.removeItem('currentUser')
  router.push('/login')
}

const saveProfile = async () => {
  if (!user.value) return
  saving.value = true
  try {
    const profileData = {
      username: profile.value.username,
      first_name: profile.value.first_name,
      last_name: profile.value.last_name,
    }
    
    // Only include role if user is admin and it's being updated
    if (isAdmin.value && profile.value.role) {
      profileData.role = profile.value.role
    }
    
    const res = await usersApi.update(user.value.id, profileData)
    const updated = res?.data || res
    user.value = updated
    localStorage.setItem('currentUser', JSON.stringify(user.value))
    showProfile.value = false
  } catch (e) {
    console.error('Failed to update profile', e)
    alert('Failed to save profile. ' + (e.message || 'Ensure backend is running and migration applied.'))
  } finally {
    saving.value = false
  }
}

const confirmDelete = () => {
  if (confirm('⚠️ Are you sure you want to delete your account? This action cannot be undone!')) {
    deleteAccount()
  }
}

const deleteAccount = async () => {
  if (!user.value) return
  
  if (!confirm('This will permanently delete your account and all associated data. Are you absolutely sure?')) {
    return
  }
  
  saving.value = true
  try {
    await usersApi.remove(user.value.id)
    alert('Your account has been deleted successfully.')
    handleLogout()
  } catch (e) {
    console.error('Failed to delete account', e)
    alert('Failed to delete account: ' + (e.message || 'Please try again later.'))
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
/* All styles are now handled by Tailwind CSS utility classes */
</style>
