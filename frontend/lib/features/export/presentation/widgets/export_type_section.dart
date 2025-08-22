import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
import 'package:frontend/l10n/features/export/export_localizations.dart';

class ExportTypeSection extends StatelessWidget {
  const ExportTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;
    final l10n = ExportLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, theme, isDark, isLargeScreen, l10n),
        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xl,
          ),
        ),
        _buildAssetCard(context, theme, isDark, isLargeScreen, l10n),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isLargeScreen,
    ExportLocalizations l10n,
  ) {
    return Row(
      children: [
        Icon(
          Icons.category,
          color: isDark ? theme.colorScheme.primary : theme.colorScheme.primary,
          size: isLargeScreen ? 24 : 20,
        ),
        AppSpacing.horizontalSpaceSM,
        Text(
          l10n.exportType, // แทน Export Type
          style: AppTextStyles.responsive(
            context: context,
            style: AppTextStyles.cardTitle.copyWith(
              color: isDark ? AppColors.darkText : theme.colorScheme.onSurface,
            ),
            desktopFactor: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isLargeScreen,
    ExportLocalizations l10n,
  ) {
    return _buildLargeScreenCard(context, theme, isDark, l10n);
  }

  Widget _buildLargeScreenCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        AppSpacing.responsiveSpacing(
          context,
          mobile: AppSpacing.lg,
          tablet: AppSpacing.xl,
          desktop: AppSpacing.xl,
        ),
      ),
      decoration: _buildCardDecoration(theme, isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            children: [
              Icon(
                Icons.inventory_2,
                color: isDark ? AppColors.onPrimary : AppColors.onPrimary,
                size: 28,
              ),
              AppSpacing.horizontalSpaceLG,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.assetsExport, // แทน Assets Export
                      style: AppTextStyles.responsive(
                        context: context,
                        style: AppTextStyles.headline5.copyWith(
                          color: isDark
                              ? AppColors.onPrimary
                              : AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        desktopFactor: 1.05,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      l10n.assetsExportDescription, // แทนรายละเอียดคำอธิบาย
                      style: AppTextStyles.responsive(
                        context: context,
                        style: AppTextStyles.body2.copyWith(
                          color: isDark
                              ? AppColors.onPrimary.withValues(alpha: 0.9)
                              : AppColors.onPrimary.withValues(alpha: 0.9),
                        ),
                        desktopFactor: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceLG,

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: _buildBadgeDecoration(isDark),
            child: Text(
              l10n.allStatusLabel, // แทนข้อความสถานะ
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.onPrimary : AppColors.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration(ThemeData theme, bool isDark) {
    if (isDark) {
      // Dark theme: ใช้ gradient ที่อ่อนลง
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: AppBorders.lg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      );
    } else {
      // Light theme: ใช้ gradient เดิม
      return AppDecorations.buttonPrimary.copyWith(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      );
    }
  }

  BoxDecoration _buildBadgeDecoration(bool isDark) {
    return AppDecorations.custom(
      color: AppColors.onPrimary.withValues(alpha: isDark ? 0.15 : 0.2),
      borderRadius: AppBorders.sm,
    );
  }
}
