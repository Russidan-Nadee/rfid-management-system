// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/overview_data.dart';
import '../../domain/entities/alert.dart';
import '../../domain/entities/recent_activity.dart';
import '../../domain/entities/department_analytics.dart';
import '../../domain/entities/growth_trends.dart';
import '../../domain/entities/location_analytics.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state with message
class DashboardLoading extends DashboardState {
  final String message;

  const DashboardLoading({this.message = 'Loading...'});

  @override
  List<Object?> get props => [message];
}

/// Dashboard statistics loaded successfully
class DashboardStatsLoaded extends DashboardState {
  final DashboardStats stats;

  const DashboardStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Overview data loaded successfully
class OverviewDataLoaded extends DashboardState {
  final OverviewData overview;

  const OverviewDataLoaded(this.overview);

  @override
  List<Object?> get props => [overview];
}

/// Quick statistics loaded successfully
class QuickStatsLoaded extends DashboardState {
  final Map<String, dynamic> quickStats;

  const QuickStatsLoaded(this.quickStats);

  @override
  List<Object?> get props => [quickStats];
}

/// Department analytics loaded successfully
class DepartmentAnalyticsLoaded extends DashboardState {
  final DepartmentAnalytics analytics;

  const DepartmentAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

/// Growth trends loaded successfully
class GrowthTrendsLoaded extends DashboardState {
  final GrowthTrends trends;

  const GrowthTrendsLoaded(this.trends);

  @override
  List<Object?> get props => [trends];
}

/// Location analytics loaded successfully (legacy Map version)
class LocationAnalyticsLoaded extends DashboardState {
  final Map<String, dynamic> analytics;

  const LocationAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

/// Location analytics loaded with typed entity
class LocationAnalyticsLoadedEntity extends DashboardState {
  final LocationAnalytics analytics;

  const LocationAnalyticsLoadedEntity(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

/// Audit progress loaded successfully
class AuditProgressLoaded extends DashboardState {
  final Map<String, dynamic> progress;

  const AuditProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Alerts loaded successfully
class AlertsLoaded extends DashboardState {
  final List<Alert> alerts;

  const AlertsLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

/// Recent activities loaded successfully
class RecentActivitiesLoaded extends DashboardState {
  final RecentActivity activities;

  const RecentActivitiesLoaded(this.activities);

  @override
  List<Object?> get props => [activities];
}

/// Dashboard refreshed successfully
class DashboardRefreshed extends DashboardState {
  const DashboardRefreshed();
}

/// Dashboard cache cleared successfully
class DashboardCacheCleared extends DashboardState {
  const DashboardCacheCleared();
}

/// Period changed successfully
class DashboardPeriodChanged extends DashboardState {
  final String period;

  const DashboardPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

/// Multiple data loaded successfully (for combined UI)
class DashboardDataLoaded extends DashboardState {
  final DashboardStats? stats;
  final OverviewData? overview;
  final Map<String, dynamic>? quickStats;
  final List<Alert>? alerts;
  final RecentActivity? recentActivities;
  final DepartmentAnalytics? departmentAnalytics;
  final GrowthTrends? growthTrends;
  final LocationAnalytics? locationAnalytics;
  final Map<String, dynamic>? auditProgress;

  const DashboardDataLoaded({
    this.stats,
    this.overview,
    this.quickStats,
    this.alerts,
    this.recentActivities,
    this.departmentAnalytics,
    this.growthTrends,
    this.locationAnalytics,
    this.auditProgress,
  });

  @override
  List<Object?> get props => [
    stats,
    overview,
    quickStats,
    alerts,
    recentActivities,
    departmentAnalytics,
    growthTrends,
    locationAnalytics,
    auditProgress,
  ];

  /// Helper methods to check data availability
  bool get hasStats => stats != null;
  bool get hasOverview => overview != null;
  bool get hasQuickStats => quickStats != null;
  bool get hasAlerts => alerts != null && alerts!.isNotEmpty;
  bool get hasRecentActivities => recentActivities != null;
  bool get hasDepartmentAnalytics => departmentAnalytics != null;
  bool get hasGrowthTrends => growthTrends != null;
  bool get hasLocationAnalytics => locationAnalytics != null;
  bool get hasAuditProgress => auditProgress != null;

  /// Copy with method for updating specific data
  DashboardDataLoaded copyWith({
    DashboardStats? stats,
    OverviewData? overview,
    Map<String, dynamic>? quickStats,
    List<Alert>? alerts,
    RecentActivity? recentActivities,
    DepartmentAnalytics? departmentAnalytics,
    GrowthTrends? growthTrends,
    LocationAnalytics? locationAnalytics,
    Map<String, dynamic>? auditProgress,
  }) {
    return DashboardDataLoaded(
      stats: stats ?? this.stats,
      overview: overview ?? this.overview,
      quickStats: quickStats ?? this.quickStats,
      alerts: alerts ?? this.alerts,
      recentActivities: recentActivities ?? this.recentActivities,
      departmentAnalytics: departmentAnalytics ?? this.departmentAnalytics,
      growthTrends: growthTrends ?? this.growthTrends,
      locationAnalytics: locationAnalytics ?? this.locationAnalytics,
      auditProgress: auditProgress ?? this.auditProgress,
    );
  }
}

/// Error state
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}