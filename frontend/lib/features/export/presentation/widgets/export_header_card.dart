// Path: frontend/lib/features/export/presentation/widgets/export_header_card.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

class ExportHeaderCard extends StatelessWidget {
  const ExportHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.cardPaddingAll,
      decoration: AppDecorations.card.copyWith(
        color: AppColors.primarySurface,
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
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
                    color: theme.brightness == Brightness.dark
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalSpaceXS,
                Text(
                  'Configure your export format and filters',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.onPrimary.withOpacity(0.8)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
