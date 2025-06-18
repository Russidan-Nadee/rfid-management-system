// Path: frontend/lib/di/search_injection.dart
import 'package:get_it/get_it.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';

// Domain
import '../features/search/domain/usecases/instant_search_handler.dart';
import '../features/search/domain/usecases/global_search_handler.dart';
import '../features/search/domain/usecases/suggestion_builder.dart';
import '../features/search/domain/usecases/history_manager.dart';
import '../features/search/domain/usecases/query_validator.dart';
import '../features/search/domain/usecases/ranking_calculator.dart';
import '../features/search/domain/repositories/search_repository.dart';

// Data
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/search/data/repositories/search_cache_strategy.dart';
import '../features/search/data/datasources/remote/search_remote_datasource_impl.dart';
import '../features/search/data/datasources/cache/search_cache_datasource_impl.dart';
import '../features/search/data/contracts/search_datasource_contracts.dart';

// Presentation
import '../features/search/presentation/bloc/search_bloc.dart';

final getIt = GetIt.instance;

void configureSearchDependencies() {
  // Data Sources
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<SearchCacheDataSource>(
    () => SearchCacheDataSourceImpl(getIt<StorageService>()),
  );

  // Cache Strategy
  getIt.registerLazySingleton<SearchCacheStrategy>(
    () => SearchCacheStrategy(getIt<SearchCacheDataSource>()),
  );

  // Repository
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: getIt<SearchRemoteDataSource>(),
      cacheDataSource: getIt<SearchCacheDataSource>(),
      cacheStrategy: getIt<SearchCacheStrategy>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<QueryValidator>(() => QueryValidator());

  getIt.registerLazySingleton<RankingCalculator>(() => RankingCalculator());

  getIt.registerLazySingleton<InstantSearchHandler>(
    () => InstantSearchHandler(getIt<SearchRepository>()),
  );

  getIt.registerLazySingleton<GlobalSearchHandler>(
    () =>
        GlobalSearchHandler(getIt<SearchRepository>(), getIt<QueryValidator>()),
  );

  getIt.registerLazySingleton<SuggestionBuilder>(
    () => SuggestionBuilder(
      getIt<SearchRepository>(),
      getIt<RankingCalculator>(),
    ),
  );

  getIt.registerLazySingleton<HistoryManager>(
    () => HistoryManager(getIt<SearchRepository>()),
  );

  // BLoC
  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(
      instantSearchHandler: getIt<InstantSearchHandler>(),
      searchRepository: getIt<SearchRepository>(),
    ),
  );
}
