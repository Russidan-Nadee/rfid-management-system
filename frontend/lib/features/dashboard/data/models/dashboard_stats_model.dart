// Path: frontend/lib/features/dashboard/data/models/dashboard_stats_model.dart
import '../../domain/entities/dashboard_stats.dart';
import 'overview_model.dart';
import 'charts_model.dart';

class DashboardStatsModel {
  final OverviewModel overview;
  final ChartsModel charts;
  final DateTime lastUpdated;

  DashboardStatsModel({
    required this.overview,
    required this.charts,
    required this.lastUpdated,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      overview: OverviewModel.fromJson(json['overview'] ?? {}),
      charts: ChartsModel.fromJson(json['charts'] ?? {}),
      lastUpdated:
          DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overview': overview.toJson(),
      'charts': charts.toJson(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  DashboardStats toEntity() {
    return DashboardStats(
      overview: overview.toEntity(),
      charts: charts.toEntity(),
    );
  }

  // Helper methods
  bool get hasData => overview.totalAssets > 0;

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inMinutes < 30;
  }

  String get lastUpdatedFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
