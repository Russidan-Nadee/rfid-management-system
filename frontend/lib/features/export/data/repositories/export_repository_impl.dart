// Path: frontend/lib/features/export/data/repositories/export_repository_impl.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repositories/export_repository.dart';
import '../datasources/export_remote_datasource.dart';
import '../models/export_job_model.dart';
import '../models/export_config_model.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource remoteDataSource;

  ExportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ExportJobModel>> createExportJob({
    required String exportType,
    required ExportConfigModel config,
  }) async {
    try {
      // Business validation
      final validation = _validateExportRequest(exportType, config);
      if (validation.isLeft) {
        return Left(validation.left!);
      }

      // Create request model
      final request = ExportRequestModel(
        exportType: exportType,
        exportConfig: config,
      );

      // Call API
      final exportJob = await remoteDataSource.createExportJob(
        request: request,
      );

      return Right(exportJob);
    } on ExportException catch (e) {
      return Left(_mapExportException(e));
    } catch (e) {
      return Left(
        ServerFailure('Failed to create export job: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ExportJobModel>> getExportJobStatus(
    int exportId,
  ) async {
    try {
      // Input validation
      if (exportId <= 0) {
        return const Left(ValidationFailure(['Invalid export ID']));
      }

      final exportJob = await remoteDataSource.getExportJobStatus(exportId);
      return Right(exportJob);
    } on ExportException catch (e) {
      return Left(_mapExportException(e));
    } catch (e) {
      return Left(
        ServerFailure('Failed to get export status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> downloadExportFile(int exportId) async {
    try {
      // Input validation
      if (exportId <= 0) {
        return const Left(ValidationFailure(['Invalid export ID']));
      }

      // Check if export is ready before downloading
      final statusResult = await getExportJobStatus(exportId);
      if (statusResult.isLeft) {
        return Left(statusResult.left!);
      }

      final exportJob = statusResult.right!;
      if (!exportJob.canDownload) {
        return Left(_getDownloadFailure(exportJob));
      }

      // Download file
      await remoteDataSource.downloadExportFile(exportId);
      return const Right(unit);
    } on ExportException catch (e) {
      return Left(_mapExportException(e));
    } catch (e) {
      return Left(ServerFailure('Failed to download export: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ExportJobModel>>> getExportHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      // Input validation
      if (page < 1) {
        return const Left(ValidationFailure(['Page must be greater than 0']));
      }

      if (limit < 1 || limit > 100) {
        return const Left(
          ValidationFailure(['Limit must be between 1 and 100']),
        );
      }

      final exports = await remoteDataSource.getExportHistory(
        page: page,
        limit: limit,
        status: status,
      );

      // Filter only assets exports (extra safety)
      final assetsExports = exports
          .where((export) => export.exportType == 'assets')
          .toList();

      return Right(assetsExports);
    } on ExportException catch (e) {
      return Left(_mapExportException(e));
    } catch (e) {
      return Left(
        ServerFailure('Failed to get export history: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> cancelExportJob(int exportId) async {
    try {
      // Input validation
      if (exportId <= 0) {
        return const Left(ValidationFailure(['Invalid export ID']));
      }

      // Check if export can be cancelled
      final statusResult = await getExportJobStatus(exportId);
      if (statusResult.isLeft) {
        return Left(statusResult.left!);
      }

      final exportJob = statusResult.right!;
      if (!exportJob.isPending) {
        return Left(
          ValidationFailure([
            'Cannot cancel export with status: ${exportJob.statusLabel}',
          ]),
        );
      }

      final success = await remoteDataSource.cancelExportJob(exportId);
      return Right(success);
    } on ExportException catch (e) {
      return Left(_mapExportException(e));
    } catch (e) {
      return Left(
        ServerFailure('Failed to cancel export job: ${e.toString()}'),
      );
    }
  }

  // Helper methods

  /// Validate export request according to business rules
  Either<Failure, Unit> _validateExportRequest(
    String exportType,
    ExportConfigModel config,
  ) {
    final errors = <String>[];

    // Validate export type - only assets allowed
    if (exportType != 'assets') {
      errors.add('Only assets export is supported');
    }

    // Validate format
    if (!config.isValidFormat) {
      errors.add('Invalid format. Must be xlsx or csv');
    }

    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors));
    }

    return const Right(unit);
  }

  /// Get appropriate failure for download issues
  Failure _getDownloadFailure(ExportJobModel exportJob) {
    if (exportJob.isPending) {
      return const ValidationFailure([
        'Export is still processing. Please wait and try again.',
      ]);
    } else if (exportJob.isFailed) {
      return ValidationFailure([
        'Export failed: ${exportJob.errorMessage ?? 'Unknown error'}',
      ]);
    } else if (exportJob.isExpired) {
      return const ValidationFailure(['Export file has expired']);
    } else {
      return const ValidationFailure([
        'Export file is not available for download',
      ]);
    }
  }

  /// Map ExportException to Failure
  Failure _mapExportException(ExportException e) {
    switch (e.errorType) {
      case ExportErrorType.api:
        return ServerFailure(e.message);
      case ExportErrorType.network:
        return NetworkFailure(e.message);
      case ExportErrorType.timeout:
        return const TimeoutFailure();
      case ExportErrorType.authentication:
        return const UnauthorizedFailure();
      case ExportErrorType.permission:
        return const ForbiddenFailure();
      case ExportErrorType.validation:
        return ValidationFailure([e.message]);
      case ExportErrorType.notFound:
        return NotFoundFailure(e.message);
      case ExportErrorType.server:
        return const InternalServerFailure();
      case ExportErrorType.download:
        return ServerFailure('Download failed: ${e.message}');
      case ExportErrorType.fileSystem:
        return ServerFailure('File system error: ${e.message}');
      case ExportErrorType.platform:
        return ValidationFailure([e.message]);
      case ExportErrorType.unknown:
        return ServerFailure('Unknown error: ${e.message}');
    }
  }
}

/// Result wrapper for better error handling in UI
class ExportResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final String? errorCode;

  const ExportResult._({
    required this.success,
    this.data,
    this.errorMessage,
    this.errorCode,
  });

  factory ExportResult.success(T data) {
    return ExportResult._(success: true, data: data);
  }

  factory ExportResult.failure({required String message, String? code}) {
    return ExportResult._(
      success: false,
      errorMessage: message,
      errorCode: code,
    );
  }

  bool get hasData => data != null;
  bool get hasError => errorMessage != null;

  /// Convert Either to ExportResult for easier UI handling
  static ExportResult<T> fromEither<T>(Either<Failure, T> either) {
    return either.fold(
      (failure) =>
          ExportResult.failure(message: failure.message, code: failure.code),
      (data) => ExportResult.success(data),
    );
  }

  @override
  String toString() {
    return 'ExportResult(success: $success, hasData: $hasData, error: $errorMessage)';
  }
}

/// Extension for easier Either handling in Repository
extension EitherExtension<L, R> on Either<L, R> {
  /// Execute async operation and wrap in Either
  static Future<Either<Failure, T>> execute<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } on ExportException catch (e) {
      return Left(_mapExportException(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  static Failure _mapExportException(ExportException e) {
    // Same mapping logic as in repository
    switch (e.errorType) {
      case ExportErrorType.api:
        return ServerFailure(e.message);
      case ExportErrorType.network:
        return NetworkFailure(e.message);
      case ExportErrorType.timeout:
        return const TimeoutFailure();
      case ExportErrorType.authentication:
        return const UnauthorizedFailure();
      case ExportErrorType.permission:
        return const ForbiddenFailure();
      case ExportErrorType.validation:
        return ValidationFailure([e.message]);
      case ExportErrorType.notFound:
        return NotFoundFailure(e.message);
      case ExportErrorType.server:
        return const InternalServerFailure();
      case ExportErrorType.download:
        return ServerFailure('Download failed: ${e.message}');
      case ExportErrorType.fileSystem:
        return ServerFailure('File system error: ${e.message}');
      case ExportErrorType.platform:
        return ValidationFailure([e.message]);
      case ExportErrorType.unknown:
        return ServerFailure('Unknown error: ${e.message}');
    }
  }
}
