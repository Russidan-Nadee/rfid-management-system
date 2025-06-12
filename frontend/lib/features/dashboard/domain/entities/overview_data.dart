// Path: frontend/lib/features/dashboard/domain/entities/overview_data.dart
import 'overview.dart';

class OverviewData {
  final Overview overview;
  final DateTime lastUpdated;

  const OverviewData({required this.overview, required this.lastUpdated});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OverviewData &&
        other.overview == overview &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return overview.hashCode ^ lastUpdated.hashCode;
  }

  @override
  String toString() {
    return 'OverviewData(overview: $overview, lastUpdated: $lastUpdated)';
  }
}
