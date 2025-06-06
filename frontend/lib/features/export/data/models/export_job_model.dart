// Path: frontend/lib/features/export/data/models/export_job_model.dart
import '../../domain/entities/export_job_entity.dart';

class ExportJobModel extends ExportJobEntity {
  const ExportJobModel({
    required super.exportId,
    required super.exportType,
    required super.status,
    super.totalRecords,
    super.fileSize,
    required super.createdAt,
    required super.expiresAt,
    super.errorMessage,
    super.downloadUrl,
  });

  /// Create model from API JSON response
  factory ExportJobModel.fromJson(Map<String, dynamic> json) {
    return ExportJobModel(
      exportId: _parseId(json['export_id']),
      exportType: json['export_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'P',
      totalRecords: _parseOptionalInt(json['total_records']),
      fileSize: _parseOptionalInt(json['file_size']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      expiresAt:
          _parseDateTime(json['expires_at']) ??
          DateTime.now().add(const Duration(days: 7)),
      errorMessage: json['error_message']?.toString(),
      downloadUrl: json['download_url']?.toString(),
    );
  }

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'export_id': exportId,
      'export_type': exportType,
      'status': status,
      if (totalRecords != null) 'total_records': totalRecords,
      if (fileSize != null) 'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      if (errorMessage != null) 'error_message': errorMessage,
      if (downloadUrl != null) 'download_url': downloadUrl,
    };
  }

  /// Convert Entity to Model
  factory ExportJobModel.fromEntity(ExportJobEntity entity) {
    return ExportJobModel(
      exportId: entity.exportId,
      exportType: entity.exportType,
      status: entity.status,
      totalRecords: entity.totalRecords,
      fileSize: entity.fileSize,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
      errorMessage: entity.errorMessage,
      downloadUrl: entity.downloadUrl,
    );
  }

  /// Create model from API list response (for export history)
  factory ExportJobModel.fromListJson(Map<String, dynamic> json) {
    // Handle different API response formats
    if (json.containsKey('data')) {
      return ExportJobModel.fromJson(json['data']);
    }
    return ExportJobModel.fromJson(json);
  }

  /// Copy with new values (useful for updates)
  ExportJobModel copyWith({
    int? exportId,
    String? exportType,
    String? status,
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
      totalRecords: totalRecords ?? this.totalRecords,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  /// Create mock model for testing/development
  factory ExportJobModel.mock({
    int? exportId,
    String? exportType,
    String? status,
  }) {
    final now = DateTime.now();
    return ExportJobModel(
      exportId: exportId ?? 1,
      exportType: exportType ?? 'assets',
      status: status ?? 'C',
      totalRecords: 142,
      fileSize: 1024 * 256, // 256KB
      createdAt: now.subtract(const Duration(hours: 2)),
      expiresAt: now.add(const Duration(days: 7)),
      downloadUrl: '/api/v1/export/download/${exportId ?? 1}',
    );
  }

  /// Create list of mock models for testing
  static List<ExportJobModel> mockList() {
    return [
      ExportJobModel.mock(exportId: 1, exportType: 'assets', status: 'C'),
      ExportJobModel.mock(exportId: 2, exportType: 'scan_logs', status: 'P'),
      ExportJobModel.mock(
        exportId: 3,
        exportType: 'status_history',
        status: 'F',
      ).copyWith(
        errorMessage: 'Date range too large',
        fileSize: null,
        totalRecords: null,
      ),
    ];
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
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Try different date formats
        return _tryParseAlternativeDateFormats(value);
      }
    }
    return null;
  }

  static DateTime? _tryParseAlternativeDateFormats(String dateString) {
    // Common API date formats
    final formats = [
      // ISO format variations
      RegExp(r'(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.(\d{3})Z'),
      RegExp(r'(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z'),
      RegExp(r'(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})'),
      // MySQL datetime format
      RegExp(r'(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})'),
    ];

    for (final format in formats) {
      final match = format.firstMatch(dateString);
      if (match != null) {
        try {
          return DateTime.parse(dateString);
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'ExportJobModel(id: $exportId, type: $exportType, status: $status)';
  }
}

/// Model for create export job response
class CreateExportJobResponse {
  final ExportJobModel exportJob;
  final String message;
  final DateTime timestamp;

  const CreateExportJobResponse({
    required this.exportJob,
    required this.message,
    required this.timestamp,
  });

  factory CreateExportJobResponse.fromJson(Map<String, dynamic> json) {
    return CreateExportJobResponse(
      exportJob: ExportJobModel.fromJson(json['data'] ?? json),
      message: json['message']?.toString() ?? 'Export job created',
      timestamp:
          ExportJobModel._parseDateTime(json['timestamp']) ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CreateExportJobResponse(exportId: ${exportJob.exportId}, message: $message)';
  }
}

/// Model for export history response
class ExportHistoryResponse {
  final List<ExportJobModel> exports;
  final PaginationMeta? pagination;
  final String message;

  const ExportHistoryResponse({
    required this.exports,
    this.pagination,
    required this.message,
  });

  factory ExportHistoryResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final exports = dataList
        .map((item) => ExportJobModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ExportHistoryResponse(
      exports: exports,
      pagination: json['meta']?['pagination'] != null
          ? PaginationMeta.fromJson(json['meta']['pagination'])
          : null,
      message: json['message']?.toString() ?? 'Export history retrieved',
    );
  }

  bool get hasMore => pagination?.hasNextPage ?? false;
  int get totalCount => pagination?.totalItems ?? exports.length;

  @override
  String toString() {
    return 'ExportHistoryResponse(count: ${exports.length}, hasMore: $hasMore)';
  }
}

/// Pagination metadata model
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['currentPage']?.toInt() ?? 1,
      totalPages: json['totalPages']?.toInt() ?? 1,
      totalItems: json['totalItems']?.toInt() ?? 0,
      itemsPerPage: json['itemsPerPage']?.toInt() ?? 20,
      hasNextPage: json['hasNextPage'] == true,
      hasPrevPage: json['hasPrevPage'] == true,
    );
  }

  @override
  String toString() {
    return 'PaginationMeta(page: $currentPage/$totalPages, total: $totalItems)';
  }
}
