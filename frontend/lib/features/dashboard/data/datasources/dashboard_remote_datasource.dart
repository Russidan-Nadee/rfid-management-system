// Path: frontend/lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart
import 'package:frontend/features/dashboard/data/models/overview_data_model.dart';
import 'package:frontend/features/dashboard/data/models/department_analytics_model.dart';
import 'package:frontend/features/dashboard/data/models/growth_trends_model.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../models/alert_model.dart';
import '../models/recent_activity_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats({String period = 'today'});
  Future<OverviewDataModel> getOverviewData({String period = '7d'});
  Future<Map<String, dynamic>> getQuickStats({String period = 'today'});
  Future<List<AlertModel>> getAlerts();
  Future<RecentActivityModel> getRecentActivities({String period = '7d'});

  // Enhanced Dashboard APIs
  Future<DepartmentAnalyticsModel> getAssetsByDepartment({String? plantCode});
  Future<GrowthTrendsModel> getGrowthTrends({
    String? deptCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
  });
  Future<Map<String, dynamic>> getLocationAnalytics({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
  });
  Future<Map<String, dynamic>> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiService apiService;

  DashboardRemoteDataSourceImpl(this.apiService);

  @override
  Future<DashboardStatsModel> getDashboardStats({
    String period = 'today',
  }) async {
    try {
      final response = await apiService.get(
        '${ApiConstants.dashboardStats}?period=$period',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return DashboardStatsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<OverviewDataModel> getOverviewData({String period = '7d'}) async {
    try {
      final response = await apiService.get(
        '${ApiConstants.dashboardOverview}?period=$period',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return OverviewDataModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getQuickStats({String period = 'today'}) async {
    try {
      final response = await apiService.get(
        '${ApiConstants.dashboardBase}/quick-stats?period=$period',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<List<AlertModel>> getAlerts() async {
    try {
      final response = await apiService.get(
        '${ApiConstants.dashboardBase}/alerts',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final alertsList = response.data as List<dynamic>;
        return alertsList
            .map((item) => AlertModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<RecentActivityModel> getRecentActivities({
    String period = '7d',
  }) async {
    try {
      final response = await apiService.get(
        '${ApiConstants.dashboardBase}/recent?period=$period',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return RecentActivityModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }

  // Enhanced Dashboard APIs Implementation
  @override
  Future<DepartmentAnalyticsModel> getAssetsByDepartment({
    String? plantCode,
  }) async {
    try {
      String url = '${ApiConstants.dashboardBase}/assets-by-plant';
      if (plantCode != null && plantCode.isNotEmpty) {
        url += '?plant_code=$plantCode';
      }

      final response = await apiService.get(url, requiresAuth: false);

      if (response.success && response.data != null) {
        return DepartmentAnalyticsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<GrowthTrendsModel> getGrowthTrends({
    String? deptCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '${ApiConstants.dashboardBase}/growth-trends?period=$period';

      if (deptCode != null && deptCode.isNotEmpty) {
        url += '&dept_code=$deptCode';
      }

      if (period == 'custom') {
        if (startDate != null && endDate != null) {
          url += '&start_date=$startDate&end_date=$endDate';
        } else {
          throw ArgumentError(
            'start_date and end_date are required for custom period',
          );
        }
      } else if (year != null) {
        url += '&year=$year';
      }

      final response = await apiService.get(url, requiresAuth: false);

      if (response.success && response.data != null) {
        return GrowthTrendsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getLocationAnalytics({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
  }) async {
    try {
      String url =
          '${ApiConstants.dashboardBase}/location-analytics?period=$period&include_trends=$includeTrends';

      if (locationCode != null && locationCode.isNotEmpty) {
        url += '&location_code=$locationCode';
      }

      if (period == 'custom') {
        if (startDate != null && endDate != null) {
          url += '&start_date=$startDate&end_date=$endDate';
        } else {
          throw ArgumentError(
            'start_date and end_date are required for custom period',
          );
        }
      } else if (year != null) {
        url += '&year=$year';
      }

      final response = await apiService.get(url, requiresAuth: false);

      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
  }) async {
    try {
      String url =
          '${ApiConstants.dashboardBase}/audit-progress?include_details=$includeDetails';

      if (deptCode != null && deptCode.isNotEmpty) {
        url += '&dept_code=$deptCode';
      }

      if (auditStatus != null && auditStatus.isNotEmpty) {
        url += '&audit_status=$auditStatus';
      }

      final response = await apiService.get(url, requiresAuth: false);

      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw ServerException();
      }
    }
  }
}
