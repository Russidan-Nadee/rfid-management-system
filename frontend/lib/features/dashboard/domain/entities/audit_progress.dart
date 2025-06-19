// Path: frontend/lib/features/dashboard/domain/entities/audit_progress.dart
import 'package:equatable/equatable.dart';

class AuditProgress extends Equatable {
  final List<DepartmentProgress> auditProgress;
  final OverallProgress? overallProgress;
  final List<Recommendation> recommendations;
  final AuditInfo auditInfo;

  const AuditProgress({
    required this.auditProgress,
    this.overallProgress,
    required this.recommendations,
    required this.auditInfo,
  });

  // Helper methods
  bool get hasOverallProgress => overallProgress != null;
  bool get hasRecommendations => recommendations.isNotEmpty;
  bool get hasMultipleDepartments => auditProgress.length > 1;

  List<DepartmentProgress> get completedDepartments =>
      auditProgress.where((dept) => dept.isCompleted).toList();

  List<DepartmentProgress> get incompleteDepartments =>
      auditProgress.where((dept) => !dept.isCompleted).toList();

  List<DepartmentProgress> get criticalDepartments =>
      auditProgress.where((dept) => dept.isCritical).toList();

  List<Recommendation> get criticalRecommendations =>
      recommendations.where((rec) => rec.isCritical).toList();

  List<Recommendation> get warningRecommendations =>
      recommendations.where((rec) => rec.isWarning).toList();

  double get averageCompletionPercentage => auditProgress.isNotEmpty
      ? auditProgress
                .map((dept) => dept.completionPercentage)
                .reduce((a, b) => a + b) /
            auditProgress.length
      : 0.0;

  @override
  List<Object?> get props => [
    auditProgress,
    overallProgress,
    recommendations,
    auditInfo,
  ];
}

class DepartmentProgress extends Equatable {
  final String deptCode;
  final String deptDescription;
  final int totalAssets;
  final int auditedAssets;
  final int pendingAudit;
  final double completionPercentage;

  const DepartmentProgress({
    required this.deptCode,
    required this.deptDescription,
    required this.totalAssets,
    required this.auditedAssets,
    required this.pendingAudit,
    required this.completionPercentage,
  });

  // Helper methods
  bool get hasAssets => totalAssets > 0;
  bool get isCompleted => completionPercentage >= 100.0;
  bool get isNearlyCompleted => completionPercentage >= 90.0;
  bool get isCritical => completionPercentage < 30.0 && totalAssets > 0;
  bool get needsAttention => completionPercentage < 50.0 && totalAssets > 0;

  String get displayName =>
      deptDescription.isNotEmpty ? deptDescription : deptCode;
  String get formattedCompletionPercentage =>
      '${completionPercentage.toStringAsFixed(1)}%';

  String get statusLevel {
    if (isCompleted) return 'completed';
    if (isNearlyCompleted) return 'near_completion';
    if (isCritical) return 'critical';
    if (needsAttention) return 'needs_attention';
    return 'in_progress';
  }

  @override
  List<Object> get props => [
    deptCode,
    deptDescription,
    totalAssets,
    auditedAssets,
    pendingAudit,
    completionPercentage,
  ];
}

class OverallProgress extends Equatable {
  final int totalAssets;
  final int auditedAssets;
  final int pendingAudit;
  final double completionPercentage;

  const OverallProgress({
    required this.totalAssets,
    required this.auditedAssets,
    required this.pendingAudit,
    required this.completionPercentage,
  });

  // Helper methods
  bool get hasAssets => totalAssets > 0;
  bool get isCompleted => completionPercentage >= 100.0;
  bool get isNearlyCompleted => completionPercentage >= 90.0;
  bool get isCritical => completionPercentage < 30.0;
  bool get needsAttention => completionPercentage < 50.0;

  String get formattedCompletionPercentage =>
      '${completionPercentage.toStringAsFixed(1)}%';
  double get pendingPercentage =>
      totalAssets > 0 ? (pendingAudit / totalAssets) * 100 : 0;

  String get statusLevel {
    if (isCompleted) return 'completed';
    if (isNearlyCompleted) return 'near_completion';
    if (isCritical) return 'critical';
    if (needsAttention) return 'needs_attention';
    return 'in_progress';
  }

  @override
  List<Object> get props => [
    totalAssets,
    auditedAssets,
    pendingAudit,
    completionPercentage,
  ];
}

class Recommendation extends Equatable {
  final String type;
  final String message;
  final String action;
  final String? deptCode;

  const Recommendation({
    required this.type,
    required this.message,
    required this.action,
    this.deptCode,
  });

  // Helper methods
  bool get isCritical => type == 'critical';
  bool get isWarning => type == 'warning';
  bool get isSuccess => type == 'success';
  bool get isDepartmentSpecific => deptCode != null && deptCode!.isNotEmpty;
  bool get isSystemWide => !isDepartmentSpecific;

  String get priority {
    switch (type) {
      case 'critical':
        return 'high';
      case 'warning':
        return 'medium';
      case 'success':
        return 'low';
      default:
        return 'medium';
    }
  }

  @override
  List<Object?> get props => [type, message, action, deptCode];
}

class AuditInfo extends Equatable {
  final String auditPeriod;
  final String generatedAt;
  final AuditFilters filtersApplied;

  const AuditInfo({
    required this.auditPeriod,
    required this.generatedAt,
    required this.filtersApplied,
  });

  // Helper methods
  DateTime get generatedDateTime => DateTime.parse(generatedAt);
  bool get hasActiveFilters => filtersApplied.hasActiveFilters;
  bool get isRecent => DateTime.now().difference(generatedDateTime).inHours < 1;

  @override
  List<Object> get props => [auditPeriod, generatedAt, filtersApplied];
}

class AuditFilters extends Equatable {
  final String? deptCode;
  final String? auditStatus;
  final bool includeDetails;

  const AuditFilters({
    this.deptCode,
    this.auditStatus,
    required this.includeDetails,
  });

  // Helper methods
  bool get hasActiveFilters =>
      (deptCode != null && deptCode!.isNotEmpty) ||
      (auditStatus != null && auditStatus!.isNotEmpty) ||
      includeDetails;

  bool get isDepartmentFiltered => deptCode != null && deptCode!.isNotEmpty;
  bool get isStatusFiltered => auditStatus != null && auditStatus!.isNotEmpty;

  @override
  List<Object?> get props => [deptCode, auditStatus, includeDetails];
}
