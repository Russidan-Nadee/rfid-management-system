// Path: frontend/lib/features/export/data/models/period_model.dart
import 'package:equatable/equatable.dart';

class PeriodModel extends Equatable {
  final DateTime from;
  final DateTime to;

  const PeriodModel({required this.from, required this.to});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'from': from.toIso8601String(), 'to': to.toIso8601String()};
  }

  /// Create from JSON
  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
    );
  }

  /// Preset periods for UI
  factory PeriodModel.today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return PeriodModel(from: startOfDay, to: endOfDay);
  }

  factory PeriodModel.yesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfDay = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
      23,
      59,
      59,
    );
    return PeriodModel(from: startOfDay, to: endOfDay);
  }

  factory PeriodModel.thisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    return PeriodModel(from: startOfWeek, to: endOfWeek);
  }

  factory PeriodModel.lastWeek() {
    final now = DateTime.now();
    final lastWeekStart = now.subtract(Duration(days: now.weekday + 6));
    final startOfWeek = DateTime(
      lastWeekStart.year,
      lastWeekStart.month,
      lastWeekStart.day,
    );
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    return PeriodModel(from: startOfWeek, to: endOfWeek);
  }

  factory PeriodModel.thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return PeriodModel(from: startOfMonth, to: endOfMonth);
  }

  factory PeriodModel.lastMonth() {
    final now = DateTime.now();
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
    return PeriodModel(from: startOfLastMonth, to: endOfLastMonth);
  }

  factory PeriodModel.last7Days() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return PeriodModel(from: sevenDaysAgo, to: now);
  }

  factory PeriodModel.last30Days() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return PeriodModel(from: thirtyDaysAgo, to: now);
  }

  factory PeriodModel.last3Months() {
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    return PeriodModel(from: threeMonthsAgo, to: now);
  }

  factory PeriodModel.last6Months() {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
    return PeriodModel(from: sixMonthsAgo, to: now);
  }

  factory PeriodModel.thisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    return PeriodModel(from: startOfYear, to: endOfYear);
  }

  /// Business validation
  bool get isValid => from.isBefore(to);

  Duration get duration => to.difference(from);

  int get daysDuration => duration.inDays;

  bool get isWithinOneYear => daysDuration <= 365;

  bool get isInFuture => from.isAfter(DateTime.now());

  bool get isTooOld {
    final twoYearsAgo = DateTime.now().subtract(const Duration(days: 730));
    return from.isBefore(twoYearsAgo);
  }

  /// Validation for Backend constraints
  ValidationResult validate() {
    final errors = <String>[];

    if (!isValid) {
      errors.add('End date must be after start date');
    }

    if (isInFuture) {
      errors.add('Start date cannot be in the future');
    }

    if (isTooOld) {
      errors.add('Start date cannot be more than 2 years ago');
    }

    if (!isWithinOneYear) {
      errors.add('Date range cannot exceed 1 year');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Display helpers
  String get displayLabel {
    if (daysDuration == 0) return 'Single Day';
    if (daysDuration <= 7) return '$daysDuration Days';
    if (daysDuration <= 30) return '${(daysDuration / 7).ceil()} Weeks';
    return '${(daysDuration / 30).ceil()} Months';
  }

  @override
  List<Object?> get props => [from, to];

  @override
  String toString() =>
      'PeriodModel(from: $from, to: $to, duration: $daysDuration days)';
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}

/// Period option for UI dropdowns
class PeriodOption {
  final String label;
  final PeriodModel period;

  const PeriodOption(this.label, this.period);

  /// Get all preset options
  static List<PeriodOption> getPresetOptions() {
    return [
      PeriodOption('Today', PeriodModel.today()),
      PeriodOption('Yesterday', PeriodModel.yesterday()),
      PeriodOption('Last 7 Days', PeriodModel.last7Days()),
      PeriodOption('Last 30 Days', PeriodModel.last30Days()),
      PeriodOption('This Week', PeriodModel.thisWeek()),
      PeriodOption('Last Week', PeriodModel.lastWeek()),
      PeriodOption('This Month', PeriodModel.thisMonth()),
      PeriodOption('Last Month', PeriodModel.lastMonth()),
      PeriodOption('Last 3 Months', PeriodModel.last3Months()),
      PeriodOption('Last 6 Months', PeriodModel.last6Months()),
      PeriodOption('This Year', PeriodModel.thisYear()),
    ];
  }

  @override
  String toString() => label;
}
