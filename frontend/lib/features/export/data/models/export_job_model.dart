// Path: frontend/lib/features/export/data/models/export_job_model.dart
import 'package:equatable/equatable.dart';

class ExportJobModel extends Equatable {
  final int exportId;
  final String exportType;
  final String status;
  final String? filename; // ← เพิ่มใหม่
  final int? totalRecords;
  final int? fileSize;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final String? errorMessage;
  final String? downloadUrl;

  const ExportJobModel({
    required this.exportId,
    required this.exportType,
    required this.status,
    this.filename, // ← เพิ่มใหม่
    this.totalRecords,
    this.fileSize,
    this.createdAt,
    this.expiresAt,
    this.errorMessage,
    this.downloadUrl,
  });

  /// Create from API JSON response
  factory ExportJobModel.fromJson(Map<String, dynamic> json) {
    return ExportJobModel(
      exportId: _parseId(json['export_id']),
      exportType: json['export_type']?.toString() ?? 'assets',
      status: json['status']?.toString() ?? 'P',
      filename: json['filename']?.toString(), // ← เพิ่มใหม่
      totalRecords: _parseOptionalInt(json['total_records']),
      fileSize: _parseOptionalInt(json['file_size']),
      createdAt: _parseDateTime(json['created_at']),
      expiresAt: _parseDateTime(json['expires_at']),
      errorMessage: json['error_message']?.toString(),
      downloadUrl: json['download_url']?.toString(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'export_id': exportId,
      'export_type': exportType,
      'status': status,
      if (filename != null) 'filename': filename, // ← เพิ่มใหม่
      if (totalRecords != null) 'total_records': totalRecords,
      if (fileSize != null) 'file_size': fileSize,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (expiresAt != null) 'expires_at': expiresAt?.toIso8601String(),
      if (errorMessage != null) 'error_message': errorMessage,
      if (downloadUrl != null) 'download_url': downloadUrl,
    };
  }

  /// Business logic helpers
  bool get isCompleted => status.toUpperCase() == 'C';
  bool get isPending => status.toUpperCase() == 'P';
  bool get isFailed => status.toUpperCase() == 'F';

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get canDownload => isCompleted && !isExpired && downloadUrl != null;

  /// UI Display helpers
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
      default:
        return exportType;
    }
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '-';

    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    }
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
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now());
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

  /// Copy with
  ExportJobModel copyWith({
    int? exportId,
    String? exportType,
    String? status,
    String? filename,
    int? totalRecords,
    int? fileSize,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? errorMessage,
    String? downloadUrl,
  }) {
    return ExportJobModel(
      exportId: exportId ?? this.exportId,
      exportType: exportType ?? this.exportType,
      status: status ?? this.status,
      filename: filename ?? this.filename,
      totalRecords: totalRecords ?? this.totalRecords,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  /// Create mock for testing
  factory ExportJobModel.mock({
    int? exportId,
    String? status,
    String? filename,
  }) {
    final now = DateTime.now();
    return ExportJobModel(
      exportId: exportId ?? 1,
      exportType: 'assets',
      status: status ?? 'C',
      filename: filename ?? 'assets_1_2025-07-14T10-30-00-000Z.xlsx',
      totalRecords: 142,
      fileSize: 1024 * 256, // 256KB
      createdAt: now.subtract(const Duration(hours: 2)),
      expiresAt: now.add(const Duration(days: 1)),
      downloadUrl: '/api/v1/export/download/1',
    );
  }

  // Utility parsing methods
  static int _parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
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
    return 'ExportJobModel(id: $exportId, type: $exportType, status: $status, filename: $filename)';
  }
}

/// Response wrapper for API calls
class ExportJobResponse {
  final ExportJobModel exportJob;
  final String message;
  final DateTime timestamp;

  const ExportJobResponse({
    required this.exportJob,
    required this.message,
    required this.timestamp,
  });

  factory ExportJobResponse.fromJson(Map<String, dynamic> json) {
    return ExportJobResponse(
      exportJob: ExportJobModel.fromJson(json['data'] ?? json),
      message: json['message']?.toString() ?? 'Success',
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

/// History response with simplified pagination
class ExportHistoryResponse {
  final List<ExportJobModel> exports;
  final String message;

  const ExportHistoryResponse({required this.exports, required this.message});

  factory ExportHistoryResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final exports = dataList
        .map((item) => ExportJobModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ExportHistoryResponse(
      exports: exports,
      message: json['message']?.toString() ?? 'Success',
    );
  }

  bool get hasExports => exports.isNotEmpty;
  int get totalCount => exports.length;

  @override
  String toString() {
    return 'ExportHistoryResponse(count: ${exports.length})';
  }
}
