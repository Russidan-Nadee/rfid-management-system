// Path: frontend/lib/features/export/data/models/export_config_model.dart
import 'package:equatable/equatable.dart';

class ExportConfigModel extends Equatable {
  final String format;
  final ExportFiltersModel? filters;

  const ExportConfigModel({required this.format, this.filters});

  /// Convert to JSON for API request (ตรงกับ Backend)
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'format': format};

    if (filters != null) {
      final filtersJson = filters!.toJson();
      if (filtersJson.isNotEmpty) {
        json['filters'] = filtersJson;
      }
    }

    return json;
  }

  /// Create from JSON
  factory ExportConfigModel.fromJson(Map<String, dynamic> json) {
    return ExportConfigModel(
      format: json['format']?.toString() ?? 'xlsx',
      filters: json['filters'] != null
          ? ExportFiltersModel.fromJson(json['filters'])
          : null,
    );
  }

  /// Quick presets for common exports
  factory ExportConfigModel.allAssets({String format = 'xlsx'}) {
    return ExportConfigModel(
      format: format,
      filters: null, // No filters = export all
    );
  }

  factory ExportConfigModel.activeAssetsOnly({String format = 'xlsx'}) {
    return ExportConfigModel(
      format: format,
      filters: const ExportFiltersModel(
        status: ['A'], // Active only
      ),
    );
  }

  /// Business validation
  bool get isValidFormat => ['xlsx', 'csv'].contains(format.toLowerCase());
  bool get hasFilters => filters != null && filters!.hasAnyFilter;

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

  /// Copy with
  ExportConfigModel copyWith({String? format, ExportFiltersModel? filters}) {
    return ExportConfigModel(
      format: format ?? this.format,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [format, filters];

  @override
  String toString() =>
      'ExportConfigModel(format: $format, hasFilters: $hasFilters)';
}

class ExportFiltersModel extends Equatable {
  final List<String>? plantCodes;
  final List<String>? locationCodes;
  final List<String>? status;

  const ExportFiltersModel({this.plantCodes, this.locationCodes, this.status});

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

    // ไม่มี date_range แล้ว

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
    );
  }

  /// Business logic
  bool get hasAnyFilter =>
      (plantCodes?.isNotEmpty ?? false) ||
      (locationCodes?.isNotEmpty ?? false) ||
      (status?.isNotEmpty ?? false);

  bool get hasPlantFilter => plantCodes?.isNotEmpty ?? false;
  bool get hasLocationFilter => locationCodes?.isNotEmpty ?? false;
  bool get hasStatusFilter => status?.isNotEmpty ?? false;

  int get filterCount {
    int count = 0;
    if (hasPlantFilter) count++;
    if (hasLocationFilter) count++;
    if (hasStatusFilter) count++;
    return count;
  }

  List<String> get activeFilterLabels {
    final labels = <String>[];
    if (hasPlantFilter) labels.add('Plants (${plantCodes!.length})');
    if (hasLocationFilter) labels.add('Locations (${locationCodes!.length})');
    if (hasStatusFilter) labels.add('Status (${status!.length})');
    return labels;
  }

  /// Helper methods for UI
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

  ExportFiltersModel toggleStatus(String statusCode) {
    final newStatus = List<String>.from(status ?? []);
    if (newStatus.contains(statusCode)) {
      newStatus.remove(statusCode);
    } else {
      newStatus.add(statusCode);
    }
    return copyWith(status: newStatus.isEmpty ? null : newStatus);
  }

  ExportFiltersModel clearAll() {
    return const ExportFiltersModel();
  }

  /// Copy with
  ExportFiltersModel copyWith({
    List<String>? plantCodes,
    List<String>? locationCodes,
    List<String>? status,
  }) {
    return ExportFiltersModel(
      plantCodes: plantCodes ?? this.plantCodes,
      locationCodes: locationCodes ?? this.locationCodes,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [plantCodes, locationCodes, status];

  @override
  String toString() => 'ExportFiltersModel(filterCount: $filterCount)';
}

/// Export request model for API calls
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

  /// Quick presets
  factory ExportRequestModel.allAssets({String format = 'xlsx'}) {
    return ExportRequestModel(
      exportType: 'assets',
      exportConfig: ExportConfigModel.allAssets(format: format),
    );
  }

  factory ExportRequestModel.activeAssetsOnly({String format = 'xlsx'}) {
    return ExportRequestModel(
      exportType: 'assets',
      exportConfig: ExportConfigModel.activeAssetsOnly(format: format),
    );
  }

  @override
  String toString() =>
      'ExportRequestModel(type: $exportType, format: ${exportConfig.format})';
}
