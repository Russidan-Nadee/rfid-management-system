// Path: frontend/lib/core/services/browser_api.dart

/// Central browser API abstraction with conditional platform exports
/// This file provides the correct implementation based on the target platform
/// at compile time, eliminating runtime platform checks for imports.

// Export the contract interface for type checking
export 'browser_api_contract.dart';

// Conditional imports - the compiler will choose the correct one at compile time
import 'browser_api_factory_web.dart' if (dart.library.io) 'browser_api_factory_io.dart' as platform_factory;
import 'browser_api_contract.dart';

/// Factory function to create the appropriate BrowserApi implementation
/// This is resolved at compile time based on the target platform
BrowserApi createBrowserApi() => platform_factory.createBrowserApi();

/// Singleton service for browser API access
/// Provides a single instance throughout the app lifecycle
class BrowserApiService {
  static BrowserApi? _instance;
  
  /// Get the singleton BrowserApi instance
  static BrowserApi get instance {
    _instance ??= createBrowserApi();
    return _instance!;
  }
  
  /// Reset the instance (useful for testing)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
  
  /// Initialize with a custom instance (useful for testing)
  static void initialize(BrowserApi api) {
    _instance?.dispose();
    _instance = api;
  }
}