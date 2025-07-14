// Path: frontend/lib/features/export/domain/usecases/create_export_job_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/export_repository.dart';
import '../entities/export_job_entity.dart';
import '../../data/models/export_config_model.dart';

class CreateExportJobUseCase {
  final ExportRepository repository;

  CreateExportJobUseCase(this.repository);

  Future<Either<Failure, ExportJobEntity>> execute({
    required String exportType,
    required ExportConfigModel config,
  }) async {
    // Additional business validation (if needed)
    final validation = _validateInput(exportType, config);
    if (validation.isLeft) {
      return Left(validation.left!);
    }

    // Call repository
    final result = await repository.createExportJob(
      exportType: exportType,
      config: config,
    );

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
      expiresAt: model.expiresAt ?? DateTime.now().add(Duration(hours: 24)),
      errorMessage: model.errorMessage,
      downloadUrl: model.downloadUrl,
    );
  }

  /// Validate input parameters
  Either<Failure, Unit> _validateInput(
    String exportType,
    ExportConfigModel config,
  ) {
    final errors = <String>[];

    // Validate export type
    if (exportType.trim().isEmpty) {
      errors.add('Export type is required');
    }

    // Validate format
    if (!['xlsx', 'csv'].contains(config.format.toLowerCase())) {
      errors.add('Invalid export format');
    }

    // Additional domain-specific validation can go here

    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors));
    }

    return const Right(unit);
  }
}

/// Parameters for create export job use case
class CreateExportJobParams {
  final String exportType;
  final ExportConfigModel config;

  const CreateExportJobParams({required this.exportType, required this.config});

  @override
  String toString() =>
      'CreateExportJobParams(type: $exportType, format: ${config.format})';
}
