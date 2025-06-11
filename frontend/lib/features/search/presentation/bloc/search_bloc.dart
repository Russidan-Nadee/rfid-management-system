// Path: frontend/lib/features/search/presentation/bloc/search_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/instant_search_handler.dart';
import '../../domain/usecases/global_search_handler.dart';
import '../../domain/usecases/suggestion_builder.dart';
import '../../domain/usecases/history_manager.dart';
import '../../domain/usecases/result_processor.dart';
import '../../domain/entities/search_filter_entity.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;
  final InstantSearchHandler instantSearchHandler;
  final GlobalSearchHandler globalSearchHandler;
  final SuggestionBuilder suggestionBuilder;
  final HistoryManager historyManager;
  final ResultProcessor resultProcessor;

  // Current search context
  String _currentQuery = '';
  List<String> _selectedEntities = ['assets'];
  String _sortOrder = 'relevance';
  SearchFilterEntity _activeFilters = SearchFilterEntity.empty();
  Timer? _debounceTimer;

  SearchBloc({
    required this.repository,
    required this.instantSearchHandler,
    required this.globalSearchHandler,
    required this.suggestionBuilder,
    required this.historyManager,
    required this.resultProcessor,
  }) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ClearSearch>(_onClearSearch);
    on<LoadSuggestions>(_onLoadSuggestions);
    on<SuggestionSelected>(_onSuggestionSelected);
    on<PerformSearch>(_onPerformSearch);
    on<LoadMoreResults>(_onLoadMoreResults);
    on<UpdateFilters>(_onUpdateFilters);
    on<ClearFilters>(_onClearFilters);
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<ClearSearchHistory>(_onClearSearchHistory);
    on<SelectEntity>(_onSelectEntity);
    on<ChangeSortOrder>(_onChangeSortOrder);
  }

  /// Handle query change with debouncing
  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // Show loading state
    emit(SearchInputChanged(query: event.query, isLoadingSuggestions: true));

    // Debounce suggestions
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      add(LoadSuggestions(event.query));
    });
  }

  /// Load suggestions for query
  Future<void> _onLoadSuggestions(
    LoadSuggestions event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final suggestions = await suggestionBuilder.buildSuggestions(
        event.query,
        entities: _selectedEntities,
        limit: 8,
      );

      emit(
        SearchInputChanged(
          query: event.query,
          suggestions: suggestions,
          isLoadingSuggestions: false,
        ),
      );
    } catch (e) {
      emit(
        SearchInputChanged(
          query: event.query,
          suggestions: [],
          isLoadingSuggestions: false,
        ),
      );
    }
  }

  /// Handle suggestion selection
  Future<void> _onSuggestionSelected(
    SuggestionSelected event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.suggestion;
    add(PerformSearch(event.suggestion));
  }

  /// Perform full search
  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.query;
    _selectedEntities = event.entities;
    _sortOrder = event.sort;
    if (event.filters != null) {
      _activeFilters = event.filters!;
    }

    emit(SearchLoading(query: event.query));

    try {
      final result = await globalSearchHandler.search(
        event.query,
        entities: event.entities,
        page: event.page,
        sort: event.sort,
        filters: event.filters,
      );

      if (result.success && result.hasData) {
        // Process results
        final processedResults = resultProcessor.processResults(
          result.data!,
          event.query,
          enableHighlighting: true,
        );

        // Save to history
        await historyManager.saveSearch(
          query: event.query,
          searchType: 'global',
          entities: event.entities,
          resultsCount: result.totalResults,
          wasSuccessful: true,
          filters: event.filters,
        );

        emit(
          SearchSuccess(
            query: event.query,
            results: processedResults,
            selectedEntities: event.entities,
            sortOrder: event.sort,
            activeFilters: event.filters,
            currentPage: event.page,
            totalResults: result.totalResults,
            hasMorePages: result.meta?.pagination?.hasNextPage ?? false,
            fromCache: result.fromCache,
          ),
        );
      } else if (result.success && result.totalResults == 0) {
        emit(SearchEmpty(query: event.query));
      } else {
        emit(
          SearchError(
            query: event.query,
            message: result.error ?? 'Search failed',
          ),
        );
      }
    } catch (e) {
      emit(
        SearchError(
          query: event.query,
          message: 'Search error: ${e.toString()}',
        ),
      );
    }
  }

  /// Load more results for pagination
  Future<void> _onLoadMoreResults(
    LoadMoreResults event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchSuccess || !currentState.hasMorePages) {
      return;
    }

    try {
      final nextPage = currentState.currentPage + 1;
      final result = await globalSearchHandler.search(
        currentState.query,
        entities: currentState.selectedEntities,
        page: nextPage,
        sort: currentState.sortOrder,
        filters: currentState.activeFilters,
      );

      if (result.success && result.hasData) {
        final processedResults = resultProcessor.processResults(
          result.data!,
          currentState.query,
          enableHighlighting: true,
        );

        emit(
          currentState.copyWith(
            results: [...currentState.results, ...processedResults],
            currentPage: nextPage,
            hasMorePages: result.meta?.pagination?.hasNextPage ?? false,
          ),
        );
      }
    } catch (e) {
      // Handle error silently for load more
    }
  }

  /// Update search filters
  Future<void> _onUpdateFilters(
    UpdateFilters event,
    Emitter<SearchState> emit,
  ) async {
    _activeFilters = event.filters;

    if (_currentQuery.isNotEmpty) {
      add(
        PerformSearch(
          _currentQuery,
          entities: _selectedEntities,
          sort: _sortOrder,
          filters: event.filters,
        ),
      );
    }
  }

  /// Clear all filters
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<SearchState> emit,
  ) async {
    _activeFilters = SearchFilterEntity.empty();

    if (_currentQuery.isNotEmpty) {
      add(
        PerformSearch(
          _currentQuery,
          entities: _selectedEntities,
          sort: _sortOrder,
          filters: null,
        ),
      );
    }
  }

  /// Clear search
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = '';
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  /// Load search history
  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final recentSearches = await repository.getRecentSearches(limit: 10);
      final popularSearches = await repository.getPopularSearches(limit: 10);

      emit(
        SearchHistoryLoaded(
          recentSearches: recentSearches,
          popularSearches: popularSearches,
        ),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear search history
  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await repository.clearSearchHistory();
      emit(const SearchHistoryLoaded());
    } catch (e) {
      // Handle error silently
    }
  }

  /// Select entity types
  Future<void> _onSelectEntity(
    SelectEntity event,
    Emitter<SearchState> emit,
  ) async {
    _selectedEntities = event.entities;

    if (_currentQuery.isNotEmpty) {
      add(
        PerformSearch(
          _currentQuery,
          entities: event.entities,
          sort: _sortOrder,
          filters: _activeFilters,
        ),
      );
    }
  }

  /// Change sort order
  Future<void> _onChangeSortOrder(
    ChangeSortOrder event,
    Emitter<SearchState> emit,
  ) async {
    _sortOrder = event.sort;

    if (_currentQuery.isNotEmpty) {
      add(
        PerformSearch(
          _currentQuery,
          entities: _selectedEntities,
          sort: event.sort,
          filters: _activeFilters,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    instantSearchHandler.dispose();
    globalSearchHandler.dispose();
    suggestionBuilder.dispose();
    historyManager.dispose();
    resultProcessor.dispose();
    return super.close();
  }
}
