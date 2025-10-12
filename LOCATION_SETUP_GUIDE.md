# 📍 Location Tracking Setup Guide

## Overview
The Clock In/Out feature includes location tracking to record where employees clock in and out. This helps verify employee attendance and location.

## How Location Works

### 🎯 Primary Method: Browser GPS
The system first tries to use your device's GPS for precise location:
- **Accuracy**: High (typically 5-20 meters)
- **Requires**: Location permission in browser
- **Best for**: Mobile devices and laptops with GPS

### 🌐 Fallback Method: IP-Based Location
If GPS is unavailable, the system uses your IP address:
- **Accuracy**: Approximate (city-level)
- **Requires**: Internet connection
- **Best for**: Desktop computers without GPS

### ⚠️ No Location Available
If both methods fail, the system will proceed without location data.

## How to Enable Location Access

### For Google Chrome:
1. Click the 🔒 padlock icon in the address bar
2. Find "Location" in the permissions list
3. Change from "Block" to "Allow"
4. Refresh the page
5. When prompted "Allow [site] to access your location?", click **Allow**

### For Firefox:
1. Click the 🔒 padlock icon in the address bar
2. Click "Connection Secure" → "More Information"
3. Go to "Permissions" tab
4. Find "Access Your Location"
5. Uncheck "Use Default" and select "Allow"
6. Refresh the page

### For Safari:
1. Go to Safari menu → Settings → Websites
2. Click "Location" in the left sidebar
3. Find your website in the list
4. Change to "Allow"
5. Refresh the page

### For Mobile Browsers:
1. Go to device Settings → Apps → Browser (Chrome/Safari/etc.)
2. Tap "Permissions"
3. Enable "Location"
4. Also ensure location services are enabled in device settings

## Testing Location

### 1. Check Browser Console
Open Developer Tools (F12) and look for these messages:
- ✅ `Browser geolocation successful` - GPS working
- ⚠️ `Using IP-based geolocation` - Fallback active
- ❌ `User denied geolocation permission` - Permission denied

### 2. Clock In and Check
After clocking in, check the clock-ins table:
- **"View Location"** link appears → Location captured successfully
- **"No location data"** message → Location not available

### 3. View on Map
Click "View Location" to see the exact coordinates on Google Maps.

## Common Issues & Solutions

### Issue: "Location not available"
**Solutions:**
1. Enable location permission in browser (see guides above)
2. Enable location services in device settings
3. Check if using HTTPS (required for GPS)
4. Try a different browser
5. Restart browser after granting permissions

### Issue: "Position unavailable"
**Solutions:**
1. Check if GPS is enabled on device
2. Move to an area with better GPS signal
3. Try near a window if indoors
4. Wait a few seconds and try again

### Issue: Showing wrong location
**Likely using IP-based location:**
- Shows city/region but not exact building
- This is normal for devices without GPS
- Location will be approximate but functional

### Issue: Permission prompt doesn't appear
**Solutions:**
1. Clear browser cache and cookies
2. Reset site permissions in browser settings
3. Try in incognito/private mode
4. Update browser to latest version

## Location Data Storage

### What's Stored:
- Latitude coordinate (e.g., 40.7128)
- Longitude coordinate (e.g., -74.0060)
- Timestamp of clock in/out

### What's NOT Stored:
- Street address
- Building name
- Personal location history outside clock in/out

### Privacy:
- Location is only captured during clock in/out
- Not tracked continuously
- Used only for attendance verification
- Can be viewed by user and admin

## For Admins

### Viewing Employee Locations:
1. Go to Admin Dashboard
2. View clock-in records
3. Click "View Location" to see where employee clocked in
4. Use for attendance verification and remote work tracking

### Location Reports:
- Export clock-in data includes coordinates
- Can be used with mapping tools
- Helps identify work-from-home vs office attendance

## Technical Details

### Location Accuracy:
- **GPS (Browser)**: ±5-20 meters
- **IP-Based**: ±5-50 kilometers
- **None**: No location data

### Timeout Settings:
- GPS request: 10 seconds
- IP lookup: Default HTTP timeout
- Total wait: ~15 seconds maximum

### Supported Browsers:
- ✅ Chrome 50+
- ✅ Firefox 55+
- ✅ Safari 10+
- ✅ Edge 79+
- ✅ Mobile Chrome/Safari

## Support

If location tracking still doesn't work after following this guide:
1. Check browser console for detailed error messages
2. Try different device/browser
3. Contact IT support with:
   - Browser name and version
   - Error messages from console
   - Device type (mobile/desktop)
   - Operating system

## Quick Checklist

- [ ] HTTPS enabled on website
- [ ] Browser location permission granted
- [ ] Device location services enabled
- [ ] GPS available (if using mobile)
- [ ] Internet connection active
- [ ] Browser updated to latest version
- [ ] No browser extensions blocking location
- [ ] Page reloaded after granting permission

---

**Note**: Location tracking is implemented with privacy in mind. It only captures location at the moment of clock in/out, not continuously throughout the day.

