// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_state.dart
import 'package:equatable/equatable.dart';
import 'package:tp_rfid/features/dashboard/domain/entities/location_analytics.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/asset_distribution.dart';
import '../../domain/entities/growth_trend.dart';
import '../../domain/entities/audit_progress.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  final String? loadingMessage;

  const DashboardLoading({this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

/// Loaded state with all dashboard data
class DashboardLoaded extends DashboardState {
  final DashboardStats? stats;
  final AssetDistribution? distribution;
  final GrowthTrend? departmentGrowthTrend; // แยกสำหรับ Department
  final GrowthTrend? locationGrowthTrend; // แยกสำหรับ Location
  final AuditProgress? auditProgress;
  final LocationAnalytics? locationAnalytics;
  final String currentPeriod;
  final String? currentPlantFilter;
  // แยก filters สำหรับแต่ละ component
  final String? departmentGrowthDeptFilter; // สำหรับ Department Growth
  final String? locationGrowthLocationFilter; // สำหรับ Location Growth
  final String? auditProgressDeptFilter; // สำหรับ Audit Progress
  final String? locationAnalyticsLocationFilter;
  final bool includeDetails;
  final DateTime lastUpdated;

  const DashboardLoaded({
    this.stats,
    this.distribution,
    this.departmentGrowthTrend,
    this.locationGrowthTrend,
    this.auditProgress,
    this.locationAnalytics,
    this.currentPeriod = 'today',
    this.currentPlantFilter,
    this.departmentGrowthDeptFilter,
    this.locationGrowthLocationFilter,
    this.auditProgressDeptFilter,
    this.locationAnalyticsLocationFilter,
    this.includeDetails = false,
    required this.lastUpdated,
  });

  /// Check if has any data loaded
  bool get hasAnyData =>
      stats != null ||
      distribution != null ||
      departmentGrowthTrend != null ||
      locationGrowthTrend != null ||
      auditProgress != null ||
      locationAnalytics != null;

  /// Check if has complete dashboard data
  bool get hasCompleteData =>
      stats != null &&
      distribution != null &&
      departmentGrowthTrend != null &&
      locationGrowthTrend != null &&
      auditProgress != null &&
      locationAnalytics != null;

  /// Check if data is recent (less than 5 minutes old)
  bool get isDataRecent => DateTime.now().difference(lastUpdated).inMinutes < 5;

  /// Check if has active filters
  bool get hasActiveFilters =>
      currentPlantFilter != null ||
      departmentGrowthDeptFilter != null ||
      locationGrowthLocationFilter != null ||
      auditProgressDeptFilter != null ||
      locationAnalyticsLocationFilter != null ||
      includeDetails;

  /// Copy with method for state updates
  DashboardLoaded copyWith({
    DashboardStats? stats,
    AssetDistribution? distribution,
    GrowthTrend? departmentGrowthTrend,
    GrowthTrend? locationGrowthTrend,
    AuditProgress? auditProgress,
    LocationAnalytics? locationAnalytics,
    String? currentPeriod,
    String? currentPlantFilter,
    String? departmentGrowthDeptFilter,
    String? locationGrowthLocationFilter,
    String? auditProgressDeptFilter, // พารามิเตอร์นี้รับ null ได้
    String? locationAnalyticsLocationFilter,
    bool? includeDetails,
    DateTime? lastUpdated,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      distribution: distribution ?? this.distribution,
      departmentGrowthTrend:
          departmentGrowthTrend ?? this.departmentGrowthTrend,
      locationGrowthTrend: locationGrowthTrend ?? this.locationGrowthTrend,
      auditProgress: auditProgress ?? this.auditProgress,
      locationAnalytics: locationAnalytics ?? this.locationAnalytics,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      currentPlantFilter: currentPlantFilter ?? this.currentPlantFilter,
      departmentGrowthDeptFilter: departmentGrowthDeptFilter,
      locationGrowthLocationFilter: locationGrowthLocationFilter,
      // >>>>>>>>>> นี่คือบรรทัดที่แก้ไข! <<<<<<<<<<
      // เราเปลี่ยนจากการใช้ '?? this.auditProgressDeptFilter'
      // เป็นการส่งค่า 'auditProgressDeptFilter' ตรงๆ
      // เพื่อให้สามารถตั้งค่าเป็น null ได้อย่างแท้จริง
      auditProgressDeptFilter: auditProgressDeptFilter,
      // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      locationAnalyticsLocationFilter:
          locationAnalyticsLocationFilter ??
          this.locationAnalyticsLocationFilter,
      includeDetails: includeDetails ?? this.includeDetails,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    stats,
    distribution,
    departmentGrowthTrend,
    locationGrowthTrend,
    auditProgress,
    locationAnalytics,
    currentPeriod,
    currentPlantFilter,
    departmentGrowthDeptFilter,
    locationGrowthLocationFilter,
    auditProgressDeptFilter, // ตรงนี้สำคัญมาก! ต้องมีตัวแปรนี้
    locationAnalyticsLocationFilter,
    includeDetails,
    lastUpdated,
  ];
}

/// Error state
class DashboardError extends DashboardState {
  final String message;
  final String? errorCode;
  final DashboardLoaded? previousState;

  const DashboardError({
    required this.message,
    this.errorCode,
    this.previousState,
  });

  /// Check if can retry the operation
  bool get canRetry => true;

  /// Check if has previous data to fallback to
  bool get hasPreviousData =>
      previousState != null && previousState!.hasAnyData;

  @override
  List<Object?> get props => [message, errorCode, previousState];
}

/// Partial loading state (when some data is already loaded)
class DashboardPartialLoading extends DashboardState {
  final DashboardLoaded currentState;
  final String
  loadingType; // 'stats', 'distribution', 'department_trends', 'location_trends', 'audit'

  const DashboardPartialLoading({
    required this.currentState,
    required this.loadingType,
  });

  @override
  List<Object> get props => [currentState, loadingType];
}

/// Cache cleared state
class DashboardCacheCleared extends DashboardState {
  final String message;

  const DashboardCacheCleared({this.message = 'Cache cleared successfully'});

  @override
  List<Object> get props => [message];
}
