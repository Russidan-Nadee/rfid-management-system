// Path: frontend/lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_th.dart';
import 'app_localizations_ja.dart';

/// Abstract base class for main app localization
abstract class AppLocalizations {
  /// Get the appropriate localization instance based on current locale
  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return AppLocalizationsTh();
      case 'ja':
        return AppLocalizationsJa();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  // Navigation Labels
  String get scan;
  String get dashboard;
  String get search;
  String get reports;
  String get export;
  String get admin;
  String get settings;

  // App Info
  String get appName;
}
