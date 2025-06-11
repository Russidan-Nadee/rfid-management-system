// Path: frontend/lib/features/search/domain/usecases/ranking_calculator.dart
import '../entities/search_suggestion_entity.dart';

/// Service for calculating and ranking search suggestions
class RankingCalculator {
  /// Combine and rank suggestions from multiple sources
  List<SearchSuggestionEntity> combineAndRankSuggestions(
    Map<String, dynamic> results,
    String query,
    int limit,
  ) {
    final allSuggestions = <SearchSuggestionEntity>[];

    // Add suggestions from each source with priority boost
    for (final entry in results.entries) {
      final source = entry.key;
      final suggestions = entry.value as List<SearchSuggestionEntity>? ?? [];

      for (final suggestion in suggestions) {
        // Boost score based on source priority
        final boostScore = _getSourceBoost(source);
        final boostedSuggestion = suggestion.copyWith(
          score: (suggestion.score ?? 0.5) * boostScore,
        );

        allSuggestions.add(boostedSuggestion);
      }
    }

    // Remove duplicates
    final uniqueSuggestions = _removeDuplicates(allSuggestions);

    // Sort by comprehensive ranking
    final rankedSuggestions = rankSuggestions(uniqueSuggestions, query: query);

    return rankedSuggestions.take(limit).toList();
  }

  /// Rank suggestions using multiple criteria
  List<SearchSuggestionEntity> rankSuggestions(
    List<SearchSuggestionEntity> suggestions, {
    String? query,
  }) {
    // Calculate comprehensive scores
    final scoredSuggestions = suggestions.map((suggestion) {
      final comprehensiveScore = _calculateComprehensiveScore(
        suggestion,
        query,
      );
      return suggestion.copyWith(score: comprehensiveScore);
    }).toList();

    // Sort by score and other criteria
    scoredSuggestions.sort((a, b) {
      // Primary: Exact match priority
      if (query != null) {
        final aExact = a.value.toLowerCase() == query.toLowerCase() ? 1 : 0;
        final bExact = b.value.toLowerCase() == query.toLowerCase() ? 1 : 0;
        if (aExact != bExact) return bExact.compareTo(aExact);

        // Secondary: Starts with query priority
        final aStarts = a.value.toLowerCase().startsWith(query.toLowerCase())
            ? 1
            : 0;
        final bStarts = b.value.toLowerCase().startsWith(query.toLowerCase())
            ? 1
            : 0;
        if (aStarts != bStarts) return bStarts.compareTo(aStarts);
      }

      // Tertiary: Score priority
      final aScore = a.score ?? 0.0;
      final bScore = b.score ?? 0.0;
      if (aScore != bScore) return bScore.compareTo(aScore);

      // Quaternary: Type priority
      final aPriority = a.priority;
      final bPriority = b.priority;
      if (aPriority != bPriority) return aPriority.compareTo(bPriority);

      // Final: Frequency priority
      final aFreq = a.frequency ?? 0;
      final bFreq = b.frequency ?? 0;
      return bFreq.compareTo(aFreq);
    });

    return scoredSuggestions;
  }

  /// Calculate relevance score based on query similarity
  double calculateRelevanceScore(
    SearchSuggestionEntity suggestion,
    String query,
  ) {
    final suggestionValue = suggestion.value.toLowerCase();
    final queryLower = query.toLowerCase();

    // Exact match
    if (suggestionValue == queryLower) {
      return 1.0;
    }

    // Starts with query
    if (suggestionValue.startsWith(queryLower)) {
      return 0.9;
    }

    // Contains query
    if (suggestionValue.contains(queryLower)) {
      return 0.7;
    }

    // Word-based similarity
    final suggestionWords = suggestionValue.split(' ');
    final queryWords = queryLower.split(' ');

    int matchingWords = 0;
    for (final queryWord in queryWords) {
      if (suggestionWords.any((sw) => sw.contains(queryWord))) {
        matchingWords++;
      }
    }

    if (matchingWords > 0) {
      return 0.5 * (matchingWords / queryWords.length);
    }

    // Character-based similarity (Levenshtein-like)
    return _calculateCharacterSimilarity(suggestionValue, queryLower);
  }

  /// Calculate popularity score based on frequency and recency
  double calculatePopularityScore(SearchSuggestionEntity suggestion) {
    final frequency = suggestion.frequency ?? 0;

    // Base frequency score (logarithmic scale)
    double score = frequency > 0
        ? (1.0 + (frequency / 100.0)).clamp(0.0, 2.0)
        : 0.5;

    // Recency boost for recent searches
    if (suggestion.isFromHistory) {
      final lastSearched = suggestion.lastSearched;
      if (lastSearched != null) {
        final daysSinceSearch = DateTime.now().difference(lastSearched).inDays;
        if (daysSinceSearch <= 1) {
          score *= 1.3; // Recent boost
        } else if (daysSinceSearch <= 7) {
          score *= 1.1; // Week boost
        }
      }
    }

    // Popularity boost for trending searches
    if (suggestion.isPopular) {
      score *= 1.2;
    }

    return score.clamp(0.0, 2.0);
  }

  /// Calculate context score based on user behavior and current context
  double calculateContextScore(
    SearchSuggestionEntity suggestion,
    String? currentContext,
    List<String>? recentQueries,
  ) {
    double score = 1.0;

    // Context matching
    if (currentContext != null && suggestion.category != null) {
      if (suggestion.category!.toLowerCase().contains(
        currentContext.toLowerCase(),
      )) {
        score *= 1.2;
      }
    }

    // Recent query patterns
    if (recentQueries != null && recentQueries.isNotEmpty) {
      final recentEntityTypes = _extractEntityTypes(recentQueries);
      if (suggestion.entity != null &&
          recentEntityTypes.contains(suggestion.entity)) {
        score *= 1.15;
      }
    }

    // Asset-related priority (domain-specific)
    if (suggestion.isAssetRelated) {
      score *= 1.1;
    }

    return score;
  }

  /// Private helper methods

  double _getSourceBoost(String source) {
    switch (source) {
      case 'entity':
        return 1.2;
      case 'personalized':
        return 1.1;
      case 'recent':
        return 1.0;
      case 'popular':
        return 0.9;
      case 'contextual':
        return 1.15;
      default:
        return 1.0;
    }
  }

  double _calculateComprehensiveScore(
    SearchSuggestionEntity suggestion,
    String? query,
  ) {
    double score = suggestion.score ?? 0.5;

    // Relevance component (40% weight)
    if (query != null) {
      final relevanceScore = calculateRelevanceScore(suggestion, query);
      score = (score * 0.6) + (relevanceScore * 0.4);
    }

    // Popularity component (30% weight)
    final popularityScore = calculatePopularityScore(suggestion);
    score = (score * 0.7) + (popularityScore * 0.3);

    // Type priority component (20% weight)
    final typePriority = _getTypePriorityScore(suggestion.type);
    score = (score * 0.8) + (typePriority * 0.2);

    // Entity priority component (10% weight)
    final entityPriority = _getEntityPriorityScore(suggestion.entity);
    score = (score * 0.9) + (entityPriority * 0.1);

    return score.clamp(0.0, 2.0);
  }

  double _getTypePriorityScore(String type) {
    const typePriorities = <String, double>{
      'asset_no': 1.0,
      'serial_no': 0.9,
      'inventory_no': 0.85,
      'description': 0.8,
      'plant_code': 0.75,
      'location_code': 0.7,
      'username': 0.6,
      'recent': 0.65,
      'popular': 0.55,
    };

    return typePriorities[type] ?? 0.5;
  }

  double _getEntityPriorityScore(String? entity) {
    if (entity == null) return 0.5;

    const entityPriorities = <String, double>{
      'assets': 1.0,
      'plants': 0.8,
      'locations': 0.7,
      'users': 0.6,
      'history': 0.65,
      'popular': 0.55,
    };

    return entityPriorities[entity] ?? 0.5;
  }

  List<SearchSuggestionEntity> _removeDuplicates(
    List<SearchSuggestionEntity> suggestions,
  ) {
    final uniqueSuggestions = <String, SearchSuggestionEntity>{};

    for (final suggestion in suggestions) {
      final key = suggestion.value.toLowerCase();
      if (!uniqueSuggestions.containsKey(key) ||
          (uniqueSuggestions[key]!.score ?? 0) < (suggestion.score ?? 0)) {
        uniqueSuggestions[key] = suggestion;
      }
    }

    return uniqueSuggestions.values.toList();
  }

  double _calculateCharacterSimilarity(String str1, String str2) {
    if (str1.isEmpty || str2.isEmpty) return 0.0;

    final maxLength = [
      str1.length,
      str2.length,
    ].reduce((a, b) => a > b ? a : b);
    final distance = _levenshteinDistance(str1, str2);

    return (maxLength - distance) / maxLength;
  }

  int _levenshteinDistance(String str1, String str2) {
    final matrix = List.generate(
      str1.length + 1,
      (_) => List.filled(str2.length + 1, 0),
    );

    for (int i = 0; i <= str1.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= str2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= str1.length; i++) {
      for (int j = 1; j <= str2.length; j++) {
        final cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[str1.length][str2.length];
  }

  List<String> _extractEntityTypes(List<String> queries) {
    final entityTypes = <String>[];

    for (final query in queries) {
      if (_isAssetQuery(query)) {
        entityTypes.add('assets');
      } else if (_isLocationQuery(query)) {
        entityTypes.add('locations');
      } else if (_isUserQuery(query)) {
        entityTypes.add('users');
      }
    }

    return entityTypes.toSet().toList();
  }

  bool _isAssetQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('asset') ||
        lowerQuery.contains('equipment') ||
        RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(query.toUpperCase());
  }

  bool _isLocationQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('location') ||
        lowerQuery.contains('plant') ||
        RegExp(r'^[A-Z0-9]{2,8}$').hasMatch(query.toUpperCase());
  }

  bool _isUserQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('user') ||
        lowerQuery.contains('@') ||
        lowerQuery.contains('username');
  }
}

/// Ranking criteria weights
class RankingWeights {
  final double relevance;
  final double popularity;
  final double recency;
  final double context;
  final double type;

  const RankingWeights({
    this.relevance = 0.4,
    this.popularity = 0.3,
    this.recency = 0.15,
    this.context = 0.1,
    this.type = 0.05,
  });

  static const RankingWeights standard = RankingWeights();

  static const RankingWeights popularityFocused = RankingWeights(
    relevance: 0.3,
    popularity: 0.5,
    recency: 0.1,
    context: 0.05,
    type: 0.05,
  );

  static const RankingWeights recencyFocused = RankingWeights(
    relevance: 0.3,
    popularity: 0.2,
    recency: 0.4,
    context: 0.05,
    type: 0.05,
  );
}
