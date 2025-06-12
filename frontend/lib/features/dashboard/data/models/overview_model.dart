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
    return ChartsModel(
      assetStatusPie: AssetStatusPieModel.fromJson(
        json['asset_status_pie'] ?? {},
      ),
      scanTrend7d:
          (json['scan_trend_7d'] as List<dynamic>?)
              ?.map(
                (item) => ScanTrendModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
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
}
