// Path: frontend/lib/features/scan/presentation/widgets/image_gallery_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
import '../../domain/entities/asset_image_entity.dart';

class ImageGalleryWidget extends StatelessWidget {
  final List<AssetImageEntity> images;
  final String assetNo;

  const ImageGalleryWidget({
    super.key,
    required this.images,
    required this.assetNo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ScanLocalizations.of(context);

    if (images.isEmpty) {
      return _buildEmptyState(context, theme, l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, theme, l10n),
        const SizedBox(height: 12),
        _buildImageGrid(context, theme),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Row(
      children: [
        Icon(
          Icons.photo_library,
          color: theme.brightness == Brightness.dark
              ? AppColors.darkText
              : theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '${l10n.images} (${images.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkText
                : theme.colorScheme.onSurface,
          ),
        ),
        if (images.any((img) => img.isPrimary)) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.primary,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive height based on screen size
        double imageHeight;
        if (constraints.maxWidth > 800) {
          imageHeight = 200; // Desktop
        } else if (constraints.maxWidth > 600) {
          imageHeight = 160; // Tablet
        } else {
          imageHeight = 120; // Mobile
        }

        return SizedBox(
          height: imageHeight,
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildImageCard(context, theme, image, imageHeight),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    ThemeData theme,
    AssetImageEntity image, [
    double? height, // Make height optional parameter
  ]) {
    final imageUrl = '${ApiConstants.baseUrl}${image.thumbnailUrl}';
    final cardHeight = height ?? 120; // Use provided height or default
    final cardWidth = cardHeight; // Keep it square

    return GestureDetector(
      onTap: () => _showFullImageDialog(context, image),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image.isPrimary
                ? theme.colorScheme.primary
                : (theme.brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : theme.colorScheme.outline.withValues(alpha: 0.3)),
            width: image.isPrimary ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: cardWidth,
                  height: cardHeight,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkSurface
                      : theme.colorScheme.surface,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: cardWidth,
                  height: cardHeight,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkSurface
                      : theme.colorScheme.surface,
                  child: Icon(
                    Icons.image_not_supported,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: cardHeight * 0.25, // Responsive icon size
                  ),
                ),
              ),
            ),

            // Primary badge
            if (image.isPrimary)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'P',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: cardHeight > 150 ? 12 : 10, // Responsive text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Image info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Text(
                  image.formattedFileSize,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: cardHeight > 150 ? 12 : 10, // Responsive text
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkText
                    : theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.images,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkText
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkSurface.withValues(alpha: 0.3)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkBorder.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.noImagesAvailable,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.imagesWillAppearHere,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextMuted
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImageDialog(BuildContext context, AssetImageEntity image) {
    showDialog(
      context: context,
      builder: (context) => _FullImageDialog(image: image),
    );
  }
}

class _FullImageDialog extends StatelessWidget {
  final AssetImageEntity image;

  const _FullImageDialog({required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ScanLocalizations.of(context);
    final fullImageUrl = '${ApiConstants.baseUrl}${image.imageUrl}';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Background tap to close
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),

          // Image container
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            image.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.darkText
                                  : theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: theme.brightness == Brightness.dark
                                ? AppColors.darkText
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Image
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 40,
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: fullImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.darkTextSecondary
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.imageLoadError,
                              style: TextStyle(
                                color: theme.brightness == Brightness.dark
                                    ? AppColors.darkTextSecondary
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Footer with image info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.darkSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          context,
                          theme,
                          Icons.straighten,
                          image.dimensions,
                        ),
                        _buildInfoItem(
                          context,
                          theme,
                          Icons.file_present,
                          image.formattedFileSize,
                        ),
                        if (image.isPrimary)
                          _buildInfoItem(
                            context,
                            theme,
                            Icons.star,
                            l10n.primary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.brightness == Brightness.dark
              ? AppColors.darkTextSecondary
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
