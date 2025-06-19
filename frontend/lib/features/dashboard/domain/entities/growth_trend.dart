// Path: frontend/lib/features/dashboard/domain/entities/growth_trend.dart
import 'package:equatable/equatable.dart';

class GrowthTrend extends Equatable {
  final List<TrendData> trends;
  final TrendPeriodInfo periodInfo;
  final TrendSummary summary;

  const GrowthTrend({
    required this.trends,
    required this.periodInfo,
    required this.summary,
  });

  // Helper methods
  bool get hasData => trends.isNotEmpty;
  bool get hasPositiveGrowth => summary.totalGrowth > 0;
  bool get hasNegativeGrowth => summary.totalGrowth < 0;

  List<TrendData> get positiveGrowthPeriods =>
      trends.where((trend) => trend.growthPercentage > 0).toList();

  List<TrendData> get negativeGrowthPeriods =>
      trends.where((trend) => trend.growthPercentage < 0).toList();

  TrendData? get highestGrowthPeriod => trends.isNotEmpty
      ? trends.reduce((a, b) => a.growthPercentage > b.growthPercentage ? a : b)
      : null;

  TrendData? get lowestGrowthPeriod => trends.isNotEmpty
      ? trends.reduce((a, b) => a.growthPercentage < b.growthPercentage ? a : b)
      : null;

  @override
  List<Object> get props => [trends, periodInfo, summary];
}

class TrendData extends Equatable {
  final String period;
  final int assetCount;
  final int growthPercentage;
  final int cumulativeCount;
  final String deptCode;
  final String deptDescription;

  const TrendData({
    required this.period,
    required this.assetCount,
    required this.growthPercentage,
    required this.cumulativeCount,
    required this.deptCode,
    required this.deptDescription,
  });

  // Helper methods
  bool get hasGrowth => assetCount > 0;
  bool get isPositiveGrowth => growthPercentage > 0;
  bool get isNegativeGrowth => growthPercentage < 0;
  bool get isStableGrowth => growthPercentage == 0;

  String get growthDirection {
    if (isPositiveGrowth) return 'increase';
    if (isNegativeGrowth) return 'decrease';
    return 'stable';
  }

  String get formattedGrowthPercentage =>
      '${growthPercentage > 0 ? '+' : ''}$growthPercentage%';
  String get displayName =>
      deptDescription.isNotEmpty ? deptDescription : deptCode;

  @override
  List<Object> get props => [
    period,
    assetCount,
    growthPercentage,
    cumulativeCount,
    deptCode,
    deptDescription,
  ];
}

class TrendPeriodInfo extends Equatable {
  final String period;
  final int year;
  final String startDate;
  final String endDate;
  final int totalGrowth;

  const TrendPeriodInfo({
    required this.period,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.totalGrowth,
  });

  // Helper methods
  DateTime get startDateTime => DateTime.parse(startDate);
  DateTime get endDateTime => DateTime.parse(endDate);
  Duration get periodDuration => endDateTime.difference(startDateTime);

  bool get isCurrentYear => year == DateTime.now().year;
  bool get isQuarterlyPeriod => ['Q1', 'Q2', 'Q3', 'Q4'].contains(period);
  bool get isYearlyPeriod => period == '1Y';
  bool get isCustomPeriod => period == 'custom';

  String get formattedTotalGrowth =>
      '${totalGrowth > 0 ? '+' : ''}$totalGrowth';

  @override
  List<Object> get props => [period, year, startDate, endDate, totalGrowth];
}

class TrendSummary extends Equatable {
  final int totalPeriods;
  final int totalGrowth;
  final int averageGrowth;

  const TrendSummary({
    required this.totalPeriods,
    required this.totalGrowth,
    required this.averageGrowth,
  });

  // Helper methods
  bool get hasPositiveAverage => averageGrowth > 0;
  bool get hasNegativeAverage => averageGrowth < 0;
  bool get isStableAverage => averageGrowth == 0;

  String get averageGrowthDirection {
    if (hasPositiveAverage) return 'increasing';
    if (hasNegativeAverage) return 'decreasing';
    return 'stable';
  }

  String get formattedAverageGrowth =>
      '${averageGrowth > 0 ? '+' : ''}$averageGrowth%';
  String get formattedTotalGrowth =>
      '${totalGrowth > 0 ? '+' : ''}$totalGrowth';

  @override
  List<Object> get props => [totalPeriods, totalGrowth, averageGrowth];
}
