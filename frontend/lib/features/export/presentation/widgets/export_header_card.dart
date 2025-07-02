// Path: frontend/lib/features/export/presentation/widgets/export_header_card.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';

class ExportHeaderCard extends StatelessWidget {
  const ExportHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;

    return Container(
      padding: _getResponsivePadding(context, isLargeScreen),
      decoration: _buildCardDecoration(theme, isLargeScreen),
      child: _buildContent(context, theme, isLargeScreen),
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

  BoxDecoration _buildCardDecoration(ThemeData theme, bool isLargeScreen) {
    return AppDecorations.card.copyWith(
      color: AppColors.primarySurface,
      border: Border.all(
        color: AppColors.primary.withOpacity(0.2),
        width: isLargeScreen ? 2 : 1,
      ),
      boxShadow: isLargeScreen
          ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isLargeScreen,
  ) {
    if (isLargeScreen) {
      return _buildLargeScreenContent(context, theme);
    } else {
      return _buildCompactContent(context, theme);
    }
  }

  Widget _buildLargeScreenContent(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Icon section
        Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: AppDecorations.custom(
            color: AppColors.primary,
            borderRadius: AppBorders.lg,
          ),
          child: Icon(Icons.settings, color: AppColors.onPrimary, size: 32),
        ),

        AppSpacing.horizontalSpaceXL,

        // Content section (expanded to fill remaining width)
        Expanded(
          child: Row(
            children: [
              // Text content
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Configuration',
                      style: AppTextStyles.responsive(
                        context: context,
                        style: AppTextStyles.headline4.copyWith(
                          color: _getTextColor(theme),
                          fontWeight: FontWeight.bold,
                        ),
                        desktopFactor: 1.1,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      'Configure your export format and filters to generate custom reports',
                      style: AppTextStyles.responsive(
                        context: context,
                        style: AppTextStyles.body1.copyWith(
                          color: _getSubtitleColor(theme),
                        ),
                        desktopFactor: 1.05,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.horizontalSpaceXL,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: AppSpacing.paddingSM,
          decoration: AppDecorations.custom(
            color: AppColors.primary,
            borderRadius: AppBorders.sm,
          ),
          child: Icon(Icons.settings, color: AppColors.onPrimary, size: 20),
        ),
        AppSpacing.horizontalSpaceLG,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Configuration',
                style: AppTextStyles.cardTitle.copyWith(
                  color: _getTextColor(theme),
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                'Configure your export format and filters',
                style: AppTextStyles.cardSubtitle.copyWith(
                  color: _getSubtitleColor(theme),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTextColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? AppColors.onPrimary
        : AppColors.textPrimary;
  }

  Color _getSubtitleColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? AppColors.onPrimary.withOpacity(0.8)
        : AppColors.textSecondary;
  }
}
