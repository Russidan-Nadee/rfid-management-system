// Path: frontend/lib/features/export/domain/usecases/get_export_status_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/export_repository.dart';
import '../entities/export_job_entity.dart';

class GetExportStatusUseCase {
  final ExportRepository repository;

  GetExportStatusUseCase(this.repository);

  Future<Either<Failure, ExportJobEntity>> execute(int exportId) async {
    // Input validation
    final validation = _validateInput(exportId);
    if (validation.isLeft) {
      return Left(validation.left!);
    }

    // Call repository
    final result = await repository.getExportJobStatus(exportId);

    // Convert Model to Entity
    return result.map((model) => _mapToEntity(model));
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
      expiresAt: model.expiresAt ?? DateTime.now().add(const Duration(hours: 24)),
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
}

/// Parameters for get export status use case
class GetExportStatusParams {
  final int exportId;

  const GetExportStatusParams({required this.exportId});

  @override
  String toString() => 'GetExportStatusParams(exportId: $exportId)';
}
