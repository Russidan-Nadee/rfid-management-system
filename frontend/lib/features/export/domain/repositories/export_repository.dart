// Path: frontend/lib/features/export/domain/repositories/export_repository.dart
import '../entities/export_job_entity.dart';
import '../entities/export_config_entity.dart';

abstract class ExportRepository {
  /// Create new export job
  /// Returns the created job with tracking ID
  Future<ExportJobEntity> createExportJob({
    required String exportType,
    required ExportConfigEntity config,
  });

  /// Get export job status by ID
  /// Throws exception if job not found
  Future<ExportJobEntity> getExportJobStatus(int exportId);

  /// Download export file
  /// Returns file path in device storage
  Future<String> downloadExportFile(int exportId);

  /// Get user's export history
  /// Returns list of export jobs ordered by creation date (newest first)
  Future<List<ExportJobEntity>> getExportHistory({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// Cancel pending export job
  /// Returns true if successfully cancelled
  Future<bool> cancelExportJob(int exportId);

  /// Delete completed export job and file
  /// Returns true if successfully deleted
  Future<bool> deleteExportJob(int exportId);

  /// Get export statistics
  /// Returns summary of user's export usage
  Future<ExportStatsEntity> getExportStats();

  /// Clean up expired export files
  /// Returns number of files cleaned up
  Future<int> cleanupExpiredFiles();
}

class ExportStatsEntity {
  final int totalExports;
  final int pendingExports;
  final int completedExports;
  final int failedExports;
  final int totalFilesSize;
  final DateTime? lastExportDate;

  const ExportStatsEntity({
    required this.totalExports,
    required this.pendingExports,
    required this.completedExports,
    required this.failedExports,
    required this.totalFilesSize,
    this.lastExportDate,
  });

  bool get hasAnyExports => totalExports > 0;
  bool get hasPendingExports => pendingExports > 0;
  double get successRate =>
      totalExports > 0 ? completedExports / totalExports : 0.0;

  String get totalFilesSizeFormatted {
    if (totalFilesSize < 1024) return '${totalFilesSize}B';
    if (totalFilesSize < 1024 * 1024) {
      return '${(totalFilesSize / 1024).toStringAsFixed(1)}KB';
    }
    return '${(totalFilesSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get successRateFormatted {
    return '${(successRate * 100).toStringAsFixed(1)}%';
  }
}

/// Export operation result for better error handling
class ExportResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  const ExportResult._({required this.success, this.data, this.errorMessage});

  factory ExportResult.success(T data) {
    return ExportResult._(success: true, data: data);
  }

  factory ExportResult.failure({required String message}) {
    return ExportResult._(success: false, errorMessage: message);
  }

  bool get hasData => data != null;
}

/// Export job creation parameters
class CreateExportJobParams {
  final String exportType;
  final ExportConfigEntity config;

  const CreateExportJobParams({required this.exportType, required this.config});

  Map<String, dynamic> toMap() {
    return {'exportType': exportType, 'exportConfig': _configToMap()};
  }

  Map<String, dynamic> _configToMap() {
    final map = <String, dynamic>{'format': config.format};

    if (config.filters != null) {
      final filters = <String, dynamic>{};

      if (config.filters!.plantCodes?.isNotEmpty ?? false) {
        filters['plant_codes'] = config.filters!.plantCodes;
      }

      if (config.filters!.locationCodes?.isNotEmpty ?? false) {
        filters['location_codes'] = config.filters!.locationCodes;
      }

      if (config.filters!.status?.isNotEmpty ?? false) {
        filters['status'] = config.filters!.status;
      }

      if (config.filters!.dateRange != null) {
        filters['date_range'] = {
          'from': config.filters!.dateRange!.from.toIso8601String(),
          'to': config.filters!.dateRange!.to.toIso8601String(),
        };
      }

      if (filters.isNotEmpty) {
        map['filters'] = filters;
      }
    }

    if (config.columns?.isNotEmpty ?? false) {
      map['columns'] = config.columns;
    }

    return map;
  }

  @override
  String toString() {
    return 'CreateExportJobParams(type: $exportType, format: ${config.format})';
  }
}
