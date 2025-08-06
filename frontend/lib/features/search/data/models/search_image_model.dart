import '../../domain/entities/search_image_entity.dart';
import '../../../../core/constants/api_constants.dart';

class SearchImageModel extends SearchImageEntity {
  const SearchImageModel({
    required super.id,
    required super.assetNo,
    required super.fileName,
    required super.originalName,
    required super.fileSize,
    required super.fileType,
    super.width,
    super.height,
    super.isPrimary,
    super.altText,
    super.description,
    super.category,
    required super.imageUrl,
    required super.thumbnailUrl,
    required super.createdAt,
    super.createdBy,
  });

  /// Factory constructor from JSON (API response)
  factory SearchImageModel.fromJson(Map<String, dynamic> json) {
    return SearchImageModel(
      id: json['id'] as int,
      assetNo: json['asset_no'] as String,
      fileName: json['file_name'] as String,
      originalName: json['original_name'] as String? ?? '',
      fileSize: json['file_size'] as int,
      fileType: json['file_type'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      isPrimary: json['is_primary'] as bool? ?? false,
      altText: json['alt_text'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      imageUrl: '${ApiConstants.baseUrl}${ApiConstants.serveImage(json['id'])}',
      thumbnailUrl: '${ApiConstants.baseUrl}${ApiConstants.serveImage(json['id'])}?size=thumb',
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_no': assetNo,
      'file_name': fileName,
      'original_name': originalName,
      'file_size': fileSize,
      'file_type': fileType,
      'width': width,
      'height': height,
      'is_primary': isPrimary,
      'alt_text': altText,
      'description': description,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  /// Convert to domain entity
  SearchImageEntity toDomain() {
    return SearchImageEntity(
      id: id,
      assetNo: assetNo,
      fileName: fileName,
      originalName: originalName,
      fileSize: fileSize,
      fileType: fileType,
      width: width,
      height: height,
      isPrimary: isPrimary,
      altText: altText,
      description: description,
      category: category,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }

  /// Create from domain entity
  factory SearchImageModel.fromDomain(SearchImageEntity entity) {
    return SearchImageModel(
      id: entity.id,
      assetNo: entity.assetNo,
      fileName: entity.fileName,
      originalName: entity.originalName,
      fileSize: entity.fileSize,
      fileType: entity.fileType,
      width: entity.width,
      height: entity.height,
      isPrimary: entity.isPrimary,
      altText: entity.altText,
      description: entity.description,
      category: entity.category,
      imageUrl: entity.imageUrl,
      thumbnailUrl: entity.thumbnailUrl,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
    );
  }

  @override
  SearchImageModel copyWith({
    int? id,
    String? assetNo,
    String? fileName,
    String? originalName,
    int? fileSize,
    String? fileType,
    int? width,
    int? height,
    bool? isPrimary,
    String? altText,
    String? description,
    String? category,
    String? imageUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return SearchImageModel(
      id: id ?? this.id,
      assetNo: assetNo ?? this.assetNo,
      fileName: fileName ?? this.fileName,
      originalName: originalName ?? this.originalName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      width: width ?? this.width,
      height: height ?? this.height,
      isPrimary: isPrimary ?? this.isPrimary,
      altText: altText ?? this.altText,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}