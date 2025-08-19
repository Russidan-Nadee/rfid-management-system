import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'api_service.dart';
import '../errors/exceptions.dart';

class AuthMonitorService with WidgetsBindingObserver {
  static final AuthMonitorService _instance = AuthMonitorService._internal();
  factory AuthMonitorService() => _instance;
  AuthMonitorService._internal();

  Timer? _authCheckTimer;
  final ApiService _apiService = ApiService();
  static void Function()? _onSessionExpired;
  DateTime? _lastActiveTime;
  bool _isAppActive = true;

  // Check authentication every 15 minutes for production
  static const Duration _checkInterval = Duration(minutes: 15);

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
    print('🛑 Stopping authentication monitoring');
    _authCheckTimer?.cancel();
    _authCheckTimer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      print('🔍 AuthMonitor: Checking authentication status...');
      await _apiService.get('/api/auth/check', requiresAuth: true);
      print('✅ AuthMonitor: Authentication check passed');
      // If successful, session is still valid
    } catch (e) {
      print('❌ AuthMonitor: Authentication check failed: ${e.runtimeType}');
      
      if (e is SessionExpiredException || e is UnauthorizedException) {
        print('🚨 Session expired detected during monitoring - forcing logout');
        _triggerSessionExpired();
      } else {
        print('⚠️ AuthMonitor: Non-auth error (${e.runtimeType}) - will retry on next check');
        // For network errors, etc., don't trigger logout but log for debugging
      }
    }
  }

  void _triggerSessionExpired() {
    if (_onSessionExpired != null) {
      _onSessionExpired!();
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
        _isAppActive = true;
        
        // If app was inactive for more than 15 minutes, force an auth check
        if (_lastActiveTime != null) {
          final inactiveTime = DateTime.now().difference(_lastActiveTime!);
          if (inactiveTime.inMinutes >= 15) {
            print('⚠️ App was inactive for ${inactiveTime.inMinutes} minutes - forcing auth check');
            _checkAuthenticationStatus();
          } else {
            print('ℹ️ App was inactive for ${inactiveTime.inMinutes} minutes - quick auth check');
            // Even for shorter inactivity, do a quick check
            _checkAuthenticationStatus();
          }
        } else {
          // First resume or no previous inactive time - always check
          print('🔄 First app resume - performing auth check');
          _checkAuthenticationStatus();
        }
        break;
        
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('⏸️ App paused/inactive - marking last active time');
        _isAppActive = false;
        _lastActiveTime = DateTime.now();
        break;
        
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isAppActive = false;
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