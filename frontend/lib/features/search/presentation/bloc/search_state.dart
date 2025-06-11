// Path: frontend/lib/features/search/presentation/bloc/search_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result_entity.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final String query;

  SearchLoading(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchSuccess extends SearchState {
  final List<SearchResultEntity> results;
  final String query;
  final int totalResults;
  final bool fromCache;

  SearchSuccess({
    required this.results,
    required this.query,
    required this.totalResults,
    this.fromCache = false,
  });

  @override
  List<Object?> get props => [results, query, totalResults, fromCache];
}

class SearchEmpty extends SearchState {
  final String query;

  SearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  final String query;

  SearchError({required this.message, required this.query});

  @override
  List<Object?> get props => [message, query];
}
