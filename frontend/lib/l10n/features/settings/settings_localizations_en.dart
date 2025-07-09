// Path: frontend/lib/l10n/features/settings/settings_localizations_en.dart
import 'settings_localizations.dart';

/// English localization for Settings feature
class SettingsLocalizationsEn extends SettingsLocalizations {
  @override
  String get pageTitle => 'Settings';

  @override
  String get appName => 'Asset Management';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme'; // NEW

  @override
  String get about => 'About';

  @override
  String get appDescription => 'Asset Management System';

  // Theme Options - NEW
  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get themeSystem => 'System Default';

  // Theme Descriptions - NEW
  @override
  String get themeLightDescription => 'Use light theme';

  @override
  String get themeDarkDescription => 'Use dark theme';

  @override
  String get themeSystemDescription => 'Follow system settings';

  @override
  String get themeChanged => 'Theme updated';

  @override
  String get themeChangedToLight => 'Changed to light theme';

  @override
  String get themeChangedToDark => 'Changed to dark theme';

  @override
  String get themeChangedToSystem => 'Changed to system theme';

  @override
  String get version => 'Version';

  @override
  String get build => 'Build';

  @override
  String get platform => 'Platform';

  @override
  String get lastLogin => 'Last login';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoadingSettings => 'Failed to load settings';

  @override
  String get errorGeneric => 'An unexpected error occurred';
}
