import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../errors/exceptions.dart';

/// Global API error interceptor to catch ALL authentication errors
class ApiErrorInterceptor {
  static AuthBloc? _authBloc;
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  /// Set the AuthBloc instance for triggering logout
  static void setAuthBloc(AuthBloc authBloc) {
    _authBloc = authBloc;
  }
  
  /// Set the navigator key for direct navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }
  
  /// Intercept and handle all API errors globally
  static void handleError(dynamic error, {String? source}) {
    // Check for authentication-related errors
    if (_isAuthenticationError(error)) {
      _forceLoginRedirect();
    }
  }
  
  /// Check if the error is authentication-related
  static bool _isAuthenticationError(dynamic error) {
    if (error is SessionExpiredException) {
      return true;
    }
    
    if (error is UnauthorizedException) {
      // Don't force logout for UnauthorizedException - let API service handle token refresh
      return false;
    }
    
    if (error is ApiException && error.statusCode == 401) {
      return true;
    }
    
    // Check error message for auth-related keywords
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('session expired') ||
        errorString.contains('unauthorized') ||
        errorString.contains('token expired') ||
        errorString.contains('401')) {
      return true;
    }
    
    return false;
  }
  
  /// Force immediate redirect to login page
  static void _forceLoginRedirect() {
    // Method 1: Try direct navigation
    if (_navigatorKey?.currentState != null) {
      _navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      return;
    }
    
    // Method 2: Trigger AuthBloc logout
    if (_authBloc != null) {
      _authBloc!.add(const LogoutRequested());
    }
    
    // Method 3: Force page reload (web only)
    if (kIsWeb) {
      // You can uncomment this if needed:
      // html.window.location.reload();
    }
  }
  
  /// Manual logout trigger for testing
  static void forceLogout() {
    _forceLoginRedirect();
  }
}