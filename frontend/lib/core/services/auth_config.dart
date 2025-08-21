/// Configuration for authentication monitoring and session management
/// PRODUCTION CONFIGURATION
/// 
/// Session management for 15-minute inactivity timeout:
/// - Session expiry: 15 minutes
/// - Heartbeat checks: 5 minutes  
/// - Activity checks: 5 minutes
/// - App resume threshold: 5 minutes
/// - Detection window: 5 minutes
///
/// EXPECTATIONS:
/// - Token expires at 15:00 minutes
/// - Background detection: Within 5 minutes (by 20:00)
/// - API call after expiry: Immediate logout (0 seconds)
/// - App resume after >5 min inactive: Immediate check
class AuthConfig {
  /// How often to check authentication status in the background
  static const Duration monitoringInterval = Duration(minutes: 5);
  
  /// Heartbeat interval for continuous auth checking
  static const Duration heartbeatInterval = Duration(minutes: 5);
  
  /// Minimum inactive time before forcing auth check on app resume
  static const Duration minInactiveTimeForAuthCheck = Duration(minutes: 5);
  
  /// Maximum time between activity-based auth checks
  static const Duration maxTimeBetweenActivityChecks = Duration(minutes: 5);
  
  /// Session timeout warning time (before session expires) - 13 minutes
  static const Duration sessionWarningTime = Duration(minutes: 13);
  
  /// Session timeout (should match backend setting) - 15 minutes
  static const Duration sessionTimeout = Duration(minutes: 15);
  
  /// Maximum response time for any auth-related API call
  static const Duration authApiTimeout = Duration(seconds: 10);

  /// PRODUCTION CONFIGURATION:
  /// 
  /// TOKEN EXPIRY: 15 minutes
  /// 
  /// SCENARIO 1: App is active and user is using it
  /// - Heartbeat monitoring: Checks every 5 minutes
  /// - Activity monitoring: Checks every 5 minutes on user interaction
  /// - Background monitoring: Checks every 5 minutes
  /// - Any API call failure: Immediate logout (0 seconds)
  /// 
  /// SCENARIO 2: App goes to sleep and user returns
  /// - App resume: Check if inactive >5 minutes
  /// - If check fails: Immediate logout dialog
  /// 
  /// SCENARIO 3: User idle but app active
  /// - Heartbeat monitoring: Every 5 minutes
  /// - MAXIMUM GAP: 5 minutes after token expiry
  /// 
  /// EXPECTED BEHAVIOR:
  /// - Token expires at 15:00 minutes
  /// - If no API calls: Detected by 20:00 (within 5 minutes)
  /// - If API call after expiry: Immediate logout (0 seconds)
}

/// Debug configuration for testing faster detection
class AuthConfigDebug {
  /// Very fast monitoring for testing (every 10 seconds)
  static const Duration fastMonitoringInterval = Duration(seconds: 10);
  
  /// Force auth check on any app resume (even 1 second inactive)
  static const Duration aggressiveResumeCheck = Duration(seconds: 1);
  
  /// Activity-based checks every 30 seconds
  static const Duration fastActivityChecks = Duration(seconds: 30);
}