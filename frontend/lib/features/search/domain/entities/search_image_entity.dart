import 'package:equatable/equatable.dart';

/// Search-specific image entity for displaying images in search results
class SearchImageEntity extends Equatable {
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

  const SearchImageEntity({
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

  /// Helper methods for display
  String get displayName => originalName.isNotEmpty ? originalName : fileName;

  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get dimensions {
    if (width != null && height != null) {
      return '${width}x${height}';
    }
    return 'Unknown';
  }

  double get aspectRatio {
    if (width != null && height != null && width! > 0 && height! > 0) {
      return width! / height!;
    }
    return 16 / 9; // Default aspect ratio
  }

  bool get isLandscape => aspectRatio > 1.0;
  bool get isPortrait => aspectRatio < 1.0;
  bool get isSquare => aspectRatio == 1.0;

  /// Copy method for creating modified instances
  SearchImageEntity copyWith({
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
    return SearchImageEntity(
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

  @override
  String toString() {
    return 'SearchImageEntity(id: $id, assetNo: $assetNo, fileName: $fileName, isPrimary: $isPrimary)';
  }
}