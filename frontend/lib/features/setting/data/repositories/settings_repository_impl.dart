// Path: frontend/lib/features/settings/data/repositories/settings_repository_impl.dart
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<SettingsEntity> getSettings() async {
    try {
      return await localDataSource.getSettings();
    } catch (e) {
      // ถ้า error ให้ return default settings
      return SettingsEntity.defaultSettings();
    }
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      await localDataSource.saveSettings(settingsModel);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  @override
  Future<void> updateTheme(String themeMode) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update theme: $e');
    }
  }

  @override
  Future<void> updateLanguage(String language) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(language: language);
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update language: $e');
    }
  }

  @override
  Future<void> updateRememberLogin(bool remember) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(rememberLogin: remember);
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update remember login: $e');
    }
  }

  @override
  Future<void> updateAutoLogout(int minutes) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        autoLogoutTimeout: minutes,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update auto logout: $e');
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      await localDataSource.clearSettings();
      final defaultSettings = SettingsEntity.defaultSettings();
      await saveSettings(defaultSettings);
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }
}
