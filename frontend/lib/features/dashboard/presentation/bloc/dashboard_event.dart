// Path: frontend/lib/features/dashboard/presentation/bloc/dashboard_event.dart
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final String period;
  final bool forceRefresh;

  const LoadDashboard({this.period = '7d', this.forceRefresh = false});

  @override
  List<Object?> get props => [period, forceRefresh];
}

class RefreshDashboard extends DashboardEvent {
  final String period;

  const RefreshDashboard({this.period = '7d'});

  @override
  List<Object?> get props => [period];
}

class ChangePeriod extends DashboardEvent {
  final String period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

class LoadAlerts extends DashboardEvent {
  final bool forceRefresh;

  const LoadAlerts({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class LoadRecentActivities extends DashboardEvent {
  final String period;
  final bool forceRefresh;

  const LoadRecentActivities({this.period = '7d', this.forceRefresh = false});

  @override
  List<Object?> get props => [period, forceRefresh];
}

class ClearDashboardCache extends DashboardEvent {
  const ClearDashboardCache();
}

class RetryDashboardLoad extends DashboardEvent {
  final String period;

  const RetryDashboardLoad({this.period = '7d'});

  @override
  List<Object?> get props => [period];
}
