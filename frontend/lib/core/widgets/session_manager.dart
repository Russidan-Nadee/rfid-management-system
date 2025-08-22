import 'package:flutter/material.dart';
import '../services/auth_monitor_service.dart';
import '../services/activity_monitor_service.dart';

class SessionManager extends StatefulWidget {
  final Widget child;

  const SessionManager({super.key, required this.child});

  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager>
    with WidgetsBindingObserver {
  final AuthMonitorService _authMonitor = AuthMonitorService();

  @override
  void initState() {
    super.initState();
    // DISABLED: Using only original app_entry_point.dart session logic
    // _sessionTimer.startSessionTimer();
    // _sessionTimer.showWarning.addListener(_onShowWarning);
    // _sessionTimer.sessionExpired.addListener(_onSessionExpired);

    // DISABLED: Extra monitoring services (keeping only original app_entry_point.dart logic)
    // _authMonitor.startMonitoring();
    // AuthMonitorService.setSessionExpiredCallback(_handleSessionExpired);
    // _heartbeat.startHeartbeat();

    // Listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  // App lifecycle handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 SessionManager: App resumed - checking auth status');
      // Force an immediate auth check when app resumes
      _authMonitor.checkAuthenticationNow();
    }
  }

  @override
  void dispose() {
    // DISABLED: Using only original app_entry_point.dart session logic
    // _sessionTimer.showWarning.removeListener(_onShowWarning);
    // _sessionTimer.sessionExpired.removeListener(_onSessionExpired);
    // _sessionTimer.stopSessionTimer();

    // DISABLED: Extra monitoring services
    // _authMonitor.stopMonitoring();
    // _heartbeat.stopHeartbeat();

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActivityDetector(child: widget.child);
  }
}
