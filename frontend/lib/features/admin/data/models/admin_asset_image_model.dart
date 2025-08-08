import '../../domain/entities/admin_asset_image_entity.dart';

class AdminAssetImageModel extends AdminAssetImageEntity {
  const AdminAssetImageModel({
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

  factory AdminAssetImageModel.fromJson(Map<String, dynamic> json) {
    return AdminAssetImageModel(
      id: json['id'] as int,
      assetNo: json['asset_no'] as String,
      fileName: json['file_name'] as String,
      originalName: json['original_name'] as String,
      fileSize: json['file_size'] as int,
      fileType: json['file_type'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      isPrimary: json['is_primary'] as bool? ?? false,
      altText: json['alt_text'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
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
}