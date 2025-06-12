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

      print('🔍 DEBUG: Overview JSON structure:');
      print('Raw overview data: $overview');

      // Extract values with enhanced debugging
      final totalAssets = _extractValue(overview['total_assets']) ?? 0;
      final activeAssets = _extractValue(overview['active_assets']) ?? 0;
      final inactiveAssets = _extractValue(overview['inactive_assets']) ?? 0;
      final createdAssets = _extractValue(overview['created_assets']) ?? 0;
      final todayScans = _extractValue(overview['scans']) ?? 0;
      final exportSuccess7d = _extractValue(overview['export_success']) ?? 0;
      final exportFailed7d = _extractValue(overview['export_failed']) ?? 0;

      // Extract trend data with debugging
      final scansData = overview['scans'];
      final exportSuccessData = overview['export_success'];
      final exportFailedData = overview['export_failed'];

      print('📊 DEBUG: Trend data extraction:');
      print('Scans data: $scansData');
      print('Export success data: $exportSuccessData');
      print('Export failed data: $exportFailedData');

      // Parse trend information
      final scansChangePercent = _extractChangePercent(scansData);
      final scansTrend = _extractTrend(scansData);
      final exportSuccessChangePercent = _extractChangePercent(
        exportSuccessData,
      );
      final exportSuccessTrend = _extractTrend(exportSuccessData);
      final exportFailedChangePercent = _extractChangePercent(exportFailedData);
      final exportFailedTrend = _extractTrend(exportFailedData);

      print('🔄 DEBUG: Parsed trend values:');
      print('Scans: $scansChangePercent% ($scansTrend)');
      print(
        'Export Success: $exportSuccessChangePercent% ($exportSuccessTrend)',
      );
      print('Export Failed: $exportFailedChangePercent% ($exportFailedTrend)');

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

  // Helper method to extract value from nested objects
  static int? _extractValue(dynamic data) {
    if (data == null) return null;

    if (data is int) {
      return data;
    } else if (data is Map<String, dynamic>) {
      final value = data['value'];
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    } else if (data is String) {
      return int.tryParse(data);
    }

    print(
      '⚠️ WARNING: Could not extract value from: $data (${data.runtimeType})',
    );
    return null;
  }

  // Helper method to extract change percentage
  static int? _extractChangePercent(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      final changePercent = data['change_percent'];
      if (changePercent is int) return changePercent;
      if (changePercent is double) return changePercent.round();
      if (changePercent is String) return int.tryParse(changePercent);
    }

    return null;
  }

  // Helper method to extract trend direction
  static String? _extractTrend(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      final trend = data['trend'];
      if (trend is String) return trend;
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
