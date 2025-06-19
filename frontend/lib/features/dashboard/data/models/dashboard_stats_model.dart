// Path: frontend/lib/features/dashboard/data/models/dashboard_stats_model.dart
class DashboardStatsModel {
  final DashboardOverviewModel overview;
  final DashboardChartsModel charts;
  final DashboardPeriodInfoModel periodInfo;

  const DashboardStatsModel({
    required this.overview,
    required this.charts,
    required this.periodInfo,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      overview: DashboardOverviewModel.fromJson(json['overview'] ?? {}),
      charts: DashboardChartsModel.fromJson(json['charts'] ?? {}),
      periodInfo: DashboardPeriodInfoModel.fromJson(json['period_info'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overview': overview.toJson(),
      'charts': charts.toJson(),
      'period_info': periodInfo.toJson(),
    };
  }
}

class DashboardOverviewModel {
  final AssetCountModel totalAssets;
  final AssetCountModel activeAssets;
  final AssetCountModel inactiveAssets;
  final AssetCountModel createdAssets;
  final ScanCountModel scans;
  final ExportCountModel exportSuccess;
  final ExportCountModel exportFailed;
  final int totalPlants;
  final int totalLocations;
  final int totalUsers;

  const DashboardOverviewModel({
    required this.totalAssets,
    required this.activeAssets,
    required this.inactiveAssets,
    required this.createdAssets,
    required this.scans,
    required this.exportSuccess,
    required this.exportFailed,
    required this.totalPlants,
    required this.totalLocations,
    required this.totalUsers,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      totalAssets: AssetCountModel.fromJson(json['total_assets'] ?? {}),
      activeAssets: AssetCountModel.fromJson(json['active_assets'] ?? {}),
      inactiveAssets: AssetCountModel.fromJson(json['inactive_assets'] ?? {}),
      createdAssets: AssetCountModel.fromJson(json['created_assets'] ?? {}),
      scans: ScanCountModel.fromJson(json['scans'] ?? {}),
      exportSuccess: ExportCountModel.fromJson(json['export_success'] ?? {}),
      exportFailed: ExportCountModel.fromJson(json['export_failed'] ?? {}),
      totalPlants: json['total_plants'] ?? 0,
      totalLocations: json['total_locations'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_assets': totalAssets.toJson(),
      'active_assets': activeAssets.toJson(),
      'inactive_assets': inactiveAssets.toJson(),
      'created_assets': createdAssets.toJson(),
      'scans': scans.toJson(),
      'export_success': exportSuccess.toJson(),
      'export_failed': exportFailed.toJson(),
      'total_plants': totalPlants,
      'total_locations': totalLocations,
      'total_users': totalUsers,
    };
  }
}

class AssetCountModel {
  final int value;
  final int changePercent;
  final String trend;

  const AssetCountModel({
    required this.value,
    required this.changePercent,
    required this.trend,
  });

  factory AssetCountModel.fromJson(Map<String, dynamic> json) {
    return AssetCountModel(
      value: json['value'] ?? 0,
      changePercent: json['change_percent'] ?? 0,
      trend: json['trend'] ?? 'stable',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'change_percent': changePercent, 'trend': trend};
  }
}

class ScanCountModel {
  final int value;
  final int changePercent;
  final String trend;
  final int previousValue;

  const ScanCountModel({
    required this.value,
    required this.changePercent,
    required this.trend,
    required this.previousValue,
  });

  factory ScanCountModel.fromJson(Map<String, dynamic> json) {
    return ScanCountModel(
      value: json['value'] ?? 0,
      changePercent: json['change_percent'] ?? 0,
      trend: json['trend'] ?? 'stable',
      previousValue: json['previous_value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'change_percent': changePercent,
      'trend': trend,
      'previous_value': previousValue,
    };
  }
}

class ExportCountModel {
  final int value;
  final int changePercent;
  final String trend;
  final int previousValue;

  const ExportCountModel({
    required this.value,
    required this.changePercent,
    required this.trend,
    required this.previousValue,
  });

  factory ExportCountModel.fromJson(Map<String, dynamic> json) {
    return ExportCountModel(
      value: json['value'] ?? 0,
      changePercent: json['change_percent'] ?? 0,
      trend: json['trend'] ?? 'stable',
      previousValue: json['previous_value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'change_percent': changePercent,
      'trend': trend,
      'previous_value': previousValue,
    };
  }
}

class DashboardChartsModel {
  final AssetStatusPieModel assetStatusPie;
  final List<ScanTrendModel> scanTrend7d;

  const DashboardChartsModel({
    required this.assetStatusPie,
    required this.scanTrend7d,
  });

  factory DashboardChartsModel.fromJson(Map<String, dynamic> json) {
    return DashboardChartsModel(
      assetStatusPie: AssetStatusPieModel.fromJson(
        json['asset_status_pie'] ?? {},
      ),
      scanTrend7d:
          (json['scan_trend_7d'] as List<dynamic>?)
              ?.map((e) => ScanTrendModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_status_pie': assetStatusPie.toJson(),
      'scan_trend_7d': scanTrend7d.map((e) => e.toJson()).toList(),
    };
  }
}

class AssetStatusPieModel {
  final int active;
  final int inactive;
  final int created;
  final int total;

  const AssetStatusPieModel({
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
}

class ScanTrendModel {
  final String date;
  final int count;
  final String dayName;

  const ScanTrendModel({
    required this.date,
    required this.count,
    required this.dayName,
  });

  factory ScanTrendModel.fromJson(Map<String, dynamic> json) {
    return ScanTrendModel(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      dayName: json['day_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'count': count, 'day_name': dayName};
  }
}

class DashboardPeriodInfoModel {
  final String period;
  final String startDate;
  final String endDate;
  final ComparisonPeriodModel comparisonPeriod;

  const DashboardPeriodInfoModel({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.comparisonPeriod,
  });

  factory DashboardPeriodInfoModel.fromJson(Map<String, dynamic> json) {
    return DashboardPeriodInfoModel(
      period: json['period'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      comparisonPeriod: ComparisonPeriodModel.fromJson(
        json['comparison_period'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'start_date': startDate,
      'end_date': endDate,
      'comparison_period': comparisonPeriod.toJson(),
    };
  }
}

class ComparisonPeriodModel {
  final String startDate;
  final String endDate;

  const ComparisonPeriodModel({required this.startDate, required this.endDate});

  factory ComparisonPeriodModel.fromJson(Map<String, dynamic> json) {
    return ComparisonPeriodModel(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'start_date': startDate, 'end_date': endDate};
  }
}
