// Path: frontend/lib/features/dashboard/presentation/widgets/summary_cards_widget.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/widgets/common/dashboard_card.dart';
import 'package:frontend/features/dashboard/presentation/widgets/common/loading_skeleton.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/dashboard_stats.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SummaryCardsWidget extends StatelessWidget {
  final DashboardStats stats;
  final bool isLoading;

  const SummaryCardsWidget({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCards(context);
    }

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _buildResponsiveGrid(context, constraints);
        },
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final screenWidth = constraints.maxWidth;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > AppConstants.desktopBreakpoint) {
      // Desktop - 4 columns
      crossAxisCount = 4;
      childAspectRatio = 1.3;
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      // Tablet - 2 columns
      crossAxisCount = 2;
      childAspectRatio = 1.4;
    } else {
      // Mobile - 2 columns
      crossAxisCount = 2;
      childAspectRatio = 1.2;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: AppSpacing.medium,
      mainAxisSpacing: AppSpacing.medium,
      children: [
        _buildStatCard(
          icon: LucideIcons.boxes,
          iconColor: AppColors.primary,
          title: 'All Assets',
          value: Helpers.formatNumber(stats.overview.totalAssets.value),
          trend: stats.overview.totalAssets.trend,
          trendColor: _getTrendColor(stats.overview.totalAssets.trend),
        ),
        _buildStatCard(
          icon: LucideIcons.packagePlus,
          iconColor: AppColors.assetActive,
          title: 'New Assets',
          value: Helpers.formatNumber(stats.overview.createdAssets.value),
          trend: stats.overview.createdAssets.trend,
          trendColor: _getTrendColor(stats.overview.createdAssets.trend),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String trend,
    required Color trendColor,
  }) {
    return StatCard(
      icon: icon,
      iconColor: iconColor,
      title: title,
      value: value,
      valueColor: iconColor,
      trendColor: trendColor,
    );
  }

  Widget _buildLoadingCards(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;

          if (screenWidth > AppConstants.desktopBreakpoint) {
            crossAxisCount = 4;
            childAspectRatio = 1.3;
          } else if (screenWidth > AppConstants.tabletBreakpoint) {
            crossAxisCount = 2;
            childAspectRatio = 1.4;
          } else {
            crossAxisCount = 2;
            childAspectRatio = 1.2;
          }

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: AppSpacing.medium,
            mainAxisSpacing: AppSpacing.medium,
            children: List.generate(
              2, // Show 2 loading cards
              (index) => const SkeletonStatCard(),
            ),
          );
        },
      ),
    );
  }

  Color _getTrendColor(String trend) {
    if (trend.startsWith('+')) {
      return AppColors.trendUp;
    } else if (trend.startsWith('-')) {
      return AppColors.trendDown;
    } else {
      return AppColors.trendStable;
    }
  }
}

// Legacy component for backward compatibility (if needed)
class LegacySummaryCardsWidget extends StatelessWidget {
  final DashboardStats stats;
  final bool isLoading;

  const LegacySummaryCardsWidget({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCards(context);
    }

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;

          if (screenWidth > AppConstants.desktopBreakpoint) {
            crossAxisCount = 4;
            childAspectRatio = 1.3;
          } else if (screenWidth > AppConstants.tabletBreakpoint) {
            crossAxisCount = 2;
            childAspectRatio = 1.4;
          } else {
            crossAxisCount = 2;
            childAspectRatio = 1.2;
          }

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: AppSpacing.medium,
            mainAxisSpacing: AppSpacing.medium,
            children: [
              _LegacySummaryCard(
                icon: LucideIcons.boxes,
                iconColor: AppColors.primary,
                label: 'All Assets',
                labelColor: AppColors.primary,
                value: Helpers.formatNumber(stats.overview.totalAssets.value),
                valueColor: AppColors.primary,
                trend: stats.overview.totalAssets.trend,
              ),
              _LegacySummaryCard(
                icon: LucideIcons.packagePlus,
                iconColor: AppColors.assetActive,
                labelColor: AppColors.assetActive,
                label: 'New Assets',
                value: Helpers.formatNumber(stats.overview.createdAssets.value),
                valueColor: AppColors.assetActive,
                trend: stats.overview.createdAssets.trend,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingCards(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;

          if (screenWidth > AppConstants.desktopBreakpoint) {
            crossAxisCount = 4;
            childAspectRatio = 1.3;
          } else if (screenWidth > AppConstants.tabletBreakpoint) {
            crossAxisCount = 2;
            childAspectRatio = 1.4;
          } else {
            crossAxisCount = 2;
            childAspectRatio = 1.2;
          }

          return SkeletonGrid(
            itemCount: 2,
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
          );
        },
      ),
    );
  }
}

class _LegacySummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;
  final Color? labelColor;
  final String trend;

  const _LegacySummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.iconColor,
    this.labelColor,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardCard(
      decoration: theme.cardTheme.shape != null
          ? BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16), // Use AppBorders.xl
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: iconColor),
          AppSpacing.verticalSpaceMedium,
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(color: valueColor),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceSmall,
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(color: labelColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
