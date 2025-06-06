// Path: frontend/lib/features/export/data/models/export_config_model.dart
import '../../domain/entities/export_config_entity.dart';

class ExportConfigModel extends ExportConfigEntity {
  const ExportConfigModel({
    required super.format,
    super.filters,
    super.columns,
  });

  /// Create model from Entity
  factory ExportConfigModel.fromEntity(ExportConfigEntity entity) {
    return ExportConfigModel(
      format: entity.format,
      filters: entity.filters != null
          ? ExportFiltersModel.fromEntity(entity.filters!)
          : null,
      columns: entity.columns,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'format': format};

    if (filters != null) {
      final filtersJson = (filters as ExportFiltersModel).toJson();
      if (filtersJson.isNotEmpty) {
        json['filters'] = filtersJson;
      }
    }

    if (columns != null && columns!.isNotEmpty) {
      json['columns'] = columns;
    }

    return json;
  }

  /// Create from JSON (for local storage or API response)
  factory ExportConfigModel.fromJson(Map<String, dynamic> json) {
    return ExportConfigModel(
      format: json['format']?.toString() ?? 'xlsx',
      filters: json['filters'] != null
          ? ExportFiltersModel.fromJson(json['filters'])
          : null,
      columns: json['columns'] != null
          ? List<String>.from(json['columns'])
          : null,
    );
  }

  /// Create preset configurations for quick exports
  factory ExportConfigModel.allActiveAssets() {
    return ExportConfigModel(
      format: 'xlsx',
      filters: ExportFiltersModel.fromEntity(
        const ExportFiltersEntity(status: ['A']),
      ),
    );
  }

  factory ExportConfigModel.recentScans() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return ExportConfigModel(
      format: 'csv',
      filters: ExportFiltersModel.fromEntity(
        ExportFiltersEntity(
          dateRange: DateRangeEntity(from: sevenDaysAgo, to: DateTime.now()),
        ),
      ),
    );
  }

  factory ExportConfigModel.monthlyReport() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return ExportConfigModel(
      format: 'xlsx',
      filters: ExportFiltersModel.fromEntity(
        ExportFiltersEntity(
          status: ['A', 'C'], // Active and Checked
          dateRange: DateRangeEntity(from: firstDayOfMonth, to: lastDayOfMonth),
        ),
      ),
    );
  }

  /// Copy with new values
  ExportConfigModel copyWith({
    String? format,
    ExportFiltersModel? filters,
    List<String>? columns,
  }) {
    return ExportConfigModel(
      format: format ?? this.format,
      filters: filters ?? this.filters,
      columns: columns ?? this.columns,
    );
  }

  @override
  String toString() {
    return 'ExportConfigModel(format: $format, hasFilters: $hasFilters)';
  }
}

class ExportFiltersModel extends ExportFiltersEntity {
  const ExportFiltersModel({
    super.plantCodes,
    super.locationCodes,
    super.status,
    super.dateRange,
  });

  /// Create model from Entity
  factory ExportFiltersModel.fromEntity(ExportFiltersEntity entity) {
    return ExportFiltersModel(
      plantCodes: entity.plantCodes,
      locationCodes: entity.locationCodes,
      status: entity.status,
      dateRange: entity.dateRange != null
          ? DateRangeModel.fromEntity(entity.dateRange!)
          : null,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (plantCodes != null && plantCodes!.isNotEmpty) {
      json['plant_codes'] = plantCodes;
    }

    if (locationCodes != null && locationCodes!.isNotEmpty) {
      json['location_codes'] = locationCodes;
    }

    if (status != null && status!.isNotEmpty) {
      json['status'] = status;
    }

    if (dateRange != null) {
      json['date_range'] = (dateRange as DateRangeModel).toJson();
    }

    return json;
  }

  /// Create from JSON
  factory ExportFiltersModel.fromJson(Map<String, dynamic> json) {
    return ExportFiltersModel(
      plantCodes: json['plant_codes'] != null
          ? List<String>.from(json['plant_codes'])
          : null,
      locationCodes: json['location_codes'] != null
          ? List<String>.from(json['location_codes'])
          : null,
      status: json['status'] != null ? List<String>.from(json['status']) : null,
      dateRange: json['date_range'] != null
          ? DateRangeModel.fromJson(json['date_range'])
          : null,
    );
  }

  /// Add filter values
  ExportFiltersModel addPlantCode(String plantCode) {
    final newPlantCodes = List<String>.from(plantCodes ?? []);
    if (!newPlantCodes.contains(plantCode)) {
      newPlantCodes.add(plantCode);
    }
    return copyWith(plantCodes: newPlantCodes);
  }

  ExportFiltersModel removePlantCode(String plantCode) {
    final newPlantCodes = List<String>.from(plantCodes ?? []);
    newPlantCodes.remove(plantCode);
    return copyWith(plantCodes: newPlantCodes.isEmpty ? null : newPlantCodes);
  }

  ExportFiltersModel addLocationCode(String locationCode) {
    final newLocationCodes = List<String>.from(locationCodes ?? []);
    if (!newLocationCodes.contains(locationCode)) {
      newLocationCodes.add(locationCode);
    }
    return copyWith(locationCodes: newLocationCodes);
  }

  ExportFiltersModel removeLocationCode(String locationCode) {
    final newLocationCodes = List<String>.from(locationCodes ?? []);
    newLocationCodes.remove(locationCode);
    return copyWith(
      locationCodes: newLocationCodes.isEmpty ? null : newLocationCodes,
    );
  }

  ExportFiltersModel toggleStatus(String statusCode) {
    final newStatus = List<String>.from(status ?? []);
    if (newStatus.contains(statusCode)) {
      newStatus.remove(statusCode);
    } else {
      newStatus.add(statusCode);
    }
    return copyWith(status: newStatus.isEmpty ? null : newStatus);
  }

  ExportFiltersModel setDateRange(DateRangeEntity? dateRange) {
    return copyWith(
      dateRange: dateRange != null
          ? DateRangeModel.fromEntity(dateRange)
          : null,
    );
  }

  /// Copy with new values
  ExportFiltersModel copyWith({
    List<String>? plantCodes,
    List<String>? locationCodes,
    List<String>? status,
    DateRangeModel? dateRange,
  }) {
    return ExportFiltersModel(
      plantCodes: plantCodes ?? this.plantCodes,
      locationCodes: locationCodes ?? this.locationCodes,
      status: status ?? this.status,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  String toString() {
    return 'ExportFiltersModel(filterCount: $filterCount)';
  }
}

class DateRangeModel extends DateRangeEntity {
  const DateRangeModel({required super.from, required super.to});

  /// Create model from Entity
  factory DateRangeModel.fromEntity(DateRangeEntity entity) {
    return DateRangeModel(from: entity.from, to: entity.to);
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'from': from.toIso8601String(), 'to': to.toIso8601String()};
  }

  /// Create from JSON
  factory DateRangeModel.fromJson(Map<String, dynamic> json) {
    return DateRangeModel(
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
    );
  }

  /// Create common date ranges
  factory DateRangeModel.today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return DateRangeModel(from: startOfDay, to: endOfDay);
  }

  factory DateRangeModel.yesterday() {
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

    return DateRangeModel(from: startOfDay, to: endOfDay);
  }

  factory DateRangeModel.thisWeek() {
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

    return DateRangeModel(from: startOfWeek, to: endOfWeek);
  }

  factory DateRangeModel.lastWeek() {
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

    return DateRangeModel(from: startOfWeek, to: endOfWeek);
  }

  factory DateRangeModel.thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return DateRangeModel(from: startOfMonth, to: endOfMonth);
  }

  factory DateRangeModel.lastMonth() {
    final now = DateTime.now();
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

    return DateRangeModel(from: startOfLastMonth, to: endOfLastMonth);
  }

  factory DateRangeModel.last7Days() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return DateRangeModel(from: sevenDaysAgo, to: now);
  }

  factory DateRangeModel.last30Days() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return DateRangeModel(from: thirtyDaysAgo, to: now);
  }

  /// Get preset date range options for UI
  static List<DateRangeOption> getPresetOptions() {
    return [
      DateRangeOption('Today', DateRangeModel.today()),
      DateRangeOption('Yesterday', DateRangeModel.yesterday()),
      DateRangeOption('This Week', DateRangeModel.thisWeek()),
      DateRangeOption('Last Week', DateRangeModel.lastWeek()),
      DateRangeOption('This Month', DateRangeModel.thisMonth()),
      DateRangeOption('Last Month', DateRangeModel.lastMonth()),
      DateRangeOption('Last 7 Days', DateRangeModel.last7Days()),
      DateRangeOption('Last 30 Days', DateRangeModel.last30Days()),
    ];
  }

  @override
  String toString() {
    return 'DateRangeModel(from: $from, to: $to, duration: $daysDuration days)';
  }
}

/// Helper class for date range UI options
class DateRangeOption {
  final String label;
  final DateRangeModel dateRange;

  const DateRangeOption(this.label, this.dateRange);

  @override
  String toString() => label;
}

/// Export request model for API
class ExportRequestModel {
  final String exportType;
  final ExportConfigModel exportConfig;

  const ExportRequestModel({
    required this.exportType,
    required this.exportConfig,
  });

  Map<String, dynamic> toJson() {
    return {'exportType': exportType, 'exportConfig': exportConfig.toJson()};
  }

  /// Create requests for quick exports
  factory ExportRequestModel.allActiveAssets() {
    return ExportRequestModel(
      exportType: 'assets',
      exportConfig: ExportConfigModel.allActiveAssets(),
    );
  }

  factory ExportRequestModel.recentScans() {
    return ExportRequestModel(
      exportType: 'scan_logs',
      exportConfig: ExportConfigModel.recentScans(),
    );
  }

  factory ExportRequestModel.monthlyReport() {
    return ExportRequestModel(
      exportType: 'status_history',
      exportConfig: ExportConfigModel.monthlyReport(),
    );
  }

  @override
  String toString() {
    return 'ExportRequestModel(type: $exportType, format: ${exportConfig.format})';
  }
}
