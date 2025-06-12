// Path: frontend/lib/features/dashboard/data/datasources/dashboard_cache_datasource.dart
import '../../../../core/services/storage_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../models/overview_data_model.dart';

abstract class DashboardCacheDataSource {
  Future<DashboardStatsModel?> getCachedStats();
  Future<void> cacheStats(DashboardStatsModel stats);
  Future<OverviewDataModel?> getCachedOverview();
  Future<void> cacheOverview(OverviewDataModel overview);
  Future<bool> isCacheValid();
  Future<void> clearCache();
}

class DashboardCacheDataSourceImpl implements DashboardCacheDataSource {
  final StorageService storageService;

  static const String _statsKey = 'dashboard_stats';
  static const String _overviewKey = 'dashboard_overview';
  static const String _timestampKey = 'dashboard_cache_timestamp';
  static const Duration _cacheTimeout = Duration(minutes: 5);

  DashboardCacheDataSourceImpl(this.storageService);

  @override
  Future<DashboardStatsModel?> getCachedStats() async {
    try {
      if (!await isCacheValid()) {
        return null;
      }

      final cachedData = storageService.getJson(_statsKey);
      if (cachedData != null) {
        return DashboardStatsModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheStats(DashboardStatsModel stats) async {
    try {
      await storageService.setJson(_statsKey, stats.toJson());
      await storageService.setString(
        _timestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<OverviewDataModel?> getCachedOverview() async {
    try {
      if (!await isCacheValid()) {
        return null;
      }

      final cachedData = storageService.getJson(_overviewKey);
      if (cachedData != null) {
        return OverviewDataModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheOverview(OverviewDataModel overview) async {
    try {
      await storageService.setJson(_overviewKey, overview.toJson());
      await storageService.setString(
        _timestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> isCacheValid() async {
    try {
      final timestampStr = storageService.getString(_timestampKey);
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

  @override
  Future<void> clearCache() async {
    try {
      await storageService.remove(_statsKey);
      await storageService.remove(_overviewKey);
      await storageService.remove(_timestampKey);
    } catch (e) {
      throw CacheException();
    }
  }
}
