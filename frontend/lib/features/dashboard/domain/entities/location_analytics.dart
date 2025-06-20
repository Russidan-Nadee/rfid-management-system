// Path: frontend/lib/features/dashboard/domain/entities/location_analytics.dart
import 'package:equatable/equatable.dart';

class LocationAnalytics extends Equatable {
  final List<LocationTrendData> locationTrends;
  final LocationTrendPeriodInfo periodInfo;
  final LocationTrendSummary summary;

  const LocationAnalytics({
    required this.locationTrends,
    required this.periodInfo,
    required this.summary,
  });

  // Helper methods
  bool get hasData => locationTrends.isNotEmpty;
  bool get hasPositiveGrowth => summary.totalGrowth > 0;
  bool get hasNegativeGrowth => summary.totalGrowth < 0;

  List<LocationTrendData> get positiveGrowthPeriods =>
      locationTrends.where((trend) => trend.growthPercentage > 0).toList();

  List<LocationTrendData> get negativeGrowthPeriods =>
      locationTrends.where((trend) => trend.growthPercentage < 0).toList();

  LocationTrendData? get highestGrowthPeriod => locationTrends.isNotEmpty
      ? locationTrends.reduce(
          (a, b) => a.growthPercentage > b.growthPercentage ? a : b,
        )
      : null;

  LocationTrendData? get lowestGrowthPeriod => locationTrends.isNotEmpty
      ? locationTrends.reduce(
          (a, b) => a.growthPercentage < b.growthPercentage ? a : b,
        )
      : null;

  @override
  List<Object> get props => [locationTrends, periodInfo, summary];
}

class LocationTrendData extends Equatable {
  final String monthYear;
  final int assetCount;
  final int activeCount;
  final int growthPercentage;
  final String locationCode;
  final String locationDescription;
  final String? plantCode;
  final String? plantDescription;

  const LocationTrendData({
    required this.monthYear,
    required this.assetCount,
    required this.activeCount,
    required this.growthPercentage,
    required this.locationCode,
    required this.locationDescription,
    this.plantCode,
    this.plantDescription,
  });

  // Helper methods
  bool get hasAssets => assetCount > 0;
  bool get hasActiveAssets => activeCount > 0;
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
      locationDescription.isNotEmpty ? locationDescription : locationCode;

  double get activePercentage =>
      assetCount > 0 ? (activeCount / assetCount) * 100 : 0;

  @override
  List<Object?> get props => [
    monthYear,
    assetCount,
    activeCount,
    growthPercentage,
    locationCode,
    locationDescription,
    plantCode,
    plantDescription,
  ];
}

class LocationTrendPeriodInfo extends Equatable {
  final String period;
  final int year;
  final String startDate;
  final String endDate;
  final String locationCode;

  const LocationTrendPeriodInfo({
    required this.period,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.locationCode,
  });

  // Helper methods
  DateTime get startDateTime => DateTime.parse(startDate);
  DateTime get endDateTime => DateTime.parse(endDate);
  Duration get periodDuration => endDateTime.difference(startDateTime);

  bool get isCurrentYear => year == DateTime.now().year;
  bool get isQuarterlyPeriod => ['Q1', 'Q2', 'Q3', 'Q4'].contains(period);
  bool get isYearlyPeriod => period == '1Y';
  bool get isCustomPeriod => period == 'custom';

  @override
  List<Object> get props => [period, year, startDate, endDate, locationCode];
}

class LocationTrendSummary extends Equatable {
  final int totalPeriods;
  final int totalGrowth;
  final int averageGrowth;

  const LocationTrendSummary({
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
