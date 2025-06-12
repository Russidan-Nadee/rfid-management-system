// Path: frontend/lib/features/dashboard/data/models/period_info_model.dart
import '../../domain/entities/period_info.dart';

class ComparisonPeriodModel {
  final DateTime startDate;
  final DateTime endDate;

  ComparisonPeriodModel({required this.startDate, required this.endDate});

  factory ComparisonPeriodModel.fromJson(Map<String, dynamic> json) {
    return ComparisonPeriodModel(
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  ComparisonPeriod toEntity() {
    return ComparisonPeriod(startDate: startDate, endDate: endDate);
  }
}

class PeriodInfoModel {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final ComparisonPeriodModel? comparisonPeriod;
  final int? totalScans;
  final int? totalExports;

  PeriodInfoModel({
    required this.period,
    required this.startDate,
    required this.endDate,
    this.comparisonPeriod,
    this.totalScans,
    this.totalExports,
  });

  factory PeriodInfoModel.fromJson(Map<String, dynamic> json) {
    return PeriodInfoModel(
      period: json['period'] ?? 'today',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      comparisonPeriod: json['comparison_period'] != null
          ? ComparisonPeriodModel.fromJson(
              json['comparison_period'] as Map<String, dynamic>,
            )
          : null,
      totalScans: json['total_scans'],
      totalExports: json['total_exports'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'comparison_period': comparisonPeriod?.toJson(),
      'total_scans': totalScans,
      'total_exports': totalExports,
    };
  }

  PeriodInfo toEntity() {
    return PeriodInfo(
      period: period,
      startDate: startDate,
      endDate: endDate,
      comparisonPeriod: comparisonPeriod?.toEntity(),
      totalScans: totalScans,
      totalExports: totalExports,
    );
  }

  // Helper methods
  String get periodLabel {
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

  Duration get periodDuration {
    return endDate.difference(startDate);
  }

  bool get hasComparison => comparisonPeriod != null;

  String get dateRangeText {
    if (period == 'today') {
      return 'Today';
    }

    final formatter = DateTime.now().year == startDate.year
        ? 'MMM d'
        : 'MMM d, y';
    return '${_formatDate(startDate, formatter)} - ${_formatDate(endDate, formatter)}';
  }

  String _formatDate(DateTime date, String format) {
    // Simple date formatting - you might want to use intl package for better formatting
    final months = [
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

    if (format == 'MMM d') {
      return '${months[date.month - 1]} ${date.day}';
    } else if (format == 'MMM d, y') {
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    return date.toString().split(' ')[0]; // fallback
  }
}
