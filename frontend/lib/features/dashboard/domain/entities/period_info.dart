// Path: frontend/lib/features/dashboard/domain/entities/period_info.dart
class ComparisonPeriod {
  final DateTime startDate;
  final DateTime endDate;

  const ComparisonPeriod({required this.startDate, required this.endDate});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComparisonPeriod &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return startDate.hashCode ^ endDate.hashCode;
  }

  @override
  String toString() {
    return 'ComparisonPeriod(startDate: $startDate, endDate: $endDate)';
  }

  Duration get duration => endDate.difference(startDate);
}

class PeriodInfo {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final ComparisonPeriod? comparisonPeriod;
  final int? totalScans;
  final int? totalExports;

  const PeriodInfo({
    required this.period,
    required this.startDate,
    required this.endDate,
    this.comparisonPeriod,
    this.totalScans,
    this.totalExports,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeriodInfo &&
        other.period == period &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.comparisonPeriod == comparisonPeriod &&
        other.totalScans == totalScans &&
        other.totalExports == totalExports;
  }

  @override
  int get hashCode {
    return period.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        comparisonPeriod.hashCode ^
        totalScans.hashCode ^
        totalExports.hashCode;
  }

  @override
  String toString() {
    return 'PeriodInfo(period: $period, startDate: $startDate, endDate: $endDate)';
  }

  // Helper getters
  Duration get duration => endDate.difference(startDate);
  bool get hasComparison => comparisonPeriod != null;
  bool get isToday => period == 'today';
  bool get isWeek => period == '7d';
  bool get isMonth => period == '30d';

  String get displayName {
    switch (period) {
      case 'today':
        return 'Today';
      case '7d':
        return 'Last 7 Days';
      case '30d':
        return 'Last 30 Days';
      default:
        return 'Custom Period';
    }
  }

  bool get hasActivity => (totalScans ?? 0) > 0 || (totalExports ?? 0) > 0;
}
