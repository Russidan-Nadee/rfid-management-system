// Path: frontend/lib/features/export/presentation/widgets/export_type_section.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

class ExportTypeSection extends StatelessWidget {
  const ExportTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: AppColors.primary, size: 20),
            AppSpacing.horizontalSpaceSM,
            Text(
              'Export Type',
              style: AppTextStyles.cardTitle.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceLG,
        Container(
          width: double.infinity,
          padding: AppSpacing.cardPaddingAll,
          decoration: AppDecorations.buttonPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2, color: AppColors.onPrimary, size: 24),
                  AppSpacing.horizontalSpaceLG,
                  Text(
                    'Assets',
                    style: AppTextStyles.headline5.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpaceSM,
              Text(
                'Export all asset information including locations, status, and descriptions',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.onPrimary.withOpacity(0.9),
                ),
              ),
              AppSpacing.verticalSpaceXS,
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
        ),
      ],
    );
  }
}
