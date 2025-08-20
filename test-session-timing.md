# Session Timing Test Guide - 1:10 Scaled Configuration

This guide helps you test the scaled-down session timing configuration.

## Configuration Summary

### Backend Configuration
- **Session Expiry**: 2 minutes (scaled from 15 minutes)
- **JWT Token Expiry**: 2 minutes (scaled from 15 minutes) 
- **Refresh Token**: 20 minutes (scaled from 3 hours)

### Frontend Configuration  
- **Heartbeat Monitoring**: Every 30 seconds (scaled from 5 minutes)
- **Periodic Auth Check**: Every 30 seconds (scaled from 5 minutes)
- **Activity Monitoring**: Every 30 seconds 
- **App Resume Threshold**: 30 seconds (scaled from 5 minutes)

## Expected Behavior

### Scenario 1: Active User
- User logs in at `00:00`
- Token expires at `02:00` 
- **If no API calls after 02:00**: Detection within ~30 seconds (by 02:30)
- **If API call after 02:00**: Immediate logout (401 response)

### Scenario 2: App Resume
- User minimizes app for >30 seconds
- When app resumes: Immediate auth check
- If token expired: Immediate logout

### Scenario 3: Background Monitoring
- App active in background
- Heartbeat checks every 30 seconds
- Activity monitoring every 30 seconds
- Maximum detection gap: 30 seconds after expiry

## Manual Test Steps

### Test 1: Basic Session Expiry
1. Login to the app
2. Note the login time
3. Wait 2 minutes without any interaction
4. **Expected**: Automatic logout within 30 seconds (by 2:30)

### Test 2: API Call After Expiry  
1. Login to the app
2. Wait 2 minutes 5 seconds (let token expire)
3. Make an API call (navigate, search, etc.)
4. **Expected**: Immediate logout with 401 error

### Test 3: App Resume Detection
1. Login to the app
2. Minimize app for 1+ minutes
3. Wait until token expires (2 minutes total)
4. Resume the app
5. **Expected**: Immediate logout when app resumes

### Test 4: Heartbeat Monitoring
1. Login to the app  
2. Keep app active in foreground
3. Don't make any manual API calls
4. Wait 2+ minutes
5. **Expected**: Logout within 30 seconds due to heartbeat detection

## Debug Console Output

Watch for these console messages:

```
💓 Starting auth heartbeat service (every 30 seconds)
💓 Heartbeat: Checking authentication status...
✅ Heartbeat: Authentication check passed
❌ Heartbeat: Authentication check failed
🚨 Session expired detected during monitoring
🔄 App resumed after 35 seconds - checking auth
```

## Configuration Files Updated

### Backend:
- `backend/src/core/auth/authConfig.js` - JWT and session timeouts
- `backend/src/core/session/sessionModel.js` - Session creation and validation

### Frontend:
- `frontend/lib/core/services/auth_config.dart` - Timing constants
- `frontend/lib/core/services/auth_heartbeat_service.dart` - Heartbeat interval
- `frontend/lib/core/services/auth_monitor_service.dart` - Monitoring and resume threshold  
- `frontend/lib/app/app_entry_point.dart` - Periodic expiry checks

## Rollback to Production Settings

To restore production timing (15-minute sessions):

### Backend:
```javascript
// authConfig.js
expiresIn: '15m',
sessionTimeout: 15 * 60 * 1000
```

### Frontend:
```dart  
// auth_config.dart
static const Duration sessionTimeout = Duration(minutes: 15);
static const Duration monitoringInterval = Duration(minutes: 5);
static const Duration heartbeatInterval = Duration(minutes: 5);
static const Duration minInactiveTimeForAuthCheck = Duration(minutes: 5);
```

## Notes

- This 1:10 scaling makes testing much faster
- All timing relationships remain proportional  
- The 30-second detection window provides good user experience
- Immediate 401 handling prevents security gaps