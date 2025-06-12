// Path: frontend/lib/features/dashboard/domain/entities/overview.dart
class Overview {
  final int totalAssets;
  final int activeAssets;
  final int inactiveAssets;
  final int createdAssets;
  final int todayScans;
  final int exportSuccess7d;
  final int exportFailed7d;

  // Trend data for dynamic indicators
  final int? scansChangePercent;
  final String? scansTrend;
  final int? exportSuccessChangePercent;
  final String? exportSuccessTrend;
  final int? exportFailedChangePercent;
  final String? exportFailedTrend;

  const Overview({
    required this.totalAssets,
    required this.activeAssets,
    required this.inactiveAssets,
    required this.createdAssets,
    required this.todayScans,
    required this.exportSuccess7d,
    required this.exportFailed7d,
    this.scansChangePercent,
    this.scansTrend,
    this.exportSuccessChangePercent,
    this.exportSuccessTrend,
    this.exportFailedChangePercent,
    this.exportFailedTrend,
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
        other.exportFailed7d == exportFailed7d &&
        other.scansChangePercent == scansChangePercent &&
        other.scansTrend == scansTrend &&
        other.exportSuccessChangePercent == exportSuccessChangePercent &&
        other.exportSuccessTrend == exportSuccessTrend &&
        other.exportFailedChangePercent == exportFailedChangePercent &&
        other.exportFailedTrend == exportFailedTrend;
  }

  @override
  int get hashCode {
    return totalAssets.hashCode ^
        activeAssets.hashCode ^
        inactiveAssets.hashCode ^
        createdAssets.hashCode ^
        todayScans.hashCode ^
        exportSuccess7d.hashCode ^
        exportFailed7d.hashCode ^
        scansChangePercent.hashCode ^
        scansTrend.hashCode ^
        exportSuccessChangePercent.hashCode ^
        exportSuccessTrend.hashCode ^
        exportFailedChangePercent.hashCode ^
        exportFailedTrend.hashCode;
  }

  @override
  String toString() {
    return 'Overview(totalAssets: $totalAssets, activeAssets: $activeAssets, inactiveAssets: $inactiveAssets, createdAssets: $createdAssets, todayScans: $todayScans, exportSuccess7d: $exportSuccess7d, exportFailed7d: $exportFailed7d, scansChangePercent: $scansChangePercent, scansTrend: $scansTrend, exportSuccessChangePercent: $exportSuccessChangePercent, exportSuccessTrend: $exportSuccessTrend, exportFailedChangePercent: $exportFailedChangePercent, exportFailedTrend: $exportFailedTrend)';
  }

  // Helper getters for UI
  bool get hasScansData => todayScans > 0;
  bool get hasExportData => (exportSuccess7d + exportFailed7d) > 0;
  bool get hasAssetData => totalAssets > 0;

  // Trend helpers
  bool get hasScansChange => scansChangePercent != null && scansTrend != null;
  bool get hasExportSuccessChange =>
      exportSuccessChangePercent != null && exportSuccessTrend != null;
  bool get hasExportFailedChange =>
      exportFailedChangePercent != null && exportFailedTrend != null;

  // Health indicators
  double get activePercentage {
    if (totalAssets == 0) return 0.0;
    return (activeAssets / totalAssets) * 100;
  }

  double get exportSuccessRate {
    final total = exportSuccess7d + exportFailed7d;
    if (total == 0) return 0.0;
    return (exportSuccess7d / total) * 100;
  }
}
