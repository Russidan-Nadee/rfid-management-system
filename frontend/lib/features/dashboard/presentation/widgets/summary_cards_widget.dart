// Path: frontend/lib/features/dashboard/presentation/widgets/summary_cards_widget.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/widgets/common/dashboard_card.dart';
import 'package:frontend/features/dashboard/presentation/widgets/common/loading_skeleton.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = constraints.maxWidth;

    int crossAxisCount;
    double childAspectRatio;
    EdgeInsets gridPadding;

    if (screenWidth > AppConstants.desktopBreakpoint) {
      crossAxisCount = 4;
      childAspectRatio = 1.4;
      gridPadding = EdgeInsets.symmetric(horizontal: 50);
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      crossAxisCount = 2;
      childAspectRatio = 1.5;
      gridPadding = EdgeInsets.symmetric(horizontal: 50);
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
      gridPadding = EdgeInsets.symmetric(horizontal: 16);
    }

    return Padding(
      padding: gridPadding,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: AppSpacing.medium,
        mainAxisSpacing: AppSpacing.medium,
        children: [
          _buildStatCard(
            context: context,
            icon: LucideIcons.boxes,
            iconColor: isDark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
            title: 'All Assets',
            value: Helpers.formatNumber(stats.overview.totalAssets.value),
            trend: stats.overview.totalAssets.trend,
          ),
          _buildStatCard(
            context: context,
            icon: LucideIcons.packagePlus,
            iconColor: isDark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
            title: 'New Assets',
            value: Helpers.formatNumber(stats.overview.createdAssets.value),
            trend: stats.overview.createdAssets.trend,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String trend,
  }) {
    final theme = Theme.of(context);

    return StatCard(
      icon: icon,
      iconColor: iconColor,
      title: title,
      value: value,
      valueColor: iconColor,
      trend: trend,
      trendColor: _getTrendColor(trend, theme),
    );
  }

  Widget _buildLoadingCards(BuildContext context) {
    final theme = Theme.of(context);

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
              (index) => _buildLoadingCard(theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.cardPaddingAll,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : null,
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: SkeletonLoader(
        isLoading: true,
        baseColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300,
        highlightColor: isDark ? AppColors.darkBorder : Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSpacing.verticalSpaceMedium,
            Container(
              width: 80,
              height: 28,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSpacing.verticalSpaceSmall,
            Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(String trend, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    if (trend.startsWith('+')) {
      return isDark ? AppColors.success : AppColors.trendUp;
    } else if (trend.startsWith('-')) {
      return isDark ? AppColors.error : AppColors.trendDown;
    } else {
      return isDark ? AppColors.darkTextSecondary : AppColors.trendStable;
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
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
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
                context: context,
                icon: LucideIcons.boxes,
                iconColor: isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
                labelColor: isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
                label: 'All Assets',
                value: Helpers.formatNumber(stats.overview.totalAssets.value),
                valueColor: isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
                trend: stats.overview.totalAssets.trend,
                theme: theme,
              ),
              _LegacySummaryCard(
                context: context,
                icon: LucideIcons.packagePlus,
                iconColor: isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
                labelColor: isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
                label: 'New Assets',
                value: Helpers.formatNumber(stats.overview.createdAssets.value),
                valueColor: isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
                trend: stats.overview.createdAssets.trend,
                theme: theme,
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
  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;
  final Color? labelColor;
  final String trend;
  final ThemeData theme;

  const _LegacySummaryCard({
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.iconColor,
    this.labelColor,
    required this.trend,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return DashboardCard(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : theme.cardColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : null,
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: iconColor),
          AppSpacing.verticalSpaceMedium,
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              color: valueColor,
              fontSize: 24, // Slightly smaller for mobile
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceSmall,
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(
              color: isDark ? AppColors.darkTextSecondary : labelColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (trend.isNotEmpty) ...[
            AppSpacing.verticalSpaceXS,
            _buildTrendIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isDark = theme.brightness == Brightness.dark;
    IconData trendIcon;
    Color trendColor;

    if (trend.startsWith('+')) {
      trendIcon = Icons.trending_up;
      trendColor = isDark ? AppColors.success : AppColors.trendUp;
    } else if (trend.startsWith('-')) {
      trendIcon = Icons.trending_down;
      trendColor = isDark ? AppColors.error : AppColors.trendDown;
    } else {
      trendIcon = Icons.trending_flat;
      trendColor = isDark ? AppColors.darkTextSecondary : AppColors.trendStable;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(trendIcon, size: 12, color: trendColor),
        AppSpacing.horizontalSpaceXS,
        Text(
          trend,
          style: AppTextStyles.caption.copyWith(
            color: trendColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
