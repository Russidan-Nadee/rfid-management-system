// Path: frontend/lib/core/constants/api_constants.dart
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base Configuration
  static String get baseUrl {
    if (kIsWeb) {
      // สำหรับ Web (Chrome) ให้ใช้ localhost
      return 'http://localhost:3000/api/v1';
    } else {
      return 'http://10.0.2.2:3000/api/v1'; // Default สำหรับ Android Emulator
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

  // Master Data Endpoints
  static const String plants = '/plants';
  static const String locations = '/locations';
  static const String units = '/units';
  static const String users = '/users';

  // Asset Endpoints
  static const String assets = '/assets';
  static const String assetSearch = '$assets/search';
  static const String assetStats = '$assets/stats';
  static const String assetNumbers = '$assets/numbers';
  static const String assetsByPlant = '$assets/stats/by-plant';
  static const String assetsByLocation = '$assets/stats/by-location';

  // Export Endpoints (NEW)
  static const String exportBase = '/export';
  static const String exportJobs = '$exportBase/jobs';
  static const String exportHistory = '$exportBase/history';
  static const String exportStats = '$exportBase/stats';
  static const String exportCleanup = '$exportBase/cleanup';

  // Scan Endpoints
  static const String scanLog = '/scan/log';
  static const String scanMock = '/scan/mock';

  // Asset Actions
  static String assetDetail(String assetNo) => '$assets/$assetNo';
  static String assetStatusHistory(String assetNo) =>
      '$assets/$assetNo/status/history';
  static String assetUpdateStatus(String assetNo) => '$assets/$assetNo/status';
  static String plantAssets(String plantCode) => '$plants/$plantCode/assets';
  static String locationAssets(String locationCode) =>
      '$locations/$locationCode/assets';
  static String plantLocations(String plantCode) =>
      '$plants/$plantCode/locations';

  // Export Actions (NEW)
  static String exportJobStatus(int exportId) => '$exportJobs/$exportId';
  static String exportDownload(int exportId) =>
      '$exportBase/download/$exportId';
  static String exportJobCancel(int exportId) => '$exportJobs/$exportId';
  static String exportJobDelete(int exportId) => '$exportJobs/$exportId';
}
