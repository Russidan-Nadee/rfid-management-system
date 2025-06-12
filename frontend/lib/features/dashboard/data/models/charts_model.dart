// Path: frontend/lib/features/dashboard/data/models/charts_model.dart
import 'package:frontend/features/dashboard/domain/entities/scan_trend.dart';
import '../../domain/entities/charts.dart';
import 'asset_status_pie_model.dart';
import 'scan_trend_model.dart';

class ChartsModel {
  final AssetStatusPieModel assetStatusPie;
  final List<ScanTrendModel> scanTrend7d;

  ChartsModel({required this.assetStatusPie, required this.scanTrend7d});

  factory ChartsModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle Backend charts structure
      final assetStatusPieData = json['asset_status_pie'] as Map<String, dynamic>? ?? {};
      final scanTrendData = json['scan_trend_7d'] as List<dynamic>? ?? [];

      return ChartsModel(
        assetStatusPie: AssetStatusPieModel.fromJson(assetStatusPieData),
        scanTrend7d: scanTrendData
            .map((item) {
              if (item is Map<String, dynamic>) {
                return ScanTrendModel.fromJson(item);
              } else {
                // Handle malformed data
                return ScanTrendModel(
                  date: DateTime.now().toIso8601String().split('T')[0],
                  count: 0,
                  dayName: 'Unknown',
                );
              }
            })
            .toList(),
      );
    } catch (e) {
      // Fallback for parsing errors
      print('Charts model parsing error: $e');
      return ChartsModel(
        assetStatusPie: AssetStatusPieModel(
          active: 0,
          inactive: 0,
          created: 0,
          total: 0,
        ),
        scanTrend7d: _generateEmptyTrendData(),
      );
    }
  }

  // Generate empty trend data for last 7 days
  static List<ScanTrendModel> _generateEmptyTrendData() {
    final List<ScanTrendModel> trendData = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      trendData.add(ScanTrendModel(
        date: date.toIso8601String().split('T')[0],
        count: 0,
        dayName: dayNames[date.weekday - 1],
      ));
    }
    
    return trendData;
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_status_pie': assetStatusPie.toJson(),
      'scan_trend_7d': scanTrend7d.map((item) => item.toJson()).toList(),
    };
  }

  Charts toEntity() {
    final scanTrendEntities = <ScanTrend>[];
    for (final item in scanTrend7d) {
      scanTrendEntities.add(item.toEntity());
    }

    return Charts(
      assetStatusPie: assetStatusPie.toEntity(),
      scanTrend7d: scanTrendEntities,
    );
  }

  // Helper methods
  bool get hasChartData => 
      assetStatusPie.total > 0 || scanTrend7d.any((trend) => trend.count > 0);

  bool get hasAssetData => assetStatusPie.total > 0;
  
  bool get hasScanData => scanTrend7d.any((trend) => trend.count > 0);

  int get totalScansInPeriod => 
      scanTrend7d.fold(0, (sum, trend) => sum + trend.count);

  // Create safe copy with validation
  ChartsModel copyWithSafeData({
    AssetStatusPieModel? assetStatusPie,
    List<ScanTrendModel>? scanTrend7d,
  }) {
    return ChartsModel(
      assetStatusPie: assetStatusPie ?? this.assetStatusPie,
      scanTrend7d: scanTrend7d ?? this.scanTrend7d,
    );
  }
}