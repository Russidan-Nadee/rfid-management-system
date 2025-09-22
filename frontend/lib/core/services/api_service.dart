import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../errors/exceptions.dart';
import 'storage_service.dart';
import 'cookie_session_service.dart';
import 'api_error_interceptor.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();
  final CookieSessionService _cookieService = CookieSessionService();
  final http.Client _client = http.Client();

  // Request headers
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);

    if (requiresAuth) {
      // ===== Session-based Authentication =====
      final sessionHeaders = _cookieService.getRequestHeaders();
      headers.addAll(sessionHeaders);

      if (sessionHeaders.isNotEmpty) {
        await _storage.updateSessionTimestamp();
      }
    }

    return headers;
  }

  // Error handling
  AppException _handleError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final message = body['message'] ?? 'Unknown error occurred';

      switch (response.statusCode) {
        case 400:
          final errors = body['errors'] as List<dynamic>?;
          if (errors != null) {
            final errorMessages = errors
                .map((e) => e['message']?.toString() ?? '')
                .where((msg) => msg.isNotEmpty)
                .toList();
            return ValidationException(errorMessages);
          }
          return ValidationException([message]);
        case 401:
          return UnauthorizedException();
        case 403:
          return ForbiddenException();
        case 404:
          return NotFoundException(message);
        case 429:
          return ApiException('Too many requests', response.statusCode);
        case 500:
        case 502:
        case 503:
        case 504:
          return ServerException();
        default:
          return createExceptionFromStatusCode(response.statusCode, message);
      }
    } catch (e) {
      return createExceptionFromStatusCode(
        response.statusCode,
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  // Network error handling
  AppException _handleNetworkError(dynamic error) {
    if (error is SocketException) {
      return NoInternetException();
    } else if (error is HttpException) {
      return NetworkException(error.message);
    } else if (error.toString().contains('timeout')) {
      return ConnectionTimeoutException();
    } else {
      return NetworkException('Network error: $error');
    }
  }

  // Make HTTP request
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      // Check session expiry before making request
      if (requiresAuth && _cookieService.isSessionExpired()) {
        throw SessionExpiredException('Session expired - please login again');
      }

      // Build URL
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // API request logging removed

      // Get headers
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // Make request
      late http.Response response;

      switch (method.toLowerCase()) {
        case 'get':
          response = await _client
              .get(uri, headers: headers)
              .timeout(ApiConstants.timeout);
          break;
        case 'post':
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(ApiConstants.timeout);
          break;
        case 'put':
          response = await _client
              .put(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(ApiConstants.timeout);
          break;
        case 'patch':
          response = await _client
              .patch(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(ApiConstants.timeout);
          break;
        case 'delete':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(ApiConstants.timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method', 400);
      }

      // Handle response
      
      // OPTION 4: Global response interceptor - check for auth errors in ANY response
      if (requiresAuth && (response.statusCode == 401 || response.statusCode == 403)) {
        print('🚨 API: Authentication error detected in response (${response.statusCode})');
        // This will be handled by _handleError below, but log it here for visibility
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle cookies and session expiry updates in response for all successful responses
        await _cookieService.handleApiResponse(response);
        
        final responseBody = response.body.isEmpty
            ? '{"success": true, "message": "Success", "timestamp": "${DateTime.now().toIso8601String()}"}'
            : response.body;

        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(jsonResponse, fromJson);
        return apiResponse;
      } else {
        try {
          throw _handleError(response);
        } catch (e) {
          // ALWAYS pass errors to global interceptor first
          ApiErrorInterceptor.handleError(e, source: 'ApiService._makeRequest');
          
          if (e is SessionExpiredException) {
            // Force immediate logout on session expiration
            await _forceLogout();
            rethrow;
          } else if (e is UnauthorizedException && requiresAuth) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry original request
              return _makeRequest<T>(
                method,
                endpoint,
                body: body,
                queryParams: queryParams,
                requiresAuth: requiresAuth,
                fromJson: fromJson,
              );
            } else {
              await _forceLogout();
              rethrow;
            }
          } else if (response.statusCode == 401 && requiresAuth) {
            // Catch any other 401 errors that might not be properly classified
            await _forceLogout();
            rethrow;
          }
          rethrow; // throw error ต่อไป
        }
      }
    } catch (e) {
      // Pass ALL errors to global interceptor, including network errors
      ApiErrorInterceptor.handleError(e, source: 'ApiService.networkError');
      
      if (e is AppException) {
        rethrow;
      } else {
        throw _handleNetworkError(e);
      }
    }
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'GET',
      endpoint,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'POST',
      endpoint,
      body: body,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'PUT',
      endpoint,
      body: body,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  // PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'PATCH',
      endpoint,
      body: body,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'DELETE',
      endpoint,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  // Authentication helpers
  Future<bool> isAuthenticated() async {
    // Check cookie-based session first
    final hasSession = await _cookieService.hasValidSession();
    if (hasSession) return true;
    
    // Fallback to token-based authentication
    final token = await _storage.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAuthToken() async {
    final token = await _storage.getAuthToken();
    return token;
  }

  Future<Map<String, String>> getSessionHeaders() async {
    return _cookieService.getRequestHeaders();
  }

  Future<void> clearAuthToken() async {
    await _storage.clearAuthData();
    await _cookieService.clearSession();
  }

  Future<http.Response> downloadFile(
    String url,
    String savePath, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = await http.Request('GET', uri);

      if (headers != null) {
        request.headers.addAll(headers);
      }

      final response = await _client.send(request);

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.create(recursive: true);
        await response.stream.pipe(file.openWrite());
      }

      return http.Response('', response.statusCode);
    } catch (e) {
      throw NetworkException('Download failed: $e');
    }
  }

  Future<Map<String, dynamic>> getSearchResponse(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      'GET',
      endpoint,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
    );

    // Return full response structure
    return {
      'success': response.success,
      'message': response.message,
      'data': response.data,
      'meta': response.meta,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Session-based refresh for new authentication system
  Future<bool> _refreshToken() async {
    try {
      // Only attempt refresh if we have a valid session
      final hasSession = await _cookieService.hasValidSession();
      if (!hasSession) {
        return false;
      }

      final headers = await _getHeaders(requiresAuth: true);
      
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshSession}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Handle new session cookie and updated expiry time
        await _cookieService.handleApiResponse(response);
        return true;
      } else if (response.statusCode == 401) {
        // Session expired - clear local session data
        await clearAuthToken();
        return false;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Upload image using bytes with proper MediaType
  Future<ApiResponse<Map<String, dynamic>>> uploadImageBytes(
    String endpoint,
    List<int> bytes,
    String filename,
    String fieldName,
  ) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = await _getHeaders(requiresAuth: true);
      request.headers.addAll(headers);

      // Convert headers to string map for multipart
      final stringHeaders = <String, String>{};
      headers.forEach((key, value) {
        stringHeaders[key] = value.toString();
      });
      request.headers.addAll(stringHeaders);

      // Detect content type based on filename extension
      MediaType contentType;
      final extension = filename.split('.').last.toLowerCase();
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        default:
          contentType = MediaType('image', 'jpeg'); // default fallback
      }

      // Create multipart file from bytes with proper MediaType
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
        contentType: contentType,
      );

      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Upload successful',
          data: {'status': 'uploaded'},
          timestamp: DateTime.now(),
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Upload failed: ${response.statusCode}',
          data: null,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Upload error: $e',
        data: null,
        timestamp: DateTime.now(),
      );
    }
  }

  // Force logout when session expires
  static bool _isLoggingOut = false;
  
  Future<void> _forceLogout() async {
    if (_isLoggingOut) {
      print('⚠️ API SERVICE: Logout already in progress, skipping');
      return;
    }
    
    try {
      _isLoggingOut = true;
      await clearAuthToken();
      
      // Trigger global logout event through a global callback if available
      if (_onForceLogout != null) {
        _onForceLogout!();
      }
    } catch (e) {
      // Handle logout errors silently
    } finally {
      // Reset the flag after a delay to allow the logout process to complete
      Future.delayed(const Duration(seconds: 2), () {
        _isLoggingOut = false;
      });
    }
  }

  // Callback for force logout
  static void Function()? _onForceLogout;
  
  static void setForceLogoutCallback(void Function() callback) {
    _onForceLogout = callback;
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}
