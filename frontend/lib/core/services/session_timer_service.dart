import 'dart:async';
import 'dart:io';
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
  Timer? _proactiveRefreshTimer;
  
  final ValueNotifier<bool> sessionExpired = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showWarning = ValueNotifier<bool>(false);
  final ValueNotifier<int> remainingTime = ValueNotifier<int>(0);

  static const int warningTimeMs = 2 * 60 * 1000; // 2 minutes before expiry
  
  // Track user activity
  DateTime _lastActivityTime = DateTime.now();
  DateTime? _lastRefreshAttempt;
  
  // Platform detection
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  
  // Check if user was recently active within the given duration
  bool wasRecentlyActive(Duration threshold) {
    final now = DateTime.now();
    final timeSinceActivity = now.difference(_lastActivityTime);
    return timeSinceActivity <= threshold;
  }

  void startSessionTimer() {
    stopSessionTimer();
    
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _checkSession();
    });
    
    // Start proactive refresh timer for all platforms
    _startProactiveRefreshTimer();
  }

  void stopSessionTimer() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _proactiveRefreshTimer?.cancel();
    _sessionTimer = null;
    _warningTimer = null;
    _proactiveRefreshTimer = null;
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

  void _startProactiveRefreshTimer() {
    // For all platforms, check every 5 minutes if session needs proactive refresh
    _proactiveRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      try {
        await _checkProactiveRefresh();
      } catch (e) {
        if (kDebugMode) {
          final platform = kIsWeb ? "Web" : (isWindows ? "Windows" : "Mobile");
          print('🔄 $platform: Proactive refresh timer error: $e');
        }
      }
    });
    
    if (kDebugMode) {
      final platform = kIsWeb ? "Web" : (isWindows ? "Windows" : "Mobile");
      print('🔄 $platform: Started proactive refresh timer');
    }
  }
  
  Future<void> _checkProactiveRefresh() async {
    try {
      final timeUntilExpiry = _cookieService.getTimeUntilExpiry();
      
      if (timeUntilExpiry == null) return;
      
      // Refresh if session expires in less than 10 minutes and user was recently active
      if (timeUntilExpiry.inMinutes <= 10 && wasRecentlyActive(const Duration(minutes: 15))) {
        
        // Don't refresh too frequently - at least 5 minutes between attempts
        if (_lastRefreshAttempt != null) {
          final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshAttempt!);
          if (timeSinceLastRefresh.inMinutes < 5) {
            return;
          }
        }
        
        final platform = kIsWeb ? "Web" : (isWindows ? "Windows" : "Mobile");
        if (kDebugMode) {
          print('🔄 $platform: Proactive refresh - session expires in ${timeUntilExpiry.inMinutes} minutes, user was recently active');
        }
        
        _lastRefreshAttempt = DateTime.now();
        final refreshSuccess = await _attemptTokenRefresh();
        
        if (refreshSuccess) {
          if (kDebugMode) {
            print('🔄 $platform: Proactive refresh successful');
          }
        } else {
          if (kDebugMode) {
            print('🔄 $platform: Proactive refresh failed');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        final platform = kIsWeb ? "Web" : (isWindows ? "Windows" : "Mobile");
        print('🔄 $platform: Proactive refresh check error: $e');
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
      
      // Platform-specific logging
      final platform = kIsWeb ? "Web" : (isWindows ? "Windows" : "Mobile");
      print('🔄 $platform SESSION ACTIVITY: User activity recorded');
      print('🕐 $platform SESSION ACTIVITY: Time until expiry: ${timeUntilExpiry.inSeconds}s');
      print('🕐 $platform SESSION ACTIVITY: Activity recorded at: ${_lastActivityTime.toIso8601String()}');
      
      // On all platforms, consider proactive refresh when user is very active and session near expiry
      if (timeUntilExpiry.inMinutes <= 10) {
        // Don't refresh too frequently
        if (_lastRefreshAttempt == null || 
            DateTime.now().difference(_lastRefreshAttempt!).inMinutes >= 5) {
          
          print('🔄 $platform SESSION ACTIVITY: Session near expiry, considering proactive refresh');
          _lastRefreshAttempt = DateTime.now();
          
          // Attempt refresh in background - catch errors to prevent crashes
          _attemptTokenRefresh().then((success) {
            if (success && kDebugMode) {
              print('🔄 $platform SESSION ACTIVITY: Background refresh successful');
            }
          }).catchError((error) {
            if (kDebugMode) {
              print('🔄 $platform SESSION ACTIVITY: Background refresh error: $error');
            }
          });
        }
      }
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