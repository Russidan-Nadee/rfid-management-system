// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_event.dart
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load complete dashboard statistics with charts
class LoadDashboardStats extends DashboardEvent {
  final bool forceRefresh;

  const LoadDashboardStats({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Load overview data only (lightweight)
class LoadOverviewData extends DashboardEvent {
  final bool forceRefresh;

  const LoadOverviewData({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Load quick statistics for summary cards
class LoadQuickStats extends DashboardEvent {
  final bool forceRefresh;

  const LoadQuickStats({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Load department analytics (pie chart data)
class LoadDepartmentAnalytics extends DashboardEvent {
  final String? plantCode;
  final bool forceRefresh;

  const LoadDepartmentAnalytics({this.plantCode, this.forceRefresh = false});

  @override
  List<Object?> get props => [plantCode, forceRefresh];
}

/// Load growth trends (line chart data)
class LoadGrowthTrends extends DashboardEvent {
  final String? deptCode;
  final String period;
  final int? year;
  final String? startDate;
  final String? endDate;
  final bool forceRefresh;

  const LoadGrowthTrends({
    this.deptCode,
    this.period = 'Q2',
    this.year,
    this.startDate,
    this.endDate,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    deptCode,
    period,
    year,
    startDate,
    endDate,
    forceRefresh,
  ];
}

/// Load location analytics data
class LoadLocationAnalytics extends DashboardEvent {
  final String? locationCode;
  final String period;
  final int? year;
  final String? startDate;
  final String? endDate;
  final bool includeTrends;
  final bool forceRefresh;

  const LoadLocationAnalytics({
    this.locationCode,
    this.period = 'Q2',
    this.year,
    this.startDate,
    this.endDate,
    this.includeTrends = true,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    locationCode,
    period,
    year,
    startDate,
    endDate,
    includeTrends,
    forceRefresh,
  ];
}

/// Load audit progress data
class LoadAuditProgress extends DashboardEvent {
  final String? deptCode;
  final bool includeDetails;
  final String? auditStatus;
  final bool forceRefresh;

  const LoadAuditProgress({
    this.deptCode,
    this.includeDetails = false,
    this.auditStatus,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    deptCode,
    includeDetails,
    auditStatus,
    forceRefresh,
  ];
}

/// Refresh all dashboard data
class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

/// Clear dashboard cache
class ClearDashboardCache extends DashboardEvent {
  const ClearDashboardCache();
}

/// Change time period filter
class ChangePeriod extends DashboardEvent {
  final String period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Load alerts
class LoadAlerts extends DashboardEvent {
  final bool forceRefresh;

  const LoadAlerts({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Load recent activities
class LoadRecentActivities extends DashboardEvent {
  final String period;
  final bool forceRefresh;

  const LoadRecentActivities({this.period = '7d', this.forceRefresh = false});

  @override
  List<Object?> get props => [period, forceRefresh];
}
