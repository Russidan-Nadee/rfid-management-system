// Path: frontend/lib/features/dashboard/data/models/scan_trend_model.dart

class ScanTrendModel {
  final String date;
  final int count;
  final String? dayName;

  ScanTrendModel({required this.date, required this.count, this.dayName});

  factory ScanTrendModel.fromJson(Map<String, dynamic> json) {
    return ScanTrendModel(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      dayName: json['day_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'count': count, 'day_name': dayName};
  }

  ScanTrend toEntity() {
    return ScanTrend(date: date, count: count, dayName: dayName);
  }
}
