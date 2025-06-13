// Path: lib/di/scan_injection.dart
import '../features/scan/data/datasources/mock_rfid_datasource.dart';
import '../features/scan/data/repositories/scan_repository_impl.dart';
import '../features/scan/domain/repositories/scan_repository.dart';
import '../features/scan/domain/usecases/get_asset_details_usecase.dart';
import '../features/scan/domain/usecases/update_asset_status_usecase.dart';
import '../features/scan/domain/usecases/create_asset_usecase.dart';
import '../features/scan/domain/usecases/get_master_data_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/scan/presentation/bloc/scan_bloc.dart';
import '../features/scan/presentation/bloc/asset_creation_bloc.dart';
import '../core/services/api_service.dart';
import 'injection.dart';

/// Configure Scan feature dependencies
void configureScanDependencies() {
  // Data Sources
  getIt.registerLazySingleton<MockRfidDataSource>(() => MockRfidDataSource());

  // Repositories
  getIt.registerLazySingleton<ScanRepository>(() {
    return ScanRepositoryImpl(
      apiService: getIt<ApiService>(),
      mockRfidDataSource: getIt<MockRfidDataSource>(),
    );
  });

  // Use Cases
  getIt.registerLazySingleton<GetAssetDetailsUseCase>(
    () => GetAssetDetailsUseCase(getIt<ScanRepository>()),
  );

  getIt.registerLazySingleton<UpdateAssetStatusUseCase>(
    () => UpdateAssetStatusUseCase(getIt<ScanRepository>()),
  );

  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt()),
  );

  // New Use Cases for Asset Creation
  getIt.registerLazySingleton<CreateAssetUseCase>(
    () => CreateAssetUseCase(getIt<ScanRepository>()),
  );

  getIt.registerLazySingleton<GetMasterDataUseCase>(
    () => GetMasterDataUseCase(getIt<ScanRepository>()),
  );

  // BLoCs (Factory - new instance each time)
  getIt.registerFactory<ScanBloc>(() {
    return ScanBloc(
      scanRepository: getIt<ScanRepository>(),
      getAssetDetailsUseCase: getIt<GetAssetDetailsUseCase>(),
      updateAssetStatusUseCase: getIt<UpdateAssetStatusUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    );
  });

  // New BLoC for Asset Creation
  getIt.registerFactory<AssetCreationBloc>(() {
    return AssetCreationBloc(
      createAssetUseCase: getIt<CreateAssetUseCase>(),
      getMasterDataUseCase: getIt<GetMasterDataUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    );
  });
}

/// Debug Scan dependencies
void debugScanDependencies() {
  print('--- Scan Dependencies ---');
  print('MockRfidDataSource: ${getIt.isRegistered<MockRfidDataSource>()}');
  print('ScanRepository: ${getIt.isRegistered<ScanRepository>()}');
  print(
    'GetAssetDetailsUseCase: ${getIt.isRegistered<GetAssetDetailsUseCase>()}',
  );
  print(
    'UpdateAssetStatusUseCase: ${getIt.isRegistered<UpdateAssetStatusUseCase>()}',
  );
  print(
    'GetCurrentUserUseCase: ${getIt.isRegistered<GetCurrentUserUseCase>()}',
  );
  print('CreateAssetUseCase: ${getIt.isRegistered<CreateAssetUseCase>()}');
  print('GetMasterDataUseCase: ${getIt.isRegistered<GetMasterDataUseCase>()}');
  print('ScanBloc: ${getIt.isRegistered<ScanBloc>()}');
  print('AssetCreationBloc: ${getIt.isRegistered<AssetCreationBloc>()}');
}
