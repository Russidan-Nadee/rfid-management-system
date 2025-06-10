// Path: frontend/lib/features/search/domain/usecases/get_suggestions_usecase.dart
import '../entities/search_suggestion_entity.dart';
import '../entities/search_history_entity.dart';
import '../repositories/search_repository.dart';

/// Use case for getting search suggestions and autocomplete functionality
/// Provides intelligent suggestions based on user input and behavior
class GetSuggestionsUseCase {
  final SearchRepository repository;

  // Configuration
  static const int _maxSuggestions = 10;
  static const int _defaultLimit = 5;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  GetSuggestionsUseCase(this.repository);

  /// Get comprehensive suggestions for search autocomplete
  ///
  /// Combines multiple suggestion sources:
  /// - Entity-based suggestions (assets, plants, locations, users)
  /// - Recent search history
  /// - Popular search terms
  /// - Personalized recommendations
  Future<SuggestionsResult> execute({
    required String query,
    String type = 'all',
    int limit = _defaultLimit,
    bool fuzzy = false,
    bool includeHistory = true,
    bool includePopular = true,
    String? userId,
  }) async {
    final startTime = DateTime.now();

    try {
      // Validate input
      final validation = _validateInput(query, limit);
      if (!validation.isValid) {
        return SuggestionsResult.invalid(validation.errorMessage!);
      }

      // Early return for very short queries
      if (query.length < 2 && type != 'recent' && type != 'popular') {
        return _getMinimalSuggestions(
          query,
          limit,
          includeHistory,
          includePopular,
        );
      }

      // Optimize query
      final optimizedQuery = _optimizeQuery(query);

      // Execute suggestions gathering concurrently
      final futures = <Future>[];
      final results = <String, dynamic>{};

      // 1. Get entity-based suggestions
      if (type == 'all' || _isEntityType(type)) {
        futures.add(
          _getEntitySuggestions(
            optimizedQuery,
            type,
            fuzzy,
          ).then((value) => results['entity'] = value),
        );
      }

      // 2. Get recent searches if enabled
      if (includeHistory && (type == 'all' || type == 'recent')) {
        futures.add(
          _getRecentSuggestions(
            optimizedQuery,
            userId,
          ).then((value) => results['recent'] = value),
        );
      }

      // 3. Get popular searches if enabled
      if (includePopular && (type == 'all' || type == 'popular')) {
        futures.add(
          _getPopularSuggestions(
            optimizedQuery,
          ).then((value) => results['popular'] = value),
        );
      }

      // 4. Get personalized suggestions if user context available
      if (userId != null && type == 'all') {
        futures.add(
          _getPersonalizedSuggestions(
            optimizedQuery,
            userId,
          ).then((value) => results['personalized'] = value),
        );
      }

      // Wait for all suggestions to complete
      await Future.wait(futures);

      // Combine and rank suggestions
      final combinedSuggestions = _combineAndRankSuggestions(
        results,
        optimizedQuery,
        limit,
      );

      // Group suggestions by category
      final groupedSuggestions = _groupSuggestions(combinedSuggestions);

      final duration = DateTime.now().difference(startTime);

      return SuggestionsResult.success(
        suggestions: combinedSuggestions,
        groups: groupedSuggestions,
        query: optimizedQuery,
        totalCount: combinedSuggestions.length,
        duration: duration,
        sources: results.keys.toList(),
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      return SuggestionsResult.failure(
        error: e.toString(),
        query: query,
        duration: duration,
      );
    }
  }

  /// Get suggestions for specific field types
  Future<SuggestionsResult> getFieldSuggestions({
    required String query,
    required String fieldType, // 'asset_no', 'description', 'serial_no', etc.
    int limit = _defaultLimit,
    bool fuzzy = false,
  }) async {
    try {
      final validation = _validateInput(query, limit);
      if (!validation.isValid) {
        return SuggestionsResult.invalid(validation.errorMessage!);
      }

      final result = await repository.getSuggestions(
        query,
        type: fieldType,
        limit: limit,
        fuzzy: fuzzy,
      );

      if (result.success && result.data != null) {
        return SuggestionsResult.success(
          suggestions: result.data!,
          groups: [SuggestionGroup.assets(result.data!)],
          query: query,
          totalCount: result.data!.length,
          sources: [fieldType],
        );
      } else {
        return SuggestionsResult.failure(
          error: result.error ?? 'Failed to get field suggestions',
          query: query,
        );
      }
    } catch (e) {
      return SuggestionsResult.failure(error: e.toString(), query: query);
    }
  }

  /// Get smart suggestions based on context
  Future<SuggestionsResult> getContextualSuggestions({
    required String query,
    required SearchContext context,
    int limit = _defaultLimit,
    String? userId,
  }) async {
    try {
      final suggestions = <SearchSuggestionEntity>[];

      switch (context.type) {
        case SearchContextType.assetManagement:
          suggestions.addAll(
            await _getAssetManagementSuggestions(query, context),
          );
          break;
        case SearchContextType.maintenance:
          suggestions.addAll(await _getMaintenanceSuggestions(query, context));
          break;
        case SearchContextType.inventory:
          suggestions.addAll(await _getInventorySuggestions(query, context));
          break;
        case SearchContextType.reporting:
          suggestions.addAll(await _getReportingSuggestions(query, context));
          break;
      }

      // Limit and rank results
      suggestions.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      final limitedSuggestions = suggestions.take(limit).toList();

      return SuggestionsResult.success(
        suggestions: limitedSuggestions,
        groups: _groupSuggestions(limitedSuggestions),
        query: query,
        totalCount: limitedSuggestions.length,
        sources: ['contextual'],
      );
    } catch (e) {
      return SuggestionsResult.failure(error: e.toString(), query: query);
    }
  }

  /// Get trending/hot suggestions
  Future<List<SearchSuggestionEntity>> getTrendingSuggestions({
    int limit = 5,
    String period = 'day',
  }) async {
    try {
      final popular = await repository.getPopularSearches(limit: limit * 2);

      return popular
          .map(
            (query) => SearchSuggestionEntity.popular(
              query: query,
              searchCount: null, // Would be populated from analytics
            ),
          )
          .take(limit)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Debounced suggestions for real-time typing
  Future<SuggestionsResult> getDebouncedSuggestions({
    required String query,
    int limit = _defaultLimit,
    String? userId,
  }) async {
    // Simulate debounce delay
    await Future.delayed(_debounceDelay);

    return execute(query: query, limit: limit, userId: userId);
  }

  /// Check if query needs suggestions
  bool shouldShowSuggestions(String query) {
    return query.isNotEmpty && query.length <= 50;
  }

  /// Private helper methods

  /// Get entity-based suggestions
  Future<List<SearchSuggestionEntity>> _getEntitySuggestions(
    String query,
    String type,
    bool fuzzy,
  ) async {
    try {
      final result = await repository.getSuggestions(
        query,
        type: type,
        limit: _maxSuggestions,
        fuzzy: fuzzy,
      );

      if (result.success && result.data != null) {
        return result.data!;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get recent search suggestions
  Future<List<SearchSuggestionEntity>> _getRecentSuggestions(
    String query,
    String? userId,
  ) async {
    try {
      final recent = await repository.getRecentSearches(limit: 10);

      return recent
          .where(
            (recentQuery) =>
                recentQuery.toLowerCase().contains(query.toLowerCase()),
          )
          .map(
            (recentQuery) => SearchSuggestionEntity.recent(
              query: recentQuery,
              lastSearched: DateTime.now(), // Would be actual timestamp
            ),
          )
          .take(3)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get popular search suggestions
  Future<List<SearchSuggestionEntity>> _getPopularSuggestions(
    String query,
  ) async {
    try {
      final popular = await repository.getPopularSearches(limit: 10);

      return popular
          .where(
            (popularQuery) =>
                popularQuery.toLowerCase().contains(query.toLowerCase()),
          )
          .map(
            (popularQuery) =>
                SearchSuggestionEntity.popular(query: popularQuery),
          )
          .take(3)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get personalized suggestions
  Future<List<SearchSuggestionEntity>> _getPersonalizedSuggestions(
    String query,
    String userId,
  ) async {
    try {
      return await repository.getPersonalizedSuggestions(userId, limit: 5);
    } catch (e) {
      return [];
    }
  }

  /// Get minimal suggestions for short queries
  Future<SuggestionsResult> _getMinimalSuggestions(
    String query,
    int limit,
    bool includeHistory,
    bool includePopular,
  ) async {
    final suggestions = <SearchSuggestionEntity>[];

    if (includeHistory) {
      final recent = await _getRecentSuggestions(query, null);
      suggestions.addAll(recent);
    }

    if (includePopular) {
      final popular = await _getPopularSuggestions(query);
      suggestions.addAll(popular);
    }

    final limitedSuggestions = suggestions.take(limit).toList();

    return SuggestionsResult.success(
      suggestions: limitedSuggestions,
      groups: _groupSuggestions(limitedSuggestions),
      query: query,
      totalCount: limitedSuggestions.length,
      sources: ['minimal'],
    );
  }

  /// Combine and rank suggestions from multiple sources
  List<SearchSuggestionEntity> _combineAndRankSuggestions(
    Map<String, dynamic> results,
    String query,
    int limit,
  ) {
    final allSuggestions = <SearchSuggestionEntity>[];

    // Add suggestions from each source with priority
    for (final entry in results.entries) {
      final source = entry.key;
      final suggestions = entry.value as List<SearchSuggestionEntity>? ?? [];

      for (final suggestion in suggestions) {
        // Boost score based on source priority
        double boostScore = 1.0;
        switch (source) {
          case 'entity':
            boostScore = 1.2;
            break;
          case 'personalized':
            boostScore = 1.1;
            break;
          case 'recent':
            boostScore = 1.0;
            break;
          case 'popular':
            boostScore = 0.9;
            break;
        }

        final boostedSuggestion = suggestion.copyWith(
          score: (suggestion.score ?? 0.5) * boostScore,
        );

        allSuggestions.add(boostedSuggestion);
      }
    }

    // Remove duplicates
    final uniqueSuggestions = <String, SearchSuggestionEntity>{};
    for (final suggestion in allSuggestions) {
      final key = suggestion.value.toLowerCase();
      if (!uniqueSuggestions.containsKey(key) ||
          (uniqueSuggestions[key]!.score ?? 0) < (suggestion.score ?? 0)) {
        uniqueSuggestions[key] = suggestion;
      }
    }

    // Sort by relevance and take limit
    final sortedSuggestions = uniqueSuggestions.values.toList();
    sortedSuggestions.sort((a, b) {
      // Exact match priority
      final aExact = a.value.toLowerCase() == query.toLowerCase() ? 1 : 0;
      final bExact = b.value.toLowerCase() == query.toLowerCase() ? 1 : 0;
      if (aExact != bExact) return bExact.compareTo(aExact);

      // Starts with priority
      final aStarts = a.value.toLowerCase().startsWith(query.toLowerCase())
          ? 1
          : 0;
      final bStarts = b.value.toLowerCase().startsWith(query.toLowerCase())
          ? 1
          : 0;
      if (aStarts != bStarts) return bStarts.compareTo(aStarts);

      // Score priority
      final aScore = a.score ?? 0.0;
      final bScore = b.score ?? 0.0;
      if (aScore != bScore) return bScore.compareTo(aScore);

      // Type priority
      return a.priority.compareTo(b.priority);
    });

    return sortedSuggestions.take(limit).toList();
  }

  /// Group suggestions by category
  List<SuggestionGroup> _groupSuggestions(
    List<SearchSuggestionEntity> suggestions,
  ) {
    final groups = <SuggestionGroup>[];

    // Group by category
    final groupedMap = <String, List<SearchSuggestionEntity>>{};
    for (final suggestion in suggestions) {
      final category = suggestion.category ?? 'other';
      groupedMap[category] = (groupedMap[category] ?? [])..add(suggestion);
    }

    // Create groups with proper titles
    for (final entry in groupedMap.entries) {
      final category = entry.key;
      final categoryList = entry.value;

      if (categoryList.isNotEmpty) {
        switch (category) {
          case 'assets':
            groups.add(SuggestionGroup.assets(categoryList));
            break;
          case 'locations':
          case 'master_data':
            groups.add(SuggestionGroup.locations(categoryList));
            break;
          case 'history':
            groups.add(SuggestionGroup.recent(categoryList));
            break;
          case 'popular':
            groups.add(SuggestionGroup.popular(categoryList));
            break;
          default:
            groups.add(
              SuggestionGroup(
                title: _getCategoryTitle(category),
                category: category,
                suggestions: categoryList,
              ),
            );
        }
      }
    }

    return groups;
  }

  /// Context-specific suggestion methods
  Future<List<SearchSuggestionEntity>> _getAssetManagementSuggestions(
    String query,
    SearchContext context,
  ) async {
    // Implementation for asset management context
    return [];
  }

  Future<List<SearchSuggestionEntity>> _getMaintenanceSuggestions(
    String query,
    SearchContext context,
  ) async {
    // Implementation for maintenance context
    return [];
  }

  Future<List<SearchSuggestionEntity>> _getInventorySuggestions(
    String query,
    SearchContext context,
  ) async {
    // Implementation for inventory context
    return [];
  }

  Future<List<SearchSuggestionEntity>> _getReportingSuggestions(
    String query,
    SearchContext context,
  ) async {
    // Implementation for reporting context
    return [];
  }

  /// Utility methods
  ValidationResult _validateInput(String query, int limit) {
    if (limit < 1 || limit > _maxSuggestions) {
      return ValidationResult.invalid(
        'Limit must be between 1 and $_maxSuggestions',
      );
    }

    if (query.length > 100) {
      return ValidationResult.invalid('Query too long (max 100 characters)');
    }

    return ValidationResult.valid();
  }

  String _optimizeQuery(String query) {
    return query.trim().toLowerCase();
  }

  bool _isEntityType(String type) {
    return [
      'asset_no',
      'description',
      'serial_no',
      'inventory_no',
      'plant_code',
      'location_code',
      'username',
    ].contains(type);
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'assets':
        return 'Assets';
      case 'master_data':
        return 'Master Data';
      case 'history':
        return 'Recent Searches';
      case 'popular':
        return 'Popular Searches';
      case 'users':
        return 'Users';
      default:
        return category
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }
}

/// Result wrapper for suggestions operations
class SuggestionsResult {
  final bool success;
  final List<SearchSuggestionEntity>? suggestions;
  final List<SuggestionGroup>? groups;
  final String query;
  final int? totalCount;
  final Duration? duration;
  final List<String>? sources;
  final String? error;

  const SuggestionsResult({
    required this.success,
    this.suggestions,
    this.groups,
    required this.query,
    this.totalCount,
    this.duration,
    this.sources,
    this.error,
  });

  factory SuggestionsResult.success({
    required List<SearchSuggestionEntity> suggestions,
    required List<SuggestionGroup> groups,
    required String query,
    required int totalCount,
    Duration? duration,
    List<String>? sources,
  }) {
    return SuggestionsResult(
      success: true,
      suggestions: suggestions,
      groups: groups,
      query: query,
      totalCount: totalCount,
      duration: duration,
      sources: sources,
    );
  }

  factory SuggestionsResult.failure({
    required String error,
    required String query,
    Duration? duration,
  }) {
    return SuggestionsResult(
      success: false,
      query: query,
      error: error,
      duration: duration,
    );
  }

  factory SuggestionsResult.invalid(String error) {
    return SuggestionsResult(success: false, query: '', error: error);
  }

  bool get hasSuggestions =>
      success && suggestions != null && suggestions!.isNotEmpty;
  bool get isEmpty => success && (suggestions == null || suggestions!.isEmpty);
  bool get hasError => !success || error != null;
  bool get hasGroups => groups != null && groups!.isNotEmpty;
  bool get isFast => duration != null && duration!.inMilliseconds < 100;
}

/// Search context for contextual suggestions
class SearchContext {
  final SearchContextType type;
  final Map<String, dynamic> parameters;
  final String? currentLocation;
  final String? currentPlant;
  final List<String>? recentAssets;

  const SearchContext({
    required this.type,
    this.parameters = const {},
    this.currentLocation,
    this.currentPlant,
    this.recentAssets,
  });
}

/// Search context types
enum SearchContextType { assetManagement, maintenance, inventory, reporting }

/// Validation result helper (reused from instant search)
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}
