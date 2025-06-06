// Path: frontend/lib/features/export/domain/entities/export_config_entity.dart
import 'package:equatable/equatable.dart';

class ExportConfigEntity extends Equatable {
  final String format; // 'xlsx' or 'csv'
  final ExportFiltersEntity? filters;
  final List<String>? columns;

  const ExportConfigEntity({required this.format, this.filters, this.columns});

  // Business validation
  bool get isValidFormat => ['xlsx', 'csv'].contains(format.toLowerCase());
  bool get hasFilters => filters != null && filters!.hasAnyFilter;
  bool get hasCustomColumns => columns != null && columns!.isNotEmpty;

  String get formatLabel {
    switch (format.toLowerCase()) {
      case 'xlsx':
        return 'Excel (.xlsx)';
      case 'csv':
        return 'CSV (.csv)';
      default:
        return format.toUpperCase();
    }
  }

  // Factory constructors for common configurations
  factory ExportConfigEntity.defaultAssets() {
    return const ExportConfigEntity(
      format: 'xlsx',
      filters: ExportFiltersEntity(),
    );
  }

  factory ExportConfigEntity.quickAllAssets() {
    return const ExportConfigEntity(
      format: 'xlsx',
      filters: ExportFiltersEntity(
        status: ['A'], // Active only
      ),
    );
  }

  factory ExportConfigEntity.recentScans() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return ExportConfigEntity(
      format: 'csv',
      filters: ExportFiltersEntity(
        dateRange: DateRangeEntity(from: sevenDaysAgo, to: DateTime.now()),
      ),
    );
  }

  ExportConfigEntity copyWith({
    String? format,
    ExportFiltersEntity? filters,
    List<String>? columns,
  }) {
    return ExportConfigEntity(
      format: format ?? this.format,
      filters: filters ?? this.filters,
      columns: columns ?? this.columns,
    );
  }

  @override
  List<Object?> get props => [format, filters, columns];

  @override
  String toString() {
    return 'ExportConfigEntity(format: $format, hasFilters: $hasFilters)';
  }
}

class ExportFiltersEntity extends Equatable {
  final List<String>? plantCodes;
  final List<String>? locationCodes;
  final List<String>? status;
  final DateRangeEntity? dateRange;

  const ExportFiltersEntity({
    this.plantCodes,
    this.locationCodes,
    this.status,
    this.dateRange,
  });

  bool get hasAnyFilter =>
      (plantCodes?.isNotEmpty ?? false) ||
      (locationCodes?.isNotEmpty ?? false) ||
      (status?.isNotEmpty ?? false) ||
      dateRange != null;

  bool get hasDateRange => dateRange != null;
  bool get hasPlantFilter => plantCodes?.isNotEmpty ?? false;
  bool get hasLocationFilter => locationCodes?.isNotEmpty ?? false;
  bool get hasStatusFilter => status?.isNotEmpty ?? false;

  int get filterCount {
    int count = 0;
    if (hasPlantFilter) count++;
    if (hasLocationFilter) count++;
    if (hasStatusFilter) count++;
    if (hasDateRange) count++;
    return count;
  }

  List<String> get activeFilterLabels {
    final labels = <String>[];
    if (hasPlantFilter) labels.add('Plants (${plantCodes!.length})');
    if (hasLocationFilter) labels.add('Locations (${locationCodes!.length})');
    if (hasStatusFilter) labels.add('Status (${status!.length})');
    if (hasDateRange) labels.add('Date Range');
    return labels;
  }

  ExportFiltersEntity copyWith({
    List<String>? plantCodes,
    List<String>? locationCodes,
    List<String>? status,
    DateRangeEntity? dateRange,
  }) {
    return ExportFiltersEntity(
      plantCodes: plantCodes ?? this.plantCodes,
      locationCodes: locationCodes ?? this.locationCodes,
      status: status ?? this.status,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  ExportFiltersEntity clearFilter(String filterType) {
    switch (filterType) {
      case 'plants':
        return copyWith(plantCodes: []);
      case 'locations':
        return copyWith(locationCodes: []);
      case 'status':
        return copyWith(status: []);
      case 'dateRange':
        return copyWith(dateRange: null);
      default:
        return this;
    }
  }

  ExportFiltersEntity clearAll() {
    return const ExportFiltersEntity();
  }

  @override
  List<Object?> get props => [plantCodes, locationCodes, status, dateRange];

  @override
  String toString() {
    return 'ExportFiltersEntity(filterCount: $filterCount)';
  }
}

class DateRangeEntity extends Equatable {
  final DateTime from;
  final DateTime to;

  const DateRangeEntity({required this.from, required this.to});

  bool get isValid => from.isBefore(to);
  Duration get duration => to.difference(from);
  int get daysDuration => duration.inDays;

  bool get isToday {
    final today = DateTime.now();
    return _isSameDay(from, today) && _isSameDay(to, today);
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return from.isAfter(weekStart) && to.isBefore(weekEnd);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    return from.isAfter(monthStart) && to.isBefore(monthEnd);
  }

  String get displayLabel {
    if (isToday) return 'Today';
    if (isThisWeek) return 'This Week';
    if (isThisMonth) return 'This Month';
    if (daysDuration <= 1) return 'Single Day';
    if (daysDuration <= 7) return '$daysDuration Days';
    if (daysDuration <= 30) return '${(daysDuration / 7).ceil()} Weeks';
    return '${(daysDuration / 30).ceil()} Months';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  List<Object?> get props => [from, to];

  @override
  String toString() {
    return 'DateRangeEntity(from: $from, to: $to, duration: $daysDuration days)';
  }
}
