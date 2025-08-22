import 'package:flutter/material.dart';
import 'auth_monitor_service.dart';
import '../errors/exceptions.dart';

/// Helper class to test logout functionality
class LogoutTestHelper {
  
  /// Test the AuthMonitor logout flow
  static void testAuthMonitorLogout() {
    print('🧪 TESTING: AuthMonitor logout flow');
    LogoutTestMethods.testAuthMonitorCallback();
  }
  
  /// Test the API Service logout flow
  static void testApiServiceLogout() {
    print('🧪 TESTING: API Service logout flow');
    // Just trigger a manual auth check which will go through the API service
    final authMonitor = AuthMonitorService();
    authMonitor.checkAuthenticationNow();
  }
  
  /// Test SessionExpiredException handling
  static void testSessionExpiredException() {
    print('🧪 TESTING: SessionExpiredException handling');
    LogoutTestMethods.testSessionExpirationHandling();
  }
  
  /// Create debug button widget for testing
  static Widget createDebugButton(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => testAuthMonitorLogout(),
          child: const Text('Test AuthMonitor Logout'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => testApiServiceLogout(),
          child: const Text('Test API Service Logout'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => testSessionExpiredException(),
          child: const Text('Test SessionExpiredException'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            print('🧪 TESTING: Manual AuthMonitor check');
            final authMonitor = AuthMonitorService();
            authMonitor.checkAuthenticationNow();
          },
          child: const Text('Force Auth Check'),
        ),
      ],
    );
  }
}

// Simplified test methods without accessing private members
class LogoutTestMethods {
  
  /// Test the AuthMonitor callback by directly calling the set callback
  static void testAuthMonitorCallback() {
    print('🔥 TEST: Testing AuthMonitor callback');
    
    // Create a test instance and trigger authentication check
    final authMonitor = AuthMonitorService();
    authMonitor.checkAuthenticationNow();
  }
  
  /// Test session expiration by creating a SessionExpiredException
  static void testSessionExpirationHandling() {
    print('🔥 TEST: Testing SessionExpiredException handling');
    
    try {
      throw SessionExpiredException('Test session expiration');
    } catch (e) {
      print('✅ TEST: SessionExpiredException created: $e');
      // The actual error handling is done in the API service
    }
  }
}