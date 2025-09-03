// Path: frontend/lib/di/scan_injection.dart
import 'package:tp_rfid/features/scan/data/datasources/mock_rfid_datasource.dart';
import '../features/scan/data/repositories/scan_repository_impl.dart';
import '../features/scan/domain/repositories/scan_repository.dart';
import '../features/scan/domain/usecases/get_asset_details_usecase.dart';
import '../features/scan/domain/usecases/update_asset_status_usecase.dart';
import '../features/scan/domain/usecases/create_asset_usecase.dart';
import '../features/scan/domain/usecases/get_master_data_usecase.dart';
import '../features/scan/domain/usecases/get_assets_by_location_usecase.dart';
import '../features/scan/domain/usecases/get_asset_images_usecase.dart';
import '../features/scan/domain/usecases/upload_image_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/scan/presentation/bloc/scan_bloc.dart';
import '../features/scan/presentation/bloc/asset_creation_bloc.dart';
import '../features/scan/presentation/bloc/image_upload_bloc.dart';
import '../core/services/api_service.dart';
import 'injection.dart';

/// Configure Scan feature dependencies
void configureScanDependencies() {
  // Data Sources
  getIt.registerLazySingleton<RfidDataSource>(() => RfidDataSource());

  // Repositories
  getIt.registerLazySingleton<ScanRepository>(() {
    return ScanRepositoryImpl(
      apiService: getIt<ApiService>(),
      rfidDataSource: getIt<RfidDataSource>(),
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

  // Assets by location use case
  getIt.registerLazySingleton<GetAssetsByLocationUseCase>(
    () => GetAssetsByLocationUseCase(getIt<ScanRepository>()),
  );

  // Asset Images Use Case
  getIt.registerLazySingleton<GetAssetImagesUseCase>(
    () => GetAssetImagesUseCase(getIt<ScanRepository>()),
  );

  // Upload Image Use Case
  getIt.registerLazySingleton<UploadImageUseCase>(
    () => UploadImageUseCase(getIt<ScanRepository>()),
  );

  // BLoCs (Factory - new instance each time)
  getIt.registerFactory<ScanBloc>(() {
    return ScanBloc(
      scanRepository: getIt<ScanRepository>(),
      getAssetDetailsUseCase: getIt<GetAssetDetailsUseCase>(),
      updateAssetStatusUseCase: getIt<UpdateAssetStatusUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      getAssetsByLocationUseCase: getIt<GetAssetsByLocationUseCase>(),
      getAssetImagesUseCase: getIt<GetAssetImagesUseCase>(),
    );
  });

  // Asset Creation BLoC
  getIt.registerFactory<AssetCreationBloc>(() {
    return AssetCreationBloc(
      createAssetUseCase: getIt<CreateAssetUseCase>(),
      getMasterDataUseCase: getIt<GetMasterDataUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    );
  });

  //Image Upload BLoC
  getIt.registerFactory<ImageUploadBloc>(() {
    return ImageUploadBloc(uploadImageUseCase: getIt<UploadImageUseCase>());
  });
}
