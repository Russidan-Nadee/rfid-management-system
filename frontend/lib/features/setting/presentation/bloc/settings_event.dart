// Path: frontend/lib/features/settings/presentation/bloc/settings_event.dart
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateTheme extends SettingsEvent {
  final String themeMode;

  const UpdateTheme(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateLanguage extends SettingsEvent {
  final String language;

  const UpdateLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class UpdateRememberLogin extends SettingsEvent {
  final bool remember;

  const UpdateRememberLogin(this.remember);

  @override
  List<Object?> get props => [remember];
}

class UpdateAutoLogout extends SettingsEvent {
  final int minutes;

  const UpdateAutoLogout(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class ResetSettings extends SettingsEvent {
  const ResetSettings();
}
