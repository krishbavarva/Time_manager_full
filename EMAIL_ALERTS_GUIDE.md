# 📧 Email Alerts System - Complete Guide

## ✅ Status: FULLY INTEGRATED & WORKING

The email alert system has been successfully integrated into the Clock In/Out functionality using EmailJS.

---

## 🎯 Features

### 1. **Early Arrival Alert** 🌅
- **Trigger**: When user clocks in BEFORE their scheduled start time
- **Action**: 
  - Shows alert popup asking for reason
  - Sends email notification with early arrival details
  - Email includes: scheduled start, actual start, minutes early, and reason

### 2. **Late Clock In Alert** ⚠️
- **Trigger**: When user clocks in AFTER their scheduled end time
- **Action**: 
  - Shows alert popup asking for reason
  - Logs the late clock in (can be extended to send email)
  - Email includes: scheduled end, actual clock in, and reason

### 3. **Clock Out Reminder** ⏰
- **Trigger**: When scheduled work hours end (e.g., 5:00 PM)
- **Action**: 
  - Shows alert: "Your scheduled work hours have ended. Please clock out now."
  - If user ignores alert, waits 1 minute then sends email
  - Email includes: clock in time, expected clock out, current time

---

## 📧 EmailJS Configuration

### Current Credentials:
```javascript
Service ID: service_gicc3hx
Template ID: template_l18w0z9
Public Key: BjiaRWJKq6l2aHrTa
```

### Template Settings (IMPORTANT):
```
To Email: {{to_email}}
From Email: krish.bavarva114999@marwadiuniversity.ac.in
From Name: Time Management System
Subject: {{subject}}
Content: {{message}}
```

**⚠️ CRITICAL**: Make sure "From Email" is set to YOUR email address, not `{{to_email}}`!

---

## 🧪 Testing

### Method 1: Clock In Button (Recommended)
1. **Go to**: http://localhost:3002/clockins
2. **Click "Clock In"**
3. **Expected behavior**:
   - If you have a schedule set up and clock in early/late: Alert popup + Email
   - If no schedule: Only console logs (no alerts/emails)

### Method 2: Test Email Button
1. **Go to**: http://localhost:3002/clockins
2. **Click the orange "Test Email" button**
3. **Expected**: Email sent to `krish.bavarva114999@marwadiuniversity.ac.in`

---

## 🔍 Console Logs

### When Clock In is pressed:
```
🚀🚀🚀 TOGGLE FUNCTION CALLED - NEW VERSION WITH ALERTS! 🚀🚀🚀
🔵 Toggle function called
🔵 Creating state: false
🔵 Current user ID: f53addc6-3c6a-4751-bfa6-c3ad7f09c53c
🟢 Clock In - Starting session
🔍 All schedules: [...]
🔍 Schedule found for today: {...}
✅ Schedule has start time: 09:00:00
🕐 Is early arrival? true
🌅 EARLY ARRIVAL DETECTED!
📝 User reason: [user input]
📧 Sending early arrival email AFTER alert response...
📧 Using EmailJS Service ID: service_gicc3hx
📧 Using EmailJS Template ID: template_l18w0z9
📧 Using EmailJS Public Key: BjiaRWJKq6l2aHrTa
📧 Template parameters: {...}
✅ Email sent successfully
```

---

## 📋 Email Templates

### 1. Early Arrival Email
**Subject**: 🌅 Early Arrival Recorded

**Content**:
```
Dear [User Name],

Your early arrival has been recorded.

**Details:**
- Scheduled Start: 09:00:00 AM
- Actual Start: 08:30:00 AM
- Early by: 30 minutes
- Reason: [User provided reason]

Your timesheet has been updated accordingly.

Best regards,
Time Management System
```

### 2. Forgot Clock Out Email
**Subject**: ⚠️ Clock Out Reminder - Action Required

**Content**:
```
Dear [User Name],

IMPORTANT: You forgot to clock out today.

**Work Session:**
- Clock In Time: 09:00:00 AM
- Expected Clock Out: 05:00:00 PM
- Current Time: 06:05:00 PM

Please log in to the system and clock out immediately to record your accurate work hours.

If you have any issues, please contact your manager or HR department.

Best regards,
Time Management System
```

---

## 🚨 Troubleshooting

### Issue 1: No Emails Received
**Solutions**:
1. Check EmailJS template "From Email" is set correctly
2. Verify Service ID, Template ID, and Public Key
3. Check spam/junk folder
4. Look for error messages in browser console (F12)

### Issue 2: No Alerts/Emails on Clock In
**Reason**: You need to have a schedule set up first!
**Solution**: 
1. Go to "My Schedule" page
2. Set up your weekly work schedule
3. Try clocking in again

### Issue 3: Alert Shows But No Email
**Reason**: EmailJS configuration issue
**Solution**: 
1. Check console for email errors
2. Verify EmailJS credentials
3. Test with "Test Email" button

---

## 📱 How It Works

### Flow Diagram:
```
User Clicks "Clock In"
       ↓
Check if user has schedule
       ↓
   ┌───────────┬───────────┐
   ↓           ↓           ↓
Early?      On Time?     Late?
   ↓           ↓           ↓
Show Alert  Clock In   Show Alert
   ↓        Success       ↓
Get Reason               Get Reason
   ↓                       ↓
Send Email              Log Event
   ↓                       ↓
Start Work              Start Work
   ↓                       ↓
Set Clock Out Reminder Timer
   ↓
   ↓ (At scheduled end time)
   ↓
Show Clock Out Alert
   ↓
User Response?
   ↓
┌──────┴──────┐
↓             ↓
Clock Out   Ignore
Success      ↓
         Wait 1 min
             ↓
       Send Reminder Email
```

---

## 💡 Tips

1. **Set up your schedule first**: The email alerts only work if you have a weekly schedule configured
2. **Check console logs**: Open browser console (F12) to see detailed email sending logs
3. **Test with Test button**: Use the orange "Test Email" button to verify EmailJS is working
4. **Look for alerts**: Browser alert popups are BEFORE emails are sent
5. **Spam folder**: Always check your spam/junk folder for emails

---

## 📂 File Locations

- **Email Service**: `Frontend/src/services/emailService.js`
- **Clock In/Out Logic**: `Frontend/src/views/ClockinsView.vue`
- **Email Configuration**: Lines 6-8 in `emailService.js`

---

## 🎉 Success!

Your email alert system is now fully integrated and working! 

**Key Features**:
✅ Early arrival alerts with email notifications
✅ Late clock in alerts  
✅ Automatic clock out reminders
✅ Forgot to clock out email after 1 minute
✅ Detailed console logging for debugging
✅ Test button for easy testing

**Next Steps**:
1. Set up your work schedule if you haven't already
2. Test the Clock In button
3. Check your email inbox (and spam folder)
4. Enjoy automated attendance tracking! 🎊

