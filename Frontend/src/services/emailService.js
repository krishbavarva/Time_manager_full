import emailjs from '@emailjs/browser'

// EmailJS Configuration
// You need to replace these with your actual EmailJS credentials
// Sign up at https://www.emailjs.com/ to get these values
const EMAILJS_SERVICE_ID = 'service_gicc3hx' // Replace with your service ID
const EMAILJS_TEMPLATE_ID = 'template_l18w0z9' // Replace with your template ID
const EMAILJS_PUBLIC_KEY = 'BjiaRWJKq6l2aHrTa' // Replace with your public key

// Initialize EmailJS
emailjs.init(EMAILJS_PUBLIC_KEY)

/**
 * Email Templates
 */

// Template for clock-out reminder
export const CLOCK_OUT_REMINDER_TEMPLATE = {
  subject: '⏰ Time to Clock Out - Work Day Ended',
  body: `
Dear {{user_name}},

Your scheduled work hours have ended at {{end_time}}.

We noticed that you haven't clocked out yet. Please take a moment to:
1. Click the "Work End" button to clock out
2. Or use the Clock Out button in the system

**Work Summary for Today:**
- Scheduled Start: {{scheduled_start}}
- Scheduled End: {{scheduled_end}}
- Status: Still Clocked In

If you have already left, please clock out remotely or contact your manager.

Thank you for your hard work today!

Best regards,
Time Management System
  `.trim()
}

// Template for early arrival notification
export const EARLY_ARRIVAL_TEMPLATE = {
  subject: '🌅 Early Arrival Recorded',
  body: `
Dear {{user_name}},

Your early arrival has been recorded.

**Details:**
- Scheduled Start: {{scheduled_start}}
- Actual Start: {{actual_start}}
- Early by: {{early_minutes}} minutes
- Reason: {{reason}}

Your timesheet has been updated accordingly.

Best regards,
Time Management System
  `.trim()
}

// Template for overtime notification
export const OVERTIME_ALERT_TEMPLATE = {
  subject: '⏱️ Overtime Hours Recorded',
  body: `
Dear {{user_name}},

You have worked overtime today.

**Work Summary:**
- Total Hours Worked: {{total_hours}}
- Regular Hours: 8:00
- Overtime Hours: {{overtime_hours}}
- Work Start: {{work_start}}
- Work End: {{work_end}}

Your overtime will be reflected in your timesheet.

Thank you for your dedication!

Best regards,
Time Management System
  `.trim()
}

// Template for forgot to clock out
export const FORGOT_CLOCK_OUT_TEMPLATE = {
  subject: '⚠️ Clock Out Reminder - Action Required',
  body: `
Dear {{user_name}},

IMPORTANT: You forgot to clock out today.

**Work Session:**
- Clock In Time: {{clock_in_time}}
- Expected Clock Out: {{expected_clock_out}}
- Current Time: {{current_time}}

Please log in to the system and clock out immediately to record your accurate work hours.

If you have any issues, please contact your manager or HR department.

Best regards,
Time Management System
  `.trim()
}

/**
 * Send email using EmailJS
 * @param {Object} params - Email parameters
 * @param {string} params.to_email - Recipient email
 * @param {string} params.to_name - Recipient name
 * @param {string} params.subject - Email subject
 * @param {string} params.message - Email body
 * @returns {Promise} EmailJS response
 */
export const sendEmail = async (params) => {
  try {
    const templateParams = {
      to_email: params.to_email,
      to_name: params.to_name,
      subject: params.subject,
      message: params.message,
      from_name: 'Time Management System',
      reply_to: 'noreply@timemanager.com'
    }

    const response = await emailjs.send(
      EMAILJS_SERVICE_ID,
      EMAILJS_TEMPLATE_ID,
      templateParams
    )

    console.log('Email sent successfully:', response)
    return { success: true, response }
  } catch (error) {
    console.error('Failed to send email:', error)
    return { success: false, error }
  }
}

/**
 * Send clock-out reminder email
 */
export const sendClockOutReminder = async (user, scheduleInfo) => {
  const message = CLOCK_OUT_REMINDER_TEMPLATE.body
    .replace('{{user_name}}', user.first_name)
    .replace('{{end_time}}', scheduleInfo.end_time)
    .replace('{{scheduled_start}}', scheduleInfo.scheduled_start)
    .replace('{{scheduled_end}}', scheduleInfo.scheduled_end)

  return sendEmail({
    to_email: user.email,
    to_name: `${user.first_name} ${user.last_name}`,
    subject: CLOCK_OUT_REMINDER_TEMPLATE.subject,
    message
  })
}

/**
 * Send early arrival notification
 */
export const sendEarlyArrivalNotification = async (user, arrivalInfo) => {
  const message = EARLY_ARRIVAL_TEMPLATE.body
    .replace('{{user_name}}', user.first_name)
    .replace('{{scheduled_start}}', arrivalInfo.scheduled_start)
    .replace('{{actual_start}}', arrivalInfo.actual_start)
    .replace('{{early_minutes}}', arrivalInfo.early_minutes)
    .replace('{{reason}}', arrivalInfo.reason)

  return sendEmail({
    to_email: user.email,
    to_name: `${user.first_name} ${user.last_name}`,
    subject: EARLY_ARRIVAL_TEMPLATE.subject,
    message
  })
}

/**
 * Send overtime alert
 */
export const sendOvertimeAlert = async (user, overtimeInfo) => {
  const message = OVERTIME_ALERT_TEMPLATE.body
    .replace('{{user_name}}', user.first_name)
    .replace('{{total_hours}}', overtimeInfo.total_hours)
    .replace('{{overtime_hours}}', overtimeInfo.overtime_hours)
    .replace('{{work_start}}', overtimeInfo.work_start)
    .replace('{{work_end}}', overtimeInfo.work_end)

  return sendEmail({
    to_email: user.email,
    to_name: `${user.first_name} ${user.last_name}`,
    subject: OVERTIME_ALERT_TEMPLATE.subject,
    message
  })
}

/**
 * Send forgot clock out email
 */
export const sendForgotClockOutEmail = async (user, clockInfo) => {
  const message = FORGOT_CLOCK_OUT_TEMPLATE.body
    .replace('{{user_name}}', user.first_name)
    .replace('{{clock_in_time}}', clockInfo.clock_in_time)
    .replace('{{expected_clock_out}}', clockInfo.expected_clock_out)
    .replace('{{current_time}}', clockInfo.current_time)

  return sendEmail({
    to_email: user.email,
    to_name: `${user.first_name} ${user.last_name}`,
    subject: FORGOT_CLOCK_OUT_TEMPLATE.subject,
    message
  })
}

export default {
  sendEmail,
  sendClockOutReminder,
  sendEarlyArrivalNotification,
  sendOvertimeAlert,
  sendForgotClockOutEmail
}

