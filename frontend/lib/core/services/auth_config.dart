/// Configuration for authentication monitoring and session management
/// 1:10 SCALED TESTING CONFIGURATION
class AuthConfig {
  /// How often to check authentication status in the background
  static const Duration monitoringInterval = Duration(seconds: 30);
  
  /// Heartbeat interval for continuous auth checking
  static const Duration heartbeatInterval = Duration(seconds: 30);
  
  /// Minimum inactive time before forcing auth check on app resume
  static const Duration minInactiveTimeForAuthCheck = Duration(seconds: 30);
  
  /// Maximum time between activity-based auth checks
  static const Duration maxTimeBetweenActivityChecks = Duration(seconds: 30);
  
  /// Session timeout warning time (before session expires) - 1:10 scaled
  static const Duration sessionWarningTime = Duration(seconds: 78); // ~1:18
  
  /// Session timeout (should match backend setting) - 1:10 scaled
  static const Duration sessionTimeout = Duration(minutes: 2);
  
  /// Maximum response time for any auth-related API call
  static const Duration authApiTimeout = Duration(seconds: 10);

  /// 1:10 SCALED TESTING CONFIGURATION:
  /// 
  /// TOKEN EXPIRY: 2 minutes (real would be 15 minutes)
  /// 
  /// SCENARIO 1: App is active and user is using it
  /// - Heartbeat monitoring: Checks every 30 seconds
  /// - Activity monitoring: Checks every 30 seconds on user interaction
  /// - Background monitoring: Checks every 30 seconds
  /// - Any API call failure: Immediate logout (0 seconds)
  /// 
  /// SCENARIO 2: App goes to sleep and user returns
  /// - App resume: Check if inactive >30 seconds
  /// - If check fails: Immediate logout dialog
  /// 
  /// SCENARIO 3: User idle but app active
  /// - Heartbeat monitoring: Every 30 seconds
  /// - MAXIMUM GAP: 30 seconds after token expiry
  /// 
  /// EXPECTED BEHAVIOR:
  /// - Token expires at 2:00 minutes
  /// - If no API calls: Detected by 2:30 (within 30 seconds)
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