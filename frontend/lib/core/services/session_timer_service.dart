import 'dart:async';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import '../../app/app_constants.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../di/injection.dart';

class SessionTimerService {
  static final SessionTimerService _instance = SessionTimerService._internal();
  factory SessionTimerService() => _instance;
  SessionTimerService._internal();

  final StorageService _storage = StorageService();
  Timer? _sessionTimer;
  Timer? _warningTimer;
  
  final ValueNotifier<bool> sessionExpired = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showWarning = ValueNotifier<bool>(false);
  final ValueNotifier<int> remainingTime = ValueNotifier<int>(0);

  static const int warningTimeMs = 2 * 60 * 1000; // 2 minutes before expiry

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
      final isValid = await _storage.isSessionValid();
      final remaining = await _storage.getSessionRemainingTime();
      
      remainingTime.value = remaining;
      
      if (!isValid) {
        // Try to refresh token before expiring session
        final refreshSuccessful = await _attemptTokenRefresh();
        
        if (refreshSuccessful) {
          await _storage.updateSessionTimestamp();
          final newRemaining = await _storage.getSessionRemainingTime();
          remainingTime.value = newRemaining;
          if (kDebugMode) {
            print('Session refreshed successfully');
          }
        } else {
          sessionExpired.value = true;
          stopSessionTimer();
          await _storage.clearAuthData();
        }
      } else if (remaining <= warningTimeMs && !showWarning.value) {
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
      final remaining = await _storage.getSessionRemainingTime();
      remainingTime.value = remaining;
      
      if (remaining <= 0) {
        timer.cancel();
        sessionExpired.value = true;
        stopSessionTimer();
        await _storage.clearAuthData();
      }
    });
  }

  Future<void> extendSession() async {
    await _storage.updateSessionTimestamp();
    showWarning.value = false;
    _warningTimer?.cancel();
    _warningTimer = null;
    
    final remaining = await _storage.getSessionRemainingTime();
    remainingTime.value = remaining;
  }

  Future<void> resetSession() async {
    sessionExpired.value = false;
    showWarning.value = false;
    await _storage.updateSessionTimestamp();
    
    final remaining = await _storage.getSessionRemainingTime();
    remainingTime.value = remaining;
  }

  void dispose() {
    stopSessionTimer();
    sessionExpired.dispose();
    showWarning.dispose();
    remainingTime.dispose();
  }
}