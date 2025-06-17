// Path: frontend/lib/features/dashboard/data/datasources/dashboard_cache_datasource.dart
import 'dart:convert';
import 'package:frontend/features/dashboard/data/models/overview_data_model.dart';
import 'package:frontend/features/dashboard/data/models/department_analytics_model.dart';
import 'package:frontend/features/dashboard/data/models/growth_trends_model.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../models/alert_model.dart';
import '../models/recent_activity_model.dart';

abstract class DashboardCacheDataSource {
  Future<DashboardStatsModel?> getCachedStats(String period);
  Future<void> cacheStats(DashboardStatsModel stats, String period);
  Future<OverviewDataModel?> getCachedOverview(String period);
  Future<void> cacheOverview(OverviewDataModel overview, String period);
  Future<List<AlertModel>?> getCachedAlerts();
  Future<void> cacheAlerts(List<AlertModel> alerts);
  Future<RecentActivityModel?> getCachedRecentActivities(String period);
  Future<void> cacheRecentActivities(
    RecentActivityModel activities,
    String period,
  );

  // Enhanced Dashboard Cache Methods
  Future<DepartmentAnalyticsModel?> getCachedDepartmentAnalytics(
    String cacheKey,
  );
  Future<void> cacheDepartmentAnalytics(
    DepartmentAnalyticsModel analytics,
    String cacheKey,
  );
  Future<GrowthTrendsModel?> getCachedGrowthTrends(String cacheKey);
  Future<void> cacheGrowthTrends(GrowthTrendsModel trends, String cacheKey);
  Future<Map<String, dynamic>?> getCachedLocationAnalytics(String cacheKey);
  Future<void> cacheLocationAnalytics(
    Map<String, dynamic> analytics,
    String cacheKey,
  );
  Future<Map<String, dynamic>?> getCachedAuditProgress(String cacheKey);
  Future<void> cacheAuditProgress(
    Map<String, dynamic> progress,
    String cacheKey,
  );

  Future<bool> isCacheValid(String cacheKey);
  Future<void> clearCache();
  Future<void> clearPeriodCache(String period);
  Future<void> clearEnhancedCache();
}

class DashboardCacheDataSourceImpl implements DashboardCacheDataSource {
  final StorageService storageService;

  static const String _statsKeyPrefix = 'dashboard_stats_';
  static const String _overviewKeyPrefix = 'dashboard_overview_';
  static const String _alertsKey = 'dashboard_alerts';
  static const String _recentKeyPrefix = 'dashboard_recent_';

  // Enhanced Dashboard Cache Keys
  static const String _departmentAnalyticsPrefix = 'dashboard_dept_analytics_';
  static const String _growthTrendsPrefix = 'dashboard_growth_trends_';
  static const String _locationAnalyticsPrefix =
      'dashboard_location_analytics_';
  static const String _auditProgressPrefix = 'dashboard_audit_progress_';

  static const String _timestampSuffix = '_timestamp';
  static const Duration _cacheTimeout = Duration(minutes: 5);
  static const Duration _alertsCacheTimeout = Duration(minutes: 2);
  static const Duration _enhancedCacheTimeout = Duration(
    minutes: 10,
  ); // Longer for complex data

  DashboardCacheDataSourceImpl(this.storageService);

  String _getStatsKey(String period) => '$_statsKeyPrefix$period';
  String _getOverviewKey(String period) => '$_overviewKeyPrefix$period';
  String _getRecentKey(String period) => '$_recentKeyPrefix$period';
  String _getDepartmentAnalyticsKey(String plantCode) =>
      '$_departmentAnalyticsPrefix$plantCode';
  String _getGrowthTrendsKey(String params) => '$_growthTrendsPrefix$params';
  String _getLocationAnalyticsKey(String params) =>
      '$_locationAnalyticsPrefix$params';
  String _getAuditProgressKey(String params) => '$_auditProgressPrefix$params';
  String _getTimestampKey(String cacheKey) => '$cacheKey$_timestampSuffix';

  @override
  Future<DashboardStatsModel?> getCachedStats(String period) async {
    try {
      final cacheKey = _getStatsKey(period);
      if (!await isCacheValid(cacheKey)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return DashboardStatsModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheStats(DashboardStatsModel stats, String period) async {
    try {
      final cacheKey = _getStatsKey(period);
      await storageService.setJson(cacheKey, stats.toJson());
      await storageService.setString(
        _getTimestampKey(cacheKey),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<OverviewDataModel?> getCachedOverview(String period) async {
    try {
      final cacheKey = _getOverviewKey(period);
      if (!await isCacheValid(cacheKey)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return OverviewDataModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheOverview(OverviewDataModel overview, String period) async {
    try {
      final cacheKey = _getOverviewKey(period);
      await storageService.setJson(cacheKey, overview.toJson());
      await storageService.setString(
        _getTimestampKey(cacheKey),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<AlertModel>?> getCachedAlerts() async {
    try {
      if (!await _isAlertsCacheValid()) {
        return null;
      }

      final cachedString = storageService.getString(_alertsKey);
      if (cachedString != null) {
        final decoded = jsonDecode(cachedString);
        if (decoded is List) {
          final alertsList = decoded as List<dynamic>;
          return alertsList
              .map((item) => AlertModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheAlerts(List<AlertModel> alerts) async {
    try {
      final alertsJson = alerts.map((alert) => alert.toJson()).toList();
      await storageService.setString(_alertsKey, jsonEncode(alertsJson));
      await storageService.setString(
        _getTimestampKey(_alertsKey),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<RecentActivityModel?> getCachedRecentActivities(String period) async {
    try {
      final cacheKey = _getRecentKey(period);
      if (!await isCacheValid(cacheKey)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return RecentActivityModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheRecentActivities(
    RecentActivityModel activities,
    String period,
  ) async {
    try {
      final cacheKey = _getRecentKey(period);
      await storageService.setJson(cacheKey, activities.toJson());
      await storageService.setString(
        _getTimestampKey(cacheKey),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  // Enhanced Dashboard Cache Methods Implementation
  @override
  Future<DepartmentAnalyticsModel?> getCachedDepartmentAnalytics(
    String cacheKey,
  ) async {
    try {
      if (!await _isEnhancedCacheValid(cacheKey)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return DepartmentAnalyticsModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheDepartmentAnalytics(
    DepartmentAnalyticsModel analytics,
    String cacheKey,
  ) async {
    try {
      await storageService.setJson(cacheKey, analytics.toJson());
      await storageService.setString(
        _getTimestampKey(cacheKey),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<GrowthTrendsModel?> getCachedGrowthTrends(String cacheKey) async {
    try {
      if (!await _isEnhancedCacheValid(cacheKey)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return GrowthTrendsModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheGrowthTrends(
    GrowthTrendsModel trends,
    String cacheKey,
  ) async {
    try {
      await storageService.setJson(cacheKey, trends.toJson());
      await storageService.setString(
        _getTimestampKey(cacheKey),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedLocationAnalytics(
    String cacheKey,
  ) async {
    try {
      if (!await _isEnhancedCacheValid(cacheKey)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      return cachedData;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheLocationAnalytics(
    Map<String, dynamic> analytics,
    String cacheKey,
  ) async {
    try {
      await storageService.setJson(cacheKey, analytics);
      await storageService.setString(
        _getTimestampKey(cacheKey),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedAuditProgress(String cacheKey) async {
    try {
      if (!await _isEnhancedCacheValid(cacheKey)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      return cachedData;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheAuditProgress(
    Map<String, dynamic> progress,
    String cacheKey,
  ) async {
    try {
      await storageService.setJson(cacheKey, progress);
      await storageService.setString(
        _getTimestampKey(cacheKey),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> isCacheValid(String cacheKey) async {
    try {
      final timestampStr = storageService.getString(_getTimestampKey(cacheKey));
      if (timestampStr == null) return false;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return false;

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference < _cacheTimeout;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isAlertsCacheValid() async {
    try {
      final timestampStr = storageService.getString(
        _getTimestampKey(_alertsKey),
      );
      if (timestampStr == null) return false;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return false;

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference < _alertsCacheTimeout;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isEnhancedCacheValid(String cacheKey) async {
    try {
      final timestampStr = storageService.getString(_getTimestampKey(cacheKey));
      if (timestampStr == null) return false;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return false;

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference < _enhancedCacheTimeout;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final periods = ['today', '7d', '30d'];

      // Clear all period-based caches
      for (final period in periods) {
        await clearPeriodCache(period);
      }

      // Clear alerts cache
      await storageService.remove(_alertsKey);
      await storageService.remove(_getTimestampKey(_alertsKey));

      // Clear enhanced dashboard cache
      await clearEnhancedCache();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearPeriodCache(String period) async {
    try {
      final statsKey = _getStatsKey(period);
      final overviewKey = _getOverviewKey(period);
      final recentKey = _getRecentKey(period);

      await Future.wait([
        storageService.remove(statsKey),
        storageService.remove(_getTimestampKey(statsKey)),
        storageService.remove(overviewKey),
        storageService.remove(_getTimestampKey(overviewKey)),
        storageService.remove(recentKey),
        storageService.remove(_getTimestampKey(recentKey)),
      ]);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearEnhancedCache() async {
    try {} catch (e) {
      throw CacheException();
    }
  }

  // Helper methods for cache key generation
  String generateDepartmentAnalyticsCacheKey({String? plantCode}) {
    return _getDepartmentAnalyticsKey(plantCode ?? 'all');
  }

  String generateGrowthTrendsCacheKey({
    String? deptCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
  }) {
    final params = [
      if (deptCode != null) 'dept:$deptCode',
      'period:$period',
      if (year != null) 'year:$year',
      if (startDate != null && endDate != null) 'custom:$startDate-$endDate',
    ].join('_');
    return _getGrowthTrendsKey(params);
  }

  String generateLocationAnalyticsCacheKey({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
  }) {
    final params = [
      if (locationCode != null) 'loc:$locationCode',
      'period:$period',
      if (year != null) 'year:$year',
      if (startDate != null && endDate != null) 'custom:$startDate-$endDate',
      'trends:$includeTrends',
    ].join('_');
    return _getLocationAnalyticsKey(params);
  }

  String generateAuditProgressCacheKey({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
  }) {
    final params = [
      if (deptCode != null) 'dept:$deptCode',
      'details:$includeDetails',
      if (auditStatus != null) 'status:$auditStatus',
    ].join('_');
    return _getAuditProgressKey(params);
  }
}
