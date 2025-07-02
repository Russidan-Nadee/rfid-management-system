// Path: frontend/lib/features/export/presentation/widgets/export_item_card.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
import '../../domain/entities/export_job_entity.dart';

class ExportItemCard extends StatelessWidget {
  final ExportJobEntity export;
  final VoidCallback onTap;
  final bool? isLargeScreen;

  const ExportItemCard({
    super.key,
    required this.export,
    required this.onTap,
    this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge =
        isLargeScreen ?? (screenWidth >= AppConstants.tabletBreakpoint);

    print(
      '🔍 Export ${export.exportId}: status=${export.status}, canDownload=${export.canDownload}',
    );

    if (isLarge) {
      return _buildLargeScreenCard(context, theme);
    } else {
      return _buildCompactCard(context, theme);
    }
  }

  Widget _buildLargeScreenCard(BuildContext context, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: _buildCardDecoration(theme, true),
      child: Padding(
        padding: EdgeInsets.all(
          AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xl,
          ),
        ),
        child: Row(
          children: [
            // Status Icon (larger)
            Container(
              padding: AppSpacing.paddingMD,
              decoration: _buildStatusIconDecoration(),
              child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
            ),

            AppSpacing.horizontalSpaceXL,

            // Content (expanded)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Export #${export.exportId}',
                        style: AppTextStyles.responsive(
                          context: context,
                          style: AppTextStyles.headline6.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          desktopFactor: 1.1,
                        ),
                      ),
                      _buildStatusBadge(context),
                    ],
                  ),

                  AppSpacing.verticalSpaceSM,

                  // Export details in grid
                  _buildDetailsGrid(context, theme),
                ],
              ),
            ),

            AppSpacing.horizontalSpaceXL,

            // Action button (enhanced)
            _buildActionButton(context, true),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: _buildCardDecoration(theme, false),
      child: ListTile(
        contentPadding: AppSpacing.paddingLG,
        leading: _buildStatusIcon(),
        title: Text(
          'Export ID: ${export.exportId}',
          style: AppTextStyles.cardTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: AppSpacing.xs),
          child: _buildCompactDetails(context),
        ),
        trailing: _buildActionButton(context, false),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                icon: Icons.analytics,
                label: 'Status',
                value: export.statusLabel,
                color: _getStatusColor(),
              ),
            ),
            if (export.totalRecords != null)
              Expanded(
                child: _buildDetailItem(
                  context,
                  icon: Icons.numbers,
                  label: 'Records',
                  value: export.totalRecords.toString(),
                  color: AppColors.info,
                ),
              ),
          ],
        ),
        AppSpacing.verticalSpaceSM,
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                icon: Icons.schedule,
                label: 'Created',
                value: _formatDate(export.createdAt),
                color: AppColors.textSecondary,
              ),
            ),
            if (export.fileSize != null)
              Expanded(
                child: _buildDetailItem(
                  context,
                  icon: Icons.storage,
                  label: 'Size',
                  value: export.fileSizeFormatted,
                  color: AppColors.success,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        AppSpacing.horizontalSpaceXS,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status: ${export.statusLabel}',
          style: AppTextStyles.cardSubtitle,
        ),
        if (export.totalRecords != null) ...[
          AppSpacing.verticalSpaceXS,
          Text(
            'Records: ${export.totalRecords}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
        AppSpacing.verticalSpaceXS,
        Text(
          'Created: ${_formatDate(export.createdAt)}',
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      padding: AppSpacing.paddingXS,
      decoration: _buildStatusIconDecoration(),
      child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: AppBorders.sm,
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Text(
        export.statusLabel,
        style: AppTextStyles.caption.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isLarge) {
    final canDownload = export.canDownload;

    if (isLarge) {
      return Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          color: canDownload
              ? AppColors.primary
              : AppColors.backgroundSecondary,
          borderRadius: AppBorders.md,
          boxShadow: canDownload
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canDownload ? onTap : null,
            borderRadius: AppBorders.md,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download,
                  color: canDownload
                      ? AppColors.onPrimary
                      : AppColors.textMuted,
                  size: 18,
                ),
                AppSpacing.horizontalSpaceXS,
                Text(
                  'Download',
                  style: AppTextStyles.caption.copyWith(
                    color: canDownload
                        ? AppColors.onPrimary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return IconButton(
        onPressed: canDownload ? onTap : null,
        icon: Icon(
          Icons.file_upload,
          color: canDownload ? AppColors.primary : AppColors.textMuted,
        ),
      );
    }
  }

  BoxDecoration _buildCardDecoration(ThemeData theme, bool isLarge) {
    return AppDecorations.card.copyWith(
      boxShadow: isLarge
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
          : AppDecorations.card.boxShadow,
    );
  }

  BoxDecoration _buildStatusIconDecoration() {
    return AppDecorations.custom(
      color: _getStatusColor().withOpacity(0.1),
      borderRadius: AppBorders.circular,
    );
  }

  Color _getStatusColor() {
    if (export.isCompleted) {
      return AppColors.success;
    } else if (export.isFailed) {
      return AppColors.error;
    } else {
      return AppColors.warning;
    }
  }

  IconData _getStatusIcon() {
    if (export.isCompleted) {
      return Icons.check_circle;
    } else if (export.isFailed) {
      return Icons.error;
    } else {
      return Icons.hourglass_empty;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
