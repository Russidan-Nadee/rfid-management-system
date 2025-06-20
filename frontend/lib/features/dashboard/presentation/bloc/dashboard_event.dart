// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_event.dart
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard statistics
class LoadDashboardStats extends DashboardEvent {
  final String period;

  const LoadDashboardStats({this.period = 'today'});

  @override
  List<Object> get props => [period];
}

/// Event to load asset distribution
class LoadAssetDistribution extends DashboardEvent {
  final String? plantCode;
  final String? deptCode;

  const LoadAssetDistribution({this.plantCode, this.deptCode});

  @override
  List<Object?> get props => [plantCode];
}

/// Event to load growth trends
class LoadGrowthTrends extends DashboardEvent {
  final String? deptCode;
  final String period;
  final int? year;
  final String? startDate;
  final String? endDate;
  final String groupBy;

  const LoadGrowthTrends({
    this.deptCode,
    this.period = 'Q2',
    this.year,
    this.startDate,
    this.endDate,
    this.groupBy = 'day',
  });

  @override
  List<Object?> get props => [deptCode, period, year, startDate, endDate];
}

/// Event to load audit progress
class LoadAuditProgress extends DashboardEvent {
  final String? deptCode;
  final bool includeDetails;
  final String? auditStatus;

  const LoadAuditProgress({
    this.deptCode,
    this.includeDetails = false,
    this.auditStatus,
  });

  @override
  List<Object?> get props => [deptCode, includeDetails, auditStatus];
}

/// Event to refresh all dashboard data
class RefreshDashboard extends DashboardEvent {
  final String period;
  final String? plantCode;
  final String? deptCode;

  const RefreshDashboard({
    this.period = 'today',
    this.plantCode,
    this.deptCode,
  });

  @override
  List<Object?> get props => [period, plantCode, deptCode];
}

/// Event to clear dashboard cache
class ClearDashboardCache extends DashboardEvent {
  const ClearDashboardCache();
}

/// Event to change period filter
class ChangePeriodFilter extends DashboardEvent {
  final String period;

  const ChangePeriodFilter(this.period);

  @override
  List<Object> get props => [period];
}

/// Event to change plant filter
class ChangePlantFilter extends DashboardEvent {
  final String? plantCode;

  const ChangePlantFilter(this.plantCode);

  @override
  List<Object?> get props => [plantCode];
}

/// Event to change department filter
class ChangeDepartmentFilter extends DashboardEvent {
  final String? deptCode;

  const ChangeDepartmentFilter(this.deptCode);

  @override
  List<Object?> get props => [deptCode];
}

/// Event to toggle details view
class ToggleDetailsView extends DashboardEvent {
  final bool includeDetails;

  const ToggleDetailsView(this.includeDetails);

  @override
  List<Object> get props => [includeDetails];
}

/// Event to reset filters
class ResetFilters extends DashboardEvent {
  const ResetFilters();
}

/// Event to load initial dashboard data
class LoadInitialDashboard extends DashboardEvent {
  const LoadInitialDashboard();
}

/// Event to load location analytics
class LoadLocationAnalytics extends DashboardEvent {
  final String? locationCode;
  final String period;
  final int? year;
  final String? startDate;
  final String? endDate;
  final bool includeTrends;

  const LoadLocationAnalytics({
    this.locationCode,
    this.period = 'Q2',
    this.year,
    this.startDate,
    this.endDate,
    this.includeTrends = true,
  });

  @override
  List<Object?> get props => [
    locationCode,
    period,
    year,
    startDate,
    endDate,
    includeTrends,
  ];
}
