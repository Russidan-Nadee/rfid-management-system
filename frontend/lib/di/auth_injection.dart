// Path: frontend/lib/di/auth_injection.dart
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'injection.dart';

/// Configure Auth feature dependencies
void configureAuthDependencies() {
  // Data Layer
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      storageService: getIt(),
    ),
  );

  // Domain Layer - Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  // Presentation Layer - Blocs (Factory - new instance each time)
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
}

/// Debug Auth dependencies
void debugAuthDependencies() {
  print('--- Auth Dependencies ---');
  print('AuthRepository: ${getIt.isRegistered<AuthRepository>()}');
  print('LoginUseCase: ${getIt.isRegistered<LoginUseCase>()}');
  print('LogoutUseCase: ${getIt.isRegistered<LogoutUseCase>()}');
  print('AuthBloc: ${getIt.isRegistered<AuthBloc>()}');
}
