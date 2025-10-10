// Export service for CSV and PDF functionality
export const exportService = {
  
  // Export data to CSV
  exportToCSV(data, filename = 'export.csv') {
    if (!data || data.length === 0) {
      console.warn('No data to export')
      return
    }
    
    // Get headers from first object
    const headers = Object.keys(data[0])
    
    // Create CSV content
    const csvContent = [
      // Headers
      headers.join(','),
      // Data rows
      ...data.map(row => 
        headers.map(header => {
          const value = row[header]
          // Escape commas and quotes in values
          if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
            return `"${value.replace(/"/g, '""')}"`
          }
          return value
        }).join(',')
      )
    ].join('\n')
    
    // Create and download file
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    const url = URL.createObjectURL(blob)
    link.setAttribute('href', url)
    link.setAttribute('download', filename)
    link.style.visibility = 'hidden'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  },
  
  // Export users data
  exportUsers(users) {
    const data = users.map(user => ({
      'First Name': user.first_name || '',
      'Last Name': user.last_name || '',
      'Email': user.email || '',
      'Username': user.username || '',
      'Role': user.role || '',
      'Team': user.team || 'Unassigned',
      'Status': user.status || 'offline',
      'Created': user.inserted_at ? new Date(user.inserted_at).toLocaleDateString() : ''
    }))
    
    this.exportToCSV(data, `users-${new Date().toISOString().split('T')[0]}.csv`)
  },
  
  // Export working times data
  exportWorkingTimes(workingTimes) {
    const data = workingTimes.map(wt => ({
      'Date': wt.start ? new Date(wt.start).toLocaleDateString() : '',
      'Start Time': wt.start ? new Date(wt.start).toLocaleTimeString() : '',
      'End Time': wt.end ? new Date(wt.end).toLocaleTimeString() : '',
      'Total Hours': this.formatHours(wt.total_hours || 0),
      'Scheduled Hours': this.formatHours(wt.scheduled_hours || 0),
      'Break Hours': this.formatHours(wt.break_hours || 0),
      'Overtime Hours': this.formatHours(wt.overtime_hours || 0),
      'Status': wt.status || 'pending'
    }))
    
    this.exportToCSV(data, `working-times-${new Date().toISOString().split('T')[0]}.csv`)
  },
  
  // Export team data
  exportTeams(teams) {
    const data = teams.map(team => ({
      'Team Name': team.name || '',
      'Manager': team.manager_name || 'Unassigned',
      'Members': team.member_count || 0,
      'Online Members': team.online_count || 0,
      'Average Hours': team.average_hours || '0:00',
      'Created': team.inserted_at ? new Date(team.inserted_at).toLocaleDateString() : ''
    }))
    
    this.exportToCSV(data, `teams-${new Date().toISOString().split('T')[0]}.csv`)
  },
  
  // Export attendance data
  exportAttendance(attendance) {
    const data = attendance.map(att => ({
      'Date': att.date || '',
      'Employee': att.user_name || '',
      'Status': att.status || '',
      'Clock In': att.clock_in || '',
      'Clock Out': att.clock_out || '',
      'Total Hours': this.formatHours(att.total_hours || 0),
      'Break Time': this.formatHours(att.break_time || 0)
    }))
    
    this.exportToCSV(data, `attendance-${new Date().toISOString().split('T')[0]}.csv`)
  },
  
  // Export comprehensive report
  exportComprehensiveReport(data) {
    const reportData = {
      'Report Generated': new Date().toLocaleString(),
      'Total Employees': data.totalEmployees || 0,
      'Online Employees': data.onlineEmployees || 0,
      'Total Teams': data.totalTeams || 0,
      'Average Work Hours': this.formatHours(data.averageWorkHours || 0),
      'Productivity Score': `${data.productivityScore || 0}%`
    }
    
    this.exportToCSV([reportData], `comprehensive-report-${new Date().toISOString().split('T')[0]}.csv`)
  },
  
  // Helper function to format hours
  formatHours(hours) {
    if (!hours || hours === 0) return '0:00'
    const h = Math.floor(hours)
    const m = Math.round((hours - h) * 60)
    return `${h}:${m.toString().padStart(2, '0')}`
  },
  
  // Future: PDF export functionality
  exportToPDF(data, filename = 'export.pdf') {
    // TODO: Implement PDF export using a library like jsPDF
    console.log('PDF export not yet implemented')
    alert('PDF export functionality will be implemented soon!')
  }
}
