// Path: frontend/lib/features/search/domain/entities/search_suggestion_entity.dart
import 'package:equatable/equatable.dart';

/// Search suggestion entity for autocomplete functionality
class SearchSuggestionEntity extends Equatable {
  final String value;
  final String type;
  final String label;
  final String? entity;
  final double? score;
  final int? frequency;
  final String? category;
  final Map<String, dynamic>? metadata;

  const SearchSuggestionEntity({
    required this.value,
    required this.type,
    required this.label,
    this.entity,
    this.score,
    this.frequency,
    this.category,
    this.metadata,
  });

  /// Factory constructors for different suggestion types
  factory SearchSuggestionEntity.asset({
    required String value,
    required String type,
    String? description,
    double? score,
    int? frequency,
  }) {
    return SearchSuggestionEntity(
      value: value,
      type: type,
      label: description != null ? '$value - $description' : value,
      entity: 'assets',
      score: score,
      frequency: frequency,
      category: 'assets',
    );
  }

  factory SearchSuggestionEntity.plant({
    required String plantCode,
    String? description,
    double? score,
  }) {
    return SearchSuggestionEntity(
      value: plantCode,
      type: 'plant_code',
      label: description != null ? '$plantCode - $description' : plantCode,
      entity: 'plants',
      score: score,
      category: 'master_data',
    );
  }

  factory SearchSuggestionEntity.location({
    required String locationCode,
    String? description,
    String? plantCode,
    double? score,
  }) {
    String label = locationCode;
    if (description != null) label += ' - $description';
    if (plantCode != null) label += ' ($plantCode)';

    return SearchSuggestionEntity(
      value: locationCode,
      type: 'location_code',
      label: label,
      entity: 'locations',
      score: score,
      category: 'master_data',
      metadata: {
        if (description != null) 'description': description,
        if (plantCode != null) 'plant_code': plantCode,
      },
    );
  }

  factory SearchSuggestionEntity.user({
    required String username,
    String? fullName,
    String? role,
    double? score,
  }) {
    return SearchSuggestionEntity(
      value: username,
      type: 'username',
      label: fullName != null ? '$fullName ($username)' : username,
      entity: 'users',
      score: score,
      category: 'users',
      metadata: {
        if (fullName != null) 'full_name': fullName,
        if (role != null) 'role': role,
      },
    );
  }

  factory SearchSuggestionEntity.recent({
    required String query,
    DateTime? lastSearched,
    int? searchCount,
  }) {
    return SearchSuggestionEntity(
      value: query,
      type: 'recent',
      label: query,
      entity: 'history',
      frequency: searchCount,
      category: 'history',
      metadata: {
        if (lastSearched != null)
          'last_searched': lastSearched.toIso8601String(),
        'source': 'user_history',
      },
    );
  }

  factory SearchSuggestionEntity.popular({
    required String query,
    int? searchCount,
    double? avgResults,
  }) {
    return SearchSuggestionEntity(
      value: query,
      type: 'popular',
      label: query,
      entity: 'trending',
      frequency: searchCount,
      category: 'popular',
      metadata: {
        if (avgResults != null) 'avg_results': avgResults,
        'source': 'popular_searches',
      },
    );
  }

  /// Business logic methods

  /// Get display text for UI
  String get displayText => label.isNotEmpty ? label : value;

  /// Get suggestion icon based on type
  String get icon {
    switch (type.toLowerCase()) {
      case 'asset_no':
      case 'asset':
        return '📦';
      case 'description':
        return '📝';
      case 'serial_no':
      case 'serial':
        return '🏷️';
      case 'inventory_no':
      case 'inventory':
        return '📋';
      case 'plant_code':
      case 'plant':
        return '🏭';
      case 'location_code':
      case 'location':
        return '📍';
      case 'username':
      case 'user':
        return '👤';
      case 'popular':
        return '🔥';
      case 'recent':
        return '🕐';
      default:
        return '🔍';
    }
  }

  /// Get suggestion color based on category
  String get color {
    switch (category?.toLowerCase()) {
      case 'assets':
        return '#2563EB'; // Blue
      case 'master_data':
        return '#059669'; // Green
      case 'users':
        return '#7C3AED'; // Purple
      case 'history':
        return '#6B7280'; // Gray
      case 'popular':
        return '#DC2626'; // Red
      default:
        return '#6B7280'; // Gray
    }
  }

  /// Get priority for sorting suggestions
  int get priority {
    switch (type.toLowerCase()) {
      case 'asset_no':
      case 'asset':
        return 1;
      case 'serial_no':
      case 'serial':
        return 2;
      case 'inventory_no':
      case 'inventory':
        return 3;
      case 'description':
        return 4;
      case 'plant_code':
      case 'plant':
        return 5;
      case 'location_code':
      case 'location':
        return 6;
      case 'username':
      case 'user':
        return 7;
      case 'recent':
        return 8;
      case 'popular':
        return 9;
      default:
        return 10;
    }
  }

  /// Check if suggestion is from search history
  bool get isFromHistory =>
      type.toLowerCase() == 'recent' || category == 'history';

  /// Check if suggestion is popular search
  bool get isPopular =>
      type.toLowerCase() == 'popular' || category == 'popular';

  /// Check if suggestion is asset-related
  bool get isAssetRelated {
    final lowerType = type.toLowerCase();
    return lowerType.contains('asset') ||
        lowerType == 'serial_no' ||
        lowerType == 'inventory_no' ||
        lowerType == 'description' ||
        entity == 'assets';
  }

  /// Check if suggestion is location-related
  bool get isLocationRelated {
    final lowerType = type.toLowerCase();
    return lowerType.contains('location') ||
        lowerType.contains('plant') ||
        entity == 'locations' ||
        entity == 'plants';
  }

  /// Check if suggestion is user-related
  bool get isUserRelated {
    return type.toLowerCase().contains('user') ||
        type == 'username' ||
        entity == 'users';
  }

  /// Get relevance score for ranking
  double get relevanceScore {
    if (score != null) return score!;

    // Calculate based on frequency and priority
    final frequencyScore = frequency != null
        ? (frequency! / 100.0).clamp(0.0, 1.0)
        : 0.5;
    final priorityScore = (10 - priority) / 10.0;

    return (frequencyScore + priorityScore) / 2.0;
  }

  /// Check if suggestion matches query
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return value.toLowerCase().contains(lowerQuery) ||
        label.toLowerCase().contains(lowerQuery);
  }

  /// Check if suggestion starts with query (for prefix matching)
  bool startsWithQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return value.toLowerCase().startsWith(lowerQuery) ||
        label.toLowerCase().startsWith(lowerQuery);
  }

  /// Get type display name
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'asset_no':
        return 'Asset Number';
      case 'description':
        return 'Description';
      case 'serial_no':
        return 'Serial Number';
      case 'inventory_no':
        return 'Inventory Number';
      case 'plant_code':
        return 'Plant Code';
      case 'location_code':
        return 'Location Code';
      case 'username':
        return 'Username';
      case 'recent':
        return 'Recent Search';
      case 'popular':
        return 'Popular Search';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get metadata value safely
  T? getMetadata<T>(String key) {
    if (metadata == null) return null;
    final value = metadata![key];
    return value is T ? value : null;
  }

  /// Get last searched date for recent suggestions
  DateTime? get lastSearched {
    final lastSearchedStr = getMetadata<String>('last_searched');
    return lastSearchedStr != null ? DateTime.tryParse(lastSearchedStr) : null;
  }

  /// Get description from metadata
  String? get description => getMetadata<String>('description');

  /// Get plant code from metadata
  String? get plantCode => getMetadata<String>('plant_code');

  /// Get full name from metadata
  String? get fullName => getMetadata<String>('full_name');

  /// Get role from metadata
  String? get role => getMetadata<String>('role');

  /// Create copy with updated fields
  SearchSuggestionEntity copyWith({
    String? value,
    String? type,
    String? label,
    String? entity,
    double? score,
    int? frequency,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return SearchSuggestionEntity(
      value: value ?? this.value,
      type: type ?? this.type,
      label: label ?? this.label,
      entity: entity ?? this.entity,
      score: score ?? this.score,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Create suggestion with updated score
  SearchSuggestionEntity withScore(double newScore) {
    return copyWith(score: newScore);
  }

  /// Create suggestion with updated frequency
  SearchSuggestionEntity withFrequency(int newFrequency) {
    return copyWith(frequency: newFrequency);
  }

  @override
  List<Object?> get props => [
    value,
    type,
    label,
    entity,
    score,
    frequency,
    category,
    metadata,
  ];

  @override
  String toString() {
    return 'SearchSuggestionEntity(value: $value, type: $type, score: $score, priority: $priority)';
  }
}

/// Suggestion group for organizing suggestions by category
class SuggestionGroup extends Equatable {
  final String title;
  final String category;
  final List<SearchSuggestionEntity> suggestions;
  final String? icon;
  final int maxItems;

  const SuggestionGroup({
    required this.title,
    required this.category,
    required this.suggestions,
    this.icon,
    this.maxItems = 5,
  });

  factory SuggestionGroup.assets(List<SearchSuggestionEntity> suggestions) {
    return SuggestionGroup(
      title: 'Assets',
      category: 'assets',
      suggestions: suggestions.where((s) => s.isAssetRelated).toList(),
      icon: '📦',
    );
  }

  factory SuggestionGroup.locations(List<SearchSuggestionEntity> suggestions) {
    return SuggestionGroup(
      title: 'Locations & Plants',
      category: 'locations',
      suggestions: suggestions.where((s) => s.isLocationRelated).toList(),
      icon: '📍',
    );
  }

  factory SuggestionGroup.recent(List<SearchSuggestionEntity> suggestions) {
    return SuggestionGroup(
      title: 'Recent Searches',
      category: 'recent',
      suggestions: suggestions.where((s) => s.isFromHistory).toList(),
      icon: '🕐',
    );
  }

  factory SuggestionGroup.popular(List<SearchSuggestionEntity> suggestions) {
    return SuggestionGroup(
      title: 'Popular Searches',
      category: 'popular',
      suggestions: suggestions.where((s) => s.isPopular).toList(),
      icon: '🔥',
    );
  }

  /// Get limited suggestions for display
  List<SearchSuggestionEntity> get displaySuggestions {
    return suggestions.take(maxItems).toList();
  }

  /// Check if group has suggestions
  bool get hasSuggestions => suggestions.isNotEmpty;

  /// Get suggestion count
  int get count => suggestions.length;

  /// Get truncated count
  int get displayCount => displaySuggestions.length;

  /// Check if there are more suggestions than displayed
  bool get hasMore => count > maxItems;

  /// Get "and X more" text
  String get moreText {
    final moreCount = count - maxItems;
    return moreCount > 0 ? 'and $moreCount more' : '';
  }

  @override
  List<Object?> get props => [title, category, suggestions, icon, maxItems];

  @override
  String toString() {
    return 'SuggestionGroup(title: $title, count: $count)';
  }
}
