// Path: frontend/lib/features/settings/presentation/bloc/settings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_settings_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;

  SettingsBloc({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
  }) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateTheme>(_onUpdateTheme);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateRememberLogin>(_onUpdateRememberLogin);
    on<UpdateAutoLogout>(_onUpdateAutoLogout);
    on<ResetSettings>(_onResetSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    try {
      final settings = await getSettingsUseCase.execute();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to load settings: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTheme(
    UpdateTheme event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      emit(SettingsUpdating(currentSettings, 'theme'));

      try {
        await updateSettingsUseCase.updateTheme(event.themeMode);
        final updatedSettings = await getSettingsUseCase.execute();
        emit(SettingsUpdated(updatedSettings, 'Theme updated successfully'));
        emit(SettingsLoaded(updatedSettings));
      } catch (e) {
        emit(SettingsError('Failed to update theme: ${e.toString()}'));
        emit(SettingsLoaded(currentSettings));
      }
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      emit(SettingsUpdating(currentSettings, 'language'));

      try {
        await updateSettingsUseCase.updateLanguage(event.language);
        final updatedSettings = await getSettingsUseCase.execute();
        emit(SettingsUpdated(updatedSettings, 'Language updated successfully'));
        emit(SettingsLoaded(updatedSettings));
      } catch (e) {
        emit(SettingsError('Failed to update language: ${e.toString()}'));
        emit(SettingsLoaded(currentSettings));
      }
    }
  }

  Future<void> _onUpdateRememberLogin(
    UpdateRememberLogin event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        await updateSettingsUseCase.updateRememberLogin(event.remember);
        final updatedSettings = await getSettingsUseCase.execute();
        emit(SettingsLoaded(updatedSettings));
      } catch (e) {
        emit(SettingsError('Failed to update remember login: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateAutoLogout(
    UpdateAutoLogout event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        await updateSettingsUseCase.updateAutoLogout(event.minutes);
        final updatedSettings = await getSettingsUseCase.execute();
        emit(SettingsLoaded(updatedSettings));
      } catch (e) {
        emit(SettingsError('Failed to update auto logout: ${e.toString()}'));
      }
    }
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    try {
      await updateSettingsUseCase.resetToDefaults();
      final settings = await getSettingsUseCase.execute();
      emit(SettingsUpdated(settings, 'Settings reset to defaults'));
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to reset settings: ${e.toString()}'));
    }
  }
}
