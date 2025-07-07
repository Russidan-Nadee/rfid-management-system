// Path: frontend/lib/core/constants/api_constants.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base Configuration
  static String get baseUrl {
    if (kIsWeb) {
      // Web Browser
      return 'http://localhost:3000/api/v1';
    } else if (Platform.isAndroid) {
      // Android Emulator/Device
      return 'http://10.0.2.2:3000/api/v1';
    } else if (Platform.isIOS) {
      // iOS Simulator/Device
      return 'http://localhost:3000/api/v1';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Desktop Apps (Windows/Mac/Linux)
      return 'http://localhost:3000/api/v1';
    } else {
      // Fallback
      return 'http://localhost:3000/api/v1';
    }
  }

  static const Duration timeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth Endpoints
  static const String authBase = '/auth';
  static const String login = '$authBase/login';
  static const String logout = '$authBase/logout';
  static const String profile = '$authBase/me';
  static const String refreshToken = '$authBase/refresh';
  static const String changePassword = '$authBase/change-password';

  // Dashboard Endpoints
  static const String dashboardBase = '/dashboard';
  static const String dashboardStats = '$dashboardBase/stats';
  static const String dashboardOverview = '$dashboardBase/overview';
  static const String dashboardAssetsByPlant = '$dashboardBase/assets-by-plant';
  static const String dashboardGrowthTrends = '$dashboardBase/growth-trends';
  static const String dashboardLocationAnalytics =
      '$dashboardBase/location-analytics';
  static const String dashboardAuditProgress = '$dashboardBase/audit-progress';
  static const String dashboardLocations = '/dashboard/locations';

  // Master Data Endpoints
  static const String plants = '/plants';
  static const String locations = '/locations';
  static const String units = '/units';
  static const String users = '/users';

  // ===== SCAN ENDPOINTS (UPDATED) =====
  static const String scanBase = '/scan';

  // Scan Asset Operations
  static const String scanAssetCreate = '$scanBase/asset/create';
  static const String scanAssetsMock = '$scanBase/assets/mock';
  static String scanAssetDetail(String assetNo) => '$scanBase/asset/$assetNo';
  static String scanAssetCheck(String assetNo) =>
      '$scanBase/asset/$assetNo/check';
  static String scanAssetStatusHistory(String assetNo) =>
      '$scanBase/asset/$assetNo/status/history';

  // Scan Logging
  static const String scanLog = '$scanBase/log';
  static const String scanMock = '$scanBase/mock';

  // Export Endpoints
  static const String exportBase = '/export';
  static const String exportJobs = '$exportBase/jobs';
  static const String exportHistory = '$exportBase/history';
  static const String exportStats = '$exportBase/stats';
  static const String exportCleanup = '$exportBase/cleanup';

  // Plant/Location Actions for Scan
  static String plantAssets(String plantCode) => '$plants/$plantCode/assets';
  static String locationAssets(String locationCode) =>
      '$locations/$locationCode/assets';
  static String plantLocations(String plantCode) =>
      '$plants/$plantCode/locations';

  // Export Actions
  static String exportJobStatus(int exportId) => '$exportJobs/$exportId';
  static String exportDownload(int exportId) =>
      '$exportBase/download/$exportId';
  static String exportJobCancel(int exportId) => '$exportJobs/$exportId';
  static String exportJobDelete(int exportId) => '$exportJobs/$exportId';

  // ===== LEGACY SUPPORT (DEPRECATED) =====
  // Keep old constants for backward compatibility during transition
  @deprecated
  static const String assets = '/scan/asset'; // Will be removed in next version
  @deprecated
  static const String assetNumbers = '/scan/assets/mock'; // Will be removed in next version
  @deprecated
  static String assetDetail(String assetNo) => scanAssetDetail(assetNo);
  @deprecated
  static String assetUpdateStatus(String assetNo) => scanAssetCheck(assetNo);
}
