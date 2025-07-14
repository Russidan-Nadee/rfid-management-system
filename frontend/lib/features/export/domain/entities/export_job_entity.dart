// Path: frontend/lib/features/export/domain/entities/export_job_entity.dart
import 'package:equatable/equatable.dart';

class ExportJobEntity extends Equatable {
  final int exportId;
  final String exportType;
  final String status;
  final String? filename;
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
    this.filename,
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

  /// Display filename with fallback
  String get displayFilename {
    if (filename != null && filename!.isNotEmpty) {
      return filename!;
    }
    return 'Export #$exportId';
  }

  /// Get file extension from filename
  String? get fileExtension {
    if (filename == null) return null;
    final parts = filename!.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : null;
  }

  /// Time helpers
  Duration? get timeUntilExpiry {
    return expiresAt.difference(DateTime.now());
  }

  String? get timeUntilExpiryFormatted {
    final duration = timeUntilExpiry;
    if (duration == null) return null;

    if (duration.isNegative) return 'Expired';

    if (duration.inDays > 0) {
      return '${duration.inDays}d left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h left';
    } else {
      return '${duration.inMinutes}m left';
    }
  }

  @override
  List<Object?> get props => [
    exportId,
    exportType,
    status,
    filename,
    totalRecords,
    fileSize,
    createdAt,
    expiresAt,
    errorMessage,
    downloadUrl,
  ];

  @override
  String toString() {
    return 'ExportJobEntity(id: $exportId, type: $exportType, status: $status, filename: $filename)';
  }
}
