// Path: frontend/lib/features/scan/domain/entities/asset_image_entity.dart
import 'package:equatable/equatable.dart';

class AssetImageEntity extends Equatable {
  final int id;
  final String assetNo;
  final String fileName;
  final String originalName;
  final int fileSize;
  final String fileType;
  final int? width;
  final int? height;
  final bool isPrimary;
  final String? altText;
  final String? description;
  final String? category;
  final String imageUrl;
  final String thumbnailUrl;
  final DateTime createdAt;
  final String? createdBy;

  const AssetImageEntity({
    required this.id,
    required this.assetNo,
    required this.fileName,
    required this.originalName,
    required this.fileSize,
    required this.fileType,
    this.width,
    this.height,
    this.isPrimary = false,
    this.altText,
    this.description,
    this.category,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.createdAt,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
    id,
    assetNo,
    fileName,
    originalName,
    fileSize,
    fileType,
    width,
    height,
    isPrimary,
    altText,
    description,
    category,
    imageUrl,
    thumbnailUrl,
    createdAt,
    createdBy,
  ];

  // Helper methods
  String get displayName => originalName.isNotEmpty ? originalName : fileName;

  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get dimensions {
    if (width != null && height != null) {
      return '${width}x${height}';
    }
    return 'Unknown';
  }
}
