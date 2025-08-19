/// Configuration for authentication monitoring and session management
class AuthConfig {
  /// How often to check authentication status in the background
  static const Duration monitoringInterval = Duration(minutes: 15);
  
  /// Minimum inactive time before forcing auth check on app resume
  static const Duration minInactiveTimeForAuthCheck = Duration(minutes: 15);
  
  /// Maximum time between activity-based auth checks
  static const Duration maxTimeBetweenActivityChecks = Duration(minutes: 15);
  
  /// Session timeout warning time (before session expires)
  static const Duration sessionWarningTime = Duration(minutes: 13);
  
  /// Session timeout (should match backend setting)
  static const Duration sessionTimeout = Duration(minutes: 15);
  
  /// Maximum response time for any auth-related API call
  static const Duration authApiTimeout = Duration(seconds: 10);

  /// Summary of detection times for production 15-minute intervals:
  /// 
  /// SCENARIO 1: App is active and user is using it
  /// - Activity monitoring: Checks every 15 minutes on activity
  /// - Background monitoring: Checks every 15 minutes
  /// - Any API call failure: Immediate logout
  /// 
  /// SCENARIO 2: App goes to sleep and user returns
  /// - App resume: Immediate check (0 seconds)
  /// - If check fails: Immediate logout dialog
  /// 
  /// SCENARIO 3: App in background but active
  /// - Background monitoring: Every 15 minutes
  /// - Any API call failure: Immediate logout
  /// 
  /// WORST CASE: Maximum 15 minutes to detect via monitoring
  /// TYPICAL CASE: Immediate detection on app resume or API call failure
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