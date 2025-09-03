// Path: frontend/lib/features/dashboard/presentation/widgets/summary_section_widget.dart
import 'package:flutter/material.dart';
import 'package:tp_rfid/features/dashboard/presentation/widgets/common/dashboard_card.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/dashboard/dashboard_localizations.dart';
import '../../domain/entities/dashboard_stats.dart';

class SummarySectionWidget extends StatelessWidget {
  final DashboardStats? stats;

  const SummarySectionWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = DashboardLocalizations.of(context);

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // All Assets Card
        Expanded(
          child: StatCard(
            title: l10n.allAssets,
            value: Helpers.formatNumber(
              stats!.overview.totalAssets.value,
            ),
            icon: Icons.inventory,
            iconColor: theme.brightness == Brightness.dark
                ? AppColors.chartBlue
                : AppColors.primary,
            valueColor: theme.brightness == Brightness.dark
                ? AppColors.chartBlue
                : AppColors.primary,
            trend: stats!.overview.totalAssets.trend,
          ),
        ),
        AppSpacing.verticalSpaceMedium,

        // New Assets Card
        Expanded(
          child: StatCard(
            title: l10n.newAssets,
            value: Helpers.formatNumber(
              stats!.overview.createdAssets.value,
            ),
            icon: Icons.add_circle,
            iconColor: theme.brightness == Brightness.dark
                ? AppColors.chartBlue
                : AppColors.primary,
            valueColor: theme.brightness == Brightness.dark
                ? AppColors.chartBlue
                : AppColors.primary,
            trend: stats!.overview.createdAssets.trend,
          ),
        ),
      ],
    );
  }
}