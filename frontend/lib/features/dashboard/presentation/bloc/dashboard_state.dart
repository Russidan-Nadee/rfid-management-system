// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_state.dart
import 'package:equatable/equatable.dart';
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
  final GrowthTrend? growthTrend;
  final AuditProgress? auditProgress;
  final String currentPeriod;
  final String? currentPlantFilter;
  final String? currentDeptFilter;
  final bool includeDetails;
  final DateTime lastUpdated;

  const DashboardLoaded({
    this.stats,
    this.distribution,
    this.growthTrend,
    this.auditProgress,
    this.currentPeriod = 'today',
    this.currentPlantFilter,
    this.currentDeptFilter,
    this.includeDetails = false,
    required this.lastUpdated,
  });

  /// Check if has any data loaded
  bool get hasAnyData =>
      stats != null ||
      distribution != null ||
      growthTrend != null ||
      auditProgress != null;

  /// Check if has complete dashboard data
  bool get hasCompleteData =>
      stats != null &&
      distribution != null &&
      growthTrend != null &&
      auditProgress != null;

  /// Check if data is recent (less than 5 minutes old)
  bool get isDataRecent => DateTime.now().difference(lastUpdated).inMinutes < 5;

  /// Check if has active filters
  bool get hasActiveFilters =>
      currentPlantFilter != null || currentDeptFilter != null || includeDetails;

  /// Copy with method for state updates
  DashboardLoaded copyWith({
    DashboardStats? stats,
    AssetDistribution? distribution,
    GrowthTrend? growthTrend,
    AuditProgress? auditProgress,
    String? currentPeriod,
    String? currentPlantFilter,
    String? currentDeptFilter,
    bool? includeDetails,
    DateTime? lastUpdated,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      distribution: distribution ?? this.distribution,
      growthTrend: growthTrend ?? this.growthTrend,
      auditProgress: auditProgress ?? this.auditProgress,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      currentPlantFilter: currentPlantFilter ?? this.currentPlantFilter,
      currentDeptFilter: currentDeptFilter ?? this.currentDeptFilter,
      includeDetails: includeDetails ?? this.includeDetails,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    stats,
    distribution,
    growthTrend,
    auditProgress,
    currentPeriod,
    currentPlantFilter,
    currentDeptFilter,
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
  final String loadingType; // 'stats', 'distribution', 'trends', 'audit'

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
