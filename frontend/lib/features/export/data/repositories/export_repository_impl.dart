// Path: frontend/lib/features/export/data/repositories/export_repository_impl.dart
import '../../domain/entities/export_job_entity.dart';
import '../../domain/entities/export_config_entity.dart';
import '../../domain/repositories/export_repository.dart' hide ExportErrorType;
import '../datasources/export_remote_datasource.dart';
import '../models/export_config_model.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource remoteDataSource;

  ExportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ExportJobEntity> createExportJob({
    required String exportType,
    required ExportConfigEntity config,
  }) async {
    try {
      // Convert entity to model for API call
      final configModel = ExportConfigModel.fromEntity(config);

      // Call remote data source
      final jobModel = await remoteDataSource.createExportJob(
        exportType: exportType,
        config: configModel,
      );

      // Return as entity (no conversion needed since model extends entity)
      return jobModel;
    } on ExportException catch (e) {
      throw _mapExportException(e);
    } catch (e) {
      throw ExportRepositoryException(
        'Failed to create export job: ${e.toString()}',
        ExportRepositoryErrorType.unknown,
      );
    }
  }

  @override
  Future<ExportJobEntity> getExportJobStatus(int exportId) async {
    try {
      final jobModel = await remoteDataSource.getExportJobStatus(exportId);
      return jobModel;
    } on ExportException catch (e) {
      throw _mapExportException(e);
    } catch (e) {
      throw ExportRepositoryException(
        'Failed to get export job status: ${e.toString()}',
        ExportRepositoryErrorType.unknown,
      );
    }
  }

  @override
  Future<String> downloadExportFile(int exportId) async {
    try {
      final filePath = await remoteDataSource.downloadExportFile(exportId);

      // Validate downloaded file exists
      if (!await _fileExists(filePath)) {
        throw ExportRepositoryException(
          'Downloaded file not found at: $filePath',
          ExportRepositoryErrorType.fileSystem,
        );
      }

      return filePath;
    } on ExportException catch (e) {
      throw _mapExportException(e);
    } catch (e) {
      throw ExportRepositoryException(
        'Failed to download export file: ${e.toString()}',
        ExportRepositoryErrorType.unknown,
      );
    }
  }

  @override
  Future<List<ExportJobEntity>> getExportHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      // Validate pagination parameters
      if (page < 1) {
        throw ExportRepositoryException(
          'Page number must be greater than 0',
          ExportRepositoryErrorType.validation,
        );
      }

      if (limit < 1 || limit > 100) {
        throw ExportRepositoryException(
          'Limit must be between 1 and 100',
          ExportRepositoryErrorType.validation,
        );
      }

      final jobModels = await remoteDataSource.getExportHistory(
        page: page,
        limit: limit,
        status: status,
      );

      // Convert models to entities (no conversion needed since model extends entity)
      return jobModels;
    } on ExportException catch (e) {
      throw _mapExportException(e);
    } catch (e) {
      throw ExportRepositoryException(
        'Failed to get export history: ${e.toString()}',
        ExportRepositoryErrorType.unknown,
      );
    }
  }

  @override
  Future<bool> cancelExportJob(int exportId) async {
    try {
      // Validate export ID
      if (exportId <= 0) {
        throw ExportRepositoryException(
          'Invalid export ID: $exportId',
          ExportRepositoryErrorType.validation,
        );
      }

      // Check if export can be cancelled (must be pending)
      final job = await getExportJobStatus(exportId);
      if (!job.isPending) {
        throw ExportRepositoryException(
          'Cannot cancel export with status: ${job.statusLabel}',
          ExportRepositoryErrorType.validation,
        );
      }

      return await remoteDataSource.cancelExportJob(exportId);
    } on ExportRepositoryException {
      rethrow;
    } on ExportException catch (e) {
      throw _mapExportException(e);
    } catch (e) {
      throw ExportRepositoryException(
        'Failed to cancel export job: ${e.toString()}',
        ExportRepositoryErrorType.unknown,
      );
    }
  }

  @override
  Future<bool> deleteExportJob(int exportId) async {
    try {
      // Validate export ID
      if (exportId <= 0) {
        throw ExportRepositoryException(
          'Invalid export ID: $exportId',
          ExportRepositoryErrorType.validation,
        );
      }

      // Check if export can be deleted (must be completed or failed)
      final job = await getExportJobStatus(exportId);
      if (job.isPending) {
        throw ExportRepositoryException(
          'Cannot delete pending export. Cancel it first.',
          ExportRepositoryErrorType.validation,
        );
      }

      return await remoteDataSource.deleteExportJob(exportId);
    } on ExportRepositoryException {
      rethrow;
    } on ExportException catch (e) {
      throw _mapExportException(e);
    } catch (e) {
      throw ExportRepositoryException(
        'Failed to delete export job: ${e.toString()}',
        ExportRepositoryErrorType.unknown,
      );
    }
  }

  @override
  Future<ExportStatsEntity> getExportStats() async {
    try {
      final statsModel = await remoteDataSource.getExportStats();

      // Convert model to entity
      return ExportStatsEntity(
        totalExports: statsModel.totalExports,
        pendingExports: statsModel.pendingExports,
        completedExports: statsModel.completedExports,
        failedExports: statsModel.failedExports,
        totalFilesSize: statsModel.totalFilesSize,
        lastExportDate: statsModel.lastExportDate,
      );
    } on ExportException catch (e) {
      throw _mapExportException(e);
    } catch (e) {
      throw ExportRepositoryException(
        'Failed to get export statistics: ${e.toString()}',
        ExportRepositoryErrorType.unknown,
      );
    }
  }

  @override
  Future<int> cleanupExpiredFiles() async {
    try {
      return await remoteDataSource.cleanupExpiredFiles();
    } on ExportException catch (e) {
      throw _mapExportException(e);
    } catch (e) {
      throw ExportRepositoryException(
        'Failed to cleanup expired files: ${e.toString()}',
        ExportRepositoryErrorType.unknown,
      );
    }
  }

  // Helper methods

  Future<bool> _fileExists(String filePath) async {
    try {
      // In real implementation, would use dart:io File
      // final file = File(filePath);
      // return await file.exists();
      return true; // Mock implementation
    } catch (e) {
      return false;
    }
  }

  ExportRepositoryException _mapExportException(ExportException e) {
    final repositoryErrorType = _mapErrorType(e.errorType);

    return ExportRepositoryException(
      e.message,
      repositoryErrorType,
      e.originalError,
    );
  }

  ExportRepositoryErrorType _mapErrorType(ExportErrorType errorType) {
    switch (errorType) {
      case ExportErrorType.api:
        return ExportRepositoryErrorType.api;
      case ExportErrorType.network:
        return ExportRepositoryErrorType.network;
      case ExportErrorType.timeout:
        return ExportRepositoryErrorType.timeout;
      case ExportErrorType.authentication:
        return ExportRepositoryErrorType.authentication;
      case ExportErrorType.permission:
        return ExportRepositoryErrorType.permission;
      case ExportErrorType.validation:
        return ExportRepositoryErrorType.validation;
      case ExportErrorType.notFound:
        return ExportRepositoryErrorType.notFound;
      case ExportErrorType.server:
        return ExportRepositoryErrorType.server;
      case ExportErrorType.download:
        return ExportRepositoryErrorType.download;
      case ExportErrorType.fileSystem:
        return ExportRepositoryErrorType.fileSystem;
      case ExportErrorType.unknown:
        return ExportRepositoryErrorType.unknown;
    }
  }
}

/// Repository-specific exception for better error handling
class ExportRepositoryException implements Exception {
  final String message;
  final ExportRepositoryErrorType errorType;
  final dynamic originalError;

  const ExportRepositoryException(
    this.message,
    this.errorType, [
    this.originalError,
  ]);

  bool get isNetworkError => errorType == ExportRepositoryErrorType.network;
  bool get isAuthenticationError =>
      errorType == ExportRepositoryErrorType.authentication;
  bool get isValidationError =>
      errorType == ExportRepositoryErrorType.validation;
  bool get isServerError => errorType == ExportRepositoryErrorType.server;
  bool get isFileSystemError =>
      errorType == ExportRepositoryErrorType.fileSystem;

  String get userFriendlyMessage {
    switch (errorType) {
      case ExportRepositoryErrorType.network:
        return 'Please check your internet connection and try again';
      case ExportRepositoryErrorType.timeout:
        return 'Request timed out. Please try again';
      case ExportRepositoryErrorType.authentication:
        return 'Please login again to continue';
      case ExportRepositoryErrorType.permission:
        return 'You don\'t have permission to perform this action';
      case ExportRepositoryErrorType.validation:
        return message; // Use original validation message
      case ExportRepositoryErrorType.notFound:
        return 'The requested export was not found';
      case ExportRepositoryErrorType.server:
        return 'Server error. Please try again later';
      case ExportRepositoryErrorType.download:
        return 'Failed to download file. Please try again';
      case ExportRepositoryErrorType.fileSystem:
        return 'File operation failed. Please check storage permissions';
      case ExportRepositoryErrorType.api:
      case ExportRepositoryErrorType.unknown:
        return 'An unexpected error occurred. Please try again';
    }
  }

  @override
  String toString() => 'ExportRepositoryException: $message';
}

enum ExportRepositoryErrorType {
  api,
  network,
  timeout,
  authentication,
  permission,
  validation,
  notFound,
  server,
  download,
  fileSystem,
  unknown,
}

/// Result wrapper for better error handling in use cases
class ExportRepositoryResult<T> {
  final bool success;
  final T? data;
  final ExportRepositoryException? error;

  const ExportRepositoryResult._({
    required this.success,
    this.data,
    this.error,
  });

  factory ExportRepositoryResult.success(T data) {
    return ExportRepositoryResult._(success: true, data: data);
  }

  factory ExportRepositoryResult.failure(ExportRepositoryException error) {
    return ExportRepositoryResult._(success: false, error: error);
  }

  bool get hasData => data != null;
  bool get hasError => error != null;

  /// Execute operation and wrap result
  static Future<ExportRepositoryResult<T>> execute<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return ExportRepositoryResult.success(result);
    } on ExportRepositoryException catch (e) {
      return ExportRepositoryResult.failure(e);
    } catch (e) {
      return ExportRepositoryResult.failure(
        ExportRepositoryException(
          'Unexpected error: ${e.toString()}',
          ExportRepositoryErrorType.unknown,
          e,
        ),
      );
    }
  }

  @override
  String toString() {
    return 'ExportRepositoryResult(success: $success, hasData: $hasData, hasError: $hasError)';
  }
}
