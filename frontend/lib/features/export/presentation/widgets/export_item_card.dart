// Path: frontend/lib/features/export/presentation/widgets/export_item_card.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/export_job_entity.dart';

class ExportItemCard extends StatelessWidget {
  final ExportJobEntity export;
  final VoidCallback onTap;

  const ExportItemCard({super.key, required this.export, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    print(
      '🔍 Export ${export.exportId}: status=${export.status}, canDownload=${export.canDownload}',
    );

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: AppDecorations.card,
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
          child: Column(
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
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          onPressed: export.canDownload ? onTap : null,
          icon: Icon(
            Icons.file_upload,
            color: export.canDownload ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    Color iconColor;
    IconData iconData;

    if (export.isCompleted) {
      iconColor = AppColors.success;
      iconData = Icons.check_circle;
    } else if (export.isFailed) {
      iconColor = AppColors.error;
      iconData = Icons.error;
    } else {
      iconColor = AppColors.warning;
      iconData = Icons.hourglass_empty;
    }

    return Container(
      padding: AppSpacing.paddingXS,
      decoration: AppDecorations.custom(
        color: iconColor.withOpacity(0.1),
        borderRadius: AppBorders.circular,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
