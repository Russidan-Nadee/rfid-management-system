// Path: frontend/lib/di/settings_injection.dart
import 'package:frontend/features/setting/data/datasources/settings_local_datasource.dart';
import 'package:frontend/features/setting/data/repositories/settings_repository_impl.dart';
import 'package:frontend/features/setting/domain/repositories/settings_repository.dart';
import 'package:frontend/features/setting/domain/usecases/get_settings_usecase.dart';
import 'package:frontend/features/setting/domain/usecases/update_settings_usecase.dart';
import 'package:frontend/features/setting/presentation/bloc/settings_bloc.dart';
import 'injection.dart';

/// Configure Settings feature dependencies
void configureSettingsDependencies() {
  // Data Layer
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: getIt<SettingsLocalDataSource>(),
    ),
  );

  // Domain Layer - Use Cases
  getIt.registerLazySingleton<GetSettingsUseCase>(
    () => GetSettingsUseCase(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton<UpdateSettingsUseCase>(
    () => UpdateSettingsUseCase(getIt<SettingsRepository>()),
  );

  // Presentation Layer - BLoCs (Factory - new instance each time)
  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      getSettingsUseCase: getIt<GetSettingsUseCase>(),
      updateSettingsUseCase: getIt<UpdateSettingsUseCase>(),
    ),
  );
}
