// Path: frontend/lib/di/scan_injection.dart
import '../features/scan/data/datasources/mock_rfid_datasource.dart';
import '../features/scan/data/repositories/scan_repository_impl.dart';
import '../features/scan/domain/repositories/scan_repository.dart';
import '../features/scan/domain/usecases/get_asset_details_usecase.dart';
import '../features/scan/domain/usecases/update_asset_status_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/scan/presentation/bloc/scan_bloc.dart';
import '../core/services/api_service.dart';
import 'injection.dart';

/// Configure Scan feature dependencies
void configureScanDependencies() {
  print('=== Configuring Scan Dependencies ===');

  // เช็คว่า ApiService มีหรือไม่
  print('ApiService registered: ${getIt.isRegistered<ApiService>()}');

  // Data Sources
  if (!getIt.isRegistered<MockRfidDataSource>()) {
    getIt.registerLazySingleton<MockRfidDataSource>(() {
      print('Creating MockRfidDataSource');
      return MockRfidDataSource();
    });
  }

  // Repositories
  if (!getIt.isRegistered<ScanRepository>()) {
    getIt.registerLazySingleton<ScanRepository>(() {
      print('Creating ScanRepository');
      final apiService = getIt<ApiService>();
      final mockRfidDataSource = getIt<MockRfidDataSource>();
      print('ApiService: $apiService');
      print('MockRfidDataSource: $mockRfidDataSource');

      return ScanRepositoryImpl(
        apiService: apiService,
        mockRfidDataSource: mockRfidDataSource,
      );
    });
  }

  // Use Cases
  if (!getIt.isRegistered<GetAssetDetailsUseCase>()) {
    getIt.registerLazySingleton<GetAssetDetailsUseCase>(() {
      print('Creating GetAssetDetailsUseCase');
      return GetAssetDetailsUseCase(getIt<ScanRepository>());
    });
  }

  if (!getIt.isRegistered<UpdateAssetStatusUseCase>()) {
    getIt.registerLazySingleton<UpdateAssetStatusUseCase>(() {
      print('Creating UpdateAssetStatusUseCase');
      final repository = getIt<ScanRepository>();
      print('Repository for UseCase: $repository');
      return UpdateAssetStatusUseCase(repository);
    });
  }

  if (!getIt.isRegistered<GetCurrentUserUseCase>()) {
    getIt.registerLazySingleton<GetCurrentUserUseCase>(() {
      print('Creating GetCurrentUserUseCase');
      return GetCurrentUserUseCase(getIt());
    });
  }

  // BLoCs (Factory - new instance each time)
  if (!getIt.isRegistered<ScanBloc>()) {
    getIt.registerFactory<ScanBloc>(() {
      print('Creating ScanBloc');
      return ScanBloc(
        scanRepository: getIt<ScanRepository>(),
        getAssetDetailsUseCase: getIt<GetAssetDetailsUseCase>(),
        updateAssetStatusUseCase: getIt<UpdateAssetStatusUseCase>(),
        getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      );
    });
  }

  print('=== Scan Dependencies Configured ===');

  // Test dependencies
  print('Testing dependencies...');
  try {
    final testUseCase = getIt<UpdateAssetStatusUseCase>();
    print('UpdateAssetStatusUseCase resolved: $testUseCase');
  } catch (e) {
    print('Failed to resolve UpdateAssetStatusUseCase: $e');
  }
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
  print('ScanBloc: ${getIt.isRegistered<ScanBloc>()}');
}
