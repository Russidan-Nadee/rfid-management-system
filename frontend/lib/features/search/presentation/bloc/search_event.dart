// Path: frontend/lib/features/search/presentation/bloc/search_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/search_filter_entity.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Instant search events
class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

/// Suggestion events
class LoadSuggestions extends SearchEvent {
  final String query;

  const LoadSuggestions(this.query);

  @override
  List<Object?> get props => [query];
}

class SuggestionSelected extends SearchEvent {
  final String suggestion;

  const SuggestionSelected(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

/// Global search events
class PerformSearch extends SearchEvent {
  final String query;
  final List<String> entities;
  final int page;
  final String sort;
  final SearchFilterEntity? filters;

  const PerformSearch(
    this.query, {
    this.entities = const ['assets'],
    this.page = 1,
    this.sort = 'relevance',
    this.filters,
  });

  @override
  List<Object?> get props => [query, entities, page, sort, filters];
}

class LoadMoreResults extends SearchEvent {
  const LoadMoreResults();
}

/// Filter events
class UpdateFilters extends SearchEvent {
  final SearchFilterEntity filters;

  const UpdateFilters(this.filters);

  @override
  List<Object?> get props => [filters];
}

class ClearFilters extends SearchEvent {
  const ClearFilters();
}

/// History events
class LoadSearchHistory extends SearchEvent {
  const LoadSearchHistory();
}

class ClearSearchHistory extends SearchEvent {
  const ClearSearchHistory();
}

/// Entity selection events
class SelectEntity extends SearchEvent {
  final List<String> entities;

  const SelectEntity(this.entities);

  @override
  List<Object?> get props => [entities];
}

/// Sort events
class ChangeSortOrder extends SearchEvent {
  final String sort;

  const ChangeSortOrder(this.sort);

  @override
  List<Object?> get props => [sort];
}
