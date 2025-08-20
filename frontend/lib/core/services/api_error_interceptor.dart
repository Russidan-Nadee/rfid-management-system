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
    print('✅ ApiErrorInterceptor: AuthBloc set successfully');
  }
  
  /// Set the navigator key for direct navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    print('✅ ApiErrorInterceptor: NavigatorKey set successfully');
  }
  
  /// Intercept and handle all API errors globally
  static void handleError(dynamic error, {String? source}) {
    final errorSource = source ?? 'Unknown';
    print('🔍 ApiErrorInterceptor: Handling error from $errorSource');
    print('🔍 Error type: ${error.runtimeType}');
    print('🔍 Error details: $error');
    
    // Check for authentication-related errors
    if (_isAuthenticationError(error)) {
      print('🚨 ApiErrorInterceptor: Authentication error detected - forcing immediate redirect');
      _forceLoginRedirect();
    } else {
      print('ℹ️ ApiErrorInterceptor: Non-auth error, not triggering logout');
    }
  }
  
  /// Check if the error is authentication-related
  static bool _isAuthenticationError(dynamic error) {
    if (error is SessionExpiredException) {
      print('✅ Detected SessionExpiredException');
      return true;
    }
    
    if (error is UnauthorizedException) {
      print('✅ Detected UnauthorizedException');
      return true;
    }
    
    if (error is ApiException && error.statusCode == 401) {
      print('✅ Detected 401 ApiException');
      return true;
    }
    
    // Check error message for auth-related keywords
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('session expired') ||
        errorString.contains('unauthorized') ||
        errorString.contains('token expired') ||
        errorString.contains('401')) {
      print('✅ Detected auth error by message content');
      return true;
    }
    
    return false;
  }
  
  /// Force immediate redirect to login page
  static void _forceLoginRedirect() {
    print('🚨 ApiErrorInterceptor: FORCE REDIRECT TO LOGIN');
    
    // Method 1: Try direct navigation
    if (_navigatorKey?.currentState != null) {
      print('🚨 Method 1: Using Navigator to push LoginPage');
      _navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      return;
    }
    
    // Method 2: Trigger AuthBloc logout
    if (_authBloc != null) {
      print('🚨 Method 2: Triggering logout via AuthBloc');
      _authBloc!.add(const LogoutRequested());
    }
    
    // Method 3: Force page reload (web only)
    if (kIsWeb) {
      print('🚨 Method 3: Force page reload');
      // You can uncomment this if needed:
      // html.window.location.reload();
    }
  }
  
  /// Manual logout trigger for testing
  static void forceLogout() {
    print('🧪 ApiErrorInterceptor: Manual force logout triggered');
    _forceLoginRedirect();
  }
}