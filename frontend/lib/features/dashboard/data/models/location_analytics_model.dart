// Path: frontend/lib/features/dashboard/data/models/location_analytics_model.dart
import '../../domain/entities/location_analytics.dart';

class LocationDataModel {
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

  LocationDataModel({
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

  factory LocationDataModel.fromJson(Map<String, dynamic> json) {
    return LocationDataModel(
      locationCode: json['location_code'] ?? '',
      locationDescription: json['location_description'] ?? '',
      plantCode: json['plant_code'] ?? '',
      plantDescription: json['plant_description'] ?? '',
      totalAssets: json['total_assets'] ?? 0,
      activeAssets: json['active_assets'] ?? 0,
      inactiveAssets: json['inactive_assets'] ?? 0,
      createdAssets: json['created_assets'] ?? 0,
      departmentCount: json['department_count'] ?? 0,
      totalScans: json['total_scans'] ?? 0,
      lastScanDate: json['last_scan_date'] != null
          ? DateTime.tryParse(json['last_scan_date'])
          : null,
      utilizationRate: json['utilization_rate'] ?? 0,
      scanFrequency: json['scan_frequency'] ?? 0,
      daysSinceLastScan: json['days_since_last_scan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_code': locationCode,
      'location_description': locationDescription,
      'plant_code': plantCode,
      'plant_description': plantDescription,
      'total_assets': totalAssets,
      'active_assets': activeAssets,
      'inactive_assets': inactiveAssets,
      'created_assets': createdAssets,
      'department_count': departmentCount,
      'total_scans': totalScans,
      'last_scan_date': lastScanDate?.toIso8601String(),
      'utilization_rate': utilizationRate,
      'scan_frequency': scanFrequency,
      'days_since_last_scan': daysSinceLastScan,
    };
  }

  LocationData toEntity() {
    return LocationData(
      locationCode: locationCode,
      locationDescription: locationDescription,
      plantCode: plantCode,
      plantDescription: plantDescription,
      totalAssets: totalAssets,
      activeAssets: activeAssets,
      inactiveAssets: inactiveAssets,
      createdAssets: createdAssets,
      departmentCount: departmentCount,
      totalScans: totalScans,
      lastScanDate: lastScanDate,
      utilizationRate: utilizationRate,
      scanFrequency: scanFrequency,
      daysSinceLastScan: daysSinceLastScan,
    );
  }
}

class AnalyticsSummaryModel {
  final int totalLocations;
  final int totalAssets;
  final int averageUtilizationRate;
  final int highUtilizationLocations;
  final int lowActivityLocations;

  AnalyticsSummaryModel({
    required this.totalLocations,
    required this.totalAssets,
    required this.averageUtilizationRate,
    required this.highUtilizationLocations,
    required this.lowActivityLocations,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      totalLocations: json['total_locations'] ?? 0,
      totalAssets: json['total_assets'] ?? 0,
      averageUtilizationRate: json['average_utilization_rate'] ?? 0,
      highUtilizationLocations: json['high_utilization_locations'] ?? 0,
      lowActivityLocations: json['low_activity_locations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_locations': totalLocations,
      'total_assets': totalAssets,
      'average_utilization_rate': averageUtilizationRate,
      'high_utilization_locations': highUtilizationLocations,
      'low_activity_locations': lowActivityLocations,
    };
  }

  AnalyticsSummary toEntity() {
    return AnalyticsSummary(
      totalLocations: totalLocations,
      totalAssets: totalAssets,
      averageUtilizationRate: averageUtilizationRate,
      highUtilizationLocations: highUtilizationLocations,
      lowActivityLocations: lowActivityLocations,
    );
  }
}

class LocationTrendModel {
  final String monthYear;
  final int assetCount;
  final int activeCount;
  final String locationCode;
  final String locationDescription;
  final int growthPercentage;
  final int activeGrowthPercentage;

  LocationTrendModel({
    required this.monthYear,
    required this.assetCount,
    required this.activeCount,
    required this.locationCode,
    required this.locationDescription,
    required this.growthPercentage,
    required this.activeGrowthPercentage,
  });

  factory LocationTrendModel.fromJson(Map<String, dynamic> json) {
    return LocationTrendModel(
      monthYear: json['month_year'] ?? '',
      assetCount: json['asset_count'] ?? 0,
      activeCount: json['active_count'] ?? 0,
      locationCode: json['location_code'] ?? '',
      locationDescription: json['location_description'] ?? '',
      growthPercentage: json['growth_percentage'] ?? 0,
      activeGrowthPercentage: json['active_growth_percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month_year': monthYear,
      'asset_count': assetCount,
      'active_count': activeCount,
      'location_code': locationCode,
      'location_description': locationDescription,
      'growth_percentage': growthPercentage,
      'active_growth_percentage': activeGrowthPercentage,
    };
  }

  LocationTrend toEntity() {
    return LocationTrend(
      monthYear: monthYear,
      assetCount: assetCount,
      activeCount: activeCount,
      locationCode: locationCode,
      locationDescription: locationDescription,
      growthPercentage: growthPercentage,
      activeGrowthPercentage: activeGrowthPercentage,
    );
  }
}

class GrowthTrendsDataModel {
  final List<LocationTrendModel> locationTrends;
  final Map<String, dynamic> periodInfo;

  GrowthTrendsDataModel({
    required this.locationTrends,
    required this.periodInfo,
  });

  factory GrowthTrendsDataModel.fromJson(Map<String, dynamic> json) {
    final trendsData = json['location_trends'] as List<dynamic>? ?? [];

    return GrowthTrendsDataModel(
      locationTrends: trendsData
          .map(
            (item) => LocationTrendModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      periodInfo: json['period_info'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_trends': locationTrends.map((item) => item.toJson()).toList(),
      'period_info': periodInfo,
    };
  }

  GrowthTrendsData toEntity() {
    return GrowthTrendsData(
      locationTrends: locationTrends.map((item) => item.toEntity()).toList(),
      periodInfo: periodInfo,
    );
  }
}

class LocationAnalyticsModel {
  final List<LocationDataModel> locationAnalytics;
  final AnalyticsSummaryModel analyticsSummary;
  final GrowthTrendsDataModel? growthTrends;

  LocationAnalyticsModel({
    required this.locationAnalytics,
    required this.analyticsSummary,
    this.growthTrends,
  });

  factory LocationAnalyticsModel.fromJson(Map<String, dynamic> json) {
    try {
      final analyticsData = json['location_analytics'] as List<dynamic>? ?? [];
      final summaryData =
          json['analytics_summary'] as Map<String, dynamic>? ?? {};
      final trendsData = json['growth_trends'] as Map<String, dynamic>?;

      return LocationAnalyticsModel(
        locationAnalytics: analyticsData
            .map(
              (item) =>
                  LocationDataModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        analyticsSummary: AnalyticsSummaryModel.fromJson(summaryData),
        growthTrends: trendsData != null
            ? GrowthTrendsDataModel.fromJson(trendsData)
            : null,
      );
    } catch (e) {
      print('Location analytics parsing error: $e');
      return LocationAnalyticsModel(
        locationAnalytics: [],
        analyticsSummary: AnalyticsSummaryModel(
          totalLocations: 0,
          totalAssets: 0,
          averageUtilizationRate: 0,
          highUtilizationLocations: 0,
          lowActivityLocations: 0,
        ),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'location_analytics': locationAnalytics
          .map((item) => item.toJson())
          .toList(),
      'analytics_summary': analyticsSummary.toJson(),
      'growth_trends': growthTrends?.toJson(),
    };
  }

  LocationAnalytics toEntity() {
    return LocationAnalytics(
      locationAnalytics: locationAnalytics
          .map((item) => item.toEntity())
          .toList(),
      analyticsSummary: analyticsSummary.toEntity(),
      growthTrends: growthTrends?.toEntity(),
    );
  }

  // Helper methods
  bool get hasData => locationAnalytics.isNotEmpty;
  bool get hasTrends =>
      growthTrends != null && growthTrends!.locationTrends.isNotEmpty;

  List<LocationDataModel> get topUtilizationLocations {
    final sorted = List<LocationDataModel>.from(locationAnalytics);
    sorted.sort((a, b) => b.utilizationRate.compareTo(a.utilizationRate));
    return sorted.take(5).toList();
  }

  int get totalAssets =>
      locationAnalytics.fold(0, (sum, location) => sum + location.totalAssets);
}
