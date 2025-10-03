<template>
  <section>
    <div class="header">
      <div>
        <h1>Dashboard</h1>
        <p v-if="user" class="muted">Welcome, <b>{{ user.username || [user.first_name, user.last_name].filter(Boolean).join(' ') }}</b></p>
      </div>
      <div class="badges">
        <span class="badge">
          <span class="k">Work</span>
          <span class="v">{{ totalWorkMin }}m ({{ totalWorkMin * 60 }}s)</span>
        </span>
        <span class="badge warn">
          <span class="k">Break</span>
          <span class="v">{{ totalBreakMin }}m ({{ totalBreakMin * 60 }}s)</span>
        </span>
        <span class="badge info">
          <span class="k">Sessions</span>
          <span class="v">{{ allSessions.length }}</span>
        </span>
      </div>
      <button class="ghost" @click="openProfile">Edit Profile</button>
    </div>

    <div class="card">
      <h2>Today's Sessions</h2>
      <p v-if="loading">Loading…</p>
      <p v-if="error" class="error">{{ error }}</p>
      <div v-if="!loading && sessions.length === 0">No sessions recorded today.</div>
      <table v-if="!loading && sessions.length" class="table">
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
      <h3>Edit profile</h3>
      <div class="form">
        <label>
          Username
          <input v-model.trim="profile.username" type="text" />
        </label>
        <label>
          First name
          <input v-model.trim="profile.first_name" type="text" />
        </label>
        <label>
          Last name
          <input v-model.trim="profile.last_name" type="text" />
        </label>
      </div>
      <div class="actions">
        <button class="ghost" @click="showProfile=false">Cancel</button>
        <button @click="saveProfile">Save</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { workingTimesApi } from '../api/workingTimes'
import { usersApi } from '../api/users'
import { chartsApi } from '../api/charts'
import Chart from 'chart.js/auto'

const user = ref(null)
const loading = ref(false)
const error = ref('')
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
  profile.value = { username: user.value.username || '', first_name: user.value.first_name || '', last_name: user.value.last_name || '' }
  showProfile.value = true
}

const saveProfile = async () => {
  if (!user.value) return
  try {
    const res = await usersApi.update(user.value.id, {
      username: profile.value.username,
      first_name: profile.value.first_name,
      last_name: profile.value.last_name,
    })
    const updated = res?.data || res
    user.value = updated
    localStorage.setItem('currentUser', JSON.stringify(user.value))
    showProfile.value = false
  } catch (e) {
    console.error('Failed to update profile', e)
    alert('Failed to save profile. Ensure backend is running and migration applied.')
  }
}
</script>

<style scoped>
/* Base styles */
section {
  padding: 1.5rem;
  max-width: 1200px;
  background: white;
  margin: 0 auto;
}

h1 {
  color: #1f2937;
  font-size: 1.875rem;
  margin-bottom: 0.5rem;
  font-weight: 700;
}

h2 {
  color: #1f2937;
  font-size: 1.25rem;
  margin: 1.5rem 0 1rem;
  font-weight: 600;
}

/* Header */
.header { 
  display: flex; 
  justify-content: space-between; 
  align-items: center; 
  gap: 1.5rem; 
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.muted { 
  color: #4b5563;
  font-size: 1rem;
}

/* Badges */
.badges { 
  display: flex; 
  gap: 1rem; 
  margin: 1rem 0; 
  flex-wrap: wrap;
}

.badge { 
  display: inline-flex; 
  flex-direction: column; 
  padding: 0.75rem 1.25rem; 
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem; 
  font-size: 0.9375rem;
  min-width: 120px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
}

.badge:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.badge .k { 
  color: #4b5563;
  font-size: 0.8125rem; 
  font-weight: 500;
  margin-bottom: 0.25rem;
}

.badge .v {
  font-weight: 600;
  color: #1f2937;
  font-size: 1.125rem;
}

.badge.warn { 
  background: #fffbeb;
  border-color: #fde68a;
}

.badge.warn .k { 
  color: #92400e; 
}

.badge.info { 
  background: #eff6ff;
  border-color: #bfdbfe;
}

.badge.info .k { 
  color: #1e40af; 
}

/* Cards */
.card { 
  background: #ffffff; 
  padding: 1.5rem; 
  border-radius: 0.75rem; 
  margin: 1.5rem 0; 
  border: 1px solid #e5e7eb;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

/* Tables */
.table { 
  width: 100%; 
  border-collapse: separate;
  border-spacing: 0;
  margin: 1.25rem 0;
  font-size: 0.9375rem;
}

.table th { 
  text-align: left; 
  padding: 0.75rem 1rem; 
  border-bottom: 1px solid #e5e7eb;
  font-weight: 600;
  color: #374151;
  background-color: #f9fafb;
}

.table td { 
  padding: 0.75rem 1rem; 
  border-bottom: 1px solid #e5e7eb;
  color: #1f2937;
}

.table tr:last-child td {
  border-bottom: none;
}

.table tr:hover td {
  background-color: #f3f4f6;
}

/* Utility classes */
.hint { 
  color: #6b7280;
  font-size: 0.9375rem;
  margin: 0.5rem 0 1.5rem;
}

.error { 
  color: #dc2626; 
  background: #fef2f2;
  padding: 0.75rem 1rem;
  border-radius: 0.375rem;
  margin: 1rem 0;
  border: 1px solid #fecaca;
}

/* Buttons */
button, .btn {
  background-color: #2563eb;
  color: white;
  border: none;
  padding: 0.625rem 1.25rem;
  border-radius: 0.5rem;
  font-weight: 500;
  font-size: 0.9375rem;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

button:hover, .btn:hover {
  background-color: #1d4ed8;
  transform: translateY(-1px);
}

.ghost { 
  background: none; 
  border: 1px solid #d1d5db; 
  color: #374151;
  padding: 0.5rem 1rem;
  transition: all 0.2s;
}

.ghost:hover { 
  background: #f3f4f6;
  border-color: #2563eb;
  color: #2563eb;
}

/* Charts */
.chart-box { 
  position: relative; 
  height: 260px; 
  margin-top: 1.5rem;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  padding: 1rem;
}

/* Modal */
.modal-backdrop { 
  position: fixed; 
  inset: 0; 
  background: white; 
  display: flex; 
  align-items: center; 
  justify-content: center; 
  z-index: 50; 
  backdrop-filter: blur(2px);
}

.modal { 
  width: 100%; 
  max-width: 420px; 
  background: white; 
  border: 1px solid #e5e7eb; 
  border-radius: 0.75rem; 
  padding: 1.5rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.modal h3 { 
  margin: 0 0 1.25rem 0;
  color: #1f2937;
  font-size: 1.25rem;
  font-weight: 600;
}

.modal .form { 
  display: flex; 
  gap: 1rem; 
  flex-direction: column; 
}

.modal input { 
  width: 100%; 
  padding: 0.625rem 0.75rem; 
  border-radius: 0.5rem; 
  border: 1px solid #d1d5db; 
  background: white; 
  color: #1f2937;
  font-size: 0.9375rem;
  transition: border-color 0.2s;
}

.modal input:focus {
  outline: none;
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.modal .actions { 
  display: flex; 
  gap: 0.75rem; 
  justify-content: flex-end; 
  margin-top: 1.5rem; 
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .badges {
    width: 100%;
    justify-content: space-between;
  }
  
  .badge {
    flex: 1;
    min-width: auto;
  }
  
  .modal {
    margin: 1rem;
    padding: 1.25rem;
  }
}
</style>
