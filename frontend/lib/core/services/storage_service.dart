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
  }

  Future<String?> getAuthToken() async {
    return await getSecureString(AppConstants.authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await setSecureString(AppConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return await getSecureString(AppConstants.refreshTokenKey);
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
  }

  // Theme preferences
  Future<void> saveThemeMode(String themeMode) async {
    await setString(AppConstants.themeKey, themeMode);
  }

  String getThemeMode() {
    return getString(AppConstants.themeKey) ?? 'system';
  }
}
