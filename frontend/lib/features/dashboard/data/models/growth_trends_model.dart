// Path: frontend/lib/features/dashboard/data/models/growth_trends_model.dart
import '../../domain/entities/growth_trends.dart';

class TrendDataPointModel {
  final String monthYear;
  final int assetCount;
  final String? deptCode;
  final String? deptDescription;
  final int growthPercentage;
  final int cumulativeCount;

  TrendDataPointModel({
    required this.monthYear,
    required this.assetCount,
    this.deptCode,
    this.deptDescription,
    required this.growthPercentage,
    required this.cumulativeCount,
  });

  factory TrendDataPointModel.fromJson(Map<String, dynamic> json) {
    return TrendDataPointModel(
      monthYear: json['month_year'] ?? '',
      assetCount: json['asset_count'] ?? 0,
      deptCode: json['dept_code'],
      deptDescription: json['dept_description'],
      growthPercentage: json['growth_percentage'] ?? 0,
      cumulativeCount: json['cumulative_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month_year': monthYear,
      'asset_count': assetCount,
      'dept_code': deptCode,
      'dept_description': deptDescription,
      'growth_percentage': growthPercentage,
      'cumulative_count': cumulativeCount,
    };
  }

  TrendDataPoint toEntity() {
    return TrendDataPoint(
      monthYear: monthYear,
      assetCount: assetCount,
      deptCode: deptCode,
      deptDescription: deptDescription,
      growthPercentage: growthPercentage,
      cumulativeCount: cumulativeCount,
    );
  }

  // Helper methods
  bool get hasGrowth => growthPercentage > 0;
  bool get hasDecline => growthPercentage < 0;
  bool get isStable => growthPercentage == 0;

  String get growthIndicator {
    if (hasGrowth) return '↗️';
    if (hasDecline) return '↘️';
    return '→';
  }

  String get formattedGrowth {
    final sign = growthPercentage >= 0 ? '+' : '';
    return '$sign$growthPercentage%';
  }

  DateTime? get parsedDate {
    try {
      // Assuming format is "YYYY-MM"
      final parts = monthYear.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        return DateTime(year, month);
      }
    } catch (e) {
      print('Date parsing error for $monthYear: $e');
    }
    return null;
  }

  String get monthLabel {
    final date = parsedDate;
    if (date == null) return monthYear;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[date.month - 1];
  }
}

class PeriodInfoModel {
  final String period;
  final int? year;
  final DateTime startDate;
  final DateTime endDate;
  final int totalGrowth;

  PeriodInfoModel({
    required this.period,
    this.year,
    required this.startDate,
    required this.endDate,
    required this.totalGrowth,
  });

  factory PeriodInfoModel.fromJson(Map<String, dynamic> json) {
    return PeriodInfoModel(
      period: json['period'] ?? '',
      year: json['year'],
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      totalGrowth: json['total_growth'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'year': year,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_growth': totalGrowth,
    };
  }

  PeriodInfo toEntity() {
    return PeriodInfo(
      period: period,
      year: year,
      startDate: startDate,
      endDate: endDate,
      totalGrowth: totalGrowth,
    );
  }

  // Helper methods
  bool get isQuarterly => ['Q1', 'Q2', 'Q3', 'Q4'].contains(period);
  bool get isYearly => period == '1Y';
  bool get isCustom => period == 'custom';

  String get periodLabel {
    switch (period) {
      case 'Q1':
        return 'Q1 ${year ?? ''}';
      case 'Q2':
        return 'Q2 ${year ?? ''}';
      case 'Q3':
        return 'Q3 ${year ?? ''}';
      case 'Q4':
        return 'Q4 ${year ?? ''}';
      case '1Y':
        return 'Year ${year ?? ''}';
      case 'custom':
        return 'Custom Period';
      default:
        return period;
    }
  }

  Duration get duration => endDate.difference(startDate);

  int get durationInDays => duration.inDays;

  String get dateRangeText {
    if (isCustom) {
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    }
    return periodLabel;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class QuarterlyDataModel {
  final String quarter;
  final int assetCount;
  final int growthPercentage;
  final String? deptCode;
  final String? deptDescription;

  QuarterlyDataModel({
    required this.quarter,
    required this.assetCount,
    required this.growthPercentage,
    this.deptCode,
    this.deptDescription,
  });

  factory QuarterlyDataModel.fromJson(Map<String, dynamic> json) {
    return QuarterlyDataModel(
      quarter: json['quarter'] ?? '',
      assetCount: json['asset_count'] ?? 0,
      growthPercentage: json['growth_percentage'] ?? 0,
      deptCode: json['dept_code'],
      deptDescription: json['dept_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quarter': quarter,
      'asset_count': assetCount,
      'growth_percentage': growthPercentage,
      'dept_code': deptCode,
      'dept_description': deptDescription,
    };
  }

  QuarterlyData toEntity() {
    return QuarterlyData(
      quarter: quarter,
      assetCount: assetCount,
      growthPercentage: growthPercentage,
      deptCode: deptCode,
      deptDescription: deptDescription,
    );
  }

  // Helper methods
  bool get hasGrowth => growthPercentage > 0;
  String get formattedGrowth => '+$growthPercentage%';
}

class YearInfoModel {
  final int year;
  final int totalAssets;
  final int averageGrowth;

  YearInfoModel({
    required this.year,
    required this.totalAssets,
    required this.averageGrowth,
  });

  factory YearInfoModel.fromJson(Map<String, dynamic> json) {
    return YearInfoModel(
      year: json['year'] ?? DateTime.now().year,
      totalAssets: json['total_assets'] ?? 0,
      averageGrowth: json['average_growth'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'total_assets': totalAssets,
      'average_growth': averageGrowth,
    };
  }

  YearInfo toEntity() {
    return YearInfo(
      year: year,
      totalAssets: totalAssets,
      averageGrowth: averageGrowth,
    );
  }
}

class GrowthTrendsModel {
  final List<TrendDataPointModel> trends;
  final PeriodInfoModel periodInfo;
  final List<QuarterlyDataModel>? quarterlyData;
  final YearInfoModel? yearInfo;

  GrowthTrendsModel({
    required this.trends,
    required this.periodInfo,
    this.quarterlyData,
    this.yearInfo,
  });

  factory GrowthTrendsModel.fromJson(Map<String, dynamic> json) {
    try {
      final trendsData = json['trends'] as List<dynamic>? ?? [];
      final periodData = json['period_info'] as Map<String, dynamic>? ?? {};
      final quarterlyListData = json['quarterly_data'] as List<dynamic>?;
      final yearData = json['year_info'] as Map<String, dynamic>?;

      return GrowthTrendsModel(
        trends: trendsData
            .map(
              (item) =>
                  TrendDataPointModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        periodInfo: PeriodInfoModel.fromJson(periodData),
        quarterlyData: quarterlyListData
            ?.map(
              (item) =>
                  QuarterlyDataModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        yearInfo: yearData != null ? YearInfoModel.fromJson(yearData) : null,
      );
    } catch (e) {
      print('Growth trends parsing error: $e');
      return GrowthTrendsModel(
        trends: [],
        periodInfo: PeriodInfoModel(
          period: 'Q2',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          totalGrowth: 0,
        ),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'trends': trends.map((item) => item.toJson()).toList(),
      'period_info': periodInfo.toJson(),
      'quarterly_data': quarterlyData?.map((item) => item.toJson()).toList(),
      'year_info': yearInfo?.toJson(),
    };
  }

  GrowthTrends toEntity() {
    return GrowthTrends(
      trends: trends.map((item) => item.toEntity()).toList(),
      periodInfo: periodInfo.toEntity(),
      quarterlyData: quarterlyData?.map((item) => item.toEntity()).toList(),
      yearInfo: yearInfo?.toEntity(),
    );
  }

  // Helper methods
  bool get hasData => trends.isNotEmpty;

  bool get hasQuarterlyData =>
      quarterlyData != null && quarterlyData!.isNotEmpty;

  bool get hasPositiveGrowth => trends.any((trend) => trend.hasGrowth);

  bool get hasNegativeGrowth => trends.any((trend) => trend.hasDecline);

  int get totalAssetCount =>
      trends.fold(0, (sum, trend) => sum + trend.assetCount);

  double get averageGrowthRate {
    if (trends.isEmpty) return 0.0;
    final totalGrowth = trends.fold(
      0,
      (sum, trend) => sum + trend.growthPercentage,
    );
    return totalGrowth / trends.length;
  }

  TrendDataPointModel? get highestGrowthPeriod {
    if (trends.isEmpty) return null;
    return trends.reduce(
      (a, b) => a.growthPercentage > b.growthPercentage ? a : b,
    );
  }

  TrendDataPointModel? get lowestGrowthPeriod {
    if (trends.isEmpty) return null;
    return trends.reduce(
      (a, b) => a.growthPercentage < b.growthPercentage ? a : b,
    );
  }

  // Chart data preparation
  List<Map<String, dynamic>> get chartData {
    return trends
        .map(
          (trend) => {
            'x': trend.monthLabel,
            'y': trend.assetCount,
            'growth': trend.growthPercentage,
            'label': trend.formattedGrowth,
          },
        )
        .toList();
  }

  // Period validation
  static bool isValidPeriod(String period) {
    const validPeriods = ['Q1', 'Q2', 'Q3', 'Q4', '1Y', 'custom'];
    return validPeriods.contains(period);
  }

  static String getDefaultPeriod() => 'Q2';

  // Growth trend analysis
  String get trendAnalysis {
    if (trends.isEmpty) return 'No data available';

    final positiveCount = trends.where((t) => t.hasGrowth).length;
    final negativeCount = trends.where((t) => t.hasDecline).length;
    final stableCount = trends.where((t) => t.isStable).length;

    if (positiveCount > negativeCount) {
      return 'Growing trend ($positiveCount periods with growth)';
    } else if (negativeCount > positiveCount) {
      return 'Declining trend ($negativeCount periods with decline)';
    } else {
      return 'Stable trend (mixed growth patterns)';
    }
  }
}
