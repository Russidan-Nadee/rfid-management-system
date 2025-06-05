// Path: frontend/lib/features/settings/domain/usecases/get_settings_usecase.dart
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<SettingsEntity> execute() async {
    try {
      final settings = await repository.getSettings();

      // Validate settings before returning
      if (!settings.isValid()) {
        // ถ้า settings ไม่ valid ให้ reset เป็น default
        await repository.resetToDefaults();
        return await repository.getSettings();
      }

      return settings;
    } catch (e) {
      // ถ้า error ให้ return default settings
      return SettingsEntity.defaultSettings();
    }
  }
}
