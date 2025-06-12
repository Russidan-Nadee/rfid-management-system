// Path: frontend/lib/features/dashboard/domain/entities/scan_trend.dart
class ScanTrend {
  final String date;
  final int count;
  final String? dayName;

  const ScanTrend({required this.date, required this.count, this.dayName});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanTrend &&
        other.date == date &&
        other.count == count &&
        other.dayName == dayName;
  }

  @override
  int get hashCode {
    return date.hashCode ^ count.hashCode ^ dayName.hashCode;
  }

  @override
  String toString() {
    return 'ScanTrend(date: $date, count: $count, dayName: $dayName)';
  }
}
