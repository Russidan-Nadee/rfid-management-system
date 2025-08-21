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
    // Processing location analytics data

    try {
      List<LocationTrendDataModel> trends = [];
      Map<String, dynamic> periodInfo = {};
      Map<String, dynamic> summaryData = {};

      // วิธีที่ 1: ตรวจสอบ format เหมือน GrowthTrendModel (Simple format)
      if (json['trends'] != null && json['trends'] is List) {
        print('✅ Using simple format (trends array)');
        trends = (json['trends'] as List<dynamic>)
            .map(
              (e) => LocationTrendDataModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        periodInfo = json['period_info'] ?? {};
        summaryData = json['summary'] ?? {};
      }
      // วิธีที่ 2: ตรวจสอบ format ซับซ้อน (Complex format)
      else if (json['growth_trends'] != null) {
        print('✅ Using complex format (growth_trends object)');
        final growthTrends = json['growth_trends'] as Map<String, dynamic>;

        if (growthTrends['location_trends'] != null) {
          trends = (growthTrends['location_trends'] as List<dynamic>)
              .map(
                (e) =>
                    LocationTrendDataModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }

        periodInfo = growthTrends['period_info'] ?? json['period_info'] ?? {};
        summaryData = json['summary'] ?? _calculateSummaryFromTrends(trends);
      }
      // วิธีที่ 3: ตรวจสอบ location_analytics array format
      else if (json['location_analytics'] != null &&
          json['location_analytics'] is List) {
        // Using location_analytics array format
        // แปลงข้อมูล location analytics เป็น trend format
        final locationAnalytics = json['location_analytics'] as List<dynamic>;
        trends = locationAnalytics
            .map((e) => _convertLocationDataToTrend(e as Map<String, dynamic>))
            .toList();

        periodInfo = json['period_info'] ?? {};
        summaryData =
            json['analytics_summary'] ?? _calculateSummaryFromTrends(trends);
      }
      // วิธีที่ 4: ไม่มีข้อมูล trends แต่มี location_analytics object
      else if (json['location_analytics'] != null &&
          json['location_analytics'] is Map) {
        print('✅ Using single location_analytics object format');
        final locationData = json['location_analytics'] as Map<String, dynamic>;
        trends = [_convertLocationDataToTrend(locationData)];

        periodInfo = json['period_info'] ?? {};
        summaryData =
            json['analytics_summary'] ?? _calculateSummaryFromTrends(trends);
      }
      // วิธีที่ 5: ตรวจสอบ location_trends array format (Direct location trends)
      else if (json['location_trends'] != null &&
          json['location_trends'] is List) {
        print('✅ Using direct location_trends array format');
        trends = (json['location_trends'] as List<dynamic>)
            .map(
              (e) => LocationTrendDataModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();

        periodInfo = json['period_info'] ?? {};
        summaryData = json['summary'] ?? _calculateSummaryFromTrends(trends);
      } else {
        print('❌ No recognizable location data format found');
        // ไม่ส่งข้อมูล mock กลับไป แต่ส่ง empty list
        trends = [];
        periodInfo = {};
        summaryData = {
          'total_periods': 0,
          'total_growth': 0,
          'average_growth': 0,
        };
      }

      // Location analytics trends processed

      return LocationAnalyticsModel(
        locationTrends: trends,
        periodInfo: LocationTrendPeriodInfoModel.fromJson(periodInfo),
        summary: LocationTrendSummaryModel.fromJson(summaryData),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing location analytics: $e');
      print('📍 Stack trace: $stackTrace');
      // ส่งข้อมูลว่างกลับไปแทน mock
      return LocationAnalyticsModel(
        locationTrends: [],
        periodInfo: LocationTrendPeriodInfoModel.fromJson({}),
        summary: LocationTrendSummaryModel.fromJson({
          'total_periods': 0,
          'total_growth': 0,
          'average_growth': 0,
        }),
      );
    }
  }
  // แปลงข้อมูล location analytics เป็น trend format
  static LocationTrendDataModel _convertLocationDataToTrend(
    Map<String, dynamic> data,
  ) {
    // print('🔄 Converting location data: ${data.keys.toList()}');

    return LocationTrendDataModel(
      monthYear:
          data['month_year'] ??
          data['period'] ??
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
      assetCount: _parseIntSafely(
        data['total_assets'] ?? data['asset_count'] ?? 0,
      ),
      activeCount: _parseIntSafely(
        data['active_assets'] ?? data['active_count'] ?? 0,
      ),
      growthPercentage: _parseIntSafely(data['growth_percentage'] ?? 0),
      locationCode: data['location_code'] ?? 'UNKNOWN',
      locationDescription:
          data['location_description'] ??
          data['description'] ??
          'Unknown Location',
      plantCode: data['plant_code'],
      plantDescription: data['plant_description'],
    );
  }

  // คำนวณ summary จาก trends ที่มี
  static Map<String, dynamic> _calculateSummaryFromTrends(
    List<LocationTrendDataModel> trends,
  ) {
    if (trends.isEmpty) {
      return {'total_periods': 0, 'total_growth': 0, 'average_growth': 0};
    }

    final totalGrowth = trends.fold<int>(
      0,
      (sum, trend) => sum + trend.assetCount,
    );
    final averageGrowth =
        trends.fold<int>(0, (sum, trend) => sum + trend.growthPercentage) ~/
        trends.length;

    return {
      'total_periods': trends.length,
      'total_growth': totalGrowth,
      'average_growth': averageGrowth,
    };
  }

  // Parse integer อย่างปลอดภัย
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'location_trends': locationTrends.map((e) => e.toJson()).toList(),
      'period_info': periodInfo.toJson(),
      'summary': summary.toJson(),
    };
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
      monthYear:
          json['month_year'] ??
          json['period'] ??
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
      assetCount: LocationAnalyticsModel._parseIntSafely(
        json['asset_count'] ?? 0,
      ),
      activeCount: LocationAnalyticsModel._parseIntSafely(
        json['active_count'] ?? 0,
      ),
      growthPercentage: LocationAnalyticsModel._parseIntSafely(
        json['growth_percentage'] ?? 0,
      ),
      locationCode: json['location_code'] ?? 'UNKNOWN',
      locationDescription: json['location_description'] ?? 'Unknown Location',
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
      totalPeriods: LocationAnalyticsModel._parseIntSafely(
        json['total_periods'] ?? 0,
      ),
      totalGrowth: LocationAnalyticsModel._parseIntSafely(
        json['total_growth'] ?? 0,
      ),
      averageGrowth: LocationAnalyticsModel._parseIntSafely(
        json['average_growth'] ?? 0,
      ),
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
