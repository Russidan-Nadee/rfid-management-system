// Path: frontend/lib/features/scan/presentation/widgets/asset_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/app/theme/app_spacing.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import 'package:frontend/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:frontend/features/scan/presentation/bloc/scan_event.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
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
        return AppColors.assetActive;
      case 'I':
        return colorScheme.error;
      case 'UNKNOWN':
        return AppColors.warning.withValues(alpha: 0.7); // สีส้มสำหรับ Unknown
      default:
        return colorScheme.primary;
    }
  }

  // เพิ่ม method สำหรับเช็ค Unknown โดยใช้ isUnknown flag
  Color getAssetStatusColorByItem(ScannedItemEntity item) {
    // ใช้ isUnknown flag เป็นหลักแทน status string
    if (item.isUnknown == true) {
      return AppColors.warning.withValues(
        alpha: 0.7,
      ); // สีส้มสำหรับ Unknown items
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
              // Icon Container
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

  Widget _buildStatusIcon(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    final statusColor = theme.getAssetStatusColorByItem(item);
    final statusIcon = theme.getAssetStatusIcon(item.status);

    // แก้สี status icon ให้เหมาะกับ dark mode แต่เก็บ Unknown เป็นสีแดง
    final displayStatusColor = item.isUnknown
        ? AppColors
              .error // Unknown: ใช้สีแดง
        : (Theme.of(context).brightness == Brightness.dark
              ? theme
                    .colorScheme
                    .onSurface // Dark Mode: สีขาว/อ่อน
              : statusColor); // Light Mode: สีตาม status เดิม

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
        // Title - แก้ตาม pattern settings feature
        Text(
          item.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: item.isUnknown
                ? AppColors
                      .error // Unknown: ใช้สีแดง
                : (Theme.of(context).brightness == Brightness.dark
                      ? theme
                            .colorScheme
                            .onSurface // Dark Mode: สีขาว
                      : theme.getAssetStatusColorByItem(
                          item,
                        )), // Light Mode: สีตาม status
          ),
        ),

        AppSpacing.verticalSpaceXS,

        // Asset Number - แก้ให้อ่านง่ายใน dark mode
        Text(
          l10n.epcCodeField(item.assetNo),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors
                      .darkTextSecondary // Dark Mode: สีเทาอ่อน
                : theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ), // Light Mode: สีเทาเข้ม
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

    // แก้สี status dot ให้เหมาะกับ dark mode แต่เก็บ Unknown เป็นสีแดง
    final displayStatusColor = item.isUnknown
        ? AppColors
              .error // Unknown: ใช้สีแดง
        : (Theme.of(context).brightness == Brightness.dark
              ? theme
                    .colorScheme
                    .onSurface // Dark Mode: สีขาว/อ่อน
              : statusColor); // Light Mode: สีตาม status เดิม

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

        // Location (ถ้ามี) - แก้ให้อ่านง่ายใน dark mode
        if (item.locationName != null) ...[
          AppSpacing.horizontalSpaceMD,
          Icon(
            Icons.location_on,
            size: 12.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors
                      .darkTextMuted // Dark Mode: สีเทามาก
                : theme.colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ), // Light Mode: สีเทาอ่อน
          ),
          AppSpacing.horizontalSpaceXS,
          Expanded(
            child: Text(
              item.locationName!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors
                          .darkTextMuted // Dark Mode: สีเทามาก
                    : theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ), // Light Mode: สีเทาอ่อน
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
          : (Theme.of(context).brightness == Brightness.dark
                ? AppColors
                      .darkTextSecondary // Dark Mode: สีเทาอ่อน
                : theme.colorScheme.onSurface.withValues(
                    alpha: 0.4,
                  )), // Light Mode: สีเทาเข้ม
    );
  }

  void _navigateToDetail(BuildContext context) async {
    if (item.isUnknown) {
      // Navigate to Create Asset Page for unknown items
      final result = await Navigator.of(context).push<ScannedItemEntity>(
        MaterialPageRoute(
          builder: (context) => CreateAssetPage(
            epcCode: item.assetNo, // ← ส่ง EPC Code (ที่เก็บใน assetNo field)
            // ลบ plantCode, locationCode, locationName ออกตามเดิม
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
