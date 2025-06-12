// Path: frontend/lib/di/dashboard_injection.dart
import '../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../features/dashboard/data/datasources/dashboard_cache_datasource.dart';
import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import '../features/dashboard/domain/usecases/get_overview_data_usecase.dart';
import '../features/dashboard/domain/usecases/get_quick_stats_usecase.dart';
import '../features/dashboard/domain/usecases/clear_cache_usecase.dart';
import '../features/dashboard/domain/usecases/refresh_dashboard_usecase.dart';
import '../features/dashboard/domain/usecases/is_cache_valid_usecase.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'injection.dart';

/// Configure Dashboard feature dependencies
void configureDashboardDependencies() {
  // Data Layer
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<DashboardCacheDataSource>(
    () => DashboardCacheDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: getIt<DashboardRemoteDataSource>(),
      cacheDataSource: getIt<DashboardCacheDataSource>(),
    ),
  );

  // Domain Layer - Use Cases
  getIt.registerLazySingleton<GetDashboardStatsUseCase>(
    () => GetDashboardStatsUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<GetOverviewDataUseCase>(
    () => GetOverviewDataUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<GetQuickStatsUseCase>(
    () => GetQuickStatsUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<ClearCacheUseCase>(
    () => ClearCacheUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<RefreshDashboardUseCase>(
    () => RefreshDashboardUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<IsCacheValidUseCase>(
    () => IsCacheValidUseCase(getIt<DashboardRepository>()),
  );

  // Presentation Layer - BLoC (Factory - new instance each time)
  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      getDashboardStats: getIt<GetDashboardStatsUseCase>(),
      getOverviewData: getIt<GetOverviewDataUseCase>(),
      getQuickStats: getIt<GetQuickStatsUseCase>(),
      clearCache: getIt<ClearCacheUseCase>(),
      refreshDashboard: getIt<RefreshDashboardUseCase>(),
      isCacheValid: getIt<IsCacheValidUseCase>(),
      repository: getIt<DashboardRepository>(),
    ),
  );
}

/// Debug Dashboard dependencies
void debugDashboardDependencies() {
  print('--- Dashboard Dependencies ---');
  print(
    'DashboardRemoteDataSource: ${getIt.isRegistered<DashboardRemoteDataSource>()}',
  );
  print(
    'DashboardCacheDataSource: ${getIt.isRegistered<DashboardCacheDataSource>()}',
  );
  print('DashboardRepository: ${getIt.isRegistered<DashboardRepository>()}');
  print(
    'GetDashboardStatsUseCase: ${getIt.isRegistered<GetDashboardStatsUseCase>()}',
  );
  print(
    'GetOverviewDataUseCase: ${getIt.isRegistered<GetOverviewDataUseCase>()}',
  );
  print('GetQuickStatsUseCase: ${getIt.isRegistered<GetQuickStatsUseCase>()}');
  print('ClearCacheUseCase: ${getIt.isRegistered<ClearCacheUseCase>()}');
  print(
    'RefreshDashboardUseCase: ${getIt.isRegistered<RefreshDashboardUseCase>()}',
  );
  print('IsCacheValidUseCase: ${getIt.isRegistered<IsCacheValidUseCase>()}');
  print('DashboardBloc: ${getIt.isRegistered<DashboardBloc>()}');
}
