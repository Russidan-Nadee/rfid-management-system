// Path: frontend/lib/features/dashboard/data/models/overview_model.dart
import '../../domain/entities/overview.dart';

class OverviewModel {
  final int totalAssets;
  final int activeAssets;
  final int inactiveAssets;
  final int createdAssets;
  final int todayScans;
  final int exportSuccess7d;
  final int exportFailed7d;

  OverviewModel({
    required this.totalAssets,
    required this.activeAssets,
    required this.inactiveAssets,
    required this.createdAssets,
    required this.todayScans,
    required this.exportSuccess7d,
    required this.exportFailed7d,
  });

  factory OverviewModel.fromJson(Map<String, dynamic> json) {
    // Handle nested structure from Backend
    final overview = json['overview'] as Map<String, dynamic>? ?? json;

    return OverviewModel(
      // Extract value from nested objects: { value: 1240, change_percent: 0, trend: 'stable' }
      totalAssets: _extractValue(overview['total_assets']) ?? 0,
      activeAssets: _extractValue(overview['active_assets']) ?? 0,
      inactiveAssets: _extractValue(overview['inactive_assets']) ?? 0,
      createdAssets: _extractValue(overview['created_assets']) ?? 0,
      todayScans: _extractValue(overview['scans']) ?? 0,
      exportSuccess7d: _extractValue(overview['export_success']) ?? 0,
      exportFailed7d: _extractValue(overview['export_failed']) ?? 0,
    );
  }

  // Helper method to extract value from nested objects
  static int? _extractValue(dynamic data) {
    if (data is int) {
      return data;
    } else if (data is Map<String, dynamic>) {
      return data['value'] as int?;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_assets': totalAssets,
      'active_assets': activeAssets,
      'inactive_assets': inactiveAssets,
      'created_assets': createdAssets,
      'today_scans': todayScans,
      'export_success_7d': exportSuccess7d,
      'export_failed_7d': exportFailed7d,
    };
  }

  Overview toEntity() {
    return Overview(
      totalAssets: totalAssets,
      activeAssets: activeAssets,
      inactiveAssets: inactiveAssets,
      createdAssets: createdAssets,
      todayScans: todayScans,
      exportSuccess7d: exportSuccess7d,
      exportFailed7d: exportFailed7d,
    );
  }

  // Helper methods for UI
  double get activePercentage {
    if (totalAssets == 0) return 0.0;
    return (activeAssets / totalAssets) * 100;
  }

  double get inactivePercentage {
    if (totalAssets == 0) return 0.0;
    return (inactiveAssets / totalAssets) * 100;
  }

  double get createdPercentage {
    if (totalAssets == 0) return 0.0;
    return (createdAssets / totalAssets) * 100;
  }

  int get totalExports7d => exportSuccess7d + exportFailed7d;

  double get exportSuccessRate {
    if (totalExports7d == 0) return 0.0;
    return (exportSuccess7d / totalExports7d) * 100;
  }

  bool get hasAssets => totalAssets > 0;
  bool get hasScansToday => todayScans > 0;
  bool get hasExports => totalExports7d > 0;
  bool get hasFailedExports => exportFailed7d > 0;

  // Status indicators
  String get assetHealthStatus {
    final activeRate = activePercentage;
    if (activeRate >= 80) return 'excellent';
    if (activeRate >= 60) return 'good';
    if (activeRate >= 40) return 'average';
    return 'poor';
  }

  String get exportHealthStatus {
    if (totalExports7d == 0) return 'no_data';
    final successRate = exportSuccessRate;
    if (successRate >= 95) return 'excellent';
    if (successRate >= 80) return 'good';
    if (successRate >= 60) return 'average';
    return 'poor';
  }
}
