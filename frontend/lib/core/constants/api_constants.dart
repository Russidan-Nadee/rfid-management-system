// Path: frontend/lib/core/constants/api_constants.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class ApiConstants {
  // Environment Configuration
  static const String _devHost = 'localhost';
  static const String _devPort = '3000';
  static const String _prodHost = 'your-api.com';
  static const String _apiVersion = 'api/v1';

  // **เพิ่มตัวแปรสำหรับ manual control**
  static String? _manualIP;
  static bool _forceRealDevice = false;

  // Base URL with Smart Detection
  static String get baseUrl {
    final host = kDebugMode ? _getDevHost() : _prodHost;
    final port = kDebugMode ? _devPort : '443';
    final protocol = kDebugMode ? 'http' : 'https';

    return '$protocol://$host:$port/$_apiVersion';
  }

  // **Simple device detection**
  static String _getDevHost() {
    // Manual override
    if (_manualIP != null) {
      return _manualIP!;
    }

    if (kIsWeb) {
      return _devHost; // localhost สำหรับ web
    } else if (Platform.isAndroid) {
      // Simple detection: emulator vs real device
      if (_forceRealDevice || _isLikelyRealDevice()) {
        return _getRealDeviceIP();
      } else {
        return '10.0.2.2'; // Android Emulator default
      }
    } else {
      return _devHost; // iOS/Desktop ใช้ localhost
    }
  }

  // **Simple real device detection**
  static bool _isLikelyRealDevice() {
    // ตรวจสอบ environment variables ง่ายๆ
    final env = Platform.environment;

    // ถ้ามี ANDROID_EMULATOR แสดงว่าเป็น emulator
    if (env.containsKey('ANDROID_EMULATOR')) return false;

    // ถ้า model มี sdk แสดงว่าเป็น emulator
    final model = env['ANDROID_PRODUCT_MODEL'] ?? '';
    if (model.toLowerCase().contains('sdk')) return false;

    // Default: assume real device (user can override)
    return true;
  }

  // **Get IP for real device - แก้เป็น IP จริง**
  static String _getRealDeviceIP() {
    // Try common development IPs
    return '172.101.35.153'; // <-- แก้เป็น IP จริงของ Laptop
  }

  // **Manual control methods**
  static void setManualIP(String ip) {
    _manualIP = ip;
    print('API: Manual IP set to $ip');
  }

  static void useEmulator() {
    _manualIP = null;
    _forceRealDevice = false;
    print('API: Switched to emulator mode (10.0.2.2)');
  }

  static void useRealDevice([String? ip]) {
    _forceRealDevice = true;
    if (ip != null) {
      _manualIP = ip;
    }
    print('API: Switched to real device mode (${ip ?? _getRealDeviceIP()})');
  }

  static void autoDetect() {
    _manualIP = null;
    _forceRealDevice = false;
    print('API: Switched to auto-detect mode');
  }

  // **Alternative: Custom Base URL**
  static String customBaseUrl({
    String? host,
    String? port,
    bool useHttps = false,
  }) {
    final targetHost = host ?? _getDevHost();
    final targetPort = port ?? _devPort;
    final protocol = useHttps ? 'https' : 'http';

    return '$protocol://$targetHost:$targetPort/$_apiVersion';
  }

  // **Debug Helper**
  static void printCurrentConfig() {
    if (kDebugMode) {
      print('=== API Configuration ===');
      print('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');

      if (Platform.isAndroid) {
        print('Manual IP: ${_manualIP ?? 'None'}');
        print('Force Real Device: $_forceRealDevice');
        print(
          'Detected Mode: ${_isLikelyRealDevice() ? 'Real Device' : 'Emulator'}',
        );
      }

      print('Current Host: ${_getDevHost()}');
      print('Base URL: $baseUrl');
      print('Environment: ${kDebugMode ? 'Development' : 'Production'}');
      print('========================');
    }
  }

  // **Quick IP changer for testing**
  static void tryCommonIPs() {
    final commonIPs = [
      '172.101.35.153', // IP ปัจจุบัน
      '192.168.1.100',
      '192.168.0.100',
      '192.168.1.10',
      '192.168.0.10',
      '10.0.0.100',
    ];

    print('Common IPs to try:');
    for (int i = 0; i < commonIPs.length; i++) {
      print('${i + 1}. ${commonIPs[i]}');
    }
    print('Use: ApiConstants.setManualIP("172.101.35.153")');
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
  static const String categories = '/categories';
  static const String brands = '/brands';
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
  static String scanAssetDetailByEpc(String epcCode) => '/scan/epc/$epcCode';
  static String scanAssetCheckByEpc(String epcCode) =>
      '/scan/epc/$epcCode/check';

  // Scan Logging
  static const String scanLog = '$scanBase/log';
  static const String scanMock = '$scanBase/mock';

  // ✅ FIXED: Image Management APIs - แก้ไข paths ให้ตรงกับ backend
  static String assetImages(String assetNo) => '/assets/$assetNo/images';
  static String serveImage(int imageId) => '/images/$imageId';
  static String uploadAssetImages(String assetNo) => '/assets/$assetNo/images';
  static String deleteAssetImage(String assetNo, int imageId) =>
      '/assets/$assetNo/images/$imageId';
  static String replaceAssetImage(String assetNo, int imageId) =>
      '/assets/$assetNo/images/$imageId';
  static String updateImageMetadata(String assetNo, int imageId) =>
      '/assets/$assetNo/images/$imageId';
  static String setPrimaryImage(String assetNo, int imageId) =>
      '/assets/$assetNo/images/$imageId/primary';
  static String getImageStats(String assetNo) =>
      '/assets/$assetNo/images/stats';

  // ❌ REMOVED: Image Search & System APIs - ลบออกเพราะ backend ไม่มี
  // static String get searchImages => '/images/search';
  // static String get imageSystemStats => '/images/system/stats';
  // static String get cleanupImages => '/images/cleanup';
  // static String get batchUpdateImages => '/images/batch/update';
  // static String get imageSystemHealth => '/images/system/health';
  // static String get imageDocs => '/images/docs';
  // static String get imageHealth => '/images/health';

  // Export Endpoints
  static const String exportBase = '/export';
  static const String exportJobs = '$exportBase/jobs';
  static const String exportHistory = '$exportBase/history';
  static const String exportStats = '$exportBase/stats';
  static const String exportCleanup = '$exportBase/cleanup';

  // Helper Methods
  static String plantAssets(String plantCode) => '$plants/$plantCode/assets';
  static String locationAssets(String locationCode) =>
      '/assets?location_code=$locationCode';
  static String plantLocations(String plantCode) =>
      '$plants/$plantCode/locations';

  // Export Actions
  static String exportJobStatus(int exportId) => '$exportJobs/$exportId';
  static String exportDownload(int exportId) =>
      '$exportBase/download/$exportId';
  static String exportJobCancel(int exportId) => '$exportJobs/$exportId';
  static String exportJobDelete(int exportId) => '$exportJobs/$exportId';

  // Notification Endpoints
  static const String notificationBase = '/notifications';
  static const String reportProblem = '$notificationBase/report-problem';
  static const String notificationCounts = '$notificationBase/counts';
  static String notificationById(int id) => '$notificationBase/$id';
  static String updateNotificationStatus(int id) => '$notificationBase/$id/status';
  static String assetNotifications(String assetNo) => '$notificationBase/asset/$assetNo';
}
