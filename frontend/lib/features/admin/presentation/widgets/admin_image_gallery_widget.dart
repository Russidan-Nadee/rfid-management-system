import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import '../../domain/entities/admin_asset_image_entity.dart';

class AdminImageGalleryWidget extends StatelessWidget {
  final List<AdminAssetImageEntity> images;
  final String assetNo;
  final Function(int imageId)? onDeleteImage;
  final Set<int> deletingImages;

  const AdminImageGalleryWidget({
    super.key,
    required this.images,
    required this.assetNo,
    this.onDeleteImage,
    this.deletingImages = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AdminLocalizations.of(context);

    if (images.isEmpty) {
      return _buildEmptyState(context, theme, l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.totalAssets + ': ${images.length}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkText
                : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < images.length - 1 ? 12 : 0),
                child: _buildImageCard(context, theme, l10n, images[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    ThemeData theme,
    AdminLocalizations l10n,
    AdminAssetImageEntity image,
  ) {
    final imageUrl = '${ApiConstants.baseUrl}${ApiConstants.serveImage(image.id)}';
    final thumbnailUrl = '${ApiConstants.baseUrl}${ApiConstants.serveImage(image.id)}?size=thumb';

    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showFullImageDialog(context, image, l10n),
                    child: CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.darkSurface
                            : theme.colorScheme.surface,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.darkSurface
                            : theme.colorScheme.surface,
                        child: Icon(
                          Icons.image_not_supported,
                          color: theme.brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  
                  // Primary badge
                  if (image.isPrimary)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.primaryImage,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Delete button
                  if (onDeleteImage != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: deletingImages.contains(image.id)
                            ? const Padding(
                                padding: EdgeInsets.all(6),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () => _showDeleteConfirmDialog(context, image, l10n),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Image info
            Container(
              padding: const EdgeInsets.all(8),
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image.formattedFileSize,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
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
    AdminLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Container(
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
              l10n.noAssetsFound,
              style: TextStyle(
                fontSize: 14,
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    AdminAssetImageEntity image,
    AdminLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deactivateAssetTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deactivateConfirmMessage),
            const SizedBox(height: 8),
            Text(
              'Image: ${image.displayName}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteImage?.call(image.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deactivate),
          ),
        ],
      ),
    );
  }

  void _showFullImageDialog(
    BuildContext context,
    AdminAssetImageEntity image,
    AdminLocalizations l10n,
  ) {
    final fullImageUrl = '${ApiConstants.baseUrl}${ApiConstants.serveImage(image.id)}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.image, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              image.displayName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
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
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 64),
                              const SizedBox(height: 8),
                              Text(l10n.errorLoadingAssets),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Footer with image info
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(Icons.straighten, image.dimensions),
                          _buildInfoItem(Icons.file_present, image.formattedFileSize),
                          if (image.isPrimary) _buildInfoItem(Icons.star, l10n.primaryImage),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}