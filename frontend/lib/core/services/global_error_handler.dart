import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../errors/exceptions.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class GlobalErrorHandler {
  static void handleError(dynamic error, BuildContext? context) {
    print('🔍 GlobalErrorHandler: Handling error: ${error.runtimeType}');
    
    if (error is SessionExpiredException || error is UnauthorizedException) {
      print('🚨 GlobalErrorHandler: Authentication error detected - forcing logout');
      _forceLogout(context);
    } else if (error is AppException) {
      print('⚠️ GlobalErrorHandler: App exception: ${error.message}');
      _showErrorDialog(context, error.message);
    } else {
      print('❌ GlobalErrorHandler: Unknown error: $error');
      _showErrorDialog(context, 'An unexpected error occurred');
    }
  }

  static void _forceLogout(BuildContext? context) {
    if (context != null && context.mounted) {
      try {
        context.read<AuthBloc>().add(const LogoutRequested());
      } catch (e) {
        print('❌ GlobalErrorHandler: Failed to trigger logout: $e');
      }
    }
  }

  static void _showErrorDialog(BuildContext? context, String message) {
    if (context != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// Extension to make error handling easier
extension ErrorHandlerExtension on BuildContext {
  void handleError(dynamic error) {
    GlobalErrorHandler.handleError(error, this);
  }
}