// Path: frontend/lib/features/dashboard/data/models/audit_progress_model.dart
class AuditProgressModel {
  final List<DepartmentProgressModel> auditProgress;
  final OverallProgressModel? overallProgress;
  final List<RecommendationModel> recommendations;
  final AuditInfoModel auditInfo;

  const AuditProgressModel({
    required this.auditProgress,
    this.overallProgress,
    required this.recommendations,
    required this.auditInfo,
  });

  factory AuditProgressModel.fromJson(Map<String, dynamic> json) {
    return AuditProgressModel(
      auditProgress:
          (json['audit_progress'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DepartmentProgressModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      overallProgress: json['overall_progress'] != null
          ? OverallProgressModel.fromJson(json['overall_progress'])
          : null,
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map(
                (e) => RecommendationModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      auditInfo: AuditInfoModel.fromJson(json['audit_info'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audit_progress': auditProgress.map((e) => e.toJson()).toList(),
      'overall_progress': overallProgress?.toJson(),
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
      'audit_info': auditInfo.toJson(),
    };
  }
}

class DepartmentProgressModel {
  final String deptCode;
  final String deptDescription;
  final int totalAssets;
  final int auditedAssets;
  final int pendingAudit;
  final double completionPercentage;

  const DepartmentProgressModel({
    required this.deptCode,
    required this.deptDescription,
    required this.totalAssets,
    required this.auditedAssets,
    required this.pendingAudit,
    required this.completionPercentage,
  });

  factory DepartmentProgressModel.fromJson(Map<String, dynamic> json) {
    return DepartmentProgressModel(
      deptCode: json['dept_code'] ?? '',
      deptDescription: json['dept_description'] ?? '',
      totalAssets: json['total_assets'] ?? 0,
      auditedAssets: json['audited_assets'] ?? 0,
      pendingAudit: json['pending_audit'] ?? 0,
      completionPercentage:
          double.tryParse(json['completion_percentage']?.toString() ?? '0') ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dept_code': deptCode,
      'dept_description': deptDescription,
      'total_assets': totalAssets,
      'audited_assets': auditedAssets,
      'pending_audit': pendingAudit,
      'completion_percentage': completionPercentage,
    };
  }
}

class OverallProgressModel {
  final int totalAssets;
  final int auditedAssets;
  final int pendingAudit;
  final double completionPercentage;

  const OverallProgressModel({
    required this.totalAssets,
    required this.auditedAssets,
    required this.pendingAudit,
    required this.completionPercentage,
  });

  factory OverallProgressModel.fromJson(Map<String, dynamic> json) {
    return OverallProgressModel(
      totalAssets: json['total_assets'] ?? 0,
      auditedAssets: json['audited_assets'] ?? 0,
      pendingAudit: json['pending_audit'] ?? 0,
      completionPercentage: (json['completion_percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_assets': totalAssets,
      'audited_assets': auditedAssets,
      'pending_audit': pendingAudit,
      'completion_percentage': completionPercentage,
    };
  }
}

class RecommendationModel {
  final String type;
  final String message;
  final String action;
  final String? deptCode;

  const RecommendationModel({
    required this.type,
    required this.message,
    required this.action,
    this.deptCode,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      action: json['action'] ?? '',
      deptCode: json['dept_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'action': action,
      'dept_code': deptCode,
    };
  }
}

class AuditInfoModel {
  final String auditPeriod;
  final String generatedAt;
  final AuditFiltersModel filtersApplied;

  const AuditInfoModel({
    required this.auditPeriod,
    required this.generatedAt,
    required this.filtersApplied,
  });

  factory AuditInfoModel.fromJson(Map<String, dynamic> json) {
    return AuditInfoModel(
      auditPeriod: json['audit_period'] ?? '',
      generatedAt: json['generated_at'] ?? '',
      filtersApplied: AuditFiltersModel.fromJson(json['filters_applied'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audit_period': auditPeriod,
      'generated_at': generatedAt,
      'filters_applied': filtersApplied.toJson(),
    };
  }
}

class AuditFiltersModel {
  final String? deptCode;
  final String? auditStatus;
  final bool includeDetails;

  const AuditFiltersModel({
    this.deptCode,
    this.auditStatus,
    required this.includeDetails,
  });

  factory AuditFiltersModel.fromJson(Map<String, dynamic> json) {
    return AuditFiltersModel(
      deptCode: json['dept_code'],
      auditStatus: json['audit_status'],
      includeDetails: json['include_details'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dept_code': deptCode,
      'audit_status': auditStatus,
      'include_details': includeDetails,
    };
  }
}
