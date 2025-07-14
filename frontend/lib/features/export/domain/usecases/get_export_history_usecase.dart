import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/export_repository.dart';
import '../entities/export_job_entity.dart';

class GetExportHistoryUseCase {
  final ExportRepository repository;

  GetExportHistoryUseCase(this.repository);

  Future<Either<Failure, List<ExportJobEntity>>> execute(
    GetExportHistoryParams params,
  ) async {
    // Input validation
    final validation = _validateInput(params);
    if (validation.isLeft) {
      return Left(validation.left!);
    }

    // Call repository
    final result = await repository.getExportHistory(
      page: params.page,
      limit: params.limit,
      status: params.status,
    );

    // Convert Models to Entities
    return result.map((models) => models.map((model) => _mapToEntity(model)).toList());
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
  Either<Failure, Unit> _validateInput(GetExportHistoryParams params) {
    final errors = <String>[];

    // Validate page
    if (params.page < 1) {
      errors.add('Page must be greater than 0');
    }

    // Validate limit
    if (params.limit < 1) {
      errors.add('Limit must be greater than 0');
    }

    if (params.limit > 100) {
      errors.add('Limit must not exceed 100');
    }

    // Validate status
    if (params.status != null) {
      final validStatuses = ['P', 'C', 'F'];
      if (!validStatuses.contains(params.status)) {
        errors.add('Invalid status. Must be P, C, or F');
      }
    }

    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors));
    }

    return const Right(unit);
  }
}

/// Parameters for get export history use case
class GetExportHistoryParams {
  final int page;
  final int limit;
  final String? status;

  const GetExportHistoryParams({
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  String toString() {
    return 'GetExportHistoryParams(page: $page, limit: $limit, status: $status)';
  }
}