// Path: frontend/lib/features/export/presentation/widgets/export_item_card.dart
import 'package:flutter/material.dart';
import 'package:tp_rfid/l10n/features/export/export_localizations.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge =
        isLargeScreen ?? (screenWidth >= AppConstants.tabletBreakpoint);

    print(
      '🔍 Export ${export.exportId}: status=${export.status}, canDownload=${export.canDownload}',
    );

    if (isLarge) {
      return _buildLargeScreenCard(context, theme, isDark);
    } else {
      return _buildCompactCard(context, theme, isDark);
    }
  }

  Widget _buildLargeScreenCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    final l10n = ExportLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: _buildCardDecoration(theme, isDark, true),
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
            // Status Icon
            Container(
              padding: AppSpacing.paddingMD,
              decoration: _buildStatusIconDecoration(isDark),
              child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
            ),

            AppSpacing.horizontalSpaceXL,

            // Export ID
            Text(
              '${l10n.exportIdNumber}${export.exportId}',
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.headline6.copyWith(
                  color: isDark
                      ? AppColors.darkText
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                desktopFactor: 1.1,
              ),
            ),

            AppSpacing.horizontalSpaceXL,

            // Status Badge
            _buildStatusBadge(context, isDark),

            AppSpacing.horizontalSpaceXL,

            // Records
            if (export.totalRecords != null) ...[
              Icon(
                Icons.numbers,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.info,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                '${export.totalRecords} ${l10n.records}',
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.horizontalSpaceXL,
            ],

            // Created Date
            Icon(
              Icons.schedule,
              size: 16,
              color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
            ),
            AppSpacing.horizontalSpaceXS,
            Text(
              _formatDate(export.createdAt),
              style: AppTextStyles.body2.copyWith(
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            AppSpacing.horizontalSpaceXL,

            // File Size
            if (export.fileSize != null) ...[
              Icon(
                Icons.storage,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.success,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                export.fileSizeFormatted,
                style: AppTextStyles.body2.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            // Spacer to push download button to the right
            const Spacer(),

            // Download Button
            _buildActionButton(context, isDark, true),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = ExportLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: _buildCardDecoration(theme, isDark, false),
      child: ListTile(
        contentPadding: AppSpacing.paddingLG,
        leading: _buildStatusIcon(isDark),
        title: Text(
          '${l10n.exportId}: ${export.exportId}',
          style: AppTextStyles.cardTitle.copyWith(
            color: isDark ? AppColors.darkText : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: _buildCompactDetails(context, isDark),
        ),
        trailing: _buildActionButton(context, isDark, false),
      ),
    );
  }

  Widget _buildCompactDetails(BuildContext context, bool isDark) {
    final l10n = ExportLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.status}: ${export.statusLabel}',
          style: AppTextStyles.cardSubtitle.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        if (export.totalRecords != null) ...[
          AppSpacing.verticalSpaceXS,
          Text(
            '${l10n.totalRecords}: ${export.totalRecords}',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textTertiary,
            ),
          ),
        ],
        AppSpacing.verticalSpaceXS,
        Text(
          '${l10n.createdAt}: ${_formatDate(export.createdAt)}',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(bool isDark) {
    return Container(
      padding: AppSpacing.paddingXS,
      decoration: _buildStatusIconDecoration(isDark),
      child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: AppBorders.sm,
        border: Border.all(
          color: _getStatusColor().withValues(alpha: isDark ? 0.4 : 0.3),
        ),
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

  Widget _buildActionButton(BuildContext context, bool isDark, bool isLarge) {
    final canDownload = export.canDownload;
    final l10n = ExportLocalizations.of(context);

    if (isLarge) {
      return Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          color: canDownload
              ? AppColors.primary
              : (isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.backgroundSecondary),
          borderRadius: AppBorders.md,
          boxShadow: canDownload
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
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
                      : (isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted),
                  size: 18,
                ),
                AppSpacing.horizontalSpaceXS,
                Text(
                  l10n.download,
                  style: AppTextStyles.caption.copyWith(
                    color: canDownload
                        ? AppColors.onPrimary
                        : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted),
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
          color: canDownload
              ? AppColors.primary
              : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
        ),
      );
    }
  }

  BoxDecoration _buildCardDecoration(
    ThemeData theme,
    bool isDark,
    bool isLarge,
  ) {
    return AppDecorations.card.copyWith(
      color: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
      border: Border.all(
        color: isDark
            ? AppColors.darkBorder.withValues(alpha: 0.3)
            : AppColors.cardBorder,
        width: 1,
      ),
      boxShadow: isLarge
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
          : AppDecorations.card.boxShadow,
    );
  }

  BoxDecoration _buildStatusIconDecoration(bool isDark) {
    return AppDecorations.custom(
      color: _getStatusColor().withValues(alpha: isDark ? 0.2 : 0.1),
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
