// Path: frontend/lib/features/scan/presentation/widgets/asset_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/app/theme/app_spacing.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import 'package:frontend/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:frontend/features/scan/presentation/bloc/scan_event.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../pages/asset_detail_page.dart';
import '../pages/create_asset_page.dart';

// Theme Extension สำหรับ Asset Status Colors
extension AssetStatusTheme on ThemeData {
  Color getAssetStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return colorScheme.primary;
      case 'C':
        return colorScheme.tertiary; // สีม่วงสำหรับ Checked
      case 'I':
        return colorScheme.error;
      case 'UNKNOWN':
        return AppColors.warning; // สีส้มสำหรับ Unknown
      default:
        return colorScheme.primary;
    }
  }

  // เพิ่ม method สำหรับเช็ค Unknown โดยใช้ isUnknown flag
  Color getAssetStatusColorByItem(ScannedItemEntity item) {
    // ใช้ isUnknown flag เป็นหลักแทน status string
    if (item.isUnknown == true) {
      return AppColors.warning; // สีส้มสำหรับ Unknown items
    }
    return getAssetStatusColor(item.status);
  }

  IconData getAssetStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return Icons.check_circle_outline;
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

  String getAssetStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return 'Active';
      case 'C':
        return 'Checked';
      case 'I':
        return 'Inactive';
      case 'UNKNOWN':
        return 'Unknown';
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
              // Icon Container
              _buildStatusIcon(theme),

              AppSpacing.horizontalSpaceLG,

              // Content
              Expanded(child: _buildContent(theme)),

              // Arrow or Create Icon
              _buildActionIcon(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    final statusColor = theme.getAssetStatusColorByItem(item);
    final statusIcon = theme.getAssetStatusIcon(item.status);

    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: AppBorders.medium,
      ),
      child: Icon(statusIcon, color: statusColor, size: 24.0),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title - ใช้สีตาม status เสมอ
        Text(
          item.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.getAssetStatusColorByItem(
              item,
            ), // ใช้สีตาม status เสมอ
          ),
        ),

        AppSpacing.verticalSpaceXS,

        // Asset Number - ใช้สีเทาเสมอ
        Text(
          'Asset No: ${item.assetNo}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),

        AppSpacing.verticalSpaceXS,

        // Status และ Location Row
        _buildStatusAndLocation(theme),
      ],
    );
  }

  Widget _buildStatusAndLocation(ThemeData theme) {
    final statusColor = theme.getAssetStatusColorByItem(item);
    final statusLabel = theme.getAssetStatusLabel(item.status);

    return Row(
      children: [
        // Status Indicator
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),

        AppSpacing.horizontalSpaceXS,

        Text(
          statusLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Location (ถ้ามี) - ใช้สีเทาเสมอ
        if (item.locationName != null) ...[
          AppSpacing.horizontalSpaceMD,
          Icon(
            Icons.location_on,
            size: 12.0,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          AppSpacing.horizontalSpaceXS,
          Expanded(
            child: Text(
              item.locationName!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionIcon(ThemeData theme) {
    return Icon(
      item.isUnknown ? Icons.add_circle_outline : Icons.chevron_right,
      color: item.isUnknown
          ? AppColors.warning
          : theme.colorScheme.onSurface.withOpacity(0.4),
    );
  }

  void _navigateToDetail(BuildContext context) async {
    if (item.isUnknown) {
      // Navigate to Create Asset Page for unknown items พร้อม location data
      final result = await Navigator.of(context).push<ScannedItemEntity>(
        MaterialPageRoute(
          builder: (context) => CreateAssetPage(
            assetNo: item.assetNo,
            plantCode: item.plantCode,
            locationCode: item.locationCode,
            locationName: item.locationName,
          ),
        ),
      );

      // ถ้าสร้าง asset สำเร็จ แล้ว result กลับมา
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
