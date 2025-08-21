import 'dart:async';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'cookie_session_service.dart';
import '../../app/app_constants.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../di/injection.dart';

class SessionTimerService {
  static final SessionTimerService _instance = SessionTimerService._internal();
  factory SessionTimerService() => _instance;
  SessionTimerService._internal();

  final StorageService _storage = StorageService();
  final CookieSessionService _cookieService = CookieSessionService();
  Timer? _sessionTimer;
  Timer? _warningTimer;
  
  final ValueNotifier<bool> sessionExpired = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showWarning = ValueNotifier<bool>(false);
  final ValueNotifier<int> remainingTime = ValueNotifier<int>(0);

  static const int warningTimeMs = 30 * 1000; // 30 seconds before expiry
  
  // Track user activity
  DateTime _lastActivityTime = DateTime.now();
  
  // Check if user was recently active within the given duration
  bool wasRecentlyActive(Duration threshold) {
    final now = DateTime.now();
    final timeSinceActivity = now.difference(_lastActivityTime);
    return timeSinceActivity <= threshold;
  }

  void startSessionTimer() {
    stopSessionTimer();
    
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkSession();
    });
  }

  void stopSessionTimer() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _sessionTimer = null;
    _warningTimer = null;
    showWarning.value = false;
  }

  Future<void> _checkSession() async {
    try {
      // Use backend session expiry time instead of local timestamp
      final isExpired = _cookieService.isSessionExpired();
      final timeUntilExpiry = _cookieService.getTimeUntilExpiry();
      
      if (timeUntilExpiry != null) {
        remainingTime.value = timeUntilExpiry.inMilliseconds;
      } else {
        remainingTime.value = 0;
      }
      
      if (isExpired) {
        // Try to refresh token before expiring session
        final refreshSuccessful = await _attemptTokenRefresh();
        
        if (refreshSuccessful) {
          // Session refresh updates the cookie service expiry time automatically
          final newTimeUntilExpiry = _cookieService.getTimeUntilExpiry();
          if (newTimeUntilExpiry != null) {
            remainingTime.value = newTimeUntilExpiry.inMilliseconds;
          }
          if (kDebugMode) {
            print('Session refreshed successfully');
          }
        } else {
          sessionExpired.value = true;
          stopSessionTimer();
          await _storage.clearAuthData();
          await _cookieService.clearSession();
        }
      } else if (timeUntilExpiry != null && timeUntilExpiry.inMilliseconds <= warningTimeMs && !showWarning.value) {
        showWarning.value = true;
        _startWarningTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Session check error: $e');
      }
    }
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final authRepository = getIt<AuthRepository>();
      return await authRepository.refreshToken();
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      return false;
    }
  }

  void _startWarningTimer() {
    _warningTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final timeUntilExpiry = _cookieService.getTimeUntilExpiry();
      
      if (timeUntilExpiry != null) {
        remainingTime.value = timeUntilExpiry.inMilliseconds;
        
        if (timeUntilExpiry.inMilliseconds <= 0) {
          timer.cancel();
          sessionExpired.value = true;
          stopSessionTimer();
          await _storage.clearAuthData();
          await _cookieService.clearSession();
        }
      } else {
        timer.cancel();
        sessionExpired.value = true;
        stopSessionTimer();
        await _storage.clearAuthData();
        await _cookieService.clearSession();
      }
    });
  }

  // Call this method on ANY user activity (navigation, taps, scrolling, etc.)
  Future<void> recordActivity() async {
    _lastActivityTime = DateTime.now();
    
    // Update local timestamp for compatibility
    await _storage.updateSessionTimestamp();
    
    // Clear any warning state since user is active
    showWarning.value = false;
    _warningTimer?.cancel();
    _warningTimer = null;
    
    // Update remaining time based on backend session expiry
    final timeUntilExpiry = _cookieService.getTimeUntilExpiry();
    if (timeUntilExpiry != null) {
      remainingTime.value = timeUntilExpiry.inMilliseconds;
      
      print('🔄 SESSION ACTIVITY: User activity recorded');
      print('🕐 SESSION ACTIVITY: Time until expiry: ${timeUntilExpiry.inSeconds}s');
      print('🕐 SESSION ACTIVITY: Activity recorded at: ${_lastActivityTime.toIso8601String()}');
    } else {
      print('⚠️ SESSION ACTIVITY: No session expiry time available');
    }
  }

  Future<void> extendSession() async {
    await recordActivity(); // Use the same logic
  }

  Future<void> resetSession() async {
    sessionExpired.value = false;
    showWarning.value = false;
    _lastActivityTime = DateTime.now();
    await _storage.updateSessionTimestamp();
    
    // Update remaining time based on backend session expiry
    final timeUntilExpiry = _cookieService.getTimeUntilExpiry();
    if (timeUntilExpiry != null) {
      remainingTime.value = timeUntilExpiry.inMilliseconds;
    } else {
      remainingTime.value = 0;
    }
  }

  void dispose() {
    stopSessionTimer();
    sessionExpired.dispose();
    showWarning.dispose();
    remainingTime.dispose();
  }
}