// Path: frontend/lib/features/dashboard/data/datasources/dashboard_cache_datasource.dart
import 'dart:convert';
import 'package:frontend/features/dashboard/data/models/overview_data_model.dart';

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
  Future<bool> isCacheValid(String cacheKey);
  Future<void> clearCache();
  Future<void> clearPeriodCache(String period);
}

class DashboardCacheDataSourceImpl implements DashboardCacheDataSource {
  final StorageService storageService;

  static const String _statsKeyPrefix = 'dashboard_stats_';
  static const String _overviewKeyPrefix = 'dashboard_overview_';
  static const String _alertsKey = 'dashboard_alerts';
  static const String _recentKeyPrefix = 'dashboard_recent_';
  static const String _timestampSuffix = '_timestamp';
  static const Duration _cacheTimeout = Duration(minutes: 5);
  static const Duration _alertsCacheTimeout = Duration(minutes: 2);

  DashboardCacheDataSourceImpl(this.storageService);

  String _getStatsKey(String period) => '$_statsKeyPrefix$period';
  String _getOverviewKey(String period) => '$_overviewKeyPrefix$period';
  String _getRecentKey(String period) => '$_recentKeyPrefix$period';
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
      // Store as list directly, not as Map
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
}
