// Path: frontend/lib/di/export_injection.dart
import '../core/services/api_service.dart';
import '../features/export/data/datasources/export_remote_datasource.dart';
import '../features/export/data/repositories/export_repository_impl.dart';
import '../features/export/domain/repositories/export_repository.dart';
import '../features/export/domain/usecases/create_export_job_usecase.dart';
import '../features/export/domain/usecases/get_export_status_usecase.dart';
import '../features/export/domain/usecases/download_export_usecase.dart';
import '../features/export/domain/usecases/get_export_history_usecase.dart';
import '../features/export/domain/usecases/cancel_export_usecase.dart';
import '../features/export/presentation/bloc/export_bloc.dart';
import 'injection.dart';

/// Configure Export feature dependencies
void configureExportDependencies() {
  // Data Layer
  getIt.registerLazySingleton<ExportRemoteDataSource>(
    () => ExportRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<ExportRepository>(
    () =>
        ExportRepositoryImpl(remoteDataSource: getIt<ExportRemoteDataSource>()),
  );

  // Domain Layer - Use Cases
  getIt.registerLazySingleton<CreateExportJobUseCase>(
    () => CreateExportJobUseCase(getIt<ExportRepository>()),
  );

  getIt.registerLazySingleton<GetExportStatusUseCase>(
    () => GetExportStatusUseCase(getIt<ExportRepository>()),
  );

  getIt.registerLazySingleton<DownloadExportUseCase>(
    () => DownloadExportUseCase(getIt<ExportRepository>()),
  );

  getIt.registerLazySingleton<GetExportHistoryUseCase>(
    () => GetExportHistoryUseCase(getIt<ExportRepository>()),
  );

  getIt.registerLazySingleton<CancelExportUseCase>(
    () => CancelExportUseCase(getIt<ExportRepository>()),
  );

  // Presentation Layer - BLoCs (Factory - new instance each time)
  getIt.registerFactory<ExportBloc>(
    () => ExportBloc(
      createExportJobUseCase: getIt<CreateExportJobUseCase>(),
      getExportStatusUseCase: getIt<GetExportStatusUseCase>(),
      downloadExportUseCase: getIt<DownloadExportUseCase>(),
      getExportHistoryUseCase: getIt<GetExportHistoryUseCase>(),
      cancelExportUseCase: getIt<CancelExportUseCase>(),
    ),
  );
}
