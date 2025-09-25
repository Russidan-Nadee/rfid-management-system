import 'dart:async';
import 'package:flutter/widgets.dart';
import 'api_service.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_error_interceptor.dart';

class AuthMonitorService with WidgetsBindingObserver {
  static final AuthMonitorService _instance = AuthMonitorService._internal();
  factory AuthMonitorService() => _instance;
  AuthMonitorService._internal();

  Timer? _authCheckTimer;
  final ApiService _apiService = ApiService();
  static void Function()? _onSessionExpired;
  DateTime? _lastActiveTime;

  // Check authentication every 5 minutes for production
  static const Duration _checkInterval = Duration(minutes: 5);
  
  // App resume threshold - check auth if inactive for more than 5 minutes
  static const Duration _resumeThreshold = Duration(minutes: 5);

  void startMonitoring() {
    if (_authCheckTimer != null) {
      return; // Already monitoring
    }

    print('🔍 Starting authentication monitoring');
    
    // Register for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    _lastActiveTime = DateTime.now();
    
    _authCheckTimer = Timer.periodic(_checkInterval, (_) async {
      await _checkAuthenticationStatus();
    });
    
    // Perform immediate check when starting
    _checkAuthenticationStatus();
  }

  void stopMonitoring() {
    _authCheckTimer?.cancel();
    _authCheckTimer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _checkAuthenticationStatus() async {
    // Skip check if monitoring is stopped
    if (_authCheckTimer == null) {
      // Monitoring stopped - skipping auth check
      return;
    }
    
    try {
      // Checking authentication status
      await _apiService.get(ApiConstants.authCheck, requiresAuth: true);
      // Authentication check passed
      // If successful, session is still valid
    } catch (e) {
      // Authentication check failed: ${e.runtimeType}
      
      // Skip handling if monitoring is stopped (user already logged out)
      if (_authCheckTimer == null) {
        // Monitoring stopped - skipping error handling
        return;
      }
      
      // ALWAYS pass to global error interceptor
      ApiErrorInterceptor.handleError(e, source: 'AuthMonitorService._checkAuthenticationStatus');
      
      if (e is SessionExpiredException || e is UnauthorizedException) {
        print('🚨 Session expired detected during monitoring - forcing logout');
        _triggerSessionExpired();
      } else {
        // Non-auth error (${e.runtimeType}) - will retry on next check
        // For network errors, etc., don't trigger logout but log for debugging
      }
    }
  }

  void _triggerSessionExpired() {
    // Triggering session expired callback
    if (_onSessionExpired != null) {
      // Calling session expired callback
      _onSessionExpired!();
    } else {
      // No session expired callback set
    }
  }

  static void setSessionExpiredCallback(void Function() callback) {
    _onSessionExpired = callback;
  }

  // App lifecycle handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('🔄 App resumed - checking authentication immediately');
        
        // Check auth on app resume if inactive for more than 5 minutes
        if (_lastActiveTime != null) {
          final inactiveTime = DateTime.now().difference(_lastActiveTime!);
          if (inactiveTime >= _resumeThreshold) {
            print('🔄 App resumed after ${inactiveTime.inSeconds} seconds - checking auth');
            _checkAuthenticationStatus();
          } else {
            print('ℹ️ App resumed after ${inactiveTime.inSeconds} seconds - no auth check needed');
          }
        } else {
          print('🔄 First app resume - checking auth');
          _checkAuthenticationStatus();
        }
        break;
        
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('⏸️ App paused/inactive - marking last active time');
        _lastActiveTime = DateTime.now();
        break;
        
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  // Manual check method that can be called from UI
  Future<bool> checkAuthenticationNow() async {
    try {
      await _checkAuthenticationStatus();
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    stopMonitoring();
  }
}