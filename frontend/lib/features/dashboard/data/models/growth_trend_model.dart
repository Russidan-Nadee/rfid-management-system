// Path: frontend/lib/features/dashboard/data/models/growth_trend_model.dart
class GrowthTrendModel {
  final List<TrendDataModel> trends;
  final TrendPeriodInfoModel periodInfo;
  final TrendSummaryModel summary;

  const GrowthTrendModel({
    required this.trends,
    required this.periodInfo,
    required this.summary,
  });

  factory GrowthTrendModel.fromJson(Map<String, dynamic> json) {
    return GrowthTrendModel(
      trends:
          (json['trends'] as List<dynamic>?)
              ?.map((e) => TrendDataModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      periodInfo: TrendPeriodInfoModel.fromJson(json['period_info'] ?? {}),
      summary: TrendSummaryModel.fromJson(json['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trends': trends.map((e) => e.toJson()).toList(),
      'period_info': periodInfo.toJson(),
      'summary': summary.toJson(),
    };
  }
}

class TrendDataModel {
  final String period;
  final int assetCount;
  final int growthPercentage;
  final int cumulativeCount;
  final String deptCode;
  final String deptDescription;

  const TrendDataModel({
    required this.period,
    required this.assetCount,
    required this.growthPercentage,
    required this.cumulativeCount,
    required this.deptCode,
    required this.deptDescription,
  });

  factory TrendDataModel.fromJson(Map<String, dynamic> json) {
    return TrendDataModel(
      period: json['period'] ?? '',
      assetCount: json['asset_count'] ?? 0,
      growthPercentage: json['growth_percentage'] ?? 0,
      cumulativeCount: json['cumulative_count'] ?? 0,
      deptCode: json['dept_code'] ?? '',
      deptDescription: json['dept_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'asset_count': assetCount,
      'growth_percentage': growthPercentage,
      'cumulative_count': cumulativeCount,
      'dept_code': deptCode,
      'dept_description': deptDescription,
    };
  }
}

class TrendPeriodInfoModel {
  final String period;
  final int year;
  final String startDate;
  final String endDate;
  final int totalGrowth;

  const TrendPeriodInfoModel({
    required this.period,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.totalGrowth,
  });

  factory TrendPeriodInfoModel.fromJson(Map<String, dynamic> json) {
    return TrendPeriodInfoModel(
      period: json['period'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalGrowth: json['total_growth'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'year': year,
      'start_date': startDate,
      'end_date': endDate,
      'total_growth': totalGrowth,
    };
  }
}

class TrendSummaryModel {
  final int totalPeriods;
  final int totalGrowth;
  final int averageGrowth;

  const TrendSummaryModel({
    required this.totalPeriods,
    required this.totalGrowth,
    required this.averageGrowth,
  });

  factory TrendSummaryModel.fromJson(Map<String, dynamic> json) {
    return TrendSummaryModel(
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
