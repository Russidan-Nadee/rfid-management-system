// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/features/dashboard/domain/entities/asset_distribution.dart';
import 'package:frontend/features/dashboard/domain/entities/audit_progress.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:frontend/features/dashboard/domain/entities/growth_trend.dart';
import 'package:frontend/features/dashboard/domain/entities/location_analytics.dart';
import 'package:frontend/features/dashboard/domain/usecases/get_location_analytics_usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_asset_distribution_usecase.dart';
import '../../domain/usecases/get_growth_trends_usecase.dart';
import '../../domain/usecases/get_audit_progress_usecase.dart';
import '../../domain/usecases/clear_dashboard_cache_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetAssetDistributionUseCase getAssetDistributionUseCase;
  final GetGrowthTrendsUseCase getGrowthTrendsUseCase;
  final GetAuditProgressUseCase getAuditProgressUseCase;
  final GetLocationAnalyticsUseCase
  getLocationAnalyticsUseCase; // เพิ่มบรรทัดนี้
  final ClearDashboardCacheUseCase clearDashboardCacheUseCase;
  DashboardBloc({
    required this.getDashboardStatsUseCase,
    required this.getAssetDistributionUseCase,
    required this.getGrowthTrendsUseCase,
    required this.getAuditProgressUseCase,
    required this.getLocationAnalyticsUseCase, // เพิ่มบรรทัดนี้
    required this.clearDashboardCacheUseCase,
  }) : super(const DashboardInitial()) {
    on<LoadInitialDashboard>(_onLoadInitialDashboard);
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadAssetDistribution>(_onLoadAssetDistribution);
    on<LoadGrowthTrends>(_onLoadGrowthTrends);
    on<LoadAuditProgress>(_onLoadAuditProgress);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ClearDashboardCache>(_onClearDashboardCache);
    on<ChangePeriodFilter>(_onChangePeriodFilter);
    on<ChangePlantFilter>(_onChangePlantFilter);
    on<ToggleDetailsView>(_onToggleDetailsView);
    on<ResetFilters>(_onResetFilters);
    on<LoadLocationAnalytics>(_onLoadLocationAnalytics);
    on<LoadLocationGrowthTrends>(_onLoadLocationGrowthTrends);
    // ลบ ChangeDepartmentFilter handler ออก
  }

  /// Load location growth trends
  Future<void> _onLoadLocationGrowthTrends(
    LoadLocationGrowthTrends event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      emit(
        DashboardPartialLoading(
          currentState: currentState,
          loadingType: 'location_trends',
        ),
      );
    } else {
      emit(
        const DashboardLoading(loadingMessage: 'Loading location trends...'),
      );
    }

    final result = await getGrowthTrendsUseCase(
      GetGrowthTrendsParams(
        deptCode: null,
        locationCode: event.locationCode,
        period: event.period,
        year: event.year,
        startDate: event.startDate,
        endDate: event.endDate,
        groupBy: event.groupBy,
      ),
    );

    result.fold(
      (failure) {
        emit(
          DashboardError(
            message: 'Failed to load location trends: ${failure.message}',
            errorCode: 'LOCATION_TRENDS_ERROR',
            previousState: currentState is DashboardLoaded
                ? currentState
                : null,
          ),
        );
      },
      (trends) {
        if (currentState is DashboardLoaded) {
          emit(
            currentState.copyWith(
              locationTrend: trends,
              locationAnalyticsLocationFilter: event.locationCode,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          emit(
            DashboardLoaded(
              locationTrend: trends,
              locationAnalyticsLocationFilter: event.locationCode,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// Load growth trends
  Future<void> _onLoadGrowthTrends(
    LoadGrowthTrends event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      emit(
        DashboardPartialLoading(
          currentState: currentState,
          loadingType: 'trends',
        ),
      );
    } else {
      emit(const DashboardLoading(loadingMessage: 'Loading trends...'));
    }

    final result = await getGrowthTrendsUseCase(
      GetGrowthTrendsParams(
        deptCode: event.deptCode,
        locationCode: event.locationCode, // เพิ่มบรรทัดนี้
        period: event.period,
        year: event.year,
        startDate: event.startDate,
        endDate: event.endDate,
        groupBy: event.groupBy,
      ),
    );

    result.fold(
      (failure) {
        emit(
          DashboardError(
            message: 'Failed to load trends: ${failure.message}',
            errorCode: 'TRENDS_ERROR',
            previousState: currentState is DashboardLoaded
                ? currentState
                : null,
          ),
        );
      },
      (trends) {
        if (currentState is DashboardLoaded) {
          emit(
            currentState.copyWith(
              growthTrend: trends,
              growthTrendDeptFilter: event.deptCode,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          emit(
            DashboardLoaded(
              growthTrend: trends,
              growthTrendDeptFilter: event.deptCode,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// Load initial dashboard data
  Future<void> _onLoadInitialDashboard(
    LoadInitialDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    print('🔵 Starting dashboard load...');
    emit(const DashboardLoading(loadingMessage: 'Loading dashboard...'));

    try {
      print('📡 Calling dashboard APIs...');

      // Load all dashboard data in parallel
      final Future<Either<Failure, DashboardStats>> statsResult =
          getDashboardStatsUseCase(
            const GetDashboardStatsParams(period: 'today'),
          );

      final Future<Either<Failure, AssetDistribution>> distributionResult =
          getAssetDistributionUseCase(GetAssetDistributionParams.all());

      final Future<Either<Failure, GrowthTrend>> trendsResult =
          getGrowthTrendsUseCase(
            GetGrowthTrendsParams(
              deptCode: null,
              locationCode: null,
              period: 'Q2',
              year: DateTime.now().year,
            ),
          );

      final Future<Either<Failure, AuditProgress>> auditResult =
          getAuditProgressUseCase(GetAuditProgressParams.overview());

      final Future<Either<Failure, LocationAnalytics>> locationAnalyticsResult =
          getLocationAnalyticsUseCase(
            GetLocationAnalyticsParams.allLocations(),
          );

      // เพิ่ม location trends (แยกจาก department trends)
      final Future<Either<Failure, GrowthTrend>> locationTrendsResult =
          getGrowthTrendsUseCase(
            GetGrowthTrendsParams(
              deptCode: null,
              locationCode: null,
              period: 'Q2',
              year: DateTime.now().year,
            ),
          );

      // Wait for all results (เปลี่ยนจาก 5 เป็น 6)
      final results = await Future.wait([
        statsResult,
        distributionResult,
        trendsResult,
        auditResult,
        locationAnalyticsResult,
        locationTrendsResult, // เพิ่มบรรทัดนี้
      ]);

      print(
        '📊 Stats result: ${results[0].isRight ? "✅ SUCCESS" : "❌ FAILED"}',
      );
      print(
        '📈 Distribution result: ${results[1].isRight ? "✅ SUCCESS" : "❌ FAILED"}',
      );
      print(
        '📉 Trends result: ${results[2].isRight ? "✅ SUCCESS" : "❌ FAILED"}',
      );
      print(
        '📋 Audit result: ${results[3].isRight ? "✅ SUCCESS" : "❌ FAILED"}',
      );
      print(
        '📍 Location Analytics result: ${results[4].isRight ? "✅ SUCCESS" : "❌ FAILED"}',
      );
      print(
        '🏢 Location Trends result: ${results[5].isRight ? "✅ SUCCESS" : "❌ FAILED"}',
      );

      // Check individual failures
      if (results[0].isLeft) {
        final failure = (results[0] as Left).left;
        print('❌ Stats error: ${failure.message}');
      }

      if (results[1].isLeft) {
        final failure = (results[1] as Left).left;
        print('❌ Distribution error: ${failure.message}');
      }

      if (results[2].isLeft) {
        final failure = (results[2] as Left).left;
        print('❌ Trends error: ${failure.message}');
      }

      if (results[3].isLeft) {
        final failure = (results[3] as Left).left;
        print('❌ Audit error: ${failure.message}');
      }

      // Check if any critical data failed to load
      if (results[0].isLeft) {
        print('💥 Critical failure: Dashboard stats failed');
        emit(
          DashboardError(
            message: 'Failed to load dashboard statistics',
            errorCode: 'STATS_LOAD_ERROR',
          ),
        );
        return;
      }

      print('✅ Loading dashboard data successfully');
      emit(
        DashboardLoaded(
          stats: results[0].fold((l) => null, (r) => r as DashboardStats?),
          distribution: results[1].fold(
            (l) => null,
            (r) => r as AssetDistribution?,
          ),
          growthTrend: results[2].fold((l) => null, (r) => r as GrowthTrend?),
          auditProgress: results[3].fold(
            (l) => null,
            (r) => r as AuditProgress?,
          ),
          locationAnalytics: results[4].fold(
            (l) => null,
            (r) => r as LocationAnalytics?,
          ),
          locationTrend: results[5].fold(
            (l) => null,
            (r) => r as GrowthTrend?,
          ), // เพิ่มบรรทัดนี้
          lastUpdated: DateTime.now(),
        ),
      );

      print('🎉 Dashboard loaded successfully!');
    } catch (e, stackTrace) {
      print('💥 Unexpected dashboard error: $e');
      print('📍 Stack trace: $stackTrace');
      emit(
        DashboardError(
          message: 'Unexpected error loading dashboard: $e',
          errorCode: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Load dashboard statistics
  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      emit(
        DashboardPartialLoading(
          currentState: currentState,
          loadingType: 'stats',
        ),
      );
    } else {
      emit(const DashboardLoading(loadingMessage: 'Loading statistics...'));
    }

    final result = await getDashboardStatsUseCase(
      GetDashboardStatsParams(period: event.period),
    );

    result.fold(
      (failure) {
        emit(
          DashboardError(
            message: 'Failed to load statistics: ${failure.message}',
            errorCode: 'STATS_ERROR',
            previousState: currentState is DashboardLoaded
                ? currentState
                : null,
          ),
        );
      },
      (stats) {
        if (currentState is DashboardLoaded) {
          emit(
            currentState.copyWith(
              stats: stats,
              currentPeriod: event.period,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          emit(
            DashboardLoaded(
              stats: stats,
              currentPeriod: event.period,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// Load asset distribution
  Future<void> _onLoadAssetDistribution(
    LoadAssetDistribution event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      emit(
        DashboardPartialLoading(
          currentState: currentState,
          loadingType: 'distribution',
        ),
      );
    } else {
      emit(const DashboardLoading(loadingMessage: 'Loading distribution...'));
    }

    final result = await getAssetDistributionUseCase(
      GetAssetDistributionParams(plantCode: event.plantCode),
    );

    result.fold(
      (failure) {
        emit(
          DashboardError(
            message: 'Failed to load distribution: ${failure.message}',
            errorCode: 'DISTRIBUTION_ERROR',
            previousState: currentState is DashboardLoaded
                ? currentState
                : null,
          ),
        );
      },
      (distribution) {
        if (currentState is DashboardLoaded) {
          emit(
            currentState.copyWith(
              distribution: distribution,
              currentPlantFilter: event.plantCode,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          emit(
            DashboardLoaded(
              distribution: distribution,
              currentPlantFilter: event.plantCode,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// Load audit progress
  Future<void> _onLoadAuditProgress(
    LoadAuditProgress event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      emit(
        DashboardPartialLoading(
          currentState: currentState,
          loadingType: 'audit',
        ),
      );
    } else {
      emit(const DashboardLoading(loadingMessage: 'Loading audit progress...'));
    }

    final result = await getAuditProgressUseCase(
      GetAuditProgressParams(
        deptCode: event.deptCode,
        includeDetails: event.includeDetails,
        auditStatus: event.auditStatus,
      ),
    );

    result.fold(
      (failure) {
        emit(
          DashboardError(
            message: 'Failed to load audit progress: ${failure.message}',
            errorCode: 'AUDIT_ERROR',
            previousState: currentState is DashboardLoaded
                ? currentState
                : null,
          ),
        );
      },
      (audit) {
        if (currentState is DashboardLoaded) {
          emit(
            currentState.copyWith(
              auditProgress: audit,
              auditProgressDeptFilter:
                  event.deptCode, // ใช้ auditProgressDeptFilter
              includeDetails: event.includeDetails,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          emit(
            DashboardLoaded(
              auditProgress: audit,
              auditProgressDeptFilter:
                  event.deptCode, // ใช้ auditProgressDeptFilter
              includeDetails: event.includeDetails,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// Refresh all dashboard data
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(loadingMessage: 'Refreshing dashboard...'));

    // Clear cache first to ensure fresh data
    await clearDashboardCacheUseCase();

    // Reload all data
    add(const LoadInitialDashboard());
  }

  /// Clear dashboard cache
  Future<void> _onClearDashboardCache(
    ClearDashboardCache event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await clearDashboardCacheUseCase();

    result.fold(
      (failure) {
        emit(
          DashboardError(
            message: 'Failed to clear cache: ${failure.message}',
            errorCode: 'CACHE_CLEAR_ERROR',
          ),
        );
      },
      (_) {
        emit(const DashboardCacheCleared());
      },
    );
  }

  /// Change period filter
  Future<void> _onChangePeriodFilter(
    ChangePeriodFilter event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboardStats(period: event.period));
  }

  /// Change plant filter
  Future<void> _onChangePlantFilter(
    ChangePlantFilter event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadAssetDistribution(plantCode: event.plantCode));
  }

  // ลบ _onChangeDepartmentFilter method ออก

  /// Toggle details view
  Future<void> _onToggleDetailsView(
    ToggleDetailsView event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      add(
        LoadAuditProgress(
          deptCode: currentState
              .auditProgressDeptFilter, // ใช้ auditProgressDeptFilter
          includeDetails: event.includeDetails,
        ),
      );
    }
  }

  /// Reset all filters
  Future<void> _onResetFilters(
    ResetFilters event,
    Emitter<DashboardState> emit,
  ) async {
    add(const LoadInitialDashboard());
  }

  /// Load location analytics
  Future<void> _onLoadLocationAnalytics(
    LoadLocationAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      emit(
        DashboardPartialLoading(
          currentState: currentState,
          loadingType: 'location_analytics',
        ),
      );
    } else {
      emit(
        const DashboardLoading(loadingMessage: 'Loading location analytics...'),
      );
    }

    final result = await getLocationAnalyticsUseCase(
      GetLocationAnalyticsParams(
        locationCode: event.locationCode,
        period: event.period,
        year: event.year,
        startDate: event.startDate,
        endDate: event.endDate,
        includeTrends: event.includeTrends,
      ),
    );

    result.fold(
      (failure) {
        print('❌ Location Analytics failure: ${failure.message}');
        emit(
          DashboardError(
            message: 'Failed to load location analytics: ${failure.message}',
            errorCode: 'LOCATION_ANALYTICS_ERROR',
            previousState: currentState is DashboardLoaded
                ? currentState
                : null,
          ),
        );
      },
      (locationAnalytics) {
        print('✅ Location Analytics success!');
        print(
          '📊 Location trends count: ${locationAnalytics.locationTrends.length}',
        );
        print('📊 Has data: ${locationAnalytics.hasData}');
        print(
          '📊 First trend: ${locationAnalytics.locationTrends.isNotEmpty ? locationAnalytics.locationTrends.first.locationCode : "none"}',
        );

        if (currentState is DashboardLoaded) {
          emit(
            currentState.copyWith(
              locationAnalytics: locationAnalytics,
              locationAnalyticsLocationFilter: event.locationCode,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          emit(
            DashboardLoaded(
              locationAnalytics: locationAnalytics,
              locationAnalyticsLocationFilter: event.locationCode,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      },
    );
  }
}
