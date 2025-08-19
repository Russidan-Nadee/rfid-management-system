import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/session_timer_service.dart';
import '../services/auth_monitor_service.dart';
import '../services/activity_monitor_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import 'session_timeout_dialog.dart';

class SessionManager extends StatefulWidget {
  final Widget child;

  const SessionManager({
    super.key,
    required this.child,
  });

  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager> with WidgetsBindingObserver {
  final SessionTimerService _sessionTimer = SessionTimerService();
  final AuthMonitorService _authMonitor = AuthMonitorService();
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _sessionTimer.startSessionTimer();
    
    _sessionTimer.showWarning.addListener(_onShowWarning);
    _sessionTimer.sessionExpired.addListener(_onSessionExpired);
    
    // Start monitoring authentication status
    _authMonitor.startMonitoring();
    AuthMonitorService.setSessionExpiredCallback(_handleSessionExpired);
    
    // Listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  void _onShowWarning() {
    if (_sessionTimer.showWarning.value && !_dialogShown) {
      _showTimeoutDialog();
    }
  }

  void _onSessionExpired() {
    if (_sessionTimer.sessionExpired.value) {
      _handleSessionExpired();
    }
  }

  void _showTimeoutDialog() {
    if (_dialogShown) return;
    
    setState(() {
      _dialogShown = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionTimeoutDialog(
        onExtend: () {
          _sessionTimer.extendSession();
          Navigator.of(context).pop();
          setState(() {
            _dialogShown = false;
          });
        },
        onLogout: () {
          Navigator.of(context).pop();
          _handleLogout();
        },
      ),
    ).then((_) {
      setState(() {
        _dialogShown = false;
      });
    });
  }

  void _handleSessionExpired() {
    if (_dialogShown) {
      Navigator.of(context).pop();
      setState(() {
        _dialogShown = false;
      });
    }
    
    _showSessionExpiredDialog();
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Session Expired'),
          ],
        ),
        content: const Text(
          'Your session has expired due to inactivity. Please login again to continue.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout();
            },
            child: const Text('Login Again'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    _sessionTimer.stopSessionTimer();
    context.read<AuthBloc>().add(const LogoutRequested());
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
    _sessionTimer.showWarning.removeListener(_onShowWarning);
    _sessionTimer.sessionExpired.removeListener(_onSessionExpired);
    _sessionTimer.stopSessionTimer();
    
    // Stop authentication monitoring
    _authMonitor.stopMonitoring();
    
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActivityDetector(
      child: widget.child,
    );
  }
}