// Path: frontend/lib/features/search/data/models/search_result_model.dart
import 'package:equatable/equatable.dart';

/// Generic search result model that can contain any entity type
class SearchResultModel<T> extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String entityType;
  final T data;
  final double? relevanceScore;
  final Map<String, dynamic>? highlights;
  final DateTime? lastModified;

  const SearchResultModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.entityType,
    required this.data,
    this.relevanceScore,
    this.highlights,
    this.lastModified,
  });

  factory SearchResultModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return SearchResultModel<T>(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      entityType: json['type'] ?? json['entity_type'] ?? '',
      data: fromJsonT(json['data'] ?? json),
      relevanceScore:
          json['relevance_score']?.toDouble() ?? json['score']?.toDouble(),
      highlights: json['highlights'] != null
          ? Map<String, dynamic>.from(json['highlights'])
          : null,
      lastModified: json['last_modified'] != null
          ? DateTime.tryParse(json['last_modified'])
          : json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'entity_type': entityType,
      'data': toJsonT(data),
      if (relevanceScore != null) 'relevance_score': relevanceScore,
      if (highlights != null) 'highlights': highlights,
      if (lastModified != null)
        'last_modified': lastModified!.toIso8601String(),
    };
  }

  SearchResultModel<T> copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? entityType,
    T? data,
    double? relevanceScore,
    Map<String, dynamic>? highlights,
    DateTime? lastModified,
  }) {
    return SearchResultModel<T>(
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
    return 'SearchResultModel(id: $id, title: $title, entityType: $entityType, score: $relevanceScore)';
  }
}

/// Specialized models for different entity types
class AssetSearchResultModel extends SearchResultModel<Map<String, dynamic>> {
  const AssetSearchResultModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.data,
    super.relevanceScore,
    super.highlights,
    super.lastModified,
  }) : super(entityType: 'assets');

  factory AssetSearchResultModel.fromJson(Map<String, dynamic> json) {
    return AssetSearchResultModel(
      id: json['asset_no'] ?? json['id'] ?? '',
      title: json['title'] ?? json['description'] ?? '',
      subtitle: json['description'] ?? '',
      data: Map<String, dynamic>.from(json),
      relevanceScore: json['relevance_score']?.toDouble(),
      highlights: json['highlights'] != null
          ? Map<String, dynamic>.from(json['highlights'])
          : null,
      lastModified: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  String get assetNo => data['asset_no'] ?? '';
  String get description => data['description'] ?? '';
  String get serialNo => data['serial_no'] ?? '';
  String get inventoryNo => data['inventory_no'] ?? '';
  String get status => data['status'] ?? '';
  String get plantCode => data['plant_code'] ?? '';
  String get locationCode => data['location_code'] ?? '';
  String get unitCode => data['unit_code'] ?? '';
}

class PlantSearchResultModel extends SearchResultModel<Map<String, dynamic>> {
  const PlantSearchResultModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.data,
    super.relevanceScore,
    super.highlights,
    super.lastModified,
  }) : super(entityType: 'plants');

  factory PlantSearchResultModel.fromJson(Map<String, dynamic> json) {
    return PlantSearchResultModel(
      id: json['plant_code'] ?? json['id'] ?? '',
      title: json['plant_code'] ?? '',
      subtitle: json['description'] ?? '',
      data: Map<String, dynamic>.from(json),
      relevanceScore: json['relevance_score']?.toDouble(),
      highlights: json['highlights'] != null
          ? Map<String, dynamic>.from(json['highlights'])
          : null,
    );
  }

  String get plantCode => data['plant_code'] ?? '';
  String get description => data['description'] ?? '';
}

class LocationSearchResultModel
    extends SearchResultModel<Map<String, dynamic>> {
  const LocationSearchResultModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.data,
    super.relevanceScore,
    super.highlights,
    super.lastModified,
  }) : super(entityType: 'locations');

  factory LocationSearchResultModel.fromJson(Map<String, dynamic> json) {
    return LocationSearchResultModel(
      id: json['location_code'] ?? json['id'] ?? '',
      title: json['description'] ?? '',
      subtitle:
          json['location_code'] ??
          (json['plant_code'] != null ? 'Plant: ${json['plant_code']}' : ''),
      data: Map<String, dynamic>.from(json),
      relevanceScore: json['relevance_score']?.toDouble(),
      highlights: json['highlights'] != null
          ? Map<String, dynamic>.from(json['highlights'])
          : null,
    );
  }

  String get locationCode => data['location_code'] ?? '';
  String get description => data['description'] ?? '';
  String get plantCode => data['plant_code'] ?? '';
}

class UserSearchResultModel extends SearchResultModel<Map<String, dynamic>> {
  const UserSearchResultModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.data,
    super.relevanceScore,
    super.highlights,
    super.lastModified,
  }) : super(entityType: 'users');

  factory UserSearchResultModel.fromJson(Map<String, dynamic> json) {
    return UserSearchResultModel(
      id: json['user_id'] ?? json['id'] ?? '',
      title: json['full_name'] ?? json['username'] ?? '',
      subtitle: '${json['role'] ?? 'User'} - ${json['username'] ?? ''}',
      data: Map<String, dynamic>.from(json),
      relevanceScore: json['relevance_score']?.toDouble(),
      highlights: json['highlights'] != null
          ? Map<String, dynamic>.from(json['highlights'])
          : null,
    );
  }

  String get userId => data['user_id'] ?? '';
  String get username => data['username'] ?? '';
  String get fullName => data['full_name'] ?? '';
  String get role => data['role'] ?? '';
}

/// Factory function to create appropriate search result model
SearchResultModel createSearchResultModel(Map<String, dynamic> json) {
  final entityType = json['entity_type'] ?? json['type'] ?? '';

  switch (entityType.toLowerCase()) {
    case 'assets':
    case 'asset':
      return AssetSearchResultModel.fromJson(json);
    case 'plants':
    case 'plant':
      return PlantSearchResultModel.fromJson(json);
    case 'locations':
    case 'location':
      return LocationSearchResultModel.fromJson(json);
    case 'users':
    case 'user':
      return UserSearchResultModel.fromJson(json);
    default:
      return SearchResultModel<Map<String, dynamic>>.fromJson(
        json,
        (data) => Map<String, dynamic>.from(data),
      );
  }
}
