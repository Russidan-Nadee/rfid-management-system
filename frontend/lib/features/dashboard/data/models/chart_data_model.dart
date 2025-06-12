// Path: frontend/lib/features/dashboard/data/models/chart_data_model.dart

import 'package:frontend/features/dashboard/domain/entities/chart_data.dart';

class ChartDataModel {
  final String label;
  final double value;
  final String? color;
  final String? date;

  ChartDataModel({
    required this.label,
    required this.value,
    this.color,
    this.date,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      color: json['color'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'color': color, 'date': date};
  }

  ChartData toEntity() {
    return ChartData(label: label, value: value, color: color, date: date);
  }
}
