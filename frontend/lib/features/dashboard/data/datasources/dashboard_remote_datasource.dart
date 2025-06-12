// Path: frontend/lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart
import 'package:frontend/features/dashboard/data/models/overview_data_model.dart';

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
}
