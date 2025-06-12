// Path: frontend/lib/features/dashboard/domain/entities/overview.dart
class Overview {
  final int totalAssets;
  final int activeAssets;
  final int inactiveAssets;
  final int createdAssets;
  final int todayScans;
  final int exportSuccess7d;
  final int exportFailed7d;

  const Overview({
    required this.totalAssets,
    required this.activeAssets,
    required this.inactiveAssets,
    required this.createdAssets,
    required this.todayScans,
    required this.exportSuccess7d,
    required this.exportFailed7d,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Overview &&
        other.totalAssets == totalAssets &&
        other.activeAssets == activeAssets &&
        other.inactiveAssets == inactiveAssets &&
        other.createdAssets == createdAssets &&
        other.todayScans == todayScans &&
        other.exportSuccess7d == exportSuccess7d &&
        other.exportFailed7d == exportFailed7d;
  }

  @override
  int get hashCode {
    return totalAssets.hashCode ^
        activeAssets.hashCode ^
        inactiveAssets.hashCode ^
        createdAssets.hashCode ^
        todayScans.hashCode ^
        exportSuccess7d.hashCode ^
        exportFailed7d.hashCode;
  }

  @override
  String toString() {
    return 'Overview(totalAssets: $totalAssets, activeAssets: $activeAssets, inactiveAssets: $inactiveAssets, createdAssets: $createdAssets, todayScans: $todayScans, exportSuccess7d: $exportSuccess7d, exportFailed7d: $exportFailed7d)';
  }
}
