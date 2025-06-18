// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_overview_data_usecase.dart';
import '../../domain/usecases/get_quick_stats_usecase.dart';
import '../../domain/usecases/clear_cache_usecase.dart';
import '../../domain/usecases/refresh_dashboard_usecase.dart';
import '../../domain/usecases/is_cache_valid_usecase.dart';
import '../../domain/repositories/dashboard_repository.dart';
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

  Timer? _refreshTimer;

  DashboardBloc({
    required this.getDashboardStats,
    required this.getOverviewData,
    required this.getQuickStats,
    required this.clearCache,
    required this.refreshDashboard,
    required this.isCacheValid,
    required this.repository,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadOverviewData>(_onLoadOverviewData);
    on<LoadQuickStats>(_onLoadQuickStats);
    on<LoadDepartmentAnalytics>(_onLoadDepartmentAnalytics);
    on<LoadGrowthTrends>(_onLoadGrowthTrends);
    on<LoadLocationAnalytics>(_onLoadLocationAnalytics);
    on<LoadAuditProgress>(_onLoadAuditProgress);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ClearDashboardCache>(_onClearDashboardCache);
    on<ChangePeriod>(_onChangePeriod);
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(message: 'Loading dashboard statistics...'));

    try {
      final result = await getDashboardStats(forceRefresh: event.forceRefresh);

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (stats) => emit(DashboardStatsLoaded(stats)),
      );
    } catch (e) {
      emit(DashboardError('Failed to load dashboard stats: ${e.toString()}'));
    }
  }

  Future<void> _onLoadOverviewData(
    LoadOverviewData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(message: 'Loading overview data...'));

    try {
      final result = await getOverviewData(forceRefresh: event.forceRefresh);

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (overview) => emit(OverviewDataLoaded(overview)),
      );
    } catch (e) {
      emit(DashboardError('Failed to load overview data: ${e.toString()}'));
    }
  }

  Future<void> _onLoadQuickStats(
    LoadQuickStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(message: 'Loading quick statistics...'));

    try {
      final result = await getQuickStats();

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (quickStats) => emit(QuickStatsLoaded(quickStats)),
      );
    } catch (e) {
      emit(DashboardError('Failed to load quick stats: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDepartmentAnalytics(
    LoadDepartmentAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(message: 'Loading department analytics...'));

    try {
      final result = await repository.getAssetsByDepartment(
        plantCode: event.plantCode,
        forceRefresh: event.forceRefresh,
      );

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (analytics) => emit(DepartmentAnalyticsLoaded(analytics)),
      );
    } catch (e) {
      emit(
        DashboardError('Failed to load department analytics: ${e.toString()}'),
      );
    }
  }

  Future<void> _onLoadGrowthTrends(
    LoadGrowthTrends event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(message: 'Loading growth trends...'));

    try {
      final result = await repository.getGrowthTrends(
        deptCode: event.deptCode,
        period: event.period,
        year: event.year,
        startDate: event.startDate,
        endDate: event.endDate,
        forceRefresh: event.forceRefresh,
      );

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (trends) => emit(GrowthTrendsLoaded(trends)),
      );
    } catch (e) {
      emit(DashboardError('Failed to load growth trends: ${e.toString()}'));
    }
  }

  Future<void> _onLoadLocationAnalytics(
    LoadLocationAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(message: 'Loading location analytics...'));

    try {
      final result = await repository.getLocationAnalytics(
        locationCode: event.locationCode,
        period: event.period,
        year: event.year,
        startDate: event.startDate,
        endDate: event.endDate,
        includeTrends: event.includeTrends,
        forceRefresh: event.forceRefresh,
      );

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (analytics) => emit(LocationAnalyticsLoaded(analytics)),
      );
    } catch (e) {
      emit(
        DashboardError('Failed to load location analytics: ${e.toString()}'),
      );
    }
  }

  Future<void> _onLoadAuditProgress(
    LoadAuditProgress event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(message: 'Loading audit progress...'));

    try {
      final result = await repository.getAuditProgress(
        deptCode: event.deptCode,
        includeDetails: event.includeDetails,
        auditStatus: event.auditStatus,
        forceRefresh: event.forceRefresh,
      );

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (progress) => emit(AuditProgressLoaded(progress)),
      );
    } catch (e) {
      emit(DashboardError('Failed to load audit progress: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(message: 'Refreshing dashboard...'));

    try {
      final result = await refreshDashboard();

      result.fold((failure) => emit(DashboardError(failure.message)), (_) {
        emit(const DashboardRefreshed());
        // Auto-reload data after refresh
        add(const LoadDashboardStats(forceRefresh: true));
      });
    } catch (e) {
      emit(DashboardError('Failed to refresh dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onClearDashboardCache(
    ClearDashboardCache event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final result = await clearCache();

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (_) => emit(const DashboardCacheCleared()),
      );
    } catch (e) {
      emit(DashboardError('Failed to clear cache: ${e.toString()}'));
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardPeriodChanged(event.period));

    // Reload data with new period
    add(const LoadDashboardStats(forceRefresh: true));
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      add(const RefreshDashboard());
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
