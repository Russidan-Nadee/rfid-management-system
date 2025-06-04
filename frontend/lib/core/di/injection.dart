// import 'package:get_it/get_it.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// import '../../features/auth/data/datasources/auth_remote_datasource.dart';
// import '../../features/auth/data/repositories/auth_repository_impl.dart';
// import '../../features/auth/domain/repositories/auth_repository.dart';
// import '../../features/auth/domain/usecases/login_usecase.dart';
// import '../../features/auth/domain/usecases/logout_usecase.dart';
// import '../../features/auth/presentation/bloc/auth_bloc.dart';

// // Global GetIt instance
// final getIt = GetIt.instance;

// /// Initialize all dependencies
// Future<void> configureDependencies() async {
//   // Core Services - Singletons (single instance throughout app)
//   getIt.registerSingleton<StorageService>(StorageService());
//   getIt.registerSingleton<ApiService>(ApiService());

//   // Initialize storage service
//   await getIt<StorageService>().init();

//   // Auth Feature Dependencies
//   _configureAuthDependencies();
// }

// /// Configure Auth feature dependencies
// void _configureAuthDependencies() {
//   // Data Layer
//   getIt.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(getIt<ApiService>()),
//   );

//   getIt.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       remoteDataSource: getIt<AuthRemoteDataSource>(),
//       storageService: getIt<StorageService>(),
//     ),
//   );

//   // Domain Layer - Use Cases
//   getIt.registerLazySingleton<LoginUseCase>(
//     () => LoginUseCase(getIt<AuthRepository>()),
//   );

//   getIt.registerLazySingleton<LogoutUseCase>(
//     () => LogoutUseCase(getIt<AuthRepository>()),
//   );

//   // Presentation Layer - Blocs (Factory - new instance each time)
//   getIt.registerFactory<AuthBloc>(
//     () => AuthBloc(
//       loginUseCase: getIt<LoginUseCase>(),
//       logoutUseCase: getIt<LogoutUseCase>(),
//     ),
//   );
// }

// /// Configure additional features (call this when adding new features)
// void _configureDashboardDependencies() {
//   // TODO: Add dashboard dependencies when implementing dashboard feature
// }

// void _configureAssetDependencies() {
//   // TODO: Add asset management dependencies when implementing asset feature
// }

// /// Reset all dependencies (useful for testing)
// void resetDependencies() {
//   getIt.reset();
// }

// /// Check if dependencies are registered (for debugging)
// void debugDependencies() {
//   print('=== Registered Dependencies ===');
//   print('StorageService: ${getIt.isRegistered<StorageService>()}');
//   print('ApiService: ${getIt.isRegistered<ApiService>()}');
//   print('AuthRepository: ${getIt.isRegistered<AuthRepository>()}');
//   print('LoginUseCase: ${getIt.isRegistered<LoginUseCase>()}');
//   print('LogoutUseCase: ${getIt.isRegistered<LogoutUseCase>()}');
//   print('AuthBloc: ${getIt.isRegistered<AuthBloc>()}');
//   print('==============================');
// }

// /// Dispose resources when app is closed
// void disposeDependencies() {
//   // Dispose API service
//   if (getIt.isRegistered<ApiService>()) {
//     getIt<ApiService>().dispose();
//   }

//   // Reset all dependencies
//   getIt.reset();
// }
