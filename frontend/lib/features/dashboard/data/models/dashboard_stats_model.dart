// Path: frontend/lib/features/dashboard/data/models/dashboard_stats_model.dart
import 'package:frontend/features/dashboard/data/models/asset_status_pie_model.dart';

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
    try {
      // Handle Backend response structure that includes period_info
      final overviewData = json['overview'] as Map<String, dynamic>? ?? {};
      final chartsData = json['charts'] as Map<String, dynamic>? ?? {};

      // Get timestamp from period_info or use current time
      final periodInfo = json['period_info'] as Map<String, dynamic>?;
      final timestampStr =
          periodInfo?['start_date'] ??
          json['timestamp'] ??
          DateTime.now().toIso8601String();

      return DashboardStatsModel(
        // Pass the entire response to OverviewModel to handle nested structure
        overview: OverviewModel.fromJson({'overview': overviewData}),
        charts: ChartsModel.fromJson(chartsData),
        lastUpdated: DateTime.tryParse(timestampStr) ?? DateTime.now(),
      );
    } catch (e) {
      // Fallback for parsing errors - create empty model
      print('Dashboard stats parsing error: $e');
      return DashboardStatsModel(
        overview: OverviewModel(
          totalAssets: 0,
          activeAssets: 0,
          inactiveAssets: 0,
          createdAssets: 0,
          todayScans: 0,
          exportSuccess7d: 0,
          exportFailed7d: 0,
        ),
        charts: ChartsModel(
          assetStatusPie: AssetStatusPieModel(
            active: 0,
            inactive: 0,
            created: 0,
            total: 0,
          ),
          scanTrend7d: [],
        ),
        lastUpdated: DateTime.now(),
      );
    }
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

  // Create a copy with error handling
  DashboardStatsModel copyWithSafeData({
    OverviewModel? overview,
    ChartsModel? charts,
    DateTime? lastUpdated,
  }) {
    return DashboardStatsModel(
      overview: overview ?? this.overview,
      charts: charts ?? this.charts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
