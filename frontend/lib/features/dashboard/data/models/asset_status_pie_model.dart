// Path: frontend/lib/features/dashboard/data/models/asset_status_pie_model.dart
import 'package:frontend/features/dashboard/domain/entities/asset_status_pie.dart';

import 'chart_data_model.dart';

class AssetStatusPieModel {
  final int active;
  final int inactive;
  final int created;
  final int total;

  AssetStatusPieModel({
    required this.active,
    required this.inactive,
    required this.created,
    required this.total,
  });

  factory AssetStatusPieModel.fromJson(Map<String, dynamic> json) {
    return AssetStatusPieModel(
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
      created: json['created'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'inactive': inactive,
      'created': created,
      'total': total,
    };
  }

  AssetStatusPie toEntity() {
    return AssetStatusPie(
      active: active,
      inactive: inactive,
      created: created,
      total: total,
    );
  }

  List<ChartDataModel> toChartData() {
    return [
      ChartDataModel(
        label: 'Active',
        value: active.toDouble(),
        color: '#4CAF50',
      ),
      ChartDataModel(
        label: 'Inactive',
        value: inactive.toDouble(),
        color: '#f44336',
      ),
      ChartDataModel(
        label: 'Created',
        value: created.toDouble(),
        color: '#2196F3',
      ),
    ].where((item) => item.value > 0).toList();
  }
}
