import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import 'auth_monitor_service.dart';
import 'global_error_handler.dart';

class AuthTestHelper {
  static Widget createTestButton(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _simulateSessionExpiration(context),
          child: const Text('Simulate Session Expiry'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _forceAuthCheck(context),
          child: const Text('Force Auth Check'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _simulateAppResume(context),
          child: const Text('Simulate App Resume'),
        ),
      ],
    );
  }

  static void _simulateSessionExpiration(BuildContext context) {
    print('🧪 Testing: Simulating session expiration');
    
    // Simulate what happens when session expires
    GlobalErrorHandler.handleError(
      SessionExpiredException('Test session expiration'),
      context,
    );
  }

  static void _forceAuthCheck(BuildContext context) {
    print('🧪 Testing: Force authentication check');
    
    final authMonitor = AuthMonitorService();
    authMonitor.checkAuthenticationNow().then((result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result 
            ? 'Authentication check passed' 
            : 'Authentication check failed'),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
    });
  }

  static void _simulateAppResume(BuildContext context) {
    print('🧪 Testing: Simulating app resume after sleep');
    
    // This would normally be called by the system
    final authMonitor = AuthMonitorService();
    authMonitor.didChangeAppLifecycleState(AppLifecycleState.resumed);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulated app resume - check logs for auth verification'),
      ),
    );
  }
}

// Import this in SessionExpiredException if not already there
class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);
  
  @override
  String toString() => 'SessionExpiredException: $message';
}