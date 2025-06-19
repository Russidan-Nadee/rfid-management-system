// Path: frontend/lib/features/dashboard/domain/usecases/get_audit_progress_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/audit_progress.dart';
import '../repositories/dashboard_repository.dart';

class GetAuditProgressUseCase {
  final DashboardRepository repository;

  GetAuditProgressUseCase(this.repository);

  /// Execute the use case to get audit progress
  ///
  /// [params] contains filters and options for audit data retrieval
  /// Returns [AuditProgress] on success or [Failure] on error
  Future<Either<Failure, AuditProgress>> call(
    GetAuditProgressParams params,
  ) async {
    // Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(ValidationFailure([validation]));
    }

    return await repository.getAuditProgress(
      deptCode: params.deptCode,
      includeDetails: params.includeDetails,
      auditStatus: params.auditStatus,
    );
  }

  /// Validate parameters
  String? _validateParams(GetAuditProgressParams params) {
    // Validate department code if provided
    if (params.deptCode != null && !_isValidDeptCode(params.deptCode!)) {
      return 'Invalid department code format';
    }

    // Validate audit status if provided
    if (params.auditStatus != null &&
        !_isValidAuditStatus(params.auditStatus!)) {
      return 'Invalid audit status. Must be audited, never_audited, or overdue';
    }

    return null;
  }

  /// Validate department code format
  bool _isValidDeptCode(String deptCode) {
    final deptCodeRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    return deptCodeRegex.hasMatch(deptCode) && deptCode.length <= 10;
  }

  /// Validate audit status
  bool _isValidAuditStatus(String auditStatus) {
    const validStatuses = ['audited', 'never_audited', 'overdue'];
    return validStatuses.contains(auditStatus);
  }
}

class GetAuditProgressParams {
  final String? deptCode;
  final bool includeDetails;
  final String? auditStatus;

  const GetAuditProgressParams({
    this.deptCode,
    this.includeDetails = false,
    this.auditStatus,
  });

  /// Factory constructor for all departments overview
  factory GetAuditProgressParams.overview() {
    return const GetAuditProgressParams(includeDetails: false);
  }

  /// Factory constructor for specific department
  factory GetAuditProgressParams.department({
    required String deptCode,
    bool includeDetails = false,
  }) {
    return GetAuditProgressParams(
      deptCode: deptCode,
      includeDetails: includeDetails,
    );
  }

  /// Factory constructor for detailed audit data
  factory GetAuditProgressParams.detailed({
    String? deptCode,
    String? auditStatus,
  }) {
    return GetAuditProgressParams(
      deptCode: deptCode,
      includeDetails: true,
      auditStatus: auditStatus,
    );
  }

  /// Factory constructor for audited assets only
  factory GetAuditProgressParams.auditedOnly({String? deptCode}) {
    return GetAuditProgressParams(
      deptCode: deptCode,
      includeDetails: true,
      auditStatus: 'audited',
    );
  }

  /// Factory constructor for never audited assets
  factory GetAuditProgressParams.neverAudited({String? deptCode}) {
    return GetAuditProgressParams(
      deptCode: deptCode,
      includeDetails: true,
      auditStatus: 'never_audited',
    );
  }

  /// Factory constructor for overdue audits
  factory GetAuditProgressParams.overdue({String? deptCode}) {
    return GetAuditProgressParams(
      deptCode: deptCode,
      includeDetails: true,
      auditStatus: 'overdue',
    );
  }

  /// Check if filtering by specific department
  bool get isDepartmentFiltered => deptCode != null && deptCode!.isNotEmpty;

  /// Check if filtering by audit status
  bool get isStatusFiltered => auditStatus != null && auditStatus!.isNotEmpty;

  /// Check if requesting detailed data
  bool get requestsDetails => includeDetails;

  /// Check if has any active filters
  bool get hasActiveFilters =>
      isDepartmentFiltered || isStatusFiltered || includeDetails;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetAuditProgressParams &&
        other.deptCode == deptCode &&
        other.includeDetails == includeDetails &&
        other.auditStatus == auditStatus;
  }

  @override
  int get hashCode => Object.hash(deptCode, includeDetails, auditStatus);

  @override
  String toString() =>
      'GetAuditProgressParams('
      'deptCode: $deptCode, '
      'includeDetails: $includeDetails, '
      'auditStatus: $auditStatus)';
}
