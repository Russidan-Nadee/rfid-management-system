// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/dashboard/domain/entities/alert.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:frontend/features/dashboard/domain/entities/overview_data.dart';
import 'package:frontend/features/dashboard/domain/entities/recent_activity.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_overview_data_usecase.dart';
import '../../domain/usecases/get_quick_stats_usecase.dart';
import '../../domain/usecases/clear_cache_usecase.dart';
import '../../domain/usecases/refresh_dashboard_usecase.dart';
import '../../domain/usecases/is_cache_valid_usecase.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/errors/failures.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStats;
  final GetOverviewDataUseCase getOverviewData;
  final GetQuickStatsUseCase getQuickStats;
  final ClearCacheUseCase clearCache;
  final RefreshDashboardUseCase refreshDashboard;
  final IsCacheValidUseCase isCacheValid;
  final DashboardRepository repository;

  DashboardBloc({
    required this.getDashboardStats,
    required this.getOverviewData,
    required this.getQuickStats,
    required this.clearCache,
    required this.refreshDashboard,
    required this.isCacheValid,
    required this.repository,
  }) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ChangePeriod>(_onChangePeriod);
    on<LoadAlerts>(_onLoadAlerts);
    on<LoadRecentActivities>(_onLoadRecentActivities);
    on<ClearDashboardCache>(_onClearCache);
    on<RetryDashboardLoad>(_onRetryDashboardLoad);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(
      DashboardLoading(period: event.period, isRefreshing: event.forceRefresh),
    );

    try {
      // Load all dashboard data concurrently
      final results = await Future.wait([
        getDashboardStats(forceRefresh: event.forceRefresh),
        getOverviewData(forceRefresh: event.forceRefresh),
        repository.getAlerts(forceRefresh: event.forceRefresh),
        repository.getRecentActivities(
          period: event.period,
          forceRefresh: event.forceRefresh,
        ),
      ]);

      final statsResult = results[0];
      final overviewResult = results[1];
      final alertsResult = results[2];
      final activitiesResult = results[3];

      // Check if all results are successful
      if (statsResult.isRight &&
          overviewResult.isRight &&
          alertsResult.isRight &&
          activitiesResult.isRight) {
        emit(
          DashboardLoaded(
            dashboardStats: statsResult.right as DashboardStats,
            overviewData: overviewResult.right as OverviewData,
            alerts: alertsResult.right as List<Alert>,
            recentActivities: activitiesResult.right as RecentActivity,
            currentPeriod: event.period,
            lastUpdated: DateTime.now(),
            isFromCache: !event.forceRefresh,
          ),
        );
      } else {
        // Handle partial success - emit partial loaded state
        final loadingComponents = <String>[];
        final errorComponents = <String>[];

        if (statsResult.isLeft) errorComponents.add('stats');
        if (overviewResult.isLeft) errorComponents.add('overview');
        if (alertsResult.isLeft) errorComponents.add('alerts');
        if (activitiesResult.isLeft) errorComponents.add('activities');

        emit(
          DashboardPartialLoaded(
            dashboardStats: statsResult.isRight
                ? statsResult.right as DashboardStats?
                : null,
            overviewData: overviewResult.isRight
                ? overviewResult.right as OverviewData?
                : null,
            alerts: alertsResult.isRight
                ? alertsResult.right as List<Alert>?
                : null,
            recentActivities: activitiesResult.isRight
                ? activitiesResult.right as RecentActivity?
                : null,
            currentPeriod: event.period,
            errorComponents: errorComponents,
          ),
        );
      }
    } catch (e) {
      emit(
        DashboardError(
          message: 'Failed to load dashboard: ${e.toString()}',
          period: event.period,
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // If currently loaded, show refreshing state
    if (state is DashboardLoaded) {
      emit(
        DashboardRefreshing(
          currentData: state as DashboardLoaded,
          refreshingComponent: 'all',
        ),
      );
    }

    // Use refresh use case
    final result = await refreshDashboard();

    if (result.isRight) {
      // Reload dashboard after refresh
      add(LoadDashboard(period: event.period, forceRefresh: true));
    } else {
      emit(
        DashboardError(
          message: 'Failed to refresh dashboard: ${result.left!.message}',
          period: event.period,
          errorType: _getErrorTypeFromFailure(result.left!),
        ),
      );
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<DashboardState> emit,
  ) async {
    // Load dashboard with new period
    add(LoadDashboard(period: event.period));
  }

  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;

      final result = await repository.getAlerts(
        forceRefresh: event.forceRefresh,
      );

      if (result.isRight) {
        emit(currentState.copyWith(alerts: result.right as List<Alert>));
      }
      // Don't emit error for individual component failures
    }
  }

  Future<void> _onLoadRecentActivities(
    LoadRecentActivities event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;

      final result = await repository.getRecentActivities(
        period: event.period,
        forceRefresh: event.forceRefresh,
      );

      if (result.isRight) {
        emit(
          currentState.copyWith(
            recentActivities: result.right as RecentActivity,
          ),
        );
      }
      // Don't emit error for individual component failures
    }
  }

  Future<void> _onClearCache(
    ClearDashboardCache event,
    Emitter<DashboardState> emit,
  ) async {
    await clearCache();

    // Reload dashboard after clearing cache
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      add(
        LoadDashboard(period: currentState.currentPeriod, forceRefresh: true),
      );
    } else {
      add(const LoadDashboard(forceRefresh: true));
    }
  }

  Future<void> _onRetryDashboardLoad(
    RetryDashboardLoad event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboard(period: event.period, forceRefresh: true));
  }

  String _getErrorType(dynamic error) {
    if (error is NetworkFailure) return 'network';
    if (error is ServerFailure) return 'server';
    if (error is CacheFailure) return 'cache';
    if (error is UnauthorizedFailure) return 'auth';
    return 'general';
  }

  String _getErrorTypeFromFailure(Failure failure) {
    if (failure is NetworkFailure) return 'network';
    if (failure is ServerFailure) return 'server';
    if (failure is CacheFailure) return 'cache';
    if (failure is UnauthorizedFailure) return 'auth';
    return 'general';
  }

  // Helper method to check if data is stale
  bool _isDataStale(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inMinutes > 5; // Consider data stale after 5 minutes
  }

  @override
  Future<void> close() {
    // Clean up any subscriptions or timers here
    return super.close();
  }
}
