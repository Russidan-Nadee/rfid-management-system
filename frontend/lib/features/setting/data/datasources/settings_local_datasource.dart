// Path: frontend/lib/features/settings/data/datasources/settings_local_datasource.dart
import '../../../../core/services/storage_service.dart';
import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
  Future<void> clearSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final StorageService storageService;
  static const String _settingsKey = 'app_settings';

  SettingsLocalDataSourceImpl(this.storageService);

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final settingsJson = storageService.getJson(_settingsKey);

      if (settingsJson != null) {
        return SettingsModel.fromJson(settingsJson);
      } else {
        // ถ้าไม่มีข้อมูล ให้ return default settings
        final defaultSettings = SettingsModel.defaultSettings();
        await saveSettings(defaultSettings); // เก็บ default ไว้เลย
        return defaultSettings;
      }
    } catch (e) {
      // ถ้า error ให้ return default settings
      return SettingsModel.defaultSettings();
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      await storageService.setJson(_settingsKey, settings.toJson());
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      await storageService.remove(_settingsKey);
    } catch (e) {
      throw Exception('Failed to clear settings: $e');
    }
  }

  // Helper methods สำหรับ update แค่บางส่วน
  Future<void> updateTheme(String themeMode) async {
    final currentSettings = await getSettings();
    final updatedSettings = SettingsModel.fromEntity(
      currentSettings.copyWith(themeMode: themeMode),
    );
    await saveSettings(updatedSettings);
  }

  Future<void> updateLanguage(String language) async {
    final currentSettings = await getSettings();
    final updatedSettings = SettingsModel.fromEntity(
      currentSettings.copyWith(language: language),
    );
    await saveSettings(updatedSettings);
  }
}
