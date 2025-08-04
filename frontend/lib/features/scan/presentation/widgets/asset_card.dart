// Path: frontend/lib/features/scan/presentation/widgets/asset_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/app/theme/app_spacing.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import 'package:frontend/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:frontend/features/scan/presentation/bloc/scan_event.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../../domain/entities/asset_image_entity.dart';
import '../../data/models/asset_image_model.dart';
import '../pages/asset_detail_page.dart';
import '../pages/create_asset_page.dart';

// Theme Extension สำหรับ Asset Status Colors
extension AssetStatusTheme on ThemeData {
  Color getAssetStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return colorScheme.primary;
      case 'C':
        return AppColors.assetActive;
      case 'I':
        return colorScheme.error;
      case 'UNKNOWN':
        return AppColors.warning.withValues(alpha: 0.7);
      default:
        return colorScheme.primary;
    }
  }

  Color getAssetStatusColorByItem(ScannedItemEntity item) {
    if (item.isUnknown == true) {
      return AppColors.warning.withValues(alpha: 0.7);
    }
    return getAssetStatusColor(item.status);
  }

  IconData getAssetStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return Icons.pending_outlined;
      case 'C':
        return Icons.task_alt;
      case 'I':
        return Icons.disabled_by_default_outlined;
      case 'UNKNOWN':
        return Icons.help_outline;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String getAssetStatusLabel(String status, ScanLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'A':
        return l10n.statusAwaiting;
      case 'C':
        return l10n.statusChecked;
      case 'I':
        return l10n.statusInactive;
      case 'UNKNOWN':
        return l10n.statusUnknown;
      default:
        return status;
    }
  }
}

class AssetCard extends StatelessWidget {
  final ScannedItemEntity item;

  const AssetCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ScanLocalizations.of(context);

    return Card(
      margin: AppSpacing.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: AppBorders.medium,
        child: Padding(
          padding: AppSpacing.cardPaddingAll,
          child: Row(
            children: [
              // Icon Container with Lazy Image Loading
              _buildStatusIcon(context, theme, l10n),

              AppSpacing.horizontalSpaceLG,

              // Content
              Expanded(child: _buildContent(context, theme, l10n)),

              // Arrow or Create Icon
              _buildActionIcon(context, theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ NEW: Lazy Image Loading Status Icon
  Widget _buildStatusIcon(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(borderRadius: AppBorders.medium),
      child: item.isUnknown
          ? _buildDefaultStatusIcon(theme, l10n) // Unknown items ไม่มีรูป
          : FutureBuilder<AssetImageEntity?>(
              // ⚡ Lazy loading - เรียก API เฉพาะเมื่อ widget นี้แสดง
              future: _loadPrimaryImage(item.assetNo),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // กำลังโหลด - แสดง skeleton
                  return _buildSkeletonIcon(theme);
                }

                if (snapshot.hasData && snapshot.data != null) {
                  // มีรูป - แสดง thumbnail with status badge
                  return _buildImageIcon(snapshot.data!, theme, l10n);
                }

                // ไม่มีรูป - แสดง status icon เดิม
                return _buildDefaultStatusIcon(theme, l10n);
              },
            ),
    );
  }

  // ⚡ Lazy loading method
  Future<AssetImageEntity?> _loadPrimaryImage(String assetNo) async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.assetImages(assetNo),
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final imagesJson = data['images'] as List<dynamic>? ?? [];
        if (imagesJson.isNotEmpty) {
          // หา primary image หรือเอารูปแรก
          final primaryImageJson = imagesJson.firstWhere(
            (img) => img['is_primary'] == true,
            orElse: () => imagesJson.first,
          );
          return AssetImageModel.fromJson(
            primaryImageJson as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      // Silent fail - แสดง default icon
      print('Failed to load image for $assetNo: $e');
    }
    return null;
  }

  // 📷 แสดงรูปภาพ with status badge
  Widget _buildImageIcon(
    AssetImageEntity image,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    // ✅ FIXED: เรียก thumbnail แทน full image
    final imageUrl =
        '${ApiConstants.baseUrl}${ApiConstants.serveImage(image.id)}?size=thumb';

    // Calculate responsive dimensions based on image aspect ratio
    double imageWidth = image.width?.toDouble() ?? 1.0;
    double imageHeight = image.height?.toDouble() ?? 1.0;
    double aspectRatio = imageWidth / imageHeight;

    const double cardSize = 48.0;
    double displayWidth, displayHeight;

    if (aspectRatio > 1.0) {
      // Landscape: จำกัดความกว้าง, ปรับความสูง (พื้นที่ว่างบน-ล่าง)
      displayWidth = cardSize;
      displayHeight = cardSize / aspectRatio;
    } else {
      // Portrait: จำกัดความสูง, ปรับความกว้าง (พื้นที่ว่างซ้าย-ขวา)
      displayHeight = cardSize;
      displayWidth = cardSize * aspectRatio;
    }

    return Container(
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(borderRadius: AppBorders.medium),
      child: Center(
        child: CachedNetworkImage(
          // ✅ ลบ ClipRRect ออก - ไม่มีขอบโค้งสำหรับรูป
          imageUrl: imageUrl, // ✅ ใช้ URL ที่มี ?size=thumb แล้ว
          width: displayWidth,
          height: displayHeight,
          fit: BoxFit.contain, // ✅ เปลี่ยนจาก cover เป็น contain
          placeholder: (context, url) => _buildSkeletonIcon(theme),
          errorWidget: (context, url, error) =>
              _buildDefaultStatusIcon(theme, l10n),
        ),
      ),
    );
  }

  // 💀 Skeleton loading state
  Widget _buildSkeletonIcon(ThemeData theme) {
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        borderRadius: AppBorders.medium,
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // 🎯 Default status icon (เดิม)
  Widget _buildDefaultStatusIcon(ThemeData theme, ScanLocalizations l10n) {
    final statusColor = theme.getAssetStatusColorByItem(item);
    final statusIcon = theme.getAssetStatusIcon(item.status);

    final displayStatusColor = item.isUnknown
        ? AppColors.error
        : (theme.brightness == Brightness.dark
              ? theme.colorScheme.onSurface
              : statusColor);

    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: displayStatusColor.withValues(alpha: 0.1),
        borderRadius: AppBorders.medium,
      ),
      child: Icon(statusIcon, color: displayStatusColor, size: 24.0),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          item.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: item.isUnknown
                ? AppColors.error
                : (theme.brightness == Brightness.dark
                      ? theme.colorScheme.onSurface
                      : theme.getAssetStatusColorByItem(item)),
          ),
        ),

        AppSpacing.verticalSpaceXS,

        // Asset Number
        Text(
          l10n.epcCodeField(item.assetNo),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),

        AppSpacing.verticalSpaceXS,

        // Status และ Location Row
        _buildStatusAndLocation(context, theme, l10n),
      ],
    );
  }

  Widget _buildStatusAndLocation(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    final statusColor = theme.getAssetStatusColorByItem(item);
    final statusLabel = theme.getAssetStatusLabel(item.status, l10n);

    final displayStatusColor = item.isUnknown
        ? AppColors.error
        : (theme.brightness == Brightness.dark
              ? theme.colorScheme.onSurface
              : statusColor);

    return Row(
      children: [
        // Status Indicator
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: displayStatusColor,
            shape: BoxShape.circle,
          ),
        ),

        AppSpacing.horizontalSpaceXS,

        Text(
          statusLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: displayStatusColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Location (ถ้ามี)
        if (item.locationName != null) ...[
          AppSpacing.horizontalSpaceMD,
          Icon(
            Icons.location_on,
            size: 12.0,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkTextMuted
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          AppSpacing.horizontalSpaceXS,
          Expanded(
            child: Text(
              item.locationName!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkTextMuted
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionIcon(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Icon(
      item.isUnknown ? Icons.add_circle_outline : Icons.chevron_right,
      color: item.isUnknown
          ? AppColors.warning.withValues(alpha: 0.7)
          : (theme.brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
    );
  }

  void _navigateToDetail(BuildContext context) async {
    if (item.isUnknown) {
      // Navigate to Create Asset Page for unknown items
      final result = await Navigator.of(context).push<ScannedItemEntity>(
        MaterialPageRoute(
          builder: (context) => CreateAssetPage(epcCode: item.assetNo),
        ),
      );

      if (result != null && context.mounted) {
        context.read<ScanBloc>().add(
          AssetCreatedFromUnknown(createdAsset: result),
        );
      }
    } else {
      // Navigate to Asset Detail Page for existing items
      final scanBloc = context.read<ScanBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssetDetailPage(item: item, scanBloc: scanBloc),
        ),
      );
    }
  }
}
