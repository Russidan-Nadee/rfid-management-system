import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import '../../app/app_constants.dart';

class CookieSessionService {
  static final CookieSessionService _instance = CookieSessionService._internal();
  factory CookieSessionService() => _instance;
  CookieSessionService._internal();

  final StorageService _storage = StorageService();
  final Map<String, String> _sessionCookies = {};

  // Platform detection
  bool get isWeb => kIsWeb;
  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Initialize session handling based on platform
  Future<void> init() async {
    if (isWeb) {
      // Web: Cookies handled automatically by browser
      if (kDebugMode) {
        print('🍪 Cookie session initialized for Web');
      }
    } else {
      // Mobile/Desktop: Manual cookie management
      await _loadStoredSession();
      if (kDebugMode) {
        print('🍪 Cookie session initialized for ${isMobile ? 'Mobile' : 'Desktop'}');
      }
    }
  }

  /// Handle login response and extract session cookies
  Future<void> handleLoginResponse(http.Response response) async {
    if (isWeb) {
      // Web: Extract sessionId from response body for manual header handling
      try {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseBody['success'] == true && 
            responseBody['data'] != null && 
            responseBody['data']['sessionId'] != null) {
          _sessionCookies['session_id'] = responseBody['data']['sessionId'];
          await _saveSessionCookies();
          if (kDebugMode) {
            print('🍪 Web: Stored sessionId from response body');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('🍪 Web: Failed to extract sessionId: $e');
        }
      }
      return;
    }

    // Mobile/Desktop: Extract and store cookies manually
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null) {
      _parseCookies(setCookieHeaders);
      await _saveSessionCookies();
    }
  }

  /// Get cookies for outgoing requests
  Map<String, String> getRequestHeaders() {
    if (isWeb) {
      // Web: Send sessionId as custom header since HTTP-only cookies don't work with Flutter web HTTP client
      if (_sessionCookies.containsKey('session_id')) {
        final sessionId = _sessionCookies['session_id']!;
        if (kDebugMode) {
          print('🍪 Web: Using sessionId header: ${sessionId.substring(0, 8)}...');
        }
        return {'x-session-id': sessionId};
      }
      return {};
    }

    // Mobile/Desktop: Add cookies manually
    if (_sessionCookies.isNotEmpty) {
      final cookieString = _sessionCookies.entries
          .map((e) => '${e.key}=${e.value}')
          .join('; ');
      return {'Cookie': cookieString};
    }
    return {};
  }

  /// Check if session is valid
  Future<bool> hasValidSession() async {
    if (isWeb) {
      // Web: Check if we have stored sessionId from login response
      await _loadStoredSession();
      final hasSessionId = _sessionCookies.containsKey('session_id');
      if (kDebugMode) {
        print('🍪 Web: Session check: hasSessionId=$hasSessionId');
      }
      return hasSessionId;
    }

    // Mobile/Desktop: Check stored session
    await _loadStoredSession(); // Ensure we have latest session data
    final hasSessionId = _sessionCookies.containsKey('session_id');
    if (kDebugMode) {
      print('🍪 Session check: hasSessionId=$hasSessionId, cookieCount=${_sessionCookies.length}');
    }
    return hasSessionId;
  }

  /// Clear session cookies
  Future<void> clearSession() async {
    if (isWeb) {
      // Web: Server should clear cookie
      return;
    }

    // Mobile/Desktop: Clear stored cookies
    _sessionCookies.clear();
    await _storage.remove('session_cookies');
  }

  /// Parse Set-Cookie headers
  void _parseCookies(String setCookieHeader) {
    final cookies = setCookieHeader.split(',');
    
    for (final cookie in cookies) {
      final parts = cookie.trim().split(';');
      if (parts.isNotEmpty) {
        final keyValue = parts[0].split('=');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          final value = keyValue[1].trim();
          
          // Store all relevant authentication cookies
          if (key.startsWith('session') || key == 'auth_token' || key == 'session_id') {
            _sessionCookies[key] = value;
            if (kDebugMode) {
              print('🍪 Stored cookie: $key = $value');
            }
          }
        }
      }
    }
  }

  /// Save session cookies to secure storage
  Future<void> _saveSessionCookies() async {
    if (_sessionCookies.isNotEmpty) {
      await _storage.setSecureJson('session_cookies', _sessionCookies);
    }
  }

  /// Load session cookies from secure storage
  Future<void> _loadStoredSession() async {
    final stored = await _storage.getSecureJson('session_cookies');
    if (stored != null) {
      _sessionCookies.clear();
      stored.forEach((key, value) {
        _sessionCookies[key] = value.toString();
      });
    }
  }

  /// Get session info for debugging
  Map<String, dynamic> getSessionInfo() {
    return {
      'platform': isWeb ? 'web' : (isMobile ? 'mobile' : 'desktop'),
      'cookieCount': _sessionCookies.length,
      'cookieKeys': _sessionCookies.keys.toList(),
      'hasSession': _sessionCookies.isNotEmpty,
    };
  }
}