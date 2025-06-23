// Path: frontend/lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart
import 'package:frontend/features/dashboard/data/models/location_analytics_model.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../models/asset_distribution_model.dart';
import '../models/growth_trend_model.dart';
import '../models/audit_progress_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<Map<String, dynamic>>> getLocations({String? plantCode});
  Future<DashboardStatsModel> getDashboardStats(String period);
  Future<AssetDistributionModel> getAssetDistribution(
    String? plantCode,
    String? deptCode,
  );
  Future<GrowthTrendModel> getGrowthTrends({
    String? deptCode,
    String? locationCode,
    String period,
    int? year,
    String? startDate,
    String? endDate,
    String groupBy,
  });
  Future<AuditProgressModel> getAuditProgress({
    String? deptCode,
    bool includeDetails,
    String? auditStatus,
  });
  Future<LocationAnalyticsModel> getLocationAnalytics({
    String? locationCode,
    String period,
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiService apiService;

  DashboardRemoteDataSourceImpl(this.apiService);
  @override
  Future<List<Map<String, dynamic>>> getLocations({String? plantCode}) async {
    try {
      final queryParams = <String, String>{};

      if (plantCode != null && plantCode.isNotEmpty) {
        queryParams['plant_code'] = plantCode;
      }

      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.dashboardLocations,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final locations = data['locations'] as List<dynamic>?;

        if (locations != null) {
          return locations.cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Failed to get locations: $e');
    }
  }

  @override
  Future<DashboardStatsModel> getDashboardStats(String period) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.dashboardStats,
        queryParams: {'period': period},
      );

      if (response.success && response.data != null) {
        return DashboardStatsModel.fromJson(response.data!);
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Failed to get dashboard stats: $e');
    }
  }

  @override
  Future<AssetDistributionModel> getAssetDistribution(
    String? plantCode,
    String? deptCode,
  ) async {
    try {
      final queryParams = <String, String>{};

      if (plantCode != null && plantCode.isNotEmpty) {
        queryParams['plant_code'] = plantCode;
      }

      if (deptCode != null && deptCode.isNotEmpty) {
        queryParams['dept_code'] = deptCode;
      }

      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.dashboardAssetsByPlant,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.success && response.data != null) {
        return AssetDistributionModel.fromJson(response.data!);
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Failed to get asset distribution: $e');
    }
  }

  @override
  Future<GrowthTrendModel> getGrowthTrends({
    String? deptCode,
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    String groupBy = 'day',
  }) async {
    try {
      final queryParams = <String, String>{'period': period};

      if (deptCode != null && deptCode.isNotEmpty) {
        queryParams['dept_code'] = deptCode;
      }

      if (locationCode != null && locationCode.isNotEmpty) {
        queryParams['location_code'] = locationCode;
      }

      if (year != null) {
        queryParams['year'] = year.toString();
      }

      if (groupBy.isNotEmpty) {
        queryParams['group_by'] = groupBy;
      }

      if (period == 'custom') {
        if (startDate != null) queryParams['start_date'] = startDate;
        if (endDate != null) queryParams['end_date'] = endDate;
      }

      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.dashboardGrowthTrends,
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        return GrowthTrendModel.fromJson(response.data!);
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Failed to get growth trends: $e');
    }
  }

  @override
  Future<AuditProgressModel> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
  }) async {
    try {
      final queryParams = <String, String>{
        'include_details': includeDetails.toString(),
      };

      if (deptCode != null && deptCode.isNotEmpty) {
        queryParams['dept_code'] = deptCode;
      }

      if (auditStatus != null && auditStatus.isNotEmpty) {
        queryParams['audit_status'] = auditStatus;
      }

      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.dashboardAuditProgress,
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        return AuditProgressModel.fromJson(response.data!);
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Failed to get audit progress: $e');
    }
  }

  @override
  Future<LocationAnalyticsModel> getLocationAnalytics({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
  }) async {
    try {
      final queryParams = <String, String>{'period': period};

      if (locationCode != null && locationCode.isNotEmpty) {
        queryParams['location_code'] = locationCode;
      }

      if (year != null) {
        queryParams['year'] = year.toString();
      }

      if (period == 'custom') {
        if (startDate != null) queryParams['start_date'] = startDate;
        if (endDate != null) queryParams['end_date'] = endDate;
      }

      queryParams['include_trends'] = includeTrends.toString();

      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.dashboardLocationAnalytics,
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        return LocationAnalyticsModel.fromJson(response.data!);
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Failed to get location analytics: $e');
    }
  }
}
