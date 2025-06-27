// Path: frontend/lib/features/search/domain/entities/search_result_entity.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Core search result entity representing any searchable item
class SearchResultEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String entityType;
  final Map<String, dynamic> data;
  final double? relevanceScore;
  final Map<String, dynamic>? highlights;
  final DateTime? lastModified;

  const SearchResultEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.entityType,
    required this.data,
    this.relevanceScore,
    this.highlights,
    this.lastModified,
  });

  /// Factory constructors for specific entity types
  factory SearchResultEntity.asset({
    required String assetNo,
    required String description,
    required Map<String, dynamic> assetData,
    double? score,
    Map<String, dynamic>? highlights,
    DateTime? lastModified,
  }) {
    return SearchResultEntity(
      id: assetNo,
      title: assetNo,
      subtitle: description,
      entityType: 'assets',
      data: assetData,
      relevanceScore: score,
      highlights: highlights,
      lastModified: lastModified,
    );
  }

  factory SearchResultEntity.plant({
    required String plantCode,
    required String description,
    required Map<String, dynamic> plantData,
    double? score,
    Map<String, dynamic>? highlights,
  }) {
    return SearchResultEntity(
      id: plantCode,
      title: plantCode,
      subtitle: description,
      entityType: 'plants',
      data: plantData,
      relevanceScore: score,
      highlights: highlights,
    );
  }

  factory SearchResultEntity.location({
    required String locationCode,
    required String description,
    required Map<String, dynamic> locationData,
    double? score,
    Map<String, dynamic>? highlights,
  }) {
    return SearchResultEntity(
      id: locationCode,
      title: locationCode,
      subtitle: description,
      entityType: 'locations',
      data: locationData,
      relevanceScore: score,
      highlights: highlights,
    );
  }

  factory SearchResultEntity.user({
    required String userId,
    required String fullName,
    required String username,
    required Map<String, dynamic> userData,
    double? score,
    Map<String, dynamic>? highlights,
  }) {
    return SearchResultEntity(
      id: userId,
      title: fullName.isNotEmpty ? fullName : username,
      subtitle: username,
      entityType: 'users',
      data: userData,
      relevanceScore: score,
      highlights: highlights,
    );
  }

  /// Getters for common data fields
  String? get assetNo => entityType == 'assets' ? data['asset_no'] : null;
  String? get description => data['description'];
  String? get serialNo => entityType == 'assets' ? data['serial_no'] : null;
  String? get inventoryNo =>
      entityType == 'assets' ? data['inventory_no'] : null;
  String? get status => data['status'];
  String? get plantCode => data['plant_code'];
  String? get locationCode => data['location_code'];
  String? get unitCode => data['unit_code'];
  String? get username => entityType == 'users' ? data['username'] : null;
  String? get fullName => entityType == 'users' ? data['full_name'] : null;
  String? get role => entityType == 'users' ? data['role'] : null;

  /// Business logic methods
  bool get isAsset => entityType == 'assets';
  bool get isPlant => entityType == 'plants';
  bool get isLocation => entityType == 'locations';
  bool get isUser => entityType == 'users';

  bool get hasHighlights => highlights != null && highlights!.isNotEmpty;
  bool get hasScore => relevanceScore != null;
  bool get isRelevant => relevanceScore != null && relevanceScore! > 0.0;

  /// Get highlighted text for a field
  String? getHighlightedText(String fieldName) {
    if (!hasHighlights) return null;
    return highlights![fieldName]?.toString();
  }

  /// Get display priority based on relevance and entity type
  int get displayPriority {
    // Higher score = higher priority
    final scoreBonus = (relevanceScore ?? 0.0) * 1000;

    // Entity type priority
    int entityPriority;
    switch (entityType) {
      case 'assets':
        entityPriority = 1000;
        break;
      case 'plants':
        entityPriority = 800;
        break;
      case 'locations':
        entityPriority = 600;
        break;
      case 'departments':
        entityPriority = 500;
        break;
      case 'users':
        entityPriority = 400;
        break;

      default:
        entityPriority = 0;
    }

    return (scoreBonus + entityPriority).round();
  }

  /// Get entity icon
  IconData get entityIcon {
    switch (entityType) {
      case 'assets':
        return Icons.inventory_2; // หรือ Icons.build, Icons.storage
      case 'plants':
        return Icons.factory; // หรือ Icons.business, Icons.location_city
      case 'locations':
        return Icons.place; // หรือ Icons.location_on, Icons.map
      case 'departments':
        return Icons.group;
      case 'users':
        return Icons.person; // หรือ Icons.account_circle, Icons.group
      default:
        return Icons.search; // ไอคอนเริ่มต้น
    }
  }

  /// Get entity color
  String get entityColor {
    switch (entityType) {
      case 'assets':
        return '#2563EB'; // Blue
      case 'plants':
        return '#059669'; // Green
      case 'locations':
        return '#DC2626'; // Red
      case 'departments':
        return '#F59E0B'; // Orange
      case 'users':
        return '#7C3AED'; // Purple
      default:
        return '#6B7280'; // Gray
    }
  }

  /// Get display status label
  String get statusLabel {
    if (status == null) return '';

    switch (status!.toUpperCase()) {
      case 'A':
        return 'Active';
      case 'C':
        return 'Created';
      case 'I':
        return 'Inactive';
      default:
        return status!;
    }
  }

  /// Get status color
  String get statusColor {
    if (status == null) return '#6B7280';

    switch (status!.toUpperCase()) {
      case 'A':
        return '#059669'; // Green
      case 'C':
        return '#2563EB'; // Blue
      case 'I':
        return '#6B7280'; // Gray
      default:
        return '#6B7280';
    }
  }

  /// Check if entity matches search criteria
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    final searchableText = [
      title.toLowerCase(),
      subtitle.toLowerCase(),
      id.toLowerCase(),
      ...data.values
          .where((v) => v is String)
          .map((v) => v.toString().toLowerCase()),
    ].join(' ');

    return searchableText.contains(lowerQuery);
  }

  /// Create copy with updated fields
  SearchResultEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? entityType,
    Map<String, dynamic>? data,
    double? relevanceScore,
    Map<String, dynamic>? highlights,
    DateTime? lastModified,
  }) {
    return SearchResultEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      entityType: entityType ?? this.entityType,
      data: data ?? this.data,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      highlights: highlights ?? this.highlights,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Create entity with updated relevance score
  SearchResultEntity withScore(double score) {
    return copyWith(relevanceScore: score);
  }

  /// Create entity with highlights
  SearchResultEntity withHighlights(Map<String, dynamic> newHighlights) {
    return copyWith(highlights: newHighlights);
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    entityType,
    data,
    relevanceScore,
    highlights,
    lastModified,
  ];

  @override
  String toString() {
    return 'SearchResultEntity(id: $id, title: $title, type: $entityType, score: $relevanceScore)';
  }
}

/// Search result with additional context
class SearchResult<T> extends Equatable {
  final bool success;
  final T? data;
  final String? error;
  final String? query;
  final bool fromCache;
  final int totalResults;
  final SearchMetaEntity? meta;

  const SearchResult({
    required this.success,
    this.data,
    this.error,
    this.query,
    this.fromCache = false,
    this.totalResults = 0,
    this.meta,
  });

  factory SearchResult.success({
    required T data,
    String? query,
    bool fromCache = false,
    int totalResults = 0,
    SearchMetaEntity? meta,
  }) {
    return SearchResult(
      success: true,
      data: data,
      query: query,
      fromCache: fromCache,
      totalResults: totalResults,
      meta: meta,
    );
  }

  factory SearchResult.failure({required Exception error, String? query}) {
    return SearchResult(success: false, error: error.toString(), query: query);
  }

  factory SearchResult.empty({String? query}) {
    return SearchResult(
      success: true,
      data: null,
      query: query,
      totalResults: 0,
    );
  }

  bool get hasData => success && data != null;
  bool get hasError => !success && error != null;
  bool get isEmpty => success && (data == null || totalResults == 0);

  @override
  List<Object?> get props => [
    success,
    data,
    error,
    query,
    fromCache,
    totalResults,
    meta,
  ];

  @override
  String toString() {
    return 'SearchResult(success: $success, totalResults: $totalResults, fromCache: $fromCache)';
  }
}

/// Forward declaration for SearchMetaEntity (will be defined in search_meta_entity.dart)
class SearchMetaEntity {
  final String query;
  final List<String> entities;
  final int totalResults;
  final bool cached;
  final SearchPerformanceEntity? performance;
  final SearchPaginationEntity? pagination;
  final List<String>? relatedQueries;
  final Map<String, dynamic>? searchOptions;

  const SearchMetaEntity({
    required this.query,
    required this.entities,
    required this.totalResults,
    this.cached = false,
    this.performance,
    this.pagination,
    this.relatedQueries,
    this.searchOptions,
  });
}

/// Forward declaration for performance entity
class SearchPerformanceEntity {
  final int durationMs;
  final int totalResults;
  final String performanceGrade;
  final DateTime timestamp;

  const SearchPerformanceEntity({
    required this.durationMs,
    required this.totalResults,
    required this.performanceGrade,
    required this.timestamp,
  });
}

/// Forward declaration for pagination entity
class SearchPaginationEntity {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  const SearchPaginationEntity({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
}
