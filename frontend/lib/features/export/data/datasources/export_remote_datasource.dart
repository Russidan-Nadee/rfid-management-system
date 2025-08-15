import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/export_job_model.dart';
import '../models/export_config_model.dart';
import '../models/period_model.dart';

abstract class ExportRemoteDataSource {
  /// Create export job (Web only)
  Future<ExportJobModel> createExportJob({required ExportRequestModel request});

  /// Get export job status
  Future<ExportJobModel> getExportJobStatus(int exportId);

  /// Download export file (Web only)
  Future<void> downloadExportFile(int exportId);

  /// Get export history
  Future<List<ExportJobModel>> getExportHistory({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// Cancel export job
  Future<bool> cancelExportJob(int exportId);

  /// Get available date period options
  Future<DatePeriodsResponse> getDatePeriods();
}

class ExportRemoteDataSourceImpl implements ExportRemoteDataSource {
  final ApiService apiService;

  ExportRemoteDataSourceImpl(this.apiService);

  @override
  Future<ExportJobModel> createExportJob({
    required ExportRequestModel request,
  }) async {
    try {
      print('🔄 Creating export job: ${request.exportType}');
      print('📊 Config: ${request.exportConfig.toJson()}');

      final response = await apiService.post<Map<String, dynamic>>(
        ApiConstants.exportJobs,
        body: request.toJson(),
        fromJson: (json) => json,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        print('✅ Export job created successfully');
        return ExportJobModel.fromJson(response.data!);
      } else {
        throw _createApiException(
          'Failed to create export job',
          response.message,
        );
      }
    } catch (e) {
      print('❌ Create export job failed: $e');
      throw _handleException(e, 'create export job');
    }
  }

  @override
  Future<ExportJobModel> getExportJobStatus(int exportId) async {
    try {
      print('🔍 Getting export job status: $exportId');

      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.exportJobStatus(exportId),
        fromJson: (json) => json,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        return ExportJobModel.fromJson(response.data!);
      } else {
        throw _createApiException('Export job not found', response.message);
      }
    } catch (e) {
      throw _handleException(e, 'get export job status');
    }
  }

  @override
  Future<void> downloadExportFile(int exportId) async {
    try {
      print('📥 Starting download for export: $exportId');

      // First check if export is ready
      final exportJob = await getExportJobStatus(exportId);

      if (!exportJob.canDownload) {
        if (exportJob.isPending) {
          throw ExportException(
            'Export is still processing. Please wait and try again.',
            ExportErrorType.validation,
          );
        } else if (exportJob.isFailed) {
          throw ExportException(
            'Export failed: ${exportJob.errorMessage ?? 'Unknown error'}',
            ExportErrorType.validation,
          );
        } else if (exportJob.isExpired) {
          throw ExportException(
            'Export file has expired',
            ExportErrorType.validation,
          );
        } else {
          throw ExportException(
            'Export file is not available for download',
            ExportErrorType.validation,
          );
        }
      }

      // For web, use browser download via URL
      await _downloadFileForWeb(exportId, exportJob.filename);

      print('✅ Download initiated successfully');
    } catch (e) {
      print('❌ Download failed: $e');
      throw _handleException(e, 'download export file');
    }
  }

  @override
  Future<List<ExportJobModel>> getExportHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      print('📋 Getting export history: page=$page, limit=$limit');

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

      if (response.success && response.data != null) {
        // Handle both array and object responses
        List<dynamic> exportsList;

        if (response.data is List) {
          exportsList = response.data as List;
        } else if (response.data is Map && response.data['data'] is List) {
          exportsList = response.data['data'] as List;
        } else {
          exportsList = [];
        }

        final exports = exportsList
            .map(
              (item) => ExportJobModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        print('✅ Got ${exports.length} export records');
        return exports;
      } else {
        throw _createApiException(
          'Failed to get export history',
          response.message,
        );
      }
    } catch (e) {
      print('❌ Get export history failed: $e');
      throw _handleException(e, 'get export history');
    }
  }

  @override
  Future<bool> cancelExportJob(int exportId) async {
    try {
      print('🚫 Cancelling export job: $exportId');

      final response = await apiService.delete<Map<String, dynamic>>(
        ApiConstants.exportJobCancel(exportId),
        fromJson: (json) => json,
        requiresAuth: true,
      );

      final success = response.success;
      print(success ? '✅ Export job cancelled' : '❌ Cancel failed');
      return success;
    } catch (e) {
      print('❌ Cancel export job failed: $e');
      throw _handleException(e, 'cancel export job');
    }
  }

  @override
  Future<DatePeriodsResponse> getDatePeriods() async {
    try {
      print('📅 Fetching date period options');

      final response = await apiService.get<Map<String, dynamic>>(
        '${ApiConstants.exportBase}/date-periods',
        fromJson: (json) => json,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final datePeriodsData = response.data!['data'] as Map<String, dynamic>;
        final datePeriods = DatePeriodsResponse.fromJson(datePeriodsData);
        print('✅ Got ${datePeriods.periods.length} period options');
        return datePeriods;
      } else {
        throw _createApiException(
          'Failed to get date periods',
          response.message,
        );
      }
    } catch (e) {
      print('❌ Get date periods failed: $e');
      throw _handleException(e, 'get date periods');
    }
  }

  // Helper methods

  /// Download file for web using browser download
  Future<void> _downloadFileForWeb(int exportId, String? filename) async {
    try {
      // Get auth token for download
      final token = await apiService.getAuthToken();
      if (token == null) {
        throw ExportException(
          'Authentication required for download',
          ExportErrorType.authentication,
        );
      }

      // Build download URL
      final downloadUrl =
          '${ApiConstants.baseUrl}${ApiConstants.exportDownload(exportId)}';

      // Use web-specific download implementation
      await _triggerWebDownload(downloadUrl, token, filename);
    } catch (e) {
      throw ExportException(
        'Failed to initiate download: ${e.toString()}',
        ExportErrorType.download,
      );
    }
  }

  /// Trigger web download (implementation depends on web platform)
  Future<void> _triggerWebDownload(
    String url,
    String token,
    String? filename,
  ) async {
    // For web, we can use dart:html or url_launcher
    // This is a simplified implementation

    try {
      // Option 1: Create a hidden anchor element (most compatible)
      _createDownloadLink(url, token, filename);
    } catch (e) {
      // Fallback: Open in new tab/window
      print('⚠️ Direct download failed, opening in new tab');
      throw ExportException(
        'Please manually download from the opened tab',
        ExportErrorType.download,
      );
    }
  }

  /// Create download link for web
  void _createDownloadLink(String url, String token, String? filename) async {
    try {
      // Build URL with auth token
      final downloadUrl = '$url?access_token=$token';
      final uri = Uri.parse(downloadUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ Download initiated via url_launcher');
      } else {
        throw Exception('Could not launch download URL');
      }
    } catch (e) {
      print('❌ Download failed: $e');
      throw ExportException(
        'Failed to initiate download: ${e.toString()}',
        ExportErrorType.download,
      );
    }
  }

  /// Create API exception
  ExportException _createApiException(String message, String apiMessage) {
    return ExportException('$message: $apiMessage', ExportErrorType.api);
  }

  /// Handle exceptions
  Exception _handleException(dynamic error, String operation) {
    if (error is ExportException) {
      return error;
    }

    if (error is UnauthorizedException) {
      return ExportException(
        'Authentication required to $operation',
        ExportErrorType.authentication,
      );
    }

    if (error is ForbiddenException) {
      return ExportException(
        'Permission denied to $operation',
        ExportErrorType.permission,
      );
    }

    if (error is NotFoundException) {
      return ExportException(
        'Resource not found while trying to $operation',
        ExportErrorType.notFound,
      );
    }

    if (error is ValidationException) {
      final errorMessages = error.errors.join(', ');
      return ExportException(
        'Validation failed: $errorMessages',
        ExportErrorType.validation,
      );
    }

    if (error is NetworkException) {
      return ExportException(
        'Network error while trying to $operation',
        ExportErrorType.network,
      );
    }

    if (error is ConnectionTimeoutException) {
      return ExportException(
        'Request timed out while trying to $operation',
        ExportErrorType.timeout,
      );
    }

    if (error is ServerException) {
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
  platform, // ← เพิ่มใหม่สำหรับ platform restriction
  unknown,
}
