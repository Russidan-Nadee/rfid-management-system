// Path: frontend/lib/features/export/domain/usecases/download_export_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/export_repository.dart';
import '../entities/export_job_entity.dart';

class DownloadExportUseCase {
  final ExportRepository repository;

  DownloadExportUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(int exportId) async {
    // Input validation
    final validation = _validateInput(exportId);
    if (validation.isLeft) {
      return Left(validation.left!);
    }

    // Get export status first to validate download eligibility
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

    // Proceed with download
    return await repository.downloadExportFile(exportId);
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

  /// Validate business rules for download
  Either<Failure, Unit> _validateBusinessRules(ExportJobEntity exportJob) {
    final errors = <String>[];

    // Check if export is completed
    if (!exportJob.isCompleted) {
      if (exportJob.isPending) {
        errors.add('Export is still processing. Please wait and try again.');
      } else if (exportJob.isFailed) {
        errors.add(
          'Export failed: ${exportJob.errorMessage ?? 'Unknown error'}',
        );
      } else {
        errors.add('Export is not ready for download');
      }
    }

    // Check if export is expired
    if (exportJob.isExpired) {
      errors.add('Export file has expired');
    }

    // Check if download URL exists
    if (!exportJob.canDownload) {
      errors.add('Export file is not available for download');
    }

    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors));
    }

    return const Right(unit);
  }
}

/// Parameters for download export use case
class DownloadExportParams {
  final int exportId;

  const DownloadExportParams({required this.exportId});

  @override
  String toString() => 'DownloadExportParams(exportId: $exportId)';
}
