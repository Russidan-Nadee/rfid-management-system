// Path: frontend/lib/features/export/domain/usecases/cancel_export_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/export_repository.dart';
import '../entities/export_job_entity.dart';

class CancelExportUseCase {
  final ExportRepository repository;

  CancelExportUseCase(this.repository);

  Future<Either<Failure, bool>> execute(int exportId) async {
    // Input validation
    final validation = _validateInput(exportId);
    if (validation.isLeft) {
      return Left(validation.left!);
    }

    // Get export status first to validate cancellation eligibility
    final statusResult = await repository.getExportJobStatus(exportId);
    if (statusResult.isLeft) {
      return Left(statusResult.left!);
    }

    final exportJobModel = statusResult.right!;
    final exportJob = _mapToEntity(exportJobModel);

    // Business rule validation
    final businessValidation = _validateBusinessRules(exportJob);
    if (businessValidation.isLeft) {
      return Left(businessValidation.left!);
    }

    // Proceed with cancellation
    return await repository.cancelExportJob(exportId);
  }

  /// Convert ExportJobModel to ExportJobEntity
  ExportJobEntity _mapToEntity(dynamic model) {
    return ExportJobEntity(
      exportId: model.exportId,
      exportType: model.exportType,
      status: model.status,
      filename: model.filename,
      totalRecords: model.totalRecords,
      fileSize: model.fileSize,
      createdAt: model.createdAt ?? DateTime.now(),
      expiresAt: model.expiresAt ?? DateTime.now().add(Duration(hours: 24)),
      errorMessage: model.errorMessage,
      downloadUrl: model.downloadUrl,
    );
  }

  /// Validate input parameters
  Either<Failure, Unit> _validateInput(int exportId) {
    final errors = <String>[];

    if (exportId <= 0) {
      errors.add('Invalid export ID');
    }

    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors));
    }

    return const Right(unit);
  }

  /// Validate business rules for cancellation
  Either<Failure, Unit> _validateBusinessRules(ExportJobEntity exportJob) {
    final errors = <String>[];

    // Only pending jobs can be cancelled
    if (!exportJob.isPending) {
      if (exportJob.isCompleted) {
        errors.add('Cannot cancel completed export job');
      } else if (exportJob.isFailed) {
        errors.add('Cannot cancel failed export job');
      } else {
        errors.add('Export job cannot be cancelled');
      }
    }

    // Additional business rules can be added here
    // e.g., time limits, user permissions, etc.

    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors));
    }

    return const Right(unit);
  }
}

/// Parameters for cancel export use case
class CancelExportParams {
  final int exportId;

  const CancelExportParams({required this.exportId});

  @override
  String toString() => 'CancelExportParams(exportId: $exportId)';
}
