// Path: frontend/lib/features/dashboard/domain/entities/location_analytics.dart

class LocationData {
  final String locationCode;
  final String locationDescription;
  final String plantCode;
  final String plantDescription;
  final int totalAssets;
  final int activeAssets;
  final int inactiveAssets;
  final int createdAssets;
  final int departmentCount;
  final int totalScans;
  final DateTime? lastScanDate;
  final int utilizationRate;
  final int scanFrequency;
  final int? daysSinceLastScan;

  const LocationData({
    required this.locationCode,
    required this.locationDescription,
    required this.plantCode,
    required this.plantDescription,
    required this.totalAssets,
    required this.activeAssets,
    required this.inactiveAssets,
    required this.createdAssets,
    required this.departmentCount,
    required this.totalScans,
    this.lastScanDate,
    required this.utilizationRate,
    required this.scanFrequency,
    this.daysSinceLastScan,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.locationCode == locationCode &&
        other.locationDescription == locationDescription &&
        other.plantCode == plantCode &&
        other.plantDescription == plantDescription &&
        other.totalAssets == totalAssets &&
        other.activeAssets == activeAssets &&
        other.inactiveAssets == inactiveAssets &&
        other.createdAssets == createdAssets &&
        other.departmentCount == departmentCount &&
        other.totalScans == totalScans &&
        other.lastScanDate == lastScanDate &&
        other.utilizationRate == utilizationRate &&
        other.scanFrequency == scanFrequency &&
        other.daysSinceLastScan == daysSinceLastScan;
  }

  @override
  int get hashCode {
    return locationCode.hashCode ^
        locationDescription.hashCode ^
        plantCode.hashCode ^
        plantDescription.hashCode ^
        totalAssets.hashCode ^
        activeAssets.hashCode ^
        inactiveAssets.hashCode ^
        createdAssets.hashCode ^
        departmentCount.hashCode ^
        totalScans.hashCode ^
        lastScanDate.hashCode ^
        utilizationRate.hashCode ^
        scanFrequency.hashCode ^
        daysSinceLastScan.hashCode;
  }

  @override
  String toString() {
    return 'LocationData(locationCode: $locationCode, locationDescription: $locationDescription, totalAssets: $totalAssets, utilizationRate: $utilizationRate)';
  }

  // Helper getters
  bool get hasAssets => totalAssets > 0;
  bool get hasScans => totalScans > 0;
  bool get isHighUtilization => utilizationRate >= 80;
  bool get isLowActivity => scanFrequency < 1;

  double get activePercentage {
    if (totalAssets == 0) return 0.0;
    return (activeAssets / totalAssets) * 100;
  }
}

class AnalyticsSummary {
  final int totalLocations;
  final int totalAssets;
  final int averageUtilizationRate;
  final int highUtilizationLocations;
  final int lowActivityLocations;

  const AnalyticsSummary({
    required this.totalLocations,
    required this.totalAssets,
    required this.averageUtilizationRate,
    required this.highUtilizationLocations,
    required this.lowActivityLocations,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsSummary &&
        other.totalLocations == totalLocations &&
        other.totalAssets == totalAssets &&
        other.averageUtilizationRate == averageUtilizationRate &&
        other.highUtilizationLocations == highUtilizationLocations &&
        other.lowActivityLocations == lowActivityLocations;
  }

  @override
  int get hashCode {
    return totalLocations.hashCode ^
        totalAssets.hashCode ^
        averageUtilizationRate.hashCode ^
        highUtilizationLocations.hashCode ^
        lowActivityLocations.hashCode;
  }

  @override
  String toString() {
    return 'AnalyticsSummary(totalLocations: $totalLocations, totalAssets: $totalAssets, averageUtilizationRate: $averageUtilizationRate)';
  }

  // Helper getters
  bool get hasData => totalLocations > 0 && totalAssets > 0;
  bool get hasHighUtilizationLocations => highUtilizationLocations > 0;
  bool get hasLowActivityLocations => lowActivityLocations > 0;

  double get averageAssetsPerLocation {
    if (totalLocations == 0) return 0.0;
    return totalAssets / totalLocations;
  }
}

class LocationTrend {
  final String monthYear;
  final int assetCount;
  final int activeCount;
  final String locationCode;
  final String locationDescription;
  final int growthPercentage;
  final int activeGrowthPercentage;

  const LocationTrend({
    required this.monthYear,
    required this.assetCount,
    required this.activeCount,
    required this.locationCode,
    required this.locationDescription,
    required this.growthPercentage,
    required this.activeGrowthPercentage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationTrend &&
        other.monthYear == monthYear &&
        other.assetCount == assetCount &&
        other.activeCount == activeCount &&
        other.locationCode == locationCode &&
        other.locationDescription == locationDescription &&
        other.growthPercentage == growthPercentage &&
        other.activeGrowthPercentage == activeGrowthPercentage;
  }

  @override
  int get hashCode {
    return monthYear.hashCode ^
        assetCount.hashCode ^
        activeCount.hashCode ^
        locationCode.hashCode ^
        locationDescription.hashCode ^
        growthPercentage.hashCode ^
        activeGrowthPercentage.hashCode;
  }

  @override
  String toString() {
    return 'LocationTrend(monthYear: $monthYear, assetCount: $assetCount, growthPercentage: $growthPercentage)';
  }

  // Helper getters
  bool get hasGrowth => growthPercentage > 0;
  bool get hasDecline => growthPercentage < 0;
  bool get isStable => growthPercentage == 0;
}

class GrowthTrendsData {
  final List<LocationTrend> locationTrends;
  final Map<String, dynamic> periodInfo;

  const GrowthTrendsData({
    required this.locationTrends,
    required this.periodInfo,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthTrendsData &&
        other.locationTrends.length == locationTrends.length &&
        other.periodInfo.length == periodInfo.length &&
        other.locationTrends.every(
          (element) => locationTrends.contains(element),
        );
  }

  @override
  int get hashCode {
    return locationTrends.hashCode ^ periodInfo.hashCode;
  }

  @override
  String toString() {
    return 'GrowthTrendsData(locationTrends: ${locationTrends.length} items, periodInfo: $periodInfo)';
  }

  // Helper getters
  bool get hasData => locationTrends.isNotEmpty;
  bool get hasPositiveGrowth => locationTrends.any((trend) => trend.hasGrowth);
  bool get hasNegativeGrowth => locationTrends.any((trend) => trend.hasDecline);

  int get totalAssetCount =>
      locationTrends.fold(0, (sum, trend) => sum + trend.assetCount);

  double get averageGrowthRate {
    if (locationTrends.isEmpty) return 0.0;
    final totalGrowth = locationTrends.fold(
      0,
      (sum, trend) => sum + trend.growthPercentage,
    );
    return totalGrowth / locationTrends.length;
  }
}

class LocationAnalytics {
  final List<LocationData> locationAnalytics;
  final AnalyticsSummary analyticsSummary;
  final GrowthTrendsData? growthTrends;

  const LocationAnalytics({
    required this.locationAnalytics,
    required this.analyticsSummary,
    this.growthTrends,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationAnalytics &&
        other.locationAnalytics.length == locationAnalytics.length &&
        other.analyticsSummary == analyticsSummary &&
        other.growthTrends == growthTrends &&
        other.locationAnalytics.every(
          (element) => locationAnalytics.contains(element),
        );
  }

  @override
  int get hashCode {
    return locationAnalytics.hashCode ^
        analyticsSummary.hashCode ^
        growthTrends.hashCode;
  }

  @override
  String toString() {
    return 'LocationAnalytics(locationAnalytics: ${locationAnalytics.length} items, analyticsSummary: $analyticsSummary)';
  }

  // Helper getters
  bool get hasData => locationAnalytics.isNotEmpty && analyticsSummary.hasData;
  bool get hasTrends => growthTrends != null && growthTrends!.hasData;
  bool get hasMultipleLocations => locationAnalytics.length > 1;

  List<LocationData> get topUtilizationLocations {
    final sorted = List<LocationData>.from(locationAnalytics);
    sorted.sort((a, b) => b.utilizationRate.compareTo(a.utilizationRate));
    return sorted.take(5).toList();
  }

  List<LocationData> get highUtilizationLocations {
    return locationAnalytics
        .where((location) => location.isHighUtilization)
        .toList();
  }

  List<LocationData> get lowActivityLocations {
    return locationAnalytics
        .where((location) => location.isLowActivity)
        .toList();
  }

  int get totalAssets =>
      locationAnalytics.fold(0, (sum, location) => sum + location.totalAssets);

  double get overallUtilizationRate {
    if (locationAnalytics.isEmpty) return 0.0;
    final totalUtilization = locationAnalytics.fold(
      0,
      (sum, location) => sum + location.utilizationRate,
    );
    return totalUtilization / locationAnalytics.length;
  }
}
