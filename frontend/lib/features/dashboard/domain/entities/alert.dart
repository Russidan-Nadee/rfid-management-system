// Path: frontend/lib/features/dashboard/domain/entities/alert.dart
class Alert {
  final String id;
  final String type;
  final String message;
  final String severity;
  final int count;
  final DateTime createdAt;

  const Alert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.count,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alert &&
        other.id == id &&
        other.type == type &&
        other.message == message &&
        other.severity == severity &&
        other.count == count &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        message.hashCode ^
        severity.hashCode ^
        count.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Alert(id: $id, type: $type, message: $message, severity: $severity, count: $count, createdAt: $createdAt)';
  }

  // Helper getters for UI
  bool get isError => severity == 'error';
  bool get isWarning => severity == 'warning';
  bool get isInfo => severity == 'info';

  bool get isExportType => type == 'export';
  bool get isAssetType => type == 'asset';
  bool get isScanType => type == 'scan';
  bool get isDataQualityType => type == 'data_quality';
  bool get isSystemType => type == 'system';

  bool get hasCount => count > 0;
  bool get isHealthy => type == 'system' && severity == 'info';
}
