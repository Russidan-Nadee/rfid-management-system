// Path: frontend/lib/features/dashboard/data/models/dashboard_stats_model.dart
import 'package:frontend/features/dashboard/domain/entities/dashboard_stats.dart';

import 'overview_model.dart';
import 'charts_model.dart';

class DashboardStatsModel {
  final OverviewModel overview;
  final ChartsModel charts;

  DashboardStatsModel({required this.overview, required this.charts});

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      overview: OverviewModel.fromJson(json['overview'] ?? {}),
      charts: ChartsModel.fromJson(json['charts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'overview': overview.toJson(), 'charts': charts.toJson()};
  }

  DashboardStats toEntity() {
    return DashboardStats(
      overview: overview.toEntity(),
      charts: charts.toEntity(),
    );
  }
}
