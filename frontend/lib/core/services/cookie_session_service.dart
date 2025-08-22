import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';

class CookieSessionService {
  static final CookieSessionService _instance = CookieSessionService._internal();
  factory CookieSessionService() => _instance;
  CookieSessionService._internal();

  final StorageService _storage = StorageService();
  final Map<String, String> _sessionCookies = {};
  DateTime? _sessionExpiryTime;

  // Platform detection
  bool get isWeb => kIsWeb;
  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Initialize session handling based on platform
  Future<void> init() async {
    if (isWeb) {
      // Web: Load stored session data
      await _loadStoredSession();
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
    if (kDebugMode) {
      print('🍪 LOGIN: Handling login response...');
      print('🍪 LOGIN: Response status: ${response.statusCode}');
      print('🍪 LOGIN: Response body: ${response.body}');
    }
    await _handleResponseWithExpiry(response);
    if (kDebugMode) {
      print('🍪 LOGIN: After handling - session expiry: $_sessionExpiryTime');
    }
  }

  /// Handle any API response that might contain session expiry updates
  Future<void> handleApiResponse(http.Response response) async {
    await _handleResponseWithExpiry(response);
  }

  /// Handle web platform responses specifically
  Future<void> _handleWebResponse(http.Response response) async {
    try {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (responseBody['success'] == true && responseBody['data'] != null) {
        
        // Extract sessionId if present (login responses) - with safe type handling
        if (responseBody['data']['sessionId'] != null) {
          try {
            _sessionCookies['session_id'] = responseBody['data']['sessionId'].toString();
            if (kDebugMode) {
              final sessionIdStr = responseBody['data']['sessionId'].toString();
              final displayId = sessionIdStr.length > 8 ? sessionIdStr.substring(0, 8) : sessionIdStr;
              print('🍪 Web: Updated sessionId from response: $displayId...');
            }
          } catch (e) {
            if (kDebugMode) {
              print('🍪 Web: Failed to process sessionId: $e');
            }
          }
        }
        
        // Extract expiry time if present (login/refresh responses)
        if (responseBody['data']['expiresAt'] != null) {
          final expiresAtString = responseBody['data']['expiresAt'].toString();
          // Web platform: Keep as UTC since browser handles timezone automatically
          _sessionExpiryTime = DateTime.parse(expiresAtString);
          if (kDebugMode) {
            print('🍪 Web: Found expiresAt in data: $expiresAtString');
            print('🍪 Web: Updated session expiry to: $_sessionExpiryTime (UTC for web)');
          }
        }
        // Also check for sessionInfo from regular API responses
        else if (responseBody['data']['sessionInfo'] != null && 
                 responseBody['data']['sessionInfo']['expiresAt'] != null) {
          try {
            final sessionInfoExpiresAt = responseBody['data']['sessionInfo']['expiresAt'].toString();
            // Web platform: Keep as UTC since browser handles timezone automatically
            _sessionExpiryTime = DateTime.parse(sessionInfoExpiresAt);
            if (kDebugMode) {
              print('🍪 Web: Found expiresAt in sessionInfo: $sessionInfoExpiresAt');
              print('🍪 Web: Updated session expiry from sessionInfo to: $_sessionExpiryTime (UTC for web)');
            }
          } catch (e) {
            if (kDebugMode) {
              print('🍪 Web: Failed to process sessionInfo: $e');
            }
          }
        }
        
        await _saveSessionCookies();
      }
    } catch (e) {
      if (kDebugMode) {
        print('🍪 Web: Failed to extract session info: $e');
        print('🍪 Web: Response body snippet: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
        // Continue processing - this is not critical for session functionality
      }
      // Don't let this error break session functionality
    }
  }

  /// Common handler for responses that may contain session expiry information
  Future<void> _handleResponseWithExpiry(http.Response response) async {
    if (isWeb) {
      // Web: Extract sessionId and expiry from response body for manual header handling
      await _handleWebResponse(response);
      return; // CRITICAL: Always return here for web platform
    }

    // Mobile/Desktop: Extract and store cookies manually
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null) {
      _parseCookies(setCookieHeaders);
      await _saveSessionCookies();
    }
    
    // IMPORTANT: Also extract expiry time from response body for Windows/Mobile
    try {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseBody['success'] == true && responseBody['data'] != null) {
        
        // Extract expiry time if present (login/refresh responses)
        if (responseBody['data']['expiresAt'] != null) {
          final expiresAtString = responseBody['data']['expiresAt'].toString();
          // Windows/Mobile: Convert UTC to local time
          _sessionExpiryTime = DateTime.parse(expiresAtString).toLocal();
          if (kDebugMode) {
            print('🍪 Windows/Mobile: Found expiresAt: $expiresAtString');
            print('🍪 Windows/Mobile: Updated session expiry to: $_sessionExpiryTime (converted to local time)');
          }
          await _saveSessionCookies();
        }
        // Also check for sessionInfo from regular API responses
        else if (responseBody['data']['sessionInfo'] != null && 
                 responseBody['data']['sessionInfo']['expiresAt'] != null) {
          final sessionInfoExpiresAt = responseBody['data']['sessionInfo']['expiresAt'].toString();
          // Windows/Mobile: Convert UTC to local time
          _sessionExpiryTime = DateTime.parse(sessionInfoExpiresAt).toLocal();
          if (kDebugMode) {
            print('🍪 Windows/Mobile: Found sessionInfo expiresAt: $sessionInfoExpiresAt');
            print('🍪 Windows/Mobile: Updated session expiry from sessionInfo to: $_sessionExpiryTime (converted to local time)');
          }
          await _saveSessionCookies();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🍪 Windows/Mobile: Failed to extract expiry time: $e');
      }
    }
  }

  /// Get cookies for outgoing requests
  Map<String, String> getRequestHeaders() {
    if (isWeb) {
      // Web: Send sessionId as custom header since HTTP-only cookies don't work with Flutter web HTTP client
      if (_sessionCookies.containsKey('session_id')) {
        final sessionId = _sessionCookies['session_id']!;
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
    if (kDebugMode) {
      print('🍪 Clearing session: ${_sessionCookies.length} cookies, expiry: $_sessionExpiryTime');
    }
    
    _sessionCookies.clear();
    _sessionExpiryTime = null;
    
    // Clear stored session data
    await _storage.remove('session_cookies');
    await _storage.remove('session_expiry');
    
    if (kDebugMode) {
      print('🍪 Session cleared: cookies and expiry time removed');
    }
  }

  /// Initialize new session (call this at login to ensure clean state)
  Future<void> initializeNewSession() async {
    if (kDebugMode) {
      print('🍪 Initializing new session - clearing old data');
    }
    
    // Clear any existing session data first
    await clearSession();
    
    if (kDebugMode) {
      print('🍪 New session initialized - ready for login response');
    }
  }

  /// Check if current session token is expired (client-side check)
  bool isSessionExpired() {
    if (_sessionExpiryTime == null) {
      // No expiry time stored - consider expired for safety
      if (kDebugMode) {
        print('🕐 EXPIRY CHECK: No session expiry time stored - considering expired');
      }
      return true;
    }
    
    // Get current time in appropriate timezone
    final now = isWeb ? DateTime.now().toUtc() : DateTime.now();
    final expiryTime = _sessionExpiryTime!;
    final isExpired = now.isAfter(expiryTime);
    
    if (kDebugMode) {
      print('🕐 EXPIRY CHECK: now=$now (${isWeb ? "UTC" : "local"})');
      print('🕐 EXPIRY CHECK: expiry=$expiryTime (${isWeb ? "UTC" : "local"})');
      print('🕐 EXPIRY CHECK: expired=$isExpired');
      if (isExpired) {
        final timeDiff = now.difference(expiryTime);
        print('🕐 EXPIRY CHECK: expired by ${timeDiff.inSeconds} seconds');
      } else {
        final timeLeft = expiryTime.difference(now);
        print('🕐 EXPIRY CHECK: ${timeLeft.inSeconds} seconds remaining');
      }
    }
    
    return isExpired;
  }

  /// Get time until session expires (for proactive refresh)
  Duration? getTimeUntilExpiry() {
    if (_sessionExpiryTime == null) return null;
    
    // Use appropriate timezone for comparison
    final now = isWeb ? DateTime.now().toUtc() : DateTime.now();
    final expiryTime = _sessionExpiryTime!;
    
    if (now.isAfter(expiryTime)) {
      return Duration.zero; // Already expired
    }
    
    return expiryTime.difference(now);
  }

  /// Extend session expiry time (when backend extends the session)
  Future<void> extendSessionExpiry(int additionalMinutes) async {
    if (_sessionExpiryTime != null) {
      _sessionExpiryTime = _sessionExpiryTime!.add(Duration(minutes: additionalMinutes));
      await _saveSessionCookies();
      if (kDebugMode) {
        print('🍪 Extended session expiry by $additionalMinutes minutes to: $_sessionExpiryTime');
      }
    }
  }

  /// Update session expiry time directly
  Future<void> updateSessionExpiry(DateTime newExpiryTime) async {
    _sessionExpiryTime = newExpiryTime;
    await _saveSessionCookies();
    if (kDebugMode) {
      print('🍪 Updated session expiry to: $_sessionExpiryTime');
    }
  }

  /// Store session ID manually (for login responses)
  Future<void> storeSessionId(String sessionId) async {
    _sessionCookies['session_id'] = sessionId;
    await _saveSessionCookies();
    if (kDebugMode) {
      print('🍪 Stored session ID: ${sessionId.substring(0, 8)}...');
    }
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
    
    // Save expiry time separately
    if (_sessionExpiryTime != null) {
      await _storage.setSecureString('session_expiry', _sessionExpiryTime!.toIso8601String());
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
    
    // Load expiry time
    final expiryString = await _storage.getSecureString('session_expiry');
    if (expiryString != null) {
      try {
        // Parse stored time and keep in original timezone context
        _sessionExpiryTime = DateTime.parse(expiryString);
        if (kDebugMode) {
          print('🍪 Loaded stored session expiry: $_sessionExpiryTime');
        }
      } catch (e) {
        if (kDebugMode) {
          print('🍪 Failed to parse stored expiry time: $e');
        }
        _sessionExpiryTime = null;
      }
    }
  }

  /// Get session info for debugging
  Map<String, dynamic> getSessionInfo() {
    return {
      'platform': isWeb ? 'web' : (isMobile ? 'mobile' : 'desktop'),
      'cookieCount': _sessionCookies.length,
      'cookieKeys': _sessionCookies.keys.toList(),
      'hasSession': _sessionCookies.isNotEmpty,
      'sessionExpiryTime': _sessionExpiryTime?.toIso8601String(),
      'isExpired': isSessionExpired(),
      'timeUntilExpiry': getTimeUntilExpiry()?.inSeconds,
    };
  }

  /// Debug method to print current session state
  void debugSessionState() {
    if (kDebugMode) {
      print('🔍 SESSION DEBUG STATE:');
      print('  Platform: ${isWeb ? "Web" : isMobile ? "Mobile" : "Desktop"}');
      print('  Session ID: ${_sessionCookies["session_id"]?.substring(0, 8) ?? "none"}...');
      print('  Expiry Time: $_sessionExpiryTime');
      print('  Is Expired: ${isSessionExpired()}');
      print('  Time Until Expiry: ${getTimeUntilExpiry()?.inSeconds ?? "N/A"} seconds');
      print('  Cookie Count: ${_sessionCookies.length}');
    }
  }
}