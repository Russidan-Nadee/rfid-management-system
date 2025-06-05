// Path: frontend/lib/features/settings/domain/repositories/settings_repository.dart
import '../entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> saveSettings(SettingsEntity settings);
  Future<void> updateTheme(String themeMode);
  Future<void> updateLanguage(String language);
  Future<void> updateRememberLogin(bool remember);
  Future<void> updateAutoLogout(int minutes);
  Future<void> resetToDefaults();
}
