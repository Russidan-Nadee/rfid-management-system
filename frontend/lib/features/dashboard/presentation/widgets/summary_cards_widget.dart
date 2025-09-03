// Path: frontend/lib/features/dashboard/presentation/widgets/summary_cards_widget.dart
import 'package:flutter/material.dart';
import 'package:tp_rfid/features/dashboard/presentation/widgets/common/dashboard_card.dart';
import 'package:tp_rfid/features/dashboard/presentation/widgets/common/loading_skeleton.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/dashboard/dashboard_localizations.dart';
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
    final l10n = DashboardLocalizations.of(context);
    final screenWidth = constraints.maxWidth;

    int crossAxisCount;
    double childAspectRatio;
    EdgeInsets gridPadding;

    if (screenWidth > AppConstants.desktopBreakpoint) {
      crossAxisCount = 4;
      childAspectRatio = 1.4;
      gridPadding = const EdgeInsets.symmetric(horizontal: 50);
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      crossAxisCount = 2;
      childAspectRatio = 1.5;
      gridPadding = const EdgeInsets.symmetric(horizontal: 50);
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
      gridPadding = const EdgeInsets.symmetric(horizontal: 16);
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
            l10n: l10n,
            icon: LucideIcons.boxes,
            iconColor: isDark
                ? AppColors.chartBlue
                : AppColors.primary,
            title: l10n.allAssets,
            value: Helpers.formatNumber(stats.overview.totalAssets.value),
            trend: stats.overview.totalAssets.trend,
          ),
          _buildStatCard(
            context: context,
            l10n: l10n,
            icon: LucideIcons.packagePlus,
            iconColor: isDark
                ? AppColors.chartBlue
                : AppColors.primary,
            title: l10n.newAssets,
            value: Helpers.formatNumber(stats.overview.createdAssets.value),
            trend: stats.overview.createdAssets.trend,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required DashboardLocalizations l10n,
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
          final l10n = DashboardLocalizations.of(context);
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
                l10n: l10n,
                icon: LucideIcons.boxes,
                iconColor: isDark
                    ? AppColors.chartBlue
                    : AppColors.primary,
                labelColor: isDark
                    ? AppColors.chartBlue
                    : AppColors.primary,
                label: l10n.allAssets,
                value: Helpers.formatNumber(stats.overview.totalAssets.value),
                valueColor: isDark
                    ? AppColors.chartBlue
                    : AppColors.primary,
                trend: stats.overview.totalAssets.trend,
                theme: theme,
              ),
              _LegacySummaryCard(
                context: context,
                l10n: l10n,
                icon: LucideIcons.packagePlus,
                iconColor: isDark
                    ? AppColors.chartBlue
                    : AppColors.primary,
                labelColor: isDark
                    ? AppColors.chartBlue
                    : AppColors.primary,
                label: l10n.newAssets,
                value: Helpers.formatNumber(stats.overview.createdAssets.value),
                valueColor: isDark
                    ? AppColors.chartBlue
                    : AppColors.primary,
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
  final DashboardLocalizations l10n;
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
    required this.l10n,
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
        ],
      ),
    );
  }
}

// Enhanced Summary Cards with additional features
class EnhancedSummaryCardsWidget extends StatelessWidget {
  final DashboardStats stats;
  final bool isLoading;
  final bool showTrends;
  final bool showSubtitles;
  final VoidCallback? onAllAssetsTab;
  final VoidCallback? onNewAssetsTab;

  const EnhancedSummaryCardsWidget({
    super.key,
    required this.stats,
    this.isLoading = false,
    this.showTrends = true,
    this.showSubtitles = false,
    this.onAllAssetsTab,
    this.onNewAssetsTab,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    if (isLoading) {
      return _buildEnhancedLoadingCards(context);
    }

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _buildEnhancedGrid(context, constraints, l10n);
        },
      ),
    );
  }

  Widget _buildEnhancedGrid(
    BuildContext context,
    BoxConstraints constraints,
    DashboardLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = constraints.maxWidth;

    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > AppConstants.desktopBreakpoint) {
      crossAxisCount = 4;
      childAspectRatio = 1.2;
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: AppSpacing.medium,
      mainAxisSpacing: AppSpacing.medium,
      children: [
        _buildEnhancedStatCard(
          context: context,
          l10n: l10n,
          icon: LucideIcons.boxes,
          title: l10n.allAssets,
          value: Helpers.formatNumber(stats.overview.totalAssets.value),
          trend: showTrends ? stats.overview.totalAssets.trend : null,
          subtitle: showSubtitles ? l10n.totalAssets : null,
          onTap: onAllAssetsTab,
          color: isDark
              ? AppColors.chartBlue
              : AppColors.primary,
        ),
        _buildEnhancedStatCard(
          context: context,
          l10n: l10n,
          icon: LucideIcons.packagePlus,
          title: l10n.newAssets,
          value: Helpers.formatNumber(stats.overview.createdAssets.value),
          trend: showTrends ? stats.overview.createdAssets.trend : null,
          subtitle: showSubtitles ? l10n.assets : null,
          onTap: onNewAssetsTab,
          color: isDark
              ? AppColors.chartBlue
              : AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard({
    required BuildContext context,
    required DashboardLocalizations l10n,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? trend,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return StatCard(
      icon: icon,
      iconColor: color,
      title: title,
      value: value,
      valueColor: color,
      trend: trend,
      subtitle: subtitle,
      trendColor: trend != null
          ? _getTrendColor(trend, Theme.of(context))
          : null,
      onTap: onTap,
    );
  }

  Widget _buildEnhancedLoadingCards(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;

          if (screenWidth > AppConstants.desktopBreakpoint) {
            crossAxisCount = 4;
            childAspectRatio = 1.2;
          } else if (screenWidth > AppConstants.tabletBreakpoint) {
            crossAxisCount = 2;
            childAspectRatio = 1.3;
          } else {
            crossAxisCount = 2;
            childAspectRatio = 1.1;
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
