import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app_constants.dart';
import '../errors/exceptions.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize storage
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw StorageException('Failed to initialize storage: $e');
    }
  }

  // Basic Storage Methods
  Future<void> setString(String key, String value) async {
    try {
      await _prefs?.setString(key, value);
    } catch (e) {
      throw StorageException('Failed to save data: $e');
    }
  }

  String? getString(String key) {
    try {
      return _prefs?.getString(key);
    } catch (e) {
      throw StorageException('Failed to read data: $e');
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs?.setBool(key, value);
    } catch (e) {
      throw StorageException('Failed to save boolean data: $e');
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs?.getBool(key);
    } catch (e) {
      throw StorageException('Failed to read boolean data: $e');
    }
  }

  Future<void> setInt(String key, int value) async {
    try {
      await _prefs?.setInt(key, value);
    } catch (e) {
      throw StorageException('Failed to save integer data: $e');
    }
  }

  int? getInt(String key) {
    try {
      return _prefs?.getInt(key);
    } catch (e) {
      throw StorageException('Failed to read integer data: $e');
    }
  }

  // JSON Storage Methods
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      await setString(key, jsonString);
    } catch (e) {
      throw StorageException('Failed to save JSON data: $e');
    }
  }

  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Failed to read JSON data: $e');
    }
  }

  // Secure Storage Methods (using prefix for sensitive data)
  Future<void> setSecureString(String key, String value) async {
    await setString('_secure_$key', value);
  }

  Future<String?> getSecureString(String key) async {
    return getString('_secure_$key');
  }

  Future<void> deleteSecureString(String key) async {
    await remove('_secure_$key');
  }

  Future<void> setSecureJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await setSecureString(key, jsonString);
  }

  Future<Map<String, dynamic>?> getSecureJson(String key) async {
    final jsonString = await getSecureString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Remove data
  Future<void> remove(String key) async {
    try {
      await _prefs?.remove(key);
    } catch (e) {
      throw StorageException('Failed to remove data: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _prefs?.clear();
    } catch (e) {
      throw StorageException('Failed to clear storage: $e');
    }
  }

  Future<void> clearSecureStorage() async {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};
      final secureKeys = keys.where((key) => key.startsWith('_secure_'));
      for (final key in secureKeys) {
        await _prefs?.remove(key);
      }
    } catch (e) {
      throw StorageException('Failed to clear secure storage: $e');
    }
  }

  // Check if key exists
  bool containsKey(String key) {
    try {
      return _prefs?.containsKey(key) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Authentication specific methods
  Future<void> saveAuthToken(String token) async {
    await setSecureString(AppConstants.authTokenKey, token);
    await updateSessionTimestamp();
  }

  Future<String?> getAuthToken() async {
    final token = await getSecureString(AppConstants.authTokenKey);
    if (token != null && await isSessionValid()) {
      await updateSessionTimestamp();
      return token;
    } else if (token != null) {
      // Don't clear auth data immediately, let refresh token handle it
      return null;
    }
    return token;
  }

  Future<void> saveRefreshToken(String token) async {
    await setSecureString(AppConstants.refreshTokenKey, token);
    await updateRefreshTokenTimestamp();
  }

  Future<String?> getRefreshToken() async {
    final token = await getSecureString(AppConstants.refreshTokenKey);
    if (token != null && await isRefreshTokenValid()) {
      return token;
    } else if (token != null) {
      await clearAuthData();
      return null;
    }
    return token;
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await setSecureJson(AppConstants.userDataKey, userData);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await getSecureJson(AppConstants.userDataKey);
  }

  Future<void> saveRememberLogin(bool remember) async {
    await setBool(AppConstants.rememberLoginKey, remember);
  }

  bool getRememberLogin() {
    return getBool(AppConstants.rememberLoginKey) ?? false;
  }

  Future<void> clearAuthData() async {
    await deleteSecureString(AppConstants.authTokenKey);
    await deleteSecureString(AppConstants.refreshTokenKey);
    await deleteSecureString(AppConstants.userDataKey);
    await remove(AppConstants.rememberLoginKey);
    await remove(AppConstants.sessionTimestampKey);
    await remove(AppConstants.refreshTokenTimestampKey);
  }

  // Theme preferences
  Future<void> saveThemeMode(String themeMode) async {
    await setString(AppConstants.themeKey, themeMode);
  }

  String getThemeMode() {
    return getString(AppConstants.themeKey) ?? 'system';
  }

  // Session management methods
  Future<void> updateSessionTimestamp() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await setInt(AppConstants.sessionTimestampKey, timestamp);
  }

  Future<bool> isSessionValid() async {
    final timestamp = getInt(AppConstants.sessionTimestampKey);
    if (timestamp == null) return false;
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDifference = currentTime - timestamp;
    
    return timeDifference < AppConstants.sessionTimeoutMs;
  }

  Future<int> getSessionRemainingTime() async {
    final timestamp = getInt(AppConstants.sessionTimestampKey);
    if (timestamp == null) return 0;
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDifference = currentTime - timestamp;
    final remainingTime = AppConstants.sessionTimeoutMs - timeDifference;
    
    return remainingTime > 0 ? remainingTime : 0;
  }

  // Refresh token management methods
  Future<void> updateRefreshTokenTimestamp() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await setInt(AppConstants.refreshTokenTimestampKey, timestamp);
  }

  Future<bool> isRefreshTokenValid() async {
    final timestamp = getInt(AppConstants.refreshTokenTimestampKey);
    if (timestamp == null) return false;
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDifference = currentTime - timestamp;
    
    return timeDifference < AppConstants.refreshTokenExpiryMs;
  }

  Future<int> getRefreshTokenRemainingTime() async {
    final timestamp = getInt(AppConstants.refreshTokenTimestampKey);
    if (timestamp == null) return 0;
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDifference = currentTime - timestamp;
    final remainingTime = AppConstants.refreshTokenExpiryMs - timeDifference;
    
    return remainingTime > 0 ? remainingTime : 0;
  }
}
