// Path: frontend/lib/features/export/domain/entities/export_job_entity.dart
import 'package:equatable/equatable.dart';

class ExportJobEntity extends Equatable {
  final int exportId;
  final String exportType;
  final String status;
  final int? totalRecords;
  final int? fileSize;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? errorMessage;
  final String? downloadUrl;

  const ExportJobEntity({
    required this.exportId,
    required this.exportType,
    required this.status,
    this.totalRecords,
    this.fileSize,
    required this.createdAt,
    required this.expiresAt,
    this.errorMessage,
    this.downloadUrl,
  });

  // Business logic helpers
  bool get isCompleted => status.toUpperCase() == 'C';
  bool get isPending => status.toUpperCase() == 'P';
  bool get isFailed => status.toUpperCase() == 'F';
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canDownload => isCompleted && !isExpired && downloadUrl != null;

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'P':
        return 'Processing';
      case 'C':
        return 'Completed';
      case 'F':
        return 'Failed';
      default:
        return status;
    }
  }

  String get exportTypeLabel {
    switch (exportType) {
      case 'assets':
        return 'Assets Export';
      case 'scan_logs':
        return 'Scan Logs Export';
      case 'status_history':
        return 'Status History Export';
      default:
        return exportType;
    }
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '-';

    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024)
      return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  @override
  List<Object?> get props => [
    exportId,
    exportType,
    status,
    totalRecords,
    fileSize,
    createdAt,
    expiresAt,
    errorMessage,
    downloadUrl,
  ];

  @override
  String toString() {
    return 'ExportJobEntity(id: $exportId, type: $exportType, status: $status)';
  }
}
