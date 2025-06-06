// Path: frontend/lib/di/injection.dart
import 'package:get_it/get_it.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import 'auth_injection.dart';
import 'scan_injection.dart';
import 'settings_injection.dart';
import 'export_injection.dart';

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
  configureSettingsDependencies();
  configureExportDependencies();

  // Debug dependencies in development
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    debugDependencies();
  }
}

/// Reset all dependencies (useful for testing)
void resetDependencies() {
  getIt.reset();
}

/// Check if dependencies are registered (for debugging)
void debugDependencies() {
  // Auth Dependencies

  // Scan Dependencies
  debugScanDependencies();

  // Settings Dependencies
  debugSettingsDependencies();

  // Export Dependencies
  debugExportDependencies(); // เพิ่มบรรทัดนี้
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
