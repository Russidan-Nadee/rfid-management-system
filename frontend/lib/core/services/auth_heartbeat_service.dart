import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_monitor_service.dart';

/// Aggressive heartbeat service to ensure no expired token gaps
class AuthHeartbeatService {
  static final AuthHeartbeatService _instance = AuthHeartbeatService._internal();
  factory AuthHeartbeatService() => _instance;
  AuthHeartbeatService._internal();

  Timer? _heartbeatTimer;
  final AuthMonitorService _authMonitor = AuthMonitorService();
  
  // Heartbeat every 5 minutes for production
  static const Duration _heartbeatInterval = Duration(minutes: 5);

  void startHeartbeat() {
    if (_heartbeatTimer != null) {
      return; // Already running
    }

    print('💓 Starting auth heartbeat service (every 5 minutes)');
    
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      await _performHeartbeat();
    });

    // Perform immediate heartbeat on start
    _performHeartbeat();
  }

  void stopHeartbeat() {
    print('💔 Stopping auth heartbeat service');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _performHeartbeat() async {
    try {
      print('💓 Heartbeat: Checking authentication status...');
      
      // Use the existing auth monitor service
      await _authMonitor.checkAuthenticationNow();
      
      print('💚 Heartbeat: Authentication OK');
    } catch (e) {
      print('💔 Heartbeat: Authentication failed - ${e.runtimeType}');
      // Don't need to handle error here - AuthMonitorService will trigger logout
    }
  }

  void dispose() {
    stopHeartbeat();
  }
}