// Path: frontend/lib/features/settings/data/models/settings_model.dart
import '../../domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.themeMode,
    required super.language,
    required super.fontSize,
    required super.rememberLogin,
    required super.autoLogoutTimeout,
    required super.enableNotifications,
    required super.lastUpdated,
  });

  // แปลง JSON เป็น Model
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: json['theme_mode'] ?? 'system',
      language: json['language'] ?? 'en',
      fontSize: (json['font_size'] ?? 1.0).toDouble(),
      rememberLogin: json['remember_login'] ?? false,
      autoLogoutTimeout: json['auto_logout_timeout'] ?? 30,
      enableNotifications: json['enable_notifications'] ?? true,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // แปลง Model เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode,
      'language': language,
      'font_size': fontSize,
      'remember_login': rememberLogin,
      'auto_logout_timeout': autoLogoutTimeout,
      'enable_notifications': enableNotifications,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // สร้าง default settings
  factory SettingsModel.defaultSettings() {
    return SettingsModel(
      themeMode: 'system',
      language: 'en',
      fontSize: 1.0,
      rememberLogin: false,
      autoLogoutTimeout: 30,
      enableNotifications: true,
      lastUpdated: DateTime.now(),
    );
  }

  // แปลง Entity เป็น Model
  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      themeMode: entity.themeMode,
      language: entity.language,
      fontSize: entity.fontSize,
      rememberLogin: entity.rememberLogin,
      autoLogoutTimeout: entity.autoLogoutTimeout,
      enableNotifications: entity.enableNotifications,
      lastUpdated: entity.lastUpdated,
    );
  }
}
