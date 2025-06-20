// Path: frontend/lib/features/dashboard/data/models/location_analytics_model.dart
class LocationAnalyticsModel {
  final List<LocationTrendDataModel> locationTrends;
  final LocationTrendPeriodInfoModel periodInfo;
  final LocationTrendSummaryModel summary;

  const LocationAnalyticsModel({
    required this.locationTrends,
    required this.periodInfo,
    required this.summary,
  });

  factory LocationAnalyticsModel.fromJson(Map<String, dynamic> json) {
    // เพิ่ม debug โดยละเอียด
    print('🔍 Location Analytics JSON keys: ${json.keys.toList()}');
    print('🔍 JSON length: ${json.toString().length} chars');

    // เช็คว่ามี key อะไรบ้างที่อาจเป็น trends
    json.keys.forEach((key) {
      final value = json[key];
      print(
        '🔍 Key "$key": ${value.runtimeType} - ${value is List ? 'List length: ${value.length}' : value}',
      );
    });

    try {
      // ลองใช้ format เหมือน GrowthTrendModel ก่อน
      final trendsData = json['trends'] as List<dynamic>?;
      print('🔍 Simple format - trends: ${trendsData?.length ?? 'null'}');

      return LocationAnalyticsModel(
        locationTrends:
            trendsData
                ?.map(
                  (e) => LocationTrendDataModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
        periodInfo: LocationTrendPeriodInfoModel.fromJson(
          json['period_info'] ?? {},
        ),
        summary: LocationTrendSummaryModel.fromJson(json['summary'] ?? {}),
      );
    } catch (e) {
      print('❌ Simple format failed: $e');
      print('🔄 Trying complex format...');

      // fallback ไปใช้ format เดิม
      final growthTrends = json['growth_trends'];
      final periodInfo = json['period_info'] ?? {};

      print('🔍 Complex format - growth_trends: ${growthTrends?.runtimeType}');
      if (growthTrends is Map) {
        print(
          '🔍 Complex format - growth_trends keys: ${growthTrends.keys.toList()}',
        );
      }

      if (growthTrends != null && growthTrends['location_trends'] != null) {
        final locationTrendsData =
            growthTrends['location_trends'] as List<dynamic>?;
        print(
          '🔍 Complex format - location_trends: ${locationTrendsData?.length ?? 'null'}',
        );

        return LocationAnalyticsModel(
          locationTrends:
              locationTrendsData
                  ?.map(
                    (e) => LocationTrendDataModel.fromJson(
                      e as Map<String, dynamic>,
                    ),
                  )
                  .toList() ??
              [],
          periodInfo: LocationTrendPeriodInfoModel.fromJson(
            growthTrends['period_info'] ?? periodInfo,
          ),
          summary: LocationTrendSummaryModel.fromJson({
            'total_periods': locationTrendsData?.length ?? 0,
            'total_growth': _calculateTotalGrowth(locationTrendsData),
            'average_growth': _calculateAverageGrowth(locationTrendsData),
          }),
        );
      } else {
        print('❌ Both formats failed, checking other possible keys...');

        // เช็ค key อื่นๆ ที่อาจเป็น location data
        final possibleKeys = [
          'location_analytics',
          'analytics_summary',
          'data',
          'results',
        ];
        for (final key in possibleKeys) {
          if (json[key] != null) {
            print(
              '🔍 Found potential data in key "$key": ${json[key].runtimeType}',
            );
          }
        }

        return LocationAnalyticsModel(
          locationTrends: [],
          periodInfo: LocationTrendPeriodInfoModel.fromJson(periodInfo),
          summary: LocationTrendSummaryModel.fromJson({}),
        );
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'location_trends': locationTrends.map((e) => e.toJson()).toList(),
      'period_info': periodInfo.toJson(),
      'summary': summary.toJson(),
    };
  }

  // Helper methods for calculating summary
  static int _calculateTotalGrowth(dynamic locationTrends) {
    if (locationTrends is! List || locationTrends.isEmpty) return 0;

    try {
      int total = 0;
      for (final trend in locationTrends) {
        if (trend is Map<String, dynamic>) {
          final assetCount = trend['asset_count'] ?? 0;
          total += (assetCount is int)
              ? assetCount
              : int.tryParse(assetCount.toString()) ?? 0;
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  static int _calculateAverageGrowth(dynamic locationTrends) {
    if (locationTrends is! List || locationTrends.isEmpty) return 0;

    try {
      int totalGrowth = 0;
      int count = 0;
      for (final trend in locationTrends) {
        if (trend is Map<String, dynamic>) {
          final growthPercentage = trend['growth_percentage'] ?? 0;
          totalGrowth += (growthPercentage is int)
              ? growthPercentage
              : int.tryParse(growthPercentage.toString()) ?? 0;
          count++;
        }
      }
      return count > 0 ? (totalGrowth / count).round() : 0;
    } catch (e) {
      return 0;
    }
  }
}

class LocationTrendDataModel {
  final String monthYear;
  final int assetCount;
  final int activeCount;
  final int growthPercentage;
  final String locationCode;
  final String locationDescription;
  final String? plantCode;
  final String? plantDescription;

  const LocationTrendDataModel({
    required this.monthYear,
    required this.assetCount,
    required this.activeCount,
    required this.growthPercentage,
    required this.locationCode,
    required this.locationDescription,
    this.plantCode,
    this.plantDescription,
  });

  factory LocationTrendDataModel.fromJson(Map<String, dynamic> json) {
    return LocationTrendDataModel(
      monthYear: json['month_year'] ?? '',
      assetCount: int.tryParse(json['asset_count']?.toString() ?? '0') ?? 0,
      activeCount: int.tryParse(json['active_count']?.toString() ?? '0') ?? 0,
      growthPercentage: json['growth_percentage'] ?? 0,
      locationCode: json['location_code'] ?? '',
      locationDescription: json['location_description'] ?? '',
      plantCode: json['plant_code'],
      plantDescription: json['plant_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month_year': monthYear,
      'asset_count': assetCount,
      'active_count': activeCount,
      'growth_percentage': growthPercentage,
      'location_code': locationCode,
      'location_description': locationDescription,
      'plant_code': plantCode,
      'plant_description': plantDescription,
    };
  }
}

class LocationTrendPeriodInfoModel {
  final String period;
  final int year;
  final String startDate;
  final String endDate;
  final String locationCode;

  const LocationTrendPeriodInfoModel({
    required this.period,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.locationCode,
  });

  factory LocationTrendPeriodInfoModel.fromJson(Map<String, dynamic> json) {
    return LocationTrendPeriodInfoModel(
      period: json['period'] ?? 'Q2',
      year: json['year'] ?? DateTime.now().year,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      locationCode: json['location_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'year': year,
      'start_date': startDate,
      'end_date': endDate,
      'location_code': locationCode,
    };
  }
}

class LocationTrendSummaryModel {
  final int totalPeriods;
  final int totalGrowth;
  final int averageGrowth;

  const LocationTrendSummaryModel({
    required this.totalPeriods,
    required this.totalGrowth,
    required this.averageGrowth,
  });

  factory LocationTrendSummaryModel.fromJson(Map<String, dynamic> json) {
    return LocationTrendSummaryModel(
      totalPeriods: json['total_periods'] ?? 0,
      totalGrowth: json['total_growth'] ?? 0,
      averageGrowth: json['average_growth'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_periods': totalPeriods,
      'total_growth': totalGrowth,
      'average_growth': averageGrowth,
    };
  }
}
