// Path: frontend/lib/di/scan_injection.dart
import '../features/scan/data/datasources/mock_rfid_datasource.dart';
import '../features/scan/data/repositories/scan_repository_impl.dart';
import '../features/scan/domain/repositories/scan_repository.dart';
import '../features/scan/domain/usecases/get_asset_details_usecase.dart';
import '../features/scan/presentation/bloc/scan_bloc.dart';
import 'injection.dart';

/// Configure Scan feature dependencies
void configureScanDependencies() {
  // Data Sources
  getIt.registerLazySingleton<MockRfidDataSource>(() => MockRfidDataSource());

  // Repositories
  getIt.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(
      apiService: getIt(),
      mockRfidDataSource: getIt<MockRfidDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetAssetDetailsUseCase>(
    () => GetAssetDetailsUseCase(getIt<ScanRepository>()),
  );

  // BLoCs (Factory - new instance each time)
  getIt.registerFactory<ScanBloc>(
    () => ScanBloc(
      scanRepository: getIt<ScanRepository>(),
      getAssetDetailsUseCase: getIt<GetAssetDetailsUseCase>(),
    ),
  );
}

/// Debug Scan dependencies
void debugScanDependencies() {
  print('--- Scan Dependencies ---');
  print('MockRfidDataSource: ${getIt.isRegistered<MockRfidDataSource>()}');
  print('ScanRepository: ${getIt.isRegistered<ScanRepository>()}');
  print(
    'GetAssetDetailsUseCase: ${getIt.isRegistered<GetAssetDetailsUseCase>()}',
  );
  print('ScanBloc: ${getIt.isRegistered<ScanBloc>()}');
}
