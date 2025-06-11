// Path: frontend/lib/features/search/presentation/bloc/search_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/entities/search_suggestion_entity.dart';
import '../../domain/entities/search_filter_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Search input and suggestions states
class SearchInputChanged extends SearchState {
  final String query;
  final List<SearchSuggestionEntity> suggestions;
  final bool isLoadingSuggestions;

  const SearchInputChanged({
    required this.query,
    this.suggestions = const [],
    this.isLoadingSuggestions = false,
  });

  @override
  List<Object?> get props => [query, suggestions, isLoadingSuggestions];
}

/// Search results states
class SearchLoading extends SearchState {
  final String query;
  final String message;

  const SearchLoading({required this.query, this.message = 'Searching...'});

  @override
  List<Object?> get props => [query, message];
}

class SearchSuccess extends SearchState {
  final String query;
  final List<SearchResultEntity> results;
  final List<SearchSuggestionEntity> suggestions;
  final SearchFilterEntity? activeFilters;
  final List<String> selectedEntities;
  final String sortOrder;
  final int currentPage;
  final int totalResults;
  final bool hasMorePages;
  final bool fromCache;

  const SearchSuccess({
    required this.query,
    required this.results,
    this.suggestions = const [],
    this.activeFilters,
    this.selectedEntities = const ['assets'],
    this.sortOrder = 'relevance',
    this.currentPage = 1,
    this.totalResults = 0,
    this.hasMorePages = false,
    this.fromCache = false,
  });

  SearchSuccess copyWith({
    String? query,
    List<SearchResultEntity>? results,
    List<SearchSuggestionEntity>? suggestions,
    SearchFilterEntity? activeFilters,
    List<String>? selectedEntities,
    String? sortOrder,
    int? currentPage,
    int? totalResults,
    bool? hasMorePages,
    bool? fromCache,
  }) {
    return SearchSuccess(
      query: query ?? this.query,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
      activeFilters: activeFilters ?? this.activeFilters,
      selectedEntities: selectedEntities ?? this.selectedEntities,
      sortOrder: sortOrder ?? this.sortOrder,
      currentPage: currentPage ?? this.currentPage,
      totalResults: totalResults ?? this.totalResults,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      fromCache: fromCache ?? this.fromCache,
    );
  }

  @override
  List<Object?> get props => [
    query,
    results,
    suggestions,
    activeFilters,
    selectedEntities,
    sortOrder,
    currentPage,
    totalResults,
    hasMorePages,
    fromCache,
  ];
}

class SearchEmpty extends SearchState {
  final String query;
  final List<String> suggestions;

  const SearchEmpty({required this.query, this.suggestions = const []});

  @override
  List<Object?> get props => [query, suggestions];
}

class SearchError extends SearchState {
  final String query;
  final String message;
  final List<SearchSuggestionEntity> suggestions;

  const SearchError({
    required this.query,
    required this.message,
    this.suggestions = const [],
  });

  @override
  List<Object?> get props => [query, message, suggestions];
}

/// History states
class SearchHistoryLoaded extends SearchState {
  final List<String> recentSearches;
  final List<String> popularSearches;

  const SearchHistoryLoaded({
    this.recentSearches = const [],
    this.popularSearches = const [],
  });

  @override
  List<Object?> get props => [recentSearches, popularSearches];
}
