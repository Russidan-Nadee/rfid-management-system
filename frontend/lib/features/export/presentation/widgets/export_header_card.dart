// Path: frontend/lib/features/export/presentation/widgets/export_header_card.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
import '../../../../l10n/features/export/export_localizations.dart';

class ExportHeaderCard extends StatelessWidget {
  const ExportHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;
    final l10n = ExportLocalizations.of(context);

    return Container(
      padding: _getResponsivePadding(context, isLargeScreen),
      decoration: _buildCardDecoration(theme, isDark, isLargeScreen),
      child: _buildContent(context, theme, isDark, isLargeScreen, l10n),
    );
  }

  EdgeInsets _getResponsivePadding(BuildContext context, bool isLargeScreen) {
    return EdgeInsets.all(
      AppSpacing.responsiveSpacing(
        context,
        mobile: AppSpacing.lg,
        tablet: AppSpacing.xl,
        desktop: AppSpacing.xl,
      ),
    );
  }

  BoxDecoration _buildCardDecoration(
    ThemeData theme,
    bool isDark,
    bool isLargeScreen,
  ) {
    return AppDecorations.card.copyWith(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.primarySurface,
      border: Border.all(
        color: isDark
            ? AppColors.darkBorder.withValues(alpha: 0.3)
            : AppColors.primary.withValues(alpha: 0.2),
        width: isLargeScreen ? 2 : 1,
      ),
      boxShadow: isLargeScreen
          ? [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isLargeScreen,
    ExportLocalizations l10n,
  ) {
    if (isLargeScreen) {
      return _buildLargeScreenContent(context, theme, isDark, l10n);
    } else {
      return _buildCompactContent(context, theme, isDark, l10n);
    }
  }

  Widget _buildLargeScreenContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    return Row(
      children: [
        // Icon section
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: AppDecorations.custom(
            color: AppColors.primary,
            borderRadius: AppBorders.lg,
          ),
          child: const Icon(Icons.settings, color: AppColors.onPrimary, size: 32),
        ),

        AppSpacing.horizontalSpaceXL,

        // Content section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.exportConfiguration,
                style: AppTextStyles.responsive(
                  context: context,
                  style: AppTextStyles.headline4.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  desktopFactor: 1.1,
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                l10n.exportConfigurationDescription,
                style: AppTextStyles.responsive(
                  context: context,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  desktopFactor: 1.05,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    return Row(
      children: [
        Container(
          padding: AppSpacing.paddingSM,
          decoration: AppDecorations.custom(
            color: AppColors.primary,
            borderRadius: AppBorders.sm,
          ),
          child: const Icon(Icons.settings, color: AppColors.onPrimary, size: 20),
        ),
        AppSpacing.horizontalSpaceLG,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.exportConfiguration,
                style: AppTextStyles.cardTitle.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                l10n.exportConfigurationDescription,
                style: AppTextStyles.cardSubtitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
