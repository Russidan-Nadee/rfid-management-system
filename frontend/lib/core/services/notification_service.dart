import '../models/api_response.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  /// Submit a problem report for an asset
  Future<ApiResponse<Map<String, dynamic>>> reportProblem({
    String? assetNo,
    required String problemType,
    required String priority,
    required String subject,
    required String description,
  }) async {
    try {
      final body = {
        'problem_type': problemType,
        'priority': priority,
        'subject': subject,
        'description': description,
      };

      if (assetNo != null && assetNo.isNotEmpty) {
        body['asset_no'] = assetNo;
      }

      print('🔍 Frontend: Submitting problem report...');
      print('🔍 Frontend: Base URL: ${ApiConstants.baseUrl}');
      print('🔍 Frontend: Endpoint: ${ApiConstants.reportProblem}');
      print('🔍 Frontend: Full URL: ${ApiConstants.baseUrl}${ApiConstants.reportProblem}');
      print('🔍 Frontend: Body: $body');
      
      // Debug: Check what user token/info we're sending
      try {
        final token = await _apiService.getAuthToken();
        print('🔍 Frontend: Auth token present: ${token != null ? "YES" : "NO"}');
        if (token != null) {
          print('🔍 Frontend: Token preview: ${token.substring(0, 20)}...');
        }
      } catch (e) {
        print('🔍 Frontend: Could not get auth token: $e');
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.reportProblem,
        body: body,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print('🔍 Frontend: Response: ${response.success ? 'SUCCESS' : 'FAILED'}');
      print('🔍 Frontend: Message: ${response.message}');

      return response;
    } catch (error) {
      print('💥 Frontend: Exception: $error');
      return ErrorResponse<Map<String, dynamic>>(
        message: 'Failed to submit problem report: $error',
      );
    }
  }

  /// Get notification counts (admin/manager only)
  Future<ApiResponse<Map<String, dynamic>>> getNotificationCounts() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.notificationCounts,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (error) {
      return ErrorResponse<Map<String, dynamic>>(
        message: 'Failed to get notification counts: $error',
      );
    }
  }

  /// Get all notifications (admin/manager only)
  Future<ApiResponse<Map<String, dynamic>>> getNotifications({
    String? status,
    String? priority,
    String? problemType,
    String? assetNo,
    int page = 1,
    int limit = 20,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (priority != null && priority.isNotEmpty) {
        queryParams['priority'] = priority;
      }
      if (problemType != null && problemType.isNotEmpty) {
        queryParams['problem_type'] = problemType;
      }
      if (assetNo != null && assetNo.isNotEmpty) {
        queryParams['asset_no'] = assetNo;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.notificationBase,
        queryParams: queryParams,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (error) {
      return ErrorResponse<Map<String, dynamic>>(
        message: 'Failed to get notifications: $error',
      );
    }
  }

  /// Get notification by ID (admin/manager only)
  Future<ApiResponse<Map<String, dynamic>>> getNotificationById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.notificationById(id),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (error) {
      return ErrorResponse<Map<String, dynamic>>(
        message: 'Failed to get notification details: $error',
      );
    }
  }

  /// Update notification status (admin/manager only)
  Future<ApiResponse<Map<String, dynamic>>> updateNotificationStatus(
    int id, {
    String? status,
    String? resolutionNote,
    String? rejectionNote,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (status != null && status.isNotEmpty) {
        body['status'] = status;
      }
      if (resolutionNote != null && resolutionNote.isNotEmpty) {
        body['resolution_note'] = resolutionNote;
      }
      if (rejectionNote != null && rejectionNote.isNotEmpty) {
        body['rejection_note'] = rejectionNote;
      }

      if (body.isEmpty) {
        return ErrorResponse<Map<String, dynamic>>(
          message: 'No updates provided',
        );
      }

      final response = await _apiService.patch<Map<String, dynamic>>(
        ApiConstants.updateNotificationStatus(id),
        body: body,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (error) {
      return ErrorResponse<Map<String, dynamic>>(
        message: 'Failed to update notification status: $error',
      );
    }
  }

  /// Get notifications for a specific asset (admin/manager only)
  Future<ApiResponse<Map<String, dynamic>>> getAssetNotifications(
    String assetNo,
  ) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.assetNotifications(assetNo),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (error) {
      return ErrorResponse<Map<String, dynamic>>(
        message: 'Failed to get asset notifications: $error',
      );
    }
  }

  /// Get current user's submitted reports
  Future<ApiResponse<List<dynamic>>> getMyReports() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/notifications/my-reports',
        fromJson: (json) => json as List<dynamic>,
      );

      return response;
    } catch (error) {
      return ErrorResponse<List<dynamic>>(
        message: 'Failed to get my reports: $error',
      );
    }
  }

  /// Get all reports for admin users (admin/manager only)
  Future<ApiResponse<Map<String, dynamic>>> getAllReports({
    String? status,
    String? priority,
    String? problemType,
    String? assetNo,
    String? plantCode,
    String? locationCode,
    int page = 1,
    int limit = 100,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (priority != null && priority.isNotEmpty) {
        queryParams['priority'] = priority;
      }
      if (problemType != null && problemType.isNotEmpty) {
        queryParams['problem_type'] = problemType;
      }
      if (assetNo != null && assetNo.isNotEmpty) {
        queryParams['asset_no'] = assetNo;
      }
      if (plantCode != null && plantCode.isNotEmpty) {
        queryParams['plant_code'] = plantCode;
      }
      if (locationCode != null && locationCode.isNotEmpty) {
        queryParams['location_code'] = locationCode;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.allReports,
        queryParams: queryParams,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (error) {
      return ErrorResponse<Map<String, dynamic>>(
        message: 'Failed to get all reports: $error',
      );
    }
  }

  /// Get master data for dropdowns (plants, locations, etc.)
  Future<ApiResponse<Map<String, dynamic>>> getMasterData() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.masterData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (error) {
      return ErrorResponse<Map<String, dynamic>>(
        message: 'Failed to get master data: $error',
      );
    }
  }

}

/// Problem notification data models for type safety
class ProblemType {
  static const String assetDamage = 'asset_damage';
  static const String assetMissing = 'asset_missing';
  static const String locationIssue = 'location_issue';
  static const String dataError = 'data_error';
  static const String urgentIssue = 'urgent_issue';
  static const String other = 'other';

  static List<String> get all => [
        assetDamage,
        assetMissing,
        locationIssue,
        dataError,
        urgentIssue,
        other,
      ];
}

class NotificationPriority {
  static const String low = 'low';
  static const String normal = 'normal';
  static const String high = 'high';
  static const String urgent = 'critical';

  static List<String> get all => [low, normal, high, urgent];
}

class NotificationStatus {
  static const String pending = 'pending';
  static const String acknowledged = 'acknowledged';
  static const String inProgress = 'in_progress';
  static const String resolved = 'resolved';
  static const String cancelled = 'cancelled';

  static List<String> get all => [
        pending,
        acknowledged,
        inProgress,
        resolved,
        cancelled,
      ];
}