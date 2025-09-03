// Path: frontend/lib/di/injection.dart
import 'package:tp_rfid/di/dashboard_injection.dart';
import 'package:tp_rfid/di/search_injection.dart';
import 'package:get_it/get_it.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/notification_service.dart';
import 'auth_injection.dart';
import 'scan_injection.dart';
import 'settings_injection.dart';
import 'export_injection.dart';
import 'reports_injection.dart';

// Global GetIt instance
final getIt = GetIt.instance;

/// Initialize all dependenciesplea
Future<void> configureDependencies() async {
  // Core Services - Singletons (single instance throughout app)
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<ApiService>(ApiService());
  getIt.registerSingleton<NotificationService>(
    NotificationService(getIt<ApiService>()),
  );

  // Initialize storage service
  await getIt<StorageService>().init();

  // Configure feature dependencies
  configureAuthDependencies();
  configureScanDependencies();
  configureSettingsDependencies();
  configureExportDependencies();
  configureSearchDependencies();
  configureDashboardDependencies();
  configureReportsDependencies();

  if (const bool.fromEnvironment('dart.vm.product') == false) {}
}

void resetDependencies() {
  getIt.reset();
}
