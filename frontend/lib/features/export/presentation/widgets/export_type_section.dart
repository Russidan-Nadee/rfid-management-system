// Path: frontend/lib/features/export/presentation/widgets/export_type_section.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';

class ExportTypeSection extends StatelessWidget {
  const ExportTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, theme, isLargeScreen),
        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xl,
          ),
        ),
        _buildAssetCard(context, theme, isLargeScreen),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    bool isLargeScreen,
  ) {
    return Row(
      children: [
        Icon(
          Icons.category,
          color: AppColors.primary,
          size: isLargeScreen ? 24 : 20,
        ),
        AppSpacing.horizontalSpaceSM,
        Text(
          'Export Type',
          style: AppTextStyles.responsive(
            context: context,
            style: AppTextStyles.cardTitle.copyWith(
              color: theme.colorScheme.onSurface,
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
    bool isLargeScreen,
  ) {
    return _buildLargeScreenCard(context);
  }

  Widget _buildLargeScreenCard(BuildContext context) {
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
      decoration: AppDecorations.buttonPrimary.copyWith(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            children: [
              Icon(Icons.inventory_2, color: AppColors.onPrimary, size: 28),
              AppSpacing.horizontalSpaceLG,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assets Export',
                      style: AppTextStyles.responsive(
                        context: context,
                        style: AppTextStyles.headline5.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        desktopFactor: 1.05,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      'Export all asset information including locations, status, and descriptions',
                      style: AppTextStyles.responsive(
                        context: context,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.onPrimary.withOpacity(0.9),
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
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: AppDecorations.custom(
              color: AppColors.onPrimary.withOpacity(0.2),
              borderRadius: AppBorders.sm,
            ),
            child: Text(
              'All Status (Active, Inactive, Created)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.location_on,
        'title': 'Location Data',
        'desc': 'Plant and location information',
      },
      {
        'icon': Icons.info,
        'title': 'Asset Details',
        'desc': 'Complete asset descriptions',
      },
      {
        'icon': Icons.analytics,
        'title': 'Status Tracking',
        'desc': 'Current and historical status',
      },
    ];

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withOpacity(0.1),
        borderRadius: AppBorders.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Includes:',
            style: AppTextStyles.button.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          ...features.map((feature) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    color: AppColors.onPrimary,
                    size: 18,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          feature['desc'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
