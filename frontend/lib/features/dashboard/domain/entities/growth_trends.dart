// Path: frontend/lib/features/dashboard/domain/entities/growth_trends.dart

class TrendDataPoint {
  final String monthYear;
  final int assetCount;
  final String? deptCode;
  final String? deptDescription;
  final int growthPercentage;
  final int cumulativeCount;

  const TrendDataPoint({
    required this.monthYear,
    required this.assetCount,
    this.deptCode,
    this.deptDescription,
    required this.growthPercentage,
    required this.cumulativeCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendDataPoint &&
        other.monthYear == monthYear &&
        other.assetCount == assetCount &&
        other.deptCode == deptCode &&
        other.deptDescription == deptDescription &&
        other.growthPercentage == growthPercentage &&
        other.cumulativeCount == cumulativeCount;
  }

  @override
  int get hashCode {
    return monthYear.hashCode ^
        assetCount.hashCode ^
        deptCode.hashCode ^
        deptDescription.hashCode ^
        growthPercentage.hashCode ^
        cumulativeCount.hashCode;
  }

  @override
  String toString() {
    return 'TrendDataPoint(monthYear: $monthYear, assetCount: $assetCount, growthPercentage: $growthPercentage)';
  }

  // Helper getters
  bool get hasGrowth => growthPercentage > 0;
  bool get hasDecline => growthPercentage < 0;
  bool get isStable => growthPercentage == 0;
}

class PeriodInfo {
  final String period;
  final int? year;
  final DateTime startDate;
  final DateTime endDate;
  final int totalGrowth;

  const PeriodInfo({
    required this.period,
    this.year,
    required this.startDate,
    required this.endDate,
    required this.totalGrowth,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeriodInfo &&
        other.period == period &&
        other.year == year &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.totalGrowth == totalGrowth;
  }

  @override
  int get hashCode {
    return period.hashCode ^
        year.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        totalGrowth.hashCode;
  }

  @override
  String toString() {
    return 'PeriodInfo(period: $period, year: $year, totalGrowth: $totalGrowth)';
  }

  // Helper getters
  bool get isQuarterly => ['Q1', 'Q2', 'Q3', 'Q4'].contains(period);
  bool get isYearly => period == '1Y';
  bool get isCustom => period == 'custom';

  Duration get duration => endDate.difference(startDate);
  int get durationInDays => duration.inDays;
}

class QuarterlyData {
  final String quarter;
  final int assetCount;
  final int growthPercentage;
  final String? deptCode;
  final String? deptDescription;

  const QuarterlyData({
    required this.quarter,
    required this.assetCount,
    required this.growthPercentage,
    this.deptCode,
    this.deptDescription,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuarterlyData &&
        other.quarter == quarter &&
        other.assetCount == assetCount &&
        other.growthPercentage == growthPercentage &&
        other.deptCode == deptCode &&
        other.deptDescription == deptDescription;
  }

  @override
  int get hashCode {
    return quarter.hashCode ^
        assetCount.hashCode ^
        growthPercentage.hashCode ^
        deptCode.hashCode ^
        deptDescription.hashCode;
  }

  @override
  String toString() {
    return 'QuarterlyData(quarter: $quarter, assetCount: $assetCount, growthPercentage: $growthPercentage)';
  }

  // Helper getters
  bool get hasGrowth => growthPercentage > 0;
}

class YearInfo {
  final int year;
  final int totalAssets;
  final int averageGrowth;

  const YearInfo({
    required this.year,
    required this.totalAssets,
    required this.averageGrowth,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YearInfo &&
        other.year == year &&
        other.totalAssets == totalAssets &&
        other.averageGrowth == averageGrowth;
  }

  @override
  int get hashCode {
    return year.hashCode ^ totalAssets.hashCode ^ averageGrowth.hashCode;
  }

  @override
  String toString() {
    return 'YearInfo(year: $year, totalAssets: $totalAssets, averageGrowth: $averageGrowth)';
  }
}

class GrowthTrends {
  final List<TrendDataPoint> trends;
  final PeriodInfo periodInfo;
  final List<QuarterlyData>? quarterlyData;
  final YearInfo? yearInfo;

  const GrowthTrends({
    required this.trends,
    required this.periodInfo,
    this.quarterlyData,
    this.yearInfo,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthTrends &&
        other.trends.length == trends.length &&
        other.periodInfo == periodInfo &&
        other.quarterlyData?.length == quarterlyData?.length &&
        other.yearInfo == yearInfo &&
        other.trends.every((element) => trends.contains(element)) &&
        (quarterlyData == null ||
            other.quarterlyData!.every(
              (element) => quarterlyData!.contains(element),
            ));
  }

  @override
  int get hashCode {
    return trends.hashCode ^
        periodInfo.hashCode ^
        quarterlyData.hashCode ^
        yearInfo.hashCode;
  }

  @override
  String toString() {
    return 'GrowthTrends(trends: ${trends.length} items, periodInfo: $periodInfo)';
  }

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

  // Helper getters
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

  TrendDataPoint? get highestGrowthPeriod {
    if (trends.isEmpty) return null;
    return trends.reduce(
      (a, b) => a.growthPercentage > b.growthPercentage ? a : b,
    );
  }

  TrendDataPoint? get lowestGrowthPeriod {
    if (trends.isEmpty) return null;
    return trends.reduce(
      (a, b) => a.growthPercentage < b.growthPercentage ? a : b,
    );
  }
}
