// Path: frontend/lib/di/search_injection.dart
import 'package:frontend/features/search/data/contracts/search_datasource_contracts.dart';
import '../features/search/data/datasources/cache/search_cache_datasource_impl.dart';
import '../features/search/data/datasources/remote/search_remote_datasource_impl.dart';
import '../features/search/data/repositories/search_cache_strategy.dart';
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/search/domain/repositories/search_repository.dart';
import '../features/search/domain/usecases/instant_search_handler.dart';
import '../features/search/domain/usecases/global_search_handler.dart';
import '../features/search/domain/usecases/suggestion_builder.dart';
import '../features/search/domain/usecases/query_validator.dart';
import '../features/search/domain/usecases/ranking_calculator.dart';
import '../features/search/domain/usecases/history_manager.dart';
import '../features/search/domain/usecases/result_processor.dart';
import '../features/search/presentation/bloc/search_bloc.dart';
import 'injection.dart';

/// Configure Search feature dependencies
void configureSearchDependencies() {
  // Data Sources (register by interface)
  getIt.registerLazySingleton<SearchCacheDataSource>(
    () => SearchCacheDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(getIt()),
  );

  // Cache Strategy
  getIt.registerLazySingleton(() => SearchCacheStrategy(getIt()));

  // Repository
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: getIt<SearchRemoteDataSource>(),
      cacheDataSource: getIt<SearchCacheDataSource>(),
      cacheStrategy: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => QueryValidator());
  getIt.registerLazySingleton(() => RankingCalculator());
  getIt.registerLazySingleton(() => ResultProcessor());

  getIt.registerLazySingleton(() => InstantSearchHandler(getIt()));
  getIt.registerLazySingleton(() => GlobalSearchHandler(getIt(), getIt()));
  getIt.registerLazySingleton(() => SuggestionBuilder(getIt(), getIt()));
  getIt.registerLazySingleton(() => HistoryManager(getIt()));

  // BLoC (Factory - new instance each time)
  getIt.registerFactory(
    () => SearchBloc(
      repository: getIt<SearchRepository>(),
      instantSearchHandler: getIt<InstantSearchHandler>(),
      globalSearchHandler: getIt<GlobalSearchHandler>(),
      suggestionBuilder: getIt<SuggestionBuilder>(),
      historyManager: getIt<HistoryManager>(),
      resultProcessor: getIt<ResultProcessor>(),
    ),
  );
}

/// Debug Search dependencies
void debugSearchDependencies() {
  print('--- Search Dependencies ---');
  print('SearchRepository: ${getIt.isRegistered<SearchRepository>()}');
  print('InstantSearchHandler: ${getIt.isRegistered<InstantSearchHandler>()}');
  print('GlobalSearchHandler: ${getIt.isRegistered<GlobalSearchHandler>()}');
  print('SuggestionBuilder: ${getIt.isRegistered<SuggestionBuilder>()}');
  print('SearchBloc: ${getIt.isRegistered<SearchBloc>()}');
}
