// Path: frontend/lib/di/injection.dart
import 'package:get_it/get_it.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import 'auth_injection.dart';
import 'scan_injection.dart';

// Global GetIt instance
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> configureDependencies() async {
  // Core Services - Singletons (single instance throughout app)
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<ApiService>(ApiService());

  // Initialize storage service
  await getIt<StorageService>().init();

  // Configure feature dependencies
  configureAuthDependencies();
  configureScanDependencies();
}

/// Reset all dependencies (useful for testing)
void resetDependencies() {
  getIt.reset();
}

/// Check if dependencies are registered (for debugging)
void debugDependencies() {
  print('=== Registered Dependencies ===');
  print('StorageService: ${getIt.isRegistered<StorageService>()}');
  print('ApiService: ${getIt.isRegistered<ApiService>()}');

  // Auth Dependencies
  debugAuthDependencies();

  // Scan Dependencies
  debugScanDependencies();

  print('==============================');
}

/// Dispose resources when app is closed
void disposeDependencies() {
  // Dispose API service
  if (getIt.isRegistered<ApiService>()) {
    getIt<ApiService>().dispose();
  }

  // Reset all dependencies
  getIt.reset();
}
