// Path: frontend/lib/features/scan/data/models/asset_image_model.dart
import '../../domain/entities/asset_image_entity.dart';

class AssetImageModel extends AssetImageEntity {
  const AssetImageModel({
    required super.id,
    required super.assetNo,
    required super.fileName,
    required super.originalName,
    required super.fileSize,
    required super.fileType,
    super.width,
    super.height,
    super.isPrimary = false,
    super.altText,
    super.description,
    super.category,
    required super.imageUrl,
    required super.thumbnailUrl,
    required super.createdAt,
    super.createdBy,
  });

  factory AssetImageModel.fromJson(Map<String, dynamic> json) {
    return AssetImageModel(
      id: json['id'] ?? 0,
      assetNo: json['asset_no'] ?? '',
      fileName: json['file_name'] ?? '',
      originalName: json['original_name'] ?? '',
      fileSize: json['file_size'] ?? 0,
      fileType: json['file_type'] ?? '',
      width: json['width'],
      height: json['height'],
      isPrimary: json['is_primary'] ?? false,
      altText: json['alt_text'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['image_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      createdBy: json['created_by'],
    );
  }

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
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  static List<AssetImageModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => AssetImageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
