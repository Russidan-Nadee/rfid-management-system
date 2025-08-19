import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../errors/exceptions.dart';
import 'storage_service.dart';
import 'cookie_session_service.dart';

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
        print('✅ Using session authentication');
        await _storage.updateSessionTimestamp();
      } else {
        print('❌ NO ACTIVE SESSION - Request will fail');
      }
    }

    return headers;
  }

  // Error handling
  AppException _handleError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final message = body['message'] ?? 'Unknown error occurred';
      final code = body['code'];

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
          // Check for specific session/token expiration codes
          if (code == 'SESSION_EXPIRED' || code == 'TOKEN_EXPIRED') {
            return SessionExpiredException(message);
          }
          throw UnauthorizedException();
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
      // Build URL
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      print('🔍 API: Making $method request');
      print('🔍 API: URL: $uri');
      print('🔍 API: Requires Auth: $requiresAuth');
      if (body != null) {
        print('🔍 API: Request Body: $body');
      }
      if (queryParams != null) {
        print('🔍 API: Query Params: $queryParams');
      }

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
      print('🔍 API: Response Status: ${response.statusCode}');
      print('🔍 API: Response Body: ${response.body}');
      print('🔍 API: Response Headers: ${response.headers}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ API: Success response');
        
        // Handle cookies in response
        await _cookieService.handleLoginResponse(response);
        
        final responseBody = response.body.isEmpty
            ? '{"success": true, "message": "Success", "timestamp": "${DateTime.now().toIso8601String()}"}'
            : response.body;

        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(jsonResponse, fromJson);
        print('🔍 API: Parsed response success: ${apiResponse.success}');
        return apiResponse;
      } else {
        print('❌ API: Error response');
        try {
          throw _handleError(response);
        } catch (e) {
          if (e is SessionExpiredException) {
            // Force immediate logout on session expiration
            print('🚨 SessionExpiredException caught - forcing logout');
            await _forceLogout();
            rethrow;
          } else if (e is UnauthorizedException && requiresAuth) {
            print('⚠️ UnauthorizedException - attempting token refresh');
            final refreshed = await _refreshToken();
            if (refreshed) {
              print('✅ Token refresh successful - retrying request');
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
              print('❌ Token refresh failed - forcing logout');
              await _forceLogout();
              rethrow;
            }
          } else if (response.statusCode == 401 && requiresAuth) {
            // Catch any other 401 errors that might not be properly classified
            print('🚨 Generic 401 error on authenticated request - forcing logout');
            await _forceLogout();
            rethrow;
          }
          rethrow; // throw error ต่อไป
        }
      }
    } catch (e) {
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
    print('🔑 DEBUG TOKEN: $token');
    print('🔑 TOKEN LENGTH: ${token?.length ?? 0}');
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
        print('❌ NO VALID SESSION - Cannot refresh');
        return false;
      }

      print('📡 CALLING SESSION REFRESH API...');
      final headers = await _getHeaders(requiresAuth: true);
      
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshSession}'),
        headers: headers,
      );
      print('📥 SESSION REFRESH RESPONSE: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle new session cookie
        await _cookieService.handleLoginResponse(response);
        print('✅ SESSION REFRESHED SUCCESSFULLY');
        return true;
      } else if (response.statusCode == 401) {
        // Session expired - clear local session data
        print('❌ SESSION EXPIRED - Clearing local session');
        await clearAuthToken();
        return false;
      }
      
      return false;
    } catch (e) {
      print('❌ REFRESH FAILED: $e');
      return false;
    }
  }

  // Upload image using bytes to avoid MediaType namespace issues
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
      
      // Create multipart file from bytes without MediaType
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
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
  Future<void> _forceLogout() async {
    try {
      print('🚨 FORCING LOGOUT DUE TO SESSION EXPIRATION');
      await clearAuthToken();
      
      // Trigger global logout event through a global callback if available
      if (_onForceLogout != null) {
        _onForceLogout!();
      }
    } catch (e) {
      print('❌ Error during force logout: $e');
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
