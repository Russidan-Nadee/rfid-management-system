// Path: frontend/lib/features/dashboard/domain/entities/dashboard_stats.dart
import 'overview.dart';
import 'charts.dart';

class DashboardStats {
  final Overview overview;
  final Charts charts;

  const DashboardStats({required this.overview, required this.charts});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStats &&
        other.overview == overview &&
        other.charts == charts;
  }

  @override
  int get hashCode {
    return overview.hashCode ^ charts.hashCode;
  }

  @override
  String toString() {
    return 'DashboardStats(overview: $overview, charts: $charts)';
  }
}
