// Path: frontend/lib/features/export/domain/repositories/export_repository.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../data/models/export_job_model.dart';
import '../../data/models/export_config_model.dart';

abstract class ExportRepository {
  /// Create new export job (Assets only)
  Future<Either<Failure, ExportJobModel>> createExportJob({
    required String exportType,
    required ExportConfigModel config,
  });

  /// Get export job status by ID
  Future<Either<Failure, ExportJobModel>> getExportJobStatus(int exportId);

  /// Download export file (Web only)
  Future<Either<Failure, Unit>> downloadExportFile(int exportId);

  /// Get user's export history
  Future<Either<Failure, List<ExportJobModel>>> getExportHistory({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// Cancel pending export job
  Future<Either<Failure, bool>> cancelExportJob(int exportId);
}

/// Export operation result for UI layer
class ExportOperationResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final String? errorCode;

  const ExportOperationResult._({
    required this.success,
    this.data,
    this.errorMessage,
    this.errorCode,
  });

  factory ExportOperationResult.success(T data) {
    return ExportOperationResult._(success: true, data: data);
  }

  factory ExportOperationResult.failure({
    required String message,
    String? code,
  }) {
    return ExportOperationResult._(
      success: false,
      errorMessage: message,
      errorCode: code,
    );
  }

  bool get hasData => data != null;
  bool get hasError => errorMessage != null;

  /// Convert Either to Result for easier UI handling
  static ExportOperationResult<T> fromEither<T>(Either<Failure, T> either) {
    return either.fold(
      (failure) => ExportOperationResult.failure(
        message: failure.message,
        code: failure.code,
      ),
      (data) => ExportOperationResult.success(data),
    );
  }

  @override
  String toString() {
    return 'ExportOperationResult(success: $success, hasData: $hasData)';
  }
}
