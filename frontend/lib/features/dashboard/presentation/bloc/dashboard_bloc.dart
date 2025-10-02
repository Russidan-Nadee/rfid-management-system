// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp_rfid/core/errors/failures.dart';
import 'package:tp_rfid/core/utils/either.dart';
import 'package:tp_rfid/features/dashboard/domain/entities/asset_distribution.dart';
import 'package:tp_rfid/features/dashboard/domain/entities/assets_by_plant.dart';
import 'package:tp_rfid/features/dashboard/domain/entities/audit_progress.dart';
import 'package:tp_rfid/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:tp_rfid/features/dashboard/domain/entities/growth_trend.dart';
import 'package:tp_rfid/features/dashboard/domain/entities/location_analytics.dart';
import 'package:tp_rfid/features/dashboard/domain/usecases/get_location_analytics_usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_asset_distribution_usecase.dart';
import '../../domain/usecases/get_assets_by_plant_usecase.dart';
import '../../domain/usecases/get_growth_trends_usecase.dart';
import '../../domain/usecases/get_audit_progress_usecase.dart';
import '../../domain/usecases/clear_dashboard_cache_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetAssetDistributionUseCase getAssetDistributionUseCase;
  final GetAssetsByPlantUsecase getAssetsByPlantUsecase;
  final GetGrowthTrendsUseCase getGrowthTrendsUseCase;
  final GetAuditProgressUseCase getAuditProgressUseCase;
  final GetLocationAnalyticsUseCase getLocationAnalyticsUseCase;
  final ClearDashboardCacheUseCase clearDashboardCacheUseCase;

  DashboardBloc({
    required this.getDashboardStatsUseCase,
    required this.getAssetDistributionUseCase,
    required this.getAssetsByPlantUsecase,
    required this.getGrowthTrendsUseCase,
    required this.getAuditProgressUseCase,
    required this.getLocationAnalyticsUseCase,
    required this.clearDashboardCacheUseCase,
  }) : super(const DashboardInitial()) {
    on<LoadInitialDashboard>(_onLoadInitialDashboard);
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadAssetDistribution>(_onLoadAssetDistribution);
    on<LoadDepartmentGrowthTrends>(_onLoadDepartmentGrowthTrends);
    on<LoadLocationGrowthTrends>(_onLoadLocationGrowthTrends);
    on<LoadAuditProgress>(_onLoadAuditProgress);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ClearDashboardCache>(_onClearDashboardCache);
    on<ChangePeriodFilter>(_onChangePeriodFilter);
    on<ChangePlantFilter>(_onChangePlantFilter);
    on<ToggleDetailsView>(_onToggleDetailsView);
    on<ResetFilters>(_onResetFilters);
    on<LoadLocationAnalytics>(_onLoadLocationAnalytics);
  }

  /// Load department growth trends
  Future<void> _onLoadDepartmentGrowthTrends(
    LoadDepartmentGrowthTrends event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      emit(
        DashboardPartialLoading(
          currentState: currentState,
          loadingType: 'department_trends',
        ),
      );
    } else {
      emit(
        const DashboardLoading(loadingMessage: 'Loading department trends...'),
      );
    }

    final result = await getGrowthTrendsUseCase(
      GetGrowthTrendsParams(
        deptCode: event.deptCode,
        locationCode: null, // ไม่ส่ง location สำหรับ department trends
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
            message: 'Failed to load department trends: ${failure.message}',
            errorCode: 'DEPARTMENT_TRENDS_ERROR',
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
              departmentGrowthTrend: trends,
              departmentGrowthDeptFilter: event.deptCode,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          emit(
            DashboardLoaded(
              departmentGrowthTrend: trends,
              departmentGrowthDeptFilter: event.deptCode,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// Load location growth trends
  Future<void> _onLoadLocationGrowthTrends(
    LoadLocationGrowthTrends event,
    Emitter<DashboardState> emit,
  ) async {
    print('🔥 BLoC received locationCode: ${event.locationCode}');

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

    print('🔥 API call with params: locationCode=${event.locationCode}');

    print('🔍 About to call getGrowthTrendsUseCase with:');
    print('🔍 - locationCode: ${event.locationCode}');
    print('🔍 - period: ${event.period}');

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

    print('🔍 getGrowthTrendsUseCase completed');

    result.fold(
      (failure) {
        print('🔥 API failed: ${failure.message}');
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
        print('🔥 API success: ${trends.trends.length} trends found');
        if (trends.trends.isNotEmpty) {
          print(
            '🔥 First trend: ${trends.trends.first.period} - ${trends.trends.first.assetCount} assets',
          );
        }

        if (currentState is DashboardLoaded) {
          print('🔥 Emitting new state with locationGrowthTrend updated');
          print(
            '🔥 Old trends count: ${currentState.locationGrowthTrend?.trends.length ?? 0}',
          );
          print('🔥 New trends count: ${trends.trends.length}');

          emit(
            currentState.copyWith(
              locationGrowthTrend: trends,
              locationGrowthLocationFilter: event.locationCode,
              lastUpdated: DateTime.now(),
            ),
          );
          print('🔥 State emitted successfully');
        } else {
          print('🔥 Creating new DashboardLoaded state');
          emit(
            DashboardLoaded(
              locationGrowthTrend: trends,
              locationGrowthLocationFilter: event.locationCode,
              lastUpdated: DateTime.now(),
            ),
          );
          print('🔥 New state created successfully');
        }
      },
    );
  }

  /// Load initial dashboard data
  Future<void> _onLoadInitialDashboard(
    LoadInitialDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading(loadingMessage: 'Loading dashboard...'));

    try {

      // Load all dashboard data in parallel
      final Future<Either<Failure, DashboardStats>> statsResult =
          getDashboardStatsUseCase(
            const GetDashboardStatsParams(period: 'today'),
          );

      final Future<Either<Failure, AssetDistribution>> distributionResult =
          getAssetDistributionUseCase(GetAssetDistributionParams.all());

      final Future<Either<Failure, GrowthTrend>> departmentTrendsResult =
          getGrowthTrendsUseCase(
            GetGrowthTrendsParams(
              deptCode: null,
              locationCode: null,
              period: 'Q2',
              year: DateTime.now().year,
            ),
          );

      final Future<Either<Failure, GrowthTrend>> locationTrendsResult =
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

      final Future<Either<Failure, AssetsByPlant>> assetsByPlantResult =
          getAssetsByPlantUsecase();

      // Wait for all results
      final results = await Future.wait([
        statsResult,
        distributionResult,
        departmentTrendsResult,
        locationTrendsResult,
        auditResult,
        locationAnalyticsResult,
        assetsByPlantResult,
      ]);

      // Check if any critical data failed to load
      if (results[0].isLeft) {
        emit(
          const DashboardError(
            message: 'Failed to load dashboard statistics',
            errorCode: 'STATS_LOAD_ERROR',
          ),
        );
        return;
      }

      emit(
        DashboardLoaded(
          stats: results[0].fold((l) => null, (r) => r as DashboardStats?),
          distribution: results[1].fold(
            (l) => null,
            (r) => r as AssetDistribution?,
          ),
          departmentGrowthTrend: results[2].fold(
            (l) => null,
            (r) => r as GrowthTrend?,
          ),
          locationGrowthTrend: results[3].fold(
            (l) => null,
            (r) => r as GrowthTrend?,
          ),
          auditProgress: results[4].fold(
            (l) => null,
            (r) => r as AuditProgress?,
          ),
          locationAnalytics: results[5].fold(
            (l) => null,
            (r) => r as LocationAnalytics?,
          ),
          assetsByPlant: results[6].fold(
            (l) => null,
            (r) => r as AssetsByPlant?,
          ),
          lastUpdated: DateTime.now(),
        ),
      );

    } catch (e) {
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
    // 1. ดึง baseLoadedState ที่เป็น DashboardLoaded ตัวล่าสุด
    //    ไม่ว่าสถานะปัจจุบันของ Bloc จะเป็น DashboardLoaded หรือ DashboardPartialLoading
    DashboardLoaded? baseLoadedState;
    if (state is DashboardLoaded) {
      baseLoadedState = state as DashboardLoaded;
    } else if (state is DashboardPartialLoading) {
      baseLoadedState = (state as DashboardPartialLoading).currentState;
    }

    // 2. Emit partial loading state เพื่อบอก UI ว่ากำลังโหลด
    if (baseLoadedState != null) {
      // ถ้ามีข้อมูลเก่าอยู่ ให้แสดงข้อมูลเก่าระหว่างโหลด
      emit(
        DashboardPartialLoading(
          currentState: baseLoadedState,
          loadingType: 'audit',
        ),
      );
    } else {
      // ถ้ายังไม่มีข้อมูลเก่า (โหลดครั้งแรก) ให้แสดง Loading เต็มหน้าจอ
      emit(const DashboardLoading(loadingMessage: 'Loading audit progress...'));
    }

    // 3. เรียกใช้งาน UseCase เพื่อดึงข้อมูลจริง
    final result = await getAuditProgressUseCase(
      GetAuditProgressParams(
        deptCode: event
            .deptCode, // event.deptCode ตรงนี้จะเป็น null ถ้าเลือก All Departments
        includeDetails: event.includeDetails,
        auditStatus: event.auditStatus,
      ),
    );

    // 4. จัดการผลลัพธ์จาก UseCase
    result.fold(
      (failure) {
        // กรณีเกิดข้อผิดพลาด
        emit(
          DashboardError(
            message: 'Failed to load audit progress: ${failure.message}',
            errorCode: 'AUDIT_ERROR',
            previousState:
                baseLoadedState, // ใช้ baseLoadedState เป็น previous state
          ),
        );
      },
      (audit) {
        // กรณีโหลดข้อมูลสำเร็จ
        if (baseLoadedState != null) {
          print(
            '🔥 BLoC: Emitting DashboardLoaded with auditProgressDeptFilter: ${event.deptCode}',
          );
          emit(
            // ใช้ baseLoadedState.copyWith() เพื่ออัปเดตเฉพาะข้อมูลที่เปลี่ยนไป
            // auditProgressDeptFilter จะถูกตั้งค่าเป็น event.deptCode (ซึ่งจะเป็น null ถ้าเลือก All)
            baseLoadedState.copyWith(
              auditProgress: audit,
              auditProgressDeptFilter:
                  event.deptCode, // <<< ตรงนี้สำคัญ! จะเป็น null หรือ deptCode
              includeDetails: event.includeDetails,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          // กรณีโหลดครั้งแรกและยังไม่มี DashboardLoaded state มาก่อน
          print(
            '🔥 BLoC: Creating new DashboardLoaded state from scratch for audit progress',
          );
          emit(
            DashboardLoaded(
              auditProgress: audit,
              auditProgressDeptFilter:
                  event.deptCode, // <<< ตรงนี้สำคัญ! จะเป็น null หรือ deptCode
              includeDetails: event.includeDetails,
              lastUpdated: DateTime.now(),
              // ต้องแน่ใจว่า field อื่นๆ ถูกตั้งค่าเริ่มต้นที่เหมาะสมเมื่อสร้าง state ใหม่
              stats: null,
              distribution: null,
              departmentGrowthTrend: null,
              locationGrowthTrend: null,
              locationAnalytics: null,
              currentPeriod: 'today',
              currentPlantFilter: null,
              departmentGrowthDeptFilter: null,
              locationGrowthLocationFilter: null,
              locationAnalyticsLocationFilter: null,
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

  /// Toggle details view
  Future<void> _onToggleDetailsView(
    ToggleDetailsView event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      add(
        LoadAuditProgress(
          deptCode: currentState.auditProgressDeptFilter,
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
        // Location Analytics success

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
