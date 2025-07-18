import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../errors/exceptions.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();
  final http.Client _client = http.Client();

  // Request headers
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);

    if (requiresAuth) {
      // ===== Development Mode: ไม่ใช้ token =====
      if (kDebugMode) {
        const bool skipAuth = true; // เปลี่ยนเป็น false เมื่อต้องการ auth กลับ

        if (skipAuth) {
          // ไม่ส่ง Authorization header
          return headers;
        }
      }

      // ===== Production Mode: ใช้ token จริง =====
      final token = await _storage.getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        print('NO TOKEN - Request will fail');
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
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body.isEmpty
            ? '{"success": true, "message": "Success", "timestamp": "${DateTime.now().toIso8601String()}"}'
            : response.body;

        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        return ApiResponse.fromJson(jsonResponse, fromJson);
      } else {
        try {
          throw _handleError(response);
        } catch (e) {
          if (e is UnauthorizedException && requiresAuth) {
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
            }
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
    final token = await _storage.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAuthToken() async {
    final token = await _storage.getAuthToken();
    print('🔑 DEBUG TOKEN: $token');
    print('🔑 TOKEN LENGTH: ${token?.length ?? 0}');
    return token;
  }

  Future<void> clearAuthToken() async {
    await _storage.clearAuthData();
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

  // เพิ่มใน api_service.dart
  Future<bool> _refreshToken() async {
    // print('🔄 ATTEMPTING TOKEN REFRESH...');
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      // print('❌ NO REFRESH TOKEN FOUND');
      return false;
    }

    try {
      print('📡 CALLING REFRESH API...');
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}'),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode({'token': refreshToken}),
      );
      print('📥 REFRESH RESPONSE: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.saveAuthToken(data['token']);
        print('✅ TOKEN REFRESHED SUCCESSFULLY');
        return true;
      }
    } catch (e) {
      print('Refresh failed: $e');
    }
    print('❌ TOKEN REFRESH FAILED');

    return false;
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}
