// Path: frontend/lib/features/search/presentation/bloc/search_event.dart
import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchSubmitted extends SearchEvent {
  final String query;

  SearchSubmitted(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {}
