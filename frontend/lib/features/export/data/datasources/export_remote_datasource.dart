// Path: frontend/lib/features/export/data/datasources/export_remote_datasource.dart
import 'dart:io';
import 'package:frontend/core/services/storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../models/export_job_model.dart';
import '../models/export_config_model.dart';

abstract class ExportRemoteDataSource {
  Future<ExportJobModel> createExportJob({
    required String exportType,
    required ExportConfigModel config,
  });

  Future<ExportJobModel> getExportJobStatus(int exportId);

  Future<String> downloadExportFile(int exportId);

  Future<List<ExportJobModel>> getExportHistory({
    int page = 1,
    int limit = 20,
    String? status,
  });

  Future<bool> cancelExportJob(int exportId);

  Future<bool> deleteExportJob(int exportId);

  Future<ExportStatsModel> getExportStats();

  Future<int> cleanupExpiredFiles();
}

class ExportRemoteDataSourceImpl implements ExportRemoteDataSource {
  final ApiService apiService;

  ExportRemoteDataSourceImpl(this.apiService);

  @override
  Future<ExportJobModel> createExportJob({
    required String exportType,
    required ExportConfigModel config,
  }) async {
    try {
      final requestBody = ExportRequestModel(
        exportType: exportType,
        exportConfig: config,
      ).toJson();

      final response = await apiService.post<Map<String, dynamic>>(
        ApiConstants.exportJobs,
        body: requestBody,
        fromJson: (json) => json,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return ExportJobModel.fromJson(response.data!);
      } else {
        throw _createApiException(
          'Failed to create export job',
          response.message,
        );
      }
    } catch (e) {
      throw _handleException(e, 'create export job');
    }
  }

  @override
  Future<ExportJobModel> getExportJobStatus(int exportId) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.exportJobStatus(exportId),
        fromJson: (json) => json,
        requiresAuth: true,
      );

      print('🔍 Response success: ${response.success}');
      print('🔍 Response data type: ${response.data.runtimeType}');
      print('🔍 Response data: ${response.data}');

      if (response.success && response.data != null) {
        print('🔍 About to parse: ${response.data!['data']}');
        return ExportJobModel.fromJson(response.data!);
      } else {
        throw _createApiException('Export job not found', response.message);
      }
    } catch (e) {
      print('💥 Error in getExportJobStatus: $e');
      throw _handleException(e, 'get export job status');
    }
  }

  @override
  Future<String> downloadExportFile(int exportId) async {
    try {
      // First verify the export is ready
      print('🔍 Getting export job status...');
      final exportJob = await getExportJobStatus(exportId);
      print('✅ Export job status: ${exportJob.status}');

      if (!exportJob.isCompleted) {
        print('❌ Export not completed: ${exportJob.statusLabel}');
        throw ExportException(
          'Export is not completed yet. Current status: ${exportJob.statusLabel}',
          ExportErrorType.validation,
        );
      }

      if (exportJob.isExpired) {
        print('❌ Export expired');
        throw ExportException(
          'Export file has expired',
          ExportErrorType.validation,
        );
      }

      // Use HTTP client directly for file download with progress
      final downloadUrl =
          '${ApiConstants.baseUrl}${ApiConstants.exportDownload(exportId)}';
      print('🌐 Download URL: $downloadUrl');

      // Get auth token for download
      final token = await apiService.getAuthToken();
      if (token == null) {
        throw ExportException(
          'Authentication required for download',
          ExportErrorType.authentication,
        );
      }

      // Create temporary file path
      final tempDir = await _getTempDirectory();
      final fileName = _generateTempFileName(exportJob);
      final tempFilePath = path.join(tempDir, fileName);

      // Download file (simplified - in real implementation would use Dio for progress)
      final response = await apiService.downloadFile(
        downloadUrl,
        tempFilePath,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return tempFilePath;
      } else {
        throw ExportException(
          'Download failed with status: ${response.statusCode}',
          ExportErrorType.download,
        );
      }
    } catch (e) {
      throw _handleException(e, 'download export file');
    }
  }

  @override
  Future<List<ExportJobModel>> getExportHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    print('🔄 Starting getExportHistory request...');

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await apiService.get<dynamic>(
        ApiConstants.exportHistory,
        fromJson: (json) => json,
        queryParams: queryParams,
        requiresAuth: true,
      );

      print('📥 Raw response: ${response.toString()}');
      print('📊 Response success: ${response.success}');
      print('📋 Response data: ${response.data}');

      if (response.success && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final historyResponse = ExportHistoryResponse.fromJson(
            response.data!,
          );
          print('✅ Parsed ${historyResponse.exports.length} exports');
          return historyResponse.exports;
        } else if (response.data is List) {
          final exportsList = (response.data as List)
              .map(
                (item) => ExportJobModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          print('✅ Parsed ${exportsList.length} exports from list');
          print(
            '🎯 Returning exports list: ${exportsList.map((e) => e.exportId).toList()}',
          );
          return exportsList;
        } else {
          throw Exception(
            'Unexpected data format: ${response.data.runtimeType}',
          );
        }
      } else {
        print('❌ Response failed or no data');
        throw _createApiException(
          'Failed to get export history',
          response.message,
        );
      }
    } catch (e) {
      print('💥 Exception in getExportHistory: $e');
      print('💥 Exception type: ${e.runtimeType}');
      throw _handleException(e, 'get export history');
    }
  }

  @override
  Future<bool> cancelExportJob(int exportId) async {
    try {
      final response = await apiService.delete<Map<String, dynamic>>(
        ApiConstants.exportJobCancel(exportId),
        fromJson: (json) => json,
        requiresAuth: true,
      );

      return response.success;
    } catch (e) {
      throw _handleException(e, 'cancel export job');
    }
  }

  @override
  Future<bool> deleteExportJob(int exportId) async {
    try {
      final response = await apiService.delete<Map<String, dynamic>>(
        ApiConstants.exportJobDelete(exportId),
        fromJson: (json) => json,
        requiresAuth: true,
      );

      return response.success;
    } catch (e) {
      throw _handleException(e, 'delete export job');
    }
  }

  @override
  Future<ExportStatsModel> getExportStats() async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.exportStats,
        fromJson: (json) => json,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return ExportStatsModel.fromJson(response.data!['data']);
      } else {
        throw _createApiException(
          'Failed to get export statistics',
          response.message,
        );
      }
    } catch (e) {
      throw _handleException(e, 'get export statistics');
    }
  }

  @override
  Future<int> cleanupExpiredFiles() async {
    try {
      final response = await apiService.post<Map<String, dynamic>>(
        ApiConstants.exportCleanup,
        fromJson: (json) => json,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return response.data!['deleted_count']?.toInt() ?? 0;
      } else {
        throw _createApiException(
          'Failed to cleanup expired files',
          response.message,
        );
      }
    } catch (e) {
      throw _handleException(e, 'cleanup expired files');
    }
  }

  // Helper methods

  Future<String> _getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  String _generateTempFileName(ExportJobModel exportJob) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final format = exportJob.downloadUrl?.contains('.xlsx') == true
        ? 'xlsx'
        : 'csv';
    return 'export_${exportJob.exportId}_${timestamp}.$format';
  }

  ExportException _createApiException(String message, String apiMessage) {
    return ExportException('$message: $apiMessage', ExportErrorType.api);
  }

  Exception _handleException(dynamic error, String operation) {
    if (error is ExportException) {
      return error;
    }

    if (error.toString().contains('timeout')) {
      return ExportException(
        'Operation timed out while trying to $operation',
        ExportErrorType.timeout,
      );
    }

    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return ExportException(
        'Network error while trying to $operation',
        ExportErrorType.network,
      );
    }

    if (error.toString().contains('401') ||
        error.toString().contains('unauthorized')) {
      return ExportException(
        'Authentication required to $operation',
        ExportErrorType.authentication,
      );
    }

    if (error.toString().contains('403') ||
        error.toString().contains('forbidden')) {
      return ExportException(
        'Permission denied to $operation',
        ExportErrorType.permission,
      );
    }

    if (error.toString().contains('404') ||
        error.toString().contains('not found')) {
      return ExportException(
        'Resource not found while trying to $operation',
        ExportErrorType.notFound,
      );
    }

    if (error.toString().contains('500') ||
        error.toString().contains('server')) {
      return ExportException(
        'Server error while trying to $operation',
        ExportErrorType.server,
      );
    }

    return ExportException(
      'Unexpected error while trying to $operation: ${error.toString()}',
      ExportErrorType.unknown,
    );
  }
}

/// Export statistics model
class ExportStatsModel {
  final int totalExports;
  final int pendingExports;
  final int completedExports;
  final int failedExports;
  final int totalFilesSize;
  final DateTime? lastExportDate;

  const ExportStatsModel({
    required this.totalExports,
    required this.pendingExports,
    required this.completedExports,
    required this.failedExports,
    required this.totalFilesSize,
    this.lastExportDate,
  });

  factory ExportStatsModel.fromJson(Map<String, dynamic> json) {
    return ExportStatsModel(
      totalExports: json['total']?.toInt() ?? 0,
      pendingExports: json['pending']?.toInt() ?? 0,
      completedExports: json['completed']?.toInt() ?? 0,
      failedExports: json['failed']?.toInt() ?? 0,
      totalFilesSize: json['total_files_size']?.toInt() ?? 0,
      lastExportDate: json['last_export_date'] != null
          ? DateTime.tryParse(json['last_export_date'])
          : null,
    );
  }

  bool get hasAnyExports => totalExports > 0;
  bool get hasPendingExports => pendingExports > 0;
  double get successRate =>
      totalExports > 0 ? completedExports / totalExports : 0.0;

  @override
  String toString() {
    return 'ExportStatsModel(total: $totalExports, pending: $pendingExports)';
  }
}

/// Custom exception for export operations
class ExportException implements Exception {
  final String message;
  final ExportErrorType errorType;
  final dynamic originalError;

  const ExportException(this.message, this.errorType, [this.originalError]);

  @override
  String toString() => 'ExportException: $message';
}

enum ExportErrorType {
  api,
  network,
  timeout,
  authentication,
  permission,
  validation,
  notFound,
  server,
  download,
  fileSystem,
  unknown,
}

/// API Service extension for file downloads
extension ApiServiceExtension on ApiService {
  Future<HttpResponse> downloadFile(
    String url,
    String savePath, {
    Map<String, String>? headers,
  }) async {
    // Simplified implementation - in real app would use Dio or similar
    // for progress tracking and better error handling
    try {
      final uri = Uri.parse(url);
      final request = await HttpClient().getUrl(uri);

      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      final response = await request.close();

      if (response.statusCode == 200) {
        final file = File(savePath);
        await response.pipe(file.openWrite());
      }

      return HttpResponse(response.statusCode, response.reasonPhrase ?? '');
    } catch (e) {
      throw ExportException(
        'File download failed: $e',
        ExportErrorType.download,
        e,
      );
    }
  }

  Future<String?> getAuthToken() async {
    return await StorageService().getAuthToken();
  }
}

class HttpResponse {
  final int statusCode;
  final String reasonPhrase;

  HttpResponse(this.statusCode, this.reasonPhrase);
}
