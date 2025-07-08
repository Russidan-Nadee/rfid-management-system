import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class ApiConstants {
  // Environment Configuration
  static const String _devHost = 'localhost';
  static const String _devPort = '3000';
  static const String _prodHost = 'your-api.com'; // Change for production
  static const String _apiVersion = 'api/v1';

  // Base URL with Environment Support
  static String get baseUrl {
    final host = kDebugMode ? _devHost : _prodHost;
    final port = kDebugMode ? _devPort : '443';
    final protocol = kDebugMode ? 'http' : 'https';

    if (kIsWeb) {
      return '$protocol://$host:$port/$_apiVersion';
    } else if (Platform.isAndroid) {
      // Android Emulator maps localhost to 10.0.2.2
      final androidHost = kDebugMode ? '10.0.2.2' : _prodHost;
      return '$protocol://$androidHost:$port/$_apiVersion';
    } else {
      return '$protocol://$host:$port/$_apiVersion';
    }
  }

  // Alternative: Manual Override (for testing different environments)
  static String customBaseUrl({
    String? host,
    String? port,
    bool useHttps = false,
  }) {
    final targetHost =
        host ?? (kIsWeb || !Platform.isAndroid ? 'localhost' : '10.0.2.2');
    final targetPort = port ?? '3000';
    final protocol = useHttps ? 'https' : 'http';

    return '$protocol://$targetHost:$targetPort/$_apiVersion';
  }

  static const Duration timeout = Duration(seconds: 30);

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

  // Scan Endpoints
  static const String scanBase = '/scan';
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

  // Helper Methods
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

  // Debug Helper
  static void printCurrentConfig() {
    if (kDebugMode) {
      print('=== API Configuration ===');
      print('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');
      print('Base URL: $baseUrl');
      print('Environment: ${kDebugMode ? 'Development' : 'Production'}');
      print('========================');
    }
  }
}
