// Path: frontend/lib/features/search/data/models/search_suggestion_model.dart
import 'package:equatable/equatable.dart';

/// Search suggestion model for autocomplete functionality
class SearchSuggestionModel extends Equatable {
  final String value;
  final String type;
  final String label;
  final String? entity;
  final double? score;
  final int? frequency;
  final String? category;
  final Map<String, dynamic>? metadata;

  const SearchSuggestionModel({
    required this.value,
    required this.type,
    required this.label,
    this.entity,
    this.score,
    this.frequency,
    this.category,
    this.metadata,
  });

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      value: json['value']?.toString() ?? '',
      type: json['type'] ?? 'all',
      label: json['label'] ?? json['value']?.toString() ?? '',
      entity: json['entity'],
      score: json['score']?.toDouble() ?? json['relevance']?.toDouble(),
      frequency: json['frequency']?.toInt() ?? json['count']?.toInt(),
      category: json['category'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type,
      'label': label,
      if (entity != null) 'entity': entity,
      if (score != null) 'score': score,
      if (frequency != null) 'frequency': frequency,
      if (category != null) 'category': category,
      if (metadata != null) 'metadata': metadata,
    };
  }

  SearchSuggestionModel copyWith({
    String? value,
    String? type,
    String? label,
    String? entity,
    double? score,
    int? frequency,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return SearchSuggestionModel(
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

  /// Get display text for the suggestion
  String get displayText => label.isNotEmpty ? label : value;

  /// Get suggestion type icon
  String get typeIcon {
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

  /// Get suggestion priority for sorting
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
      case 'popular':
        return 8;
      case 'recent':
        return 9;
      default:
        return 10;
    }
  }

  /// Check if suggestion is from search history
  bool get isFromHistory => type.toLowerCase() == 'recent';

  /// Check if suggestion is popular search
  bool get isPopular => type.toLowerCase() == 'popular';

  /// Check if suggestion is asset-related
  bool get isAssetRelated {
    final lowerType = type.toLowerCase();
    return lowerType.contains('asset') ||
        lowerType == 'serial_no' ||
        lowerType == 'inventory_no' ||
        lowerType == 'description';
  }

  /// Check if suggestion is location-related
  bool get isLocationRelated {
    final lowerType = type.toLowerCase();
    return lowerType.contains('location') || lowerType.contains('plant');
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
    return 'SearchSuggestionModel(value: $value, type: $type, score: $score)';
  }
}

/// Specialized suggestion models for different contexts
class AssetSuggestionModel extends SearchSuggestionModel {
  const AssetSuggestionModel({
    required super.value,
    required super.type,
    required super.label,
    super.score,
    super.frequency,
    super.metadata,
  }) : super(entity: 'assets');

  factory AssetSuggestionModel.fromAssetNo(
    String assetNo, {
    String? description,
  }) {
    return AssetSuggestionModel(
      value: assetNo,
      type: 'asset_no',
      label: description != null ? '$assetNo - $description' : assetNo,
    );
  }

  factory AssetSuggestionModel.fromDescription(
    String description, {
    String? assetNo,
  }) {
    return AssetSuggestionModel(
      value: description,
      type: 'description',
      label: assetNo != null ? '$description ($assetNo)' : description,
    );
  }

  factory AssetSuggestionModel.fromSerialNo(String serialNo) {
    return AssetSuggestionModel(
      value: serialNo,
      type: 'serial_no',
      label: 'Serial: $serialNo',
    );
  }
}

class LocationSuggestionModel extends SearchSuggestionModel {
  const LocationSuggestionModel({
    required super.value,
    required super.type,
    required super.label,
    super.score,
    super.frequency,
    super.metadata,
  }) : super(entity: 'locations');

  factory LocationSuggestionModel.fromLocationCode(
    String locationCode, {
    String? description,
    String? plantCode,
  }) {
    String label = locationCode;
    if (description != null) label += ' - $description';
    if (plantCode != null) label += ' ($plantCode)';

    return LocationSuggestionModel(
      value: locationCode,
      type: 'location_code',
      label: label,
      metadata: {
        if (description != null) 'description': description,
        if (plantCode != null) 'plant_code': plantCode,
      },
    );
  }
}

class PopularSuggestionModel extends SearchSuggestionModel {
  const PopularSuggestionModel({
    required super.value,
    required super.label,
    super.frequency,
    super.metadata,
  }) : super(type: 'popular', entity: 'popular', category: 'trending');

  factory PopularSuggestionModel.fromPopularSearch(
    String query, {
    int? searchCount,
    double? avgResults,
  }) {
    return PopularSuggestionModel(
      value: query,
      label: query,
      frequency: searchCount,
      metadata: {
        if (avgResults != null) 'avg_results': avgResults,
        'source': 'popular_searches',
      },
    );
  }
}

class RecentSuggestionModel extends SearchSuggestionModel {
  const RecentSuggestionModel({
    required super.value,
    required super.label,
    super.frequency,
    super.metadata,
  }) : super(type: 'recent', entity: 'recent', category: 'history');

  factory RecentSuggestionModel.fromRecentSearch(
    String query, {
    DateTime? lastSearched,
    int? searchCount,
  }) {
    return RecentSuggestionModel(
      value: query,
      label: query,
      frequency: searchCount,
      metadata: {
        if (lastSearched != null)
          'last_searched': lastSearched.toIso8601String(),
        'source': 'search_history',
      },
    );
  }

  DateTime? get lastSearched {
    final lastSearchedStr = metadata?['last_searched'];
    return lastSearchedStr != null ? DateTime.tryParse(lastSearchedStr) : null;
  }
}

/// Helper functions for creating suggestions
class SearchSuggestionFactory {
  static List<SearchSuggestionModel> fromApiResponse(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) =>
              SearchSuggestionModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  static List<SearchSuggestionModel> fromMixedSources({
    List<String>? recent,
    List<String>? popular,
    List<Map<String, dynamic>>? entities,
  }) {
    final suggestions = <SearchSuggestionModel>[];

    // Add recent searches
    if (recent != null) {
      suggestions.addAll(
        recent.map((query) => RecentSuggestionModel.fromRecentSearch(query)),
      );
    }

    // Add popular searches
    if (popular != null) {
      suggestions.addAll(
        popular.map((query) => PopularSuggestionModel.fromPopularSearch(query)),
      );
    }

    // Add entity suggestions
    if (entities != null) {
      suggestions.addAll(
        entities.map((json) => SearchSuggestionModel.fromJson(json)),
      );
    }

    // Sort by priority and score
    suggestions.sort((a, b) {
      // First by priority
      final priorityCompare = a.priority.compareTo(b.priority);
      if (priorityCompare != 0) return priorityCompare;

      // Then by score (higher first)
      if (a.score != null && b.score != null) {
        return b.score!.compareTo(a.score!);
      }

      // Finally by value length (shorter first)
      return a.value.length.compareTo(b.value.length);
    });

    return suggestions;
  }
}
