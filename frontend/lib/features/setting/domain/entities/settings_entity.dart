// Path: frontend/lib/features/settings/domain/entities/settings_entity.dart
import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final String themeMode; // 'light', 'dark', 'system'
  final String language; // 'en', 'th'
  final double fontSize; // 1.0 = normal, 1.2 = large, 0.8 = small
  final bool rememberLogin;
  final int autoLogoutTimeout; // minutes
  final bool enableNotifications;
  final DateTime lastUpdated;

  const SettingsEntity({
    required this.themeMode,
    required this.language,
    required this.fontSize,
    required this.rememberLogin,
    required this.autoLogoutTimeout,
    required this.enableNotifications,
    required this.lastUpdated,
  });

  // Factory constructor สำหรับ default settings
  factory SettingsEntity.defaultSettings() {
    return SettingsEntity(
      themeMode: 'system', // ใช้ system theme เป็น default
      language: 'en', // ใช้ภาษาอังกฤษเป็น default
      fontSize: 1.0, // ขนาดฟอนต์ปกติ
      rememberLogin: false, // ไม่จำ login เป็น default เพื่อความปลอดภัย
      autoLogoutTimeout: 30, // logout อัตโนมัติหลัง 30 นาที
      enableNotifications: true, // เปิด notifications เป็น default
      lastUpdated: DateTime.now(),
    );
  }

  // Getter สำหรับตรวจสอบ theme mode
  bool get isLightTheme => themeMode == 'light';
  bool get isDarkTheme => themeMode == 'dark';
  bool get isSystemTheme => themeMode == 'system';

  // Getter สำหรับตรวจสอบภาษา
  bool get isEnglish => language == 'en';
  bool get isThai => language == 'th';

  // Getter สำหรับ font size label
  String get fontSizeLabel {
    if (fontSize <= 0.9) return 'Small';
    if (fontSize >= 1.1) return 'Large';
    return 'Normal';
  }

  // Getter สำหรับ auto logout label
  String get autoLogoutLabel {
    if (autoLogoutTimeout <= 0) return 'Never';
    if (autoLogoutTimeout < 60) return '${autoLogoutTimeout} minutes';
    final hours = (autoLogoutTimeout / 60).floor();
    final minutes = autoLogoutTimeout % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  // Copy with method สำหรับ immutable updates
  SettingsEntity copyWith({
    String? themeMode,
    String? language,
    double? fontSize,
    bool? rememberLogin,
    int? autoLogoutTimeout,
    bool? enableNotifications,
    DateTime? lastUpdated,
  }) {
    return SettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      rememberLogin: rememberLogin ?? this.rememberLogin,
      autoLogoutTimeout: autoLogoutTimeout ?? this.autoLogoutTimeout,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  // Validation methods
  bool isValidThemeMode() {
    return ['light', 'dark', 'system'].contains(themeMode);
  }

  bool isValidLanguage() {
    return ['en', 'th'].contains(language);
  }

  bool isValidFontSize() {
    return fontSize >= 0.5 && fontSize <= 2.0;
  }

  bool isValidAutoLogoutTimeout() {
    return autoLogoutTimeout >= 0 &&
        autoLogoutTimeout <= 1440; // สูงสุด 24 ชั่วโมง
  }

  // Validate all settings
  bool isValid() {
    return isValidThemeMode() &&
        isValidLanguage() &&
        isValidFontSize() &&
        isValidAutoLogoutTimeout();
  }

  @override
  List<Object?> get props => [
    themeMode,
    language,
    fontSize,
    rememberLogin,
    autoLogoutTimeout,
    enableNotifications,
    lastUpdated,
  ];

  @override
  String toString() {
    return 'SettingsEntity(themeMode: $themeMode, language: $language, fontSize: $fontSize, rememberLogin: $rememberLogin, autoLogoutTimeout: $autoLogoutTimeout, enableNotifications: $enableNotifications)';
  }
}
