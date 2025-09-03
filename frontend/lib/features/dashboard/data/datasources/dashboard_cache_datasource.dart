// Path: frontend/lib/features/dashboard/data/datasources/dashboard_cache_datasource.dart
import 'package:tp_rfid/features/dashboard/data/models/location_analytics_model.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../models/asset_distribution_model.dart';
import '../models/growth_trend_model.dart';
import '../models/audit_progress_model.dart';

abstract class DashboardCacheDataSource {
  Future<void> cacheDashboardStats(String period, DashboardStatsModel stats);
  Future<DashboardStatsModel?> getCachedDashboardStats(String period);
  Future<void> cacheAssetDistribution(
    String key,
    AssetDistributionModel distribution,
  );
  Future<AssetDistributionModel?> getCachedAssetDistribution(String key);
  Future<void> cacheGrowthTrends(String key, GrowthTrendModel trends);
  Future<GrowthTrendModel?> getCachedGrowthTrends(String key);
  Future<void> cacheAuditProgress(String key, AuditProgressModel progress);
  Future<AuditProgressModel?> getCachedAuditProgress(String key);
  Future<void> clearDashboardCache();
  Future<void> cacheLocationAnalytics(
    String key,
    LocationAnalyticsModel analytics,
  );
  Future<LocationAnalyticsModel?> getCachedLocationAnalytics(String key);
  bool isCacheValid(String key, Duration maxAge);
  String generateDistributionCacheKey(String? plantCode, String? deptCode);
  String generateGrowthTrendsCacheKey({
    String? deptCode,
    String? locationCode,
    String period,
    int? year,
    String? startDate,
    String? endDate,
  });
  String generateAuditProgressCacheKey({
    String? deptCode,
    bool includeDetails,
    String? auditStatus,
  });
  String generateLocationAnalyticsCacheKey({
    String? locationCode,
    String period,
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends,
  });
}

class DashboardCacheDataSourceImpl implements DashboardCacheDataSource {
  final StorageService storageService;

  // Cache keys
  static const String _dashboardStatsPrefix = 'dashboard_stats_';
  static const String _assetDistributionPrefix = 'asset_distribution_';
  static const String _growthTrendsPrefix = 'growth_trends_';
  static const String _auditProgressPrefix = 'audit_progress_';
  static const String _cacheTimestampSuffix = '_timestamp';
  static const String _locationAnalyticsPrefix = 'location_analytics_';

  // Cache duration (5 minutes)
  static const Duration _defaultCacheDuration = Duration(minutes: 5);

  DashboardCacheDataSourceImpl(this.storageService);

  @override
  Future<void> cacheDashboardStats(
    String period,
    DashboardStatsModel stats,
  ) async {
    try {
      final key = '$_dashboardStatsPrefix$period';
      final timestampKey = '$key$_cacheTimestampSuffix';

      await storageService.setJson(key, stats.toJson());
      await storageService.setString(
        timestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<DashboardStatsModel?> getCachedDashboardStats(String period) async {
    try {
      final key = '$_dashboardStatsPrefix$period';

      if (!isCacheValid(key, _defaultCacheDuration)) {
        return null;
      }

      final cachedData = storageService.getJson(key);
      if (cachedData != null) {
        return DashboardStatsModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheAssetDistribution(
    String key,
    AssetDistributionModel distribution,
  ) async {
    try {
      final cacheKey = '$_assetDistributionPrefix$key';
      final timestampKey = '$cacheKey$_cacheTimestampSuffix';

      await storageService.setJson(cacheKey, distribution.toJson());
      await storageService.setString(
        timestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<AssetDistributionModel?> getCachedAssetDistribution(String key) async {
    try {
      final cacheKey = '$_assetDistributionPrefix$key';

      if (!isCacheValid(cacheKey, _defaultCacheDuration)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return AssetDistributionModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheGrowthTrends(String key, GrowthTrendModel trends) async {
    try {
      final cacheKey = '$_growthTrendsPrefix$key';
      final timestampKey = '$cacheKey$_cacheTimestampSuffix';

      await storageService.setJson(cacheKey, trends.toJson());
      await storageService.setString(
        timestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<GrowthTrendModel?> getCachedGrowthTrends(String key) async {
    try {
      final cacheKey = '$_growthTrendsPrefix$key';

      if (!isCacheValid(cacheKey, _defaultCacheDuration)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return GrowthTrendModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheAuditProgress(
    String key,
    AuditProgressModel progress,
  ) async {
    try {
      final cacheKey = '$_auditProgressPrefix$key';
      final timestampKey = '$cacheKey$_cacheTimestampSuffix';

      await storageService.setJson(cacheKey, progress.toJson());
      await storageService.setString(
        timestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<AuditProgressModel?> getCachedAuditProgress(String key) async {
    try {
      final cacheKey = '$_auditProgressPrefix$key';

      if (!isCacheValid(cacheKey, _defaultCacheDuration)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return AuditProgressModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearDashboardCache() async {
    try {
      // Note: This would need access to SharedPreferences keys
      // For now, we'll implement a simple approach
      final prefixes = [
        _dashboardStatsPrefix,
        _assetDistributionPrefix,
        _growthTrendsPrefix,
        _auditProgressPrefix,
        _locationAnalyticsPrefix,
      ];

      // Clear known cache keys (this is a simplified approach)
      // In production, you might want to store a list of active cache keys
      for (final prefix in prefixes) {
        // Clear common period combinations
        final commonKeys = [
          '${prefix}today',
          '${prefix}7d',
          '${prefix}30d',
          '${prefix}all',
          '${prefix}Q1',
          '${prefix}Q2',
          '${prefix}Q3',
          '${prefix}Q4',
        ];

        for (final key in commonKeys) {
          await storageService.remove(key);
          await storageService.remove('$key$_cacheTimestampSuffix');
        }
      }
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  bool isCacheValid(String key, Duration maxAge) {
    try {
      final timestampKey = '$key$_cacheTimestampSuffix';
      final timestampString = storageService.getString(timestampKey);

      if (timestampString == null) {
        return false;
      }

      final timestamp = DateTime.tryParse(timestampString);
      if (timestamp == null) {
        return false;
      }

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference <= maxAge;
    } catch (e) {
      return false;
    }
  }

  // Helper method to generate cache keys
  String _generateCacheKey(Map<String, dynamic> params) {
    final sortedKeys = params.keys.toList()..sort();
    final keyParts = sortedKeys.map((key) => '$key:${params[key]}').join('_');
    return keyParts.replaceAll(RegExp(r'[^a-zA-Z0-9:_]'), '_');
  }

  @override
  String generateDistributionCacheKey(String? plantCode, String? deptCode) {
    return _generateCacheKey({
      'plant_code': plantCode ?? 'all',
      'dept_code': deptCode ?? 'all',
    });
  }

  @override
  String generateGrowthTrendsCacheKey({
    String? deptCode,
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
  }) {
    return _generateCacheKey({
      'dept_code': deptCode ?? 'all',
      'location_code': locationCode ?? 'all',
      'period': period,
      'year': year ?? DateTime.now().year,
      'start_date': startDate ?? '',
      'end_date': endDate ?? '',
    });
  }

  @override
  String generateAuditProgressCacheKey({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
  }) {
    return _generateCacheKey({
      'dept_code': deptCode ?? 'all',
      'include_details': includeDetails,
      'audit_status': auditStatus ?? 'all',
    });
  }

  @override
  Future<void> cacheLocationAnalytics(
    String key,
    LocationAnalyticsModel analytics,
  ) async {
    try {
      final cacheKey = '$_locationAnalyticsPrefix$key';
      final timestampKey = '$cacheKey$_cacheTimestampSuffix';

      await storageService.setJson(cacheKey, analytics.toJson());
      await storageService.setString(
        timestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<LocationAnalyticsModel?> getCachedLocationAnalytics(String key) async {
    try {
      final cacheKey = '$_locationAnalyticsPrefix$key';

      if (!isCacheValid(cacheKey, _defaultCacheDuration)) {
        return null;
      }

      final cachedData = storageService.getJson(cacheKey);
      if (cachedData != null) {
        return LocationAnalyticsModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  String generateLocationAnalyticsCacheKey({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
  }) {
    return _generateCacheKey({
      'location_code': locationCode ?? 'all',
      'period': period,
      'year': year ?? DateTime.now().year,
      'start_date': startDate ?? '',
      'end_date': endDate ?? '',
      'include_trends': includeTrends,
    });
  }
}
