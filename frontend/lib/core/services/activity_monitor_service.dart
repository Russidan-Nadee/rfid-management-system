import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_monitor_service.dart';

class ActivityMonitorService {
  static final ActivityMonitorService _instance = ActivityMonitorService._internal();
  factory ActivityMonitorService() => _instance;
  ActivityMonitorService._internal();

  DateTime? _lastActivityTime;
  DateTime? _lastAuthCheckTime;
  Timer? _activityTimer;
  
  // Check auth if no activity-based check in last 30 seconds
  static const Duration _maxTimeSinceAuthCheck = Duration(seconds: 30);

  void startMonitoring() {
    _lastActivityTime = DateTime.now();
    _lastAuthCheckTime = DateTime.now();
    
    // Check every 30 seconds if we need an activity-based auth check
    _activityTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkIfAuthCheckNeeded();
    });
  }

  void stopMonitoring() {
    _activityTimer?.cancel();
    _activityTimer = null;
  }

  // Call this on any user interaction (tap, scroll, etc.)
  void recordActivity() {
    final now = DateTime.now();
    _lastActivityTime = now;
    
    // If it's been more than 30 seconds since last auth check, do one now
    if (_lastAuthCheckTime == null || 
        now.difference(_lastAuthCheckTime!) >= const Duration(seconds: 30)) {
      print('🔄 User activity detected - performing auth check');
      _performAuthCheck();
    }
  }

  void _checkIfAuthCheckNeeded() {
    final now = DateTime.now();
    
    // If there was recent activity but no recent auth check, do one
    if (_lastActivityTime != null && _lastAuthCheckTime != null) {
      final timeSinceActivity = now.difference(_lastActivityTime!);
      final timeSinceAuthCheck = now.difference(_lastAuthCheckTime!);
      
      if (timeSinceActivity.inSeconds < 120 && 
          timeSinceAuthCheck > _maxTimeSinceAuthCheck) {
        print('⏰ Periodic check: User was active recently, checking auth');
        _performAuthCheck();
      }
    }
  }

  void _performAuthCheck() {
    _lastAuthCheckTime = DateTime.now();
    final authMonitor = AuthMonitorService();
    authMonitor.checkAuthenticationNow();
  }

  void dispose() {
    stopMonitoring();
  }
}

// Widget wrapper that automatically detects user activity
class ActivityDetector extends StatefulWidget {
  final Widget child;

  const ActivityDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ActivityDetector> createState() => _ActivityDetectorState();
}

class _ActivityDetectorState extends State<ActivityDetector> {
  final ActivityMonitorService _monitor = ActivityMonitorService();

  @override
  void initState() {
    super.initState();
    _monitor.startMonitoring();
  }

  @override
  void dispose() {
    _monitor.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _monitor.recordActivity(),
      onScaleStart: (_) => _monitor.recordActivity(),
      behavior: HitTestBehavior.translucent,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _monitor.recordActivity();
          return false;
        },
        child: widget.child,
      ),
    );
  }
}