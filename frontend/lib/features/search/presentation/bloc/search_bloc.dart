// Path: frontend/lib/features/search/presentation/bloc/search_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/instant_search_handler.dart';
import '../../domain/repositories/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final InstantSearchHandler instantSearchHandler;
  final SearchRepository searchRepository;

  Timer? _debounceTimer;

  SearchBloc({
    required this.instantSearchHandler,
    required this.searchRepository,
  }) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<ClearSearch>(_onClearSearch);
  }

  // Handle พิมพ์ search (มี debounce)
  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    // ถ้าว่างเปล่า ให้กลับไป initial
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // ถ้าสั้นเกินไป ไม่ search
    if (query.length < 2) {
      return;
    }

    // Debounce การพิมพ์
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(SearchSubmitted(query));
    });
  }

  // Handle submit search (ค้นหาจริง)
  Future<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty || query.length < 2) {
      emit(SearchInitial());
      return;
    }

    // แสดง loading
    emit(SearchLoading(query));

    try {
      print('🔍 Searching for: "$query"');

      // เรียก domain layer ที่เชื่อมต่อกับ backend
      final result = await instantSearchHandler.search(
        query,
        entities: ['assets', 'plants', 'locations'], // ค้นหาทุก type
        limit: 10,
      );

      print(
        '📊 Search result: success=${result.success}, totalResults=${result.totalResults}',
      );

      if (result.success && result.hasData) {
        final results = result.data!;

        if (results.isEmpty) {
          emit(SearchEmpty(query));
        } else {
          emit(
            SearchSuccess(
              results: results,
              query: query,
              totalResults: result.totalResults,
              fromCache: result.fromCache,
            ),
          );
        }
      } else {
        emit(
          SearchError(message: result.error ?? 'Search failed', query: query),
        );
      }
    } catch (e) {
      print('💥 Search error: $e');
      emit(
        SearchError(message: 'Failed to search: ${e.toString()}', query: query),
      );
    }
  }

  // Clear search
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
