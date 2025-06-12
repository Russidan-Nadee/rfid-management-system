// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/overview_data.dart';
import '../../domain/entities/alert.dart';
import '../../domain/entities/recent_activity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  final String period;
  final bool isRefreshing;

  const DashboardLoading({this.period = '7d', this.isRefreshing = false});

  @override
  List<Object?> get props => [period, isRefreshing];
}

class DashboardLoaded extends DashboardState {
  final DashboardStats dashboardStats;
  final OverviewData overviewData;
  final List<Alert> alerts;
  final RecentActivity recentActivities;
  final String currentPeriod;
  final DateTime lastUpdated;
  final bool isFromCache;

  const DashboardLoaded({
    required this.dashboardStats,
    required this.overviewData,
    required this.alerts,
    required this.recentActivities,
    required this.currentPeriod,
    required this.lastUpdated,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [
    dashboardStats,
    overviewData,
    alerts,
    recentActivities,
    currentPeriod,
    lastUpdated,
    isFromCache,
  ];

  // Helper getters
  bool get hasAlerts => alerts.isNotEmpty;
  bool get hasRecentScans => recentActivities.hasScans;
  bool get hasRecentExports => recentActivities.hasExports;

  int get totalAssets => dashboardStats.overview.totalAssets;
  int get activeAssets => dashboardStats.overview.activeAssets;
  int get todayScans => dashboardStats.overview.todayScans;

  // Copy with method for state updates
  DashboardLoaded copyWith({
    DashboardStats? dashboardStats,
    OverviewData? overviewData,
    List<Alert>? alerts,
    RecentActivity? recentActivities,
    String? currentPeriod,
    DateTime? lastUpdated,
    bool? isFromCache,
  }) {
    return DashboardLoaded(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      overviewData: overviewData ?? this.overviewData,
      alerts: alerts ?? this.alerts,
      recentActivities: recentActivities ?? this.recentActivities,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  final String errorType;
  final String period;
  final bool canRetry;

  const DashboardError({
    required this.message,
    this.errorType = 'general',
    this.period = '7d',
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, errorType, period, canRetry];

  // Helper getters for error types
  bool get isNetworkError => errorType == 'network';
  bool get isServerError => errorType == 'server';
  bool get isCacheError => errorType == 'cache';
  bool get isAuthError => errorType == 'auth';
}

class DashboardPartialLoaded extends DashboardState {
  final DashboardStats? dashboardStats;
  final OverviewData? overviewData;
  final List<Alert>? alerts;
  final RecentActivity? recentActivities;
  final String currentPeriod;
  final List<String> loadingComponents;
  final List<String> errorComponents;

  const DashboardPartialLoaded({
    this.dashboardStats,
    this.overviewData,
    this.alerts,
    this.recentActivities,
    required this.currentPeriod,
    this.loadingComponents = const [],
    this.errorComponents = const [],
  });

  @override
  List<Object?> get props => [
    dashboardStats,
    overviewData,
    alerts,
    recentActivities,
    currentPeriod,
    loadingComponents,
    errorComponents,
  ];

  // Helper getters
  bool get hasOverview => dashboardStats != null && overviewData != null;
  bool get hasAlerts => alerts != null;
  bool get hasRecentActivities => recentActivities != null;
  bool get isStatsLoading => loadingComponents.contains('stats');
  bool get isAlertsLoading => loadingComponents.contains('alerts');
  bool get isActivitiesLoading => loadingComponents.contains('activities');

  DashboardPartialLoaded copyWith({
    DashboardStats? dashboardStats,
    OverviewData? overviewData,
    List<Alert>? alerts,
    RecentActivity? recentActivities,
    String? currentPeriod,
    List<String>? loadingComponents,
    List<String>? errorComponents,
  }) {
    return DashboardPartialLoaded(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      overviewData: overviewData ?? this.overviewData,
      alerts: alerts ?? this.alerts,
      recentActivities: recentActivities ?? this.recentActivities,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      loadingComponents: loadingComponents ?? this.loadingComponents,
      errorComponents: errorComponents ?? this.errorComponents,
    );
  }
}

class DashboardRefreshing extends DashboardState {
  final DashboardLoaded currentData;
  final String refreshingComponent; // 'all', 'stats', 'alerts', 'activities'

  const DashboardRefreshing({
    required this.currentData,
    this.refreshingComponent = 'all',
  });

  @override
  List<Object?> get props => [currentData, refreshingComponent];
}
