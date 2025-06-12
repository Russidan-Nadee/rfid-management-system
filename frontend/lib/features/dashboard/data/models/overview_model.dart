// Path: frontend/lib/features/dashboard/data/models/overview_model.dart

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
    return OverviewModel(
      totalAssets: json['total_assets'] ?? 0,
      activeAssets: json['active_assets'] ?? 0,
      inactiveAssets: json['inactive_assets'] ?? 0,
      createdAssets: json['created_assets'] ?? 0,
      todayScans: json['today_scans'] ?? 0,
      exportSuccess7d: json['export_success_7d'] ?? 0,
      exportFailed7d: json['export_failed_7d'] ?? 0,
    );
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
}
