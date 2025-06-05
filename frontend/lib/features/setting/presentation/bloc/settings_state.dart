// Path: frontend/lib/features/settings/presentation/bloc/settings_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final SettingsEntity settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsUpdating extends SettingsState {
  final SettingsEntity settings;
  final String updatingField; // 'theme', 'language', etc.

  const SettingsUpdating(this.settings, this.updatingField);

  @override
  List<Object?> get props => [settings, updatingField];
}

class SettingsUpdated extends SettingsState {
  final SettingsEntity settings;
  final String message;

  const SettingsUpdated(this.settings, this.message);

  @override
  List<Object?> get props => [settings, message];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
