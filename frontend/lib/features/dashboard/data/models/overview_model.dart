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
  final int? scansChangePercent;
  final String? scansTrend;
  final int? exportSuccessChangePercent;
  final String? exportSuccessTrend;
  final int? exportFailedChangePercent;
  final String? exportFailedTrend;

  OverviewModel({
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

  factory OverviewModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle nested structure from Backend
      final overview = json['overview'] as Map<String, dynamic>? ?? json;

      // Extract basic values directly
      final totalAssets = overview['total_assets'] ?? 0;
      final activeAssets = overview['active_assets'] ?? 0;
      final inactiveAssets = overview['inactive_assets'] ?? 0;
      final createdAssets = overview['created_assets'] ?? 0;

      // Extract scan data
      final scansData = overview['scans'] as Map<String, dynamic>?;
      final todayScans = scansData?['value'] ?? 0;
      final scansChangePercent = scansData?['change_percent'];
      final scansTrend = scansData?['trend'];

      // Extract export success data
      final exportSuccessData =
          overview['export_success'] as Map<String, dynamic>?;
      final exportSuccess7d = exportSuccessData?['value'] ?? 0;
      final exportSuccessChangePercent = exportSuccessData?['change_percent'];
      final exportSuccessTrend = exportSuccessData?['trend'];

      // Extract export failed data
      final exportFailedData =
          overview['export_failed'] as Map<String, dynamic>?;
      final exportFailed7d = exportFailedData?['value'] ?? 0;
      final exportFailedChangePercent = exportFailedData?['change_percent'];
      final exportFailedTrend = exportFailedData?['trend'];

      return OverviewModel(
        totalAssets: totalAssets,
        activeAssets: activeAssets,
        inactiveAssets: inactiveAssets,
        createdAssets: createdAssets,
        todayScans: todayScans,
        exportSuccess7d: exportSuccess7d,
        exportFailed7d: exportFailed7d,
        scansChangePercent: scansChangePercent,
        scansTrend: scansTrend,
        exportSuccessChangePercent: exportSuccessChangePercent,
        exportSuccessTrend: exportSuccessTrend,
        exportFailedChangePercent: exportFailedChangePercent,
        exportFailedTrend: exportFailedTrend,
      );
    } catch (e, stackTrace) {
      print('❌ ERROR: OverviewModel.fromJson failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');

      // Return fallback model
      return OverviewModel(
        totalAssets: 0,
        activeAssets: 0,
        inactiveAssets: 0,
        createdAssets: 0,
        todayScans: 0,
        exportSuccess7d: 0,
        exportFailed7d: 0,
      );
    }
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
      'scans_change_percent': scansChangePercent,
      'scans_trend': scansTrend,
      'export_success_change_percent': exportSuccessChangePercent,
      'export_success_trend': exportSuccessTrend,
      'export_failed_change_percent': exportFailedChangePercent,
      'export_failed_trend': exportFailedTrend,
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
      scansChangePercent: scansChangePercent,
      scansTrend: scansTrend,
      exportSuccessChangePercent: exportSuccessChangePercent,
      exportSuccessTrend: exportSuccessTrend,
      exportFailedChangePercent: exportFailedChangePercent,
      exportFailedTrend: exportFailedTrend,
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
