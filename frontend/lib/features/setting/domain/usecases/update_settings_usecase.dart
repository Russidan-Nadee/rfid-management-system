// Path: frontend/lib/features/settings/domain/usecases/update_settings_usecase.dart
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateSettingsUseCase {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  Future<void> updateTheme(String themeMode) async {
    // Validate theme mode
    if (!['light', 'dark', 'system'].contains(themeMode)) {
      throw Exception('Invalid theme mode: $themeMode');
    }

    await repository.updateTheme(themeMode);
  }

  Future<void> updateLanguage(String language) async {
    // Validate language
    if (!['en', 'th'].contains(language)) {
      throw Exception('Invalid language: $language');
    }

    await repository.updateLanguage(language);
  }

  Future<void> updateRememberLogin(bool remember) async {
    await repository.updateRememberLogin(remember);
  }

  Future<void> updateAutoLogout(int minutes) async {
    // Validate auto logout timeout
    if (minutes < 0 || minutes > 1440) {
      // 0 = never, max 24 hours
      throw Exception('Invalid auto logout timeout: $minutes');
    }

    await repository.updateAutoLogout(minutes);
  }

  Future<void> resetToDefaults() async {
    await repository.resetToDefaults();
  }
}
