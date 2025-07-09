// Path: frontend/lib/l10n/features/settings/settings_localizations.dart
import 'package:flutter/material.dart';
import 'settings_localizations_en.dart';
import 'settings_localizations_th.dart';
import 'settings_localizations_ja.dart';

/// Abstract base class for Settings localization
/// กำหนด Contract/Interface สำหรับ Settings feature
abstract class SettingsLocalizations {
  /// Get the appropriate localization instance based on current locale
  static SettingsLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return SettingsLocalizationsTh();
      case 'ja':
        return SettingsLocalizationsJa();
      case 'en':
      default:
        return SettingsLocalizationsEn();
    }
  }

  // Page Title
  String get pageTitle;

  // Sections
  String get about;

  // App Info Labels
  String get version;
  String get build;
  String get platform;

  // User Profile
  String get lastLogin;

  // Actions
  String get logout;
  String get cancel;
  String get retry;

  // Dialog Messages
  String get logoutConfirmTitle;
  String get logoutConfirmMessage;

  // Loading States
  String get loading;

  // Error Messages
  String get errorLoadingSettings;
  String get errorGeneric;
}
