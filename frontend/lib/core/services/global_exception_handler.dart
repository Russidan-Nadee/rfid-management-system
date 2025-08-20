import 'package:flutter/foundation.dart';
import 'api_error_interceptor.dart';

/// Global exception handler for catching ANY unhandled authentication errors
class GlobalExceptionHandler {
  
  /// Set up global error handling
  static void initialize() {
    if (kDebugMode) {
      print('🔧 GlobalExceptionHandler: Initializing global error handling');
    }
    
    // Catch any unhandled errors in Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      // Check if this might be an auth-related error
      final error = details.exception;
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('401') || 
          errorString.contains('unauthorized') ||
          errorString.contains('session') ||
          errorString.contains('token')) {
        
        print('🚨 GlobalExceptionHandler: Potential auth error caught in Flutter error handler');
        print('🔍 Error: $error');
        
        // Pass to error interceptor
        ApiErrorInterceptor.handleError(error, source: 'FlutterError.onError');
      }
      
      // Still report the error normally
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };
  }
  
  /// Manually handle any error - call this from catch blocks
  static void handleError(dynamic error, {String? source}) {
    final errorSource = source ?? 'Manual';
    
    if (kDebugMode) {
      print('🔍 GlobalExceptionHandler: Handling error from $errorSource');
      print('🔍 Error: $error');
    }
    
    // Always pass to API error interceptor
    ApiErrorInterceptor.handleError(error, source: errorSource);
  }
}