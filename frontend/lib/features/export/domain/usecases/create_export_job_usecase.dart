// Path: frontend/lib/features/export/domain/usecases/create_export_job_usecase.dart
import '../entities/export_job_entity.dart';
import '../entities/export_config_entity.dart';
import '../repositories/export_repository.dart';

class CreateExportJobUseCase {
  final ExportRepository repository;

  CreateExportJobUseCase(this.repository);

  Future<CreateExportJobResult> execute({
    required String exportType,
    required ExportConfigEntity config,
  }) async {
    try {
      // Business validation before API call
      final validation = _validateInput(exportType, config);
      if (!validation.isValid) {
        return CreateExportJobResult.failure(validation.errorMessage!);
      }

      // Apply business rules
      final processedConfig = _applyBusinessRules(exportType, config);

      // Create export job through repository
      final exportJob = await repository.createExportJob(
        exportType: exportType,
        config: processedConfig,
      );

      return CreateExportJobResult.success(
        exportJob: exportJob,
        message:
            'Export job created successfully. You will be notified when ready.',
      );
    } catch (e) {
      return CreateExportJobResult.failure(
        'Failed to create export job: ${e.toString()}',
      );
    }
  }

  /// Validate input parameters according to business rules
  ValidationResult _validateInput(
    String exportType,
    ExportConfigEntity config,
  ) {
    // Validate export type
    const validExportTypes = ['assets', 'scan_logs', 'status_history'];
    if (!validExportTypes.contains(exportType)) {
      return ValidationResult.invalid(
        'Invalid export type. Must be one of: ${validExportTypes.join(', ')}',
      );
    }

    // Validate format
    if (!config.isValidFormat) {
      return ValidationResult.invalid('Invalid format. Must be xlsx or csv');
    }

    // Validate date range if provided
    if (config.filters?.dateRange != null) {
      final dateRange = config.filters!.dateRange!;

      if (!dateRange.isValid) {
        return ValidationResult.invalid(
          'Invalid date range. End date must be after start date',
        );
      }

      // Business rule: Date range cannot exceed 1 year
      if (dateRange.daysDuration > 365) {
        return ValidationResult.invalid(
          'Date range cannot exceed 1 year. Please select a shorter period',
        );
      }

      // Business rule: Date range cannot be in the future
      if (dateRange.from.isAfter(DateTime.now())) {
        return ValidationResult.invalid('Start date cannot be in the future');
      }
    }

    // Validate scan_logs specific rules
    if (exportType == 'scan_logs') {
      if (config.filters?.dateRange == null) {
        return ValidationResult.invalid(
          'Date range is required for scan logs export',
        );
      }
    }

    // Validate status_history specific rules
    if (exportType == 'status_history') {
      if (config.filters?.dateRange == null) {
        return ValidationResult.invalid(
          'Date range is required for status history export',
        );
      }
    }

    return ValidationResult.valid();
  }

  /// Apply business rules and optimize configuration
  ExportConfigEntity _applyBusinessRules(
    String exportType,
    ExportConfigEntity config,
  ) {
    var processedConfig = config;

    // Apply default columns if not specified
    if (!config.hasCustomColumns) {
      processedConfig = processedConfig.copyWith(
        columns: _getDefaultColumns(exportType),
      );
    }

    // Apply default filters for specific export types
    if (exportType == 'assets' && config.filters?.status == null) {
      // Default to active assets only
      final updatedFilters = (config.filters ?? const ExportFiltersEntity())
          .copyWith(status: ['A']);
      processedConfig = processedConfig.copyWith(filters: updatedFilters);
    }

    // Optimize date range for scan_logs (limit to recent data if no range specified)
    if (exportType == 'scan_logs' && config.filters?.dateRange == null) {
      final defaultRange = DateRangeEntity(
        from: DateTime.now().subtract(const Duration(days: 30)),
        to: DateTime.now(),
      );
      final updatedFilters = (config.filters ?? const ExportFiltersEntity())
          .copyWith(dateRange: defaultRange);
      processedConfig = processedConfig.copyWith(filters: updatedFilters);
    }

    return processedConfig;
  }

  /// Get default columns for each export type
  List<String> _getDefaultColumns(String exportType) {
    switch (exportType) {
      case 'assets':
        return [
          'a.asset_no',
          'a.description',
          'a.serial_no',
          'a.inventory_no',
          'a.quantity',
          'a.status',
          'a.created_at',
          'p.description as plant_description',
          'l.description as location_description',
          'u.name as unit_name',
          'usr.full_name as created_by_name',
        ];

      case 'scan_logs':
        return [
          's.scan_id',
          's.asset_no',
          's.scanned_at',
          'a.description as asset_description',
          'u.full_name as scanned_by_name',
          'l.description as location_description',
        ];

      case 'status_history':
        return [
          'h.history_id',
          'h.asset_no',
          'h.old_status',
          'h.new_status',
          'h.changed_at',
          'h.remarks',
          'a.description as asset_description',
          'u.full_name as changed_by_name',
        ];

      default:
        return [];
    }
  }
}

class CreateExportJobResult {
  final bool success;
  final ExportJobEntity? exportJob;
  final String message;
  final String? errorMessage;

  const CreateExportJobResult._({
    required this.success,
    this.exportJob,
    required this.message,
    this.errorMessage,
  });

  factory CreateExportJobResult.success({
    required ExportJobEntity exportJob,
    required String message,
  }) {
    return CreateExportJobResult._(
      success: true,
      exportJob: exportJob,
      message: message,
    );
  }

  factory CreateExportJobResult.failure(String errorMessage) {
    return CreateExportJobResult._(
      success: false,
      message: 'Export job creation failed',
      errorMessage: errorMessage,
    );
  }

  bool get hasExportJob => exportJob != null;

  @override
  String toString() {
    return 'CreateExportJobResult(success: $success, message: $message)';
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() {
    return const ValidationResult._(isValid: true);
  }

  factory ValidationResult.invalid(String errorMessage) {
    return ValidationResult._(isValid: false, errorMessage: errorMessage);
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, error: $errorMessage)';
  }
}
