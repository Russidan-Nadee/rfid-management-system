// Path: frontend/lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../models/overview_data_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<OverviewDataModel> getOverviewData();
  Future<Map<String, dynamic>> getQuickStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiService apiService;

  DashboardRemoteDataSourceImpl(this.apiService);

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await apiService.get(
        ApiConstants.dashboardStats,
        requiresAuth: false, // Dashboard data อาจไม่ต้อง auth
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
  Future<OverviewDataModel> getOverviewData() async {
    try {
      final response = await apiService.get(
        ApiConstants.dashboardOverview,
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
  Future<Map<String, dynamic>> getQuickStats() async {
    try {
      final response = await apiService.get(
        '${ApiConstants.dashboardBase}/quick-stats',
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
}
