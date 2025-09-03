// Path: frontend/lib/di/dashboard_injection.dart
import 'package:tp_rfid/features/dashboard/domain/usecases/get_location_analytics_usecase.dart';

import '../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../features/dashboard/data/datasources/dashboard_cache_datasource.dart';
import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import '../features/dashboard/domain/usecases/get_asset_distribution_usecase.dart';
import '../features/dashboard/domain/usecases/get_growth_trends_usecase.dart';
import '../features/dashboard/domain/usecases/get_audit_progress_usecase.dart';
import '../features/dashboard/domain/usecases/clear_dashboard_cache_usecase.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'injection.dart';

/// Configure Dashboard feature dependencies
void configureDashboardDependencies() {
  // Data Sources
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<DashboardCacheDataSource>(
    () => DashboardCacheDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: getIt<DashboardRemoteDataSource>(),
      cacheDataSource: getIt<DashboardCacheDataSource>(),
    ),
  );

  // Dashboard Use Cases
  getIt.registerLazySingleton<GetDashboardStatsUseCase>(
    () => GetDashboardStatsUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetAssetDistributionUseCase>(
    () => GetAssetDistributionUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetGrowthTrendsUseCase>(
    () => GetGrowthTrendsUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetAuditProgressUseCase>(
    () => GetAuditProgressUseCase(getIt()),
  );

  // เพิ่มบรรทัดนี้
  getIt.registerLazySingleton<GetLocationAnalyticsUseCase>(
    () => GetLocationAnalyticsUseCase(getIt()),
  );

  getIt.registerLazySingleton<ClearDashboardCacheUseCase>(
    () => ClearDashboardCacheUseCase(getIt()),
  );

  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      getDashboardStatsUseCase: getIt<GetDashboardStatsUseCase>(),
      getAssetDistributionUseCase: getIt<GetAssetDistributionUseCase>(),
      getGrowthTrendsUseCase: getIt<GetGrowthTrendsUseCase>(),
      getAuditProgressUseCase: getIt<GetAuditProgressUseCase>(),
      clearDashboardCacheUseCase: getIt<ClearDashboardCacheUseCase>(),
      getLocationAnalyticsUseCase: getIt<GetLocationAnalyticsUseCase>(),
    ),
  );
}
