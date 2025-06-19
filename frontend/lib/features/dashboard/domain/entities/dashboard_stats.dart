// Path: frontend/lib/features/dashboard/domain/entities/dashboard_stats.dart
import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final DashboardOverview overview;
  final DashboardCharts charts;
  final DashboardPeriodInfo periodInfo;

  const DashboardStats({
    required this.overview,
    required this.charts,
    required this.periodInfo,
  });

  @override
  List<Object> get props => [overview, charts, periodInfo];
}

class DashboardOverview extends Equatable {
  final AssetCount totalAssets;
  final AssetCount activeAssets;
  final AssetCount inactiveAssets;
  final AssetCount createdAssets;
  final ScanCount scans;
  final ExportCount exportSuccess;
  final ExportCount exportFailed;
  final int totalPlants;
  final int totalLocations;
  final int totalUsers;

  const DashboardOverview({
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

  @override
  List<Object> get props => [
    totalAssets,
    activeAssets,
    inactiveAssets,
    createdAssets,
    scans,
    exportSuccess,
    exportFailed,
    totalPlants,
    totalLocations,
    totalUsers,
  ];
}

class AssetCount extends Equatable {
  final int value;
  final int changePercent;
  final String trend;

  const AssetCount({
    required this.value,
    required this.changePercent,
    required this.trend,
  });

  bool get isIncreasing => trend == 'up';
  bool get isDecreasing => trend == 'down';
  bool get isStable => trend == 'stable';

  @override
  List<Object> get props => [value, changePercent, trend];
}

class ScanCount extends Equatable {
  final int value;
  final int changePercent;
  final String trend;
  final int previousValue;

  const ScanCount({
    required this.value,
    required this.changePercent,
    required this.trend,
    required this.previousValue,
  });

  bool get isIncreasing => trend == 'up';
  bool get isDecreasing => trend == 'down';
  bool get isStable => trend == 'stable';

  @override
  List<Object> get props => [value, changePercent, trend, previousValue];
}

class ExportCount extends Equatable {
  final int value;
  final int changePercent;
  final String trend;
  final int previousValue;

  const ExportCount({
    required this.value,
    required this.changePercent,
    required this.trend,
    required this.previousValue,
  });

  bool get isIncreasing => trend == 'up';
  bool get isDecreasing => trend == 'down';
  bool get isStable => trend == 'stable';

  @override
  List<Object> get props => [value, changePercent, trend, previousValue];
}

class DashboardCharts extends Equatable {
  final AssetStatusPie assetStatusPie;
  final List<ScanTrend> scanTrend7d;

  const DashboardCharts({
    required this.assetStatusPie,
    required this.scanTrend7d,
  });

  @override
  List<Object> get props => [assetStatusPie, scanTrend7d];
}

class AssetStatusPie extends Equatable {
  final int active;
  final int inactive;
  final int created;
  final int total;

  const AssetStatusPie({
    required this.active,
    required this.inactive,
    required this.created,
    required this.total,
  });

  double get activePercentage => total > 0 ? (active / total) * 100 : 0;
  double get inactivePercentage => total > 0 ? (inactive / total) * 100 : 0;
  double get createdPercentage => total > 0 ? (created / total) * 100 : 0;

  @override
  List<Object> get props => [active, inactive, created, total];
}

class ScanTrend extends Equatable {
  final String date;
  final int count;
  final String dayName;

  const ScanTrend({
    required this.date,
    required this.count,
    required this.dayName,
  });

  DateTime get dateTime => DateTime.parse(date);

  @override
  List<Object> get props => [date, count, dayName];
}

class DashboardPeriodInfo extends Equatable {
  final String period;
  final String startDate;
  final String endDate;
  final ComparisonPeriod comparisonPeriod;

  const DashboardPeriodInfo({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.comparisonPeriod,
  });

  DateTime get startDateTime => DateTime.parse(startDate);
  DateTime get endDateTime => DateTime.parse(endDate);
  Duration get periodDuration => endDateTime.difference(startDateTime);

  @override
  List<Object> get props => [period, startDate, endDate, comparisonPeriod];
}

class ComparisonPeriod extends Equatable {
  final String startDate;
  final String endDate;

  const ComparisonPeriod({required this.startDate, required this.endDate});

  DateTime get startDateTime => DateTime.parse(startDate);
  DateTime get endDateTime => DateTime.parse(endDate);

  @override
  List<Object> get props => [startDate, endDate];
}
