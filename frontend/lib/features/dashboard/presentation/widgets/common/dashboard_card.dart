// Path: frontend/lib/core/widgets/common/dashboard_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_decorations.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/constants/app_typography.dart';

class DashboardCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool isLoading;
  final Color? backgroundColor;
  final BoxDecoration? decoration;
  final double? elevation;

  const DashboardCard({
    super.key,
    this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.isLoading = false,
    this.backgroundColor,
    this.decoration,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.large,
        child: Container(
          decoration:
              decoration ??
              AppDecorations.dashboardCard.copyWith(
                color: backgroundColor ?? theme.cardColor,
              ),
          padding: padding ?? AppSpacing.cardPaddingAll,
          child: isLoading ? _buildLoadingContent() : _buildContent(theme),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null || trailing != null) ...[
          _buildHeader(theme),
          AppSpacing.verticalSpaceMedium,
        ],
        child,
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (title != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                if (subtitle != null) ...[
                  AppSpacing.verticalSpaceXS,
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (trailing != null) trailing!,
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Container(
            width: 120,
            height: 16,
            decoration: AppDecorations.skeleton,
          ),
          AppSpacing.verticalSpaceMedium,
        ],
        Container(
          width: double.infinity,
          height: 100,
          decoration: AppDecorations.skeleton,
        ),
      ],
    );
  }
}

// Specialized Dashboard Cards
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;
  final String? trend;
  final Color? trendColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.trend,
    this.trendColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardCard(
      onTap: onTap,
      decoration: AppDecorations.summaryCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24, color: iconColor ?? theme.primaryColor),
            AppSpacing.verticalSpaceMedium,
          ],
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              color: valueColor ?? theme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceSmall,
          Text(
            title,
            style: AppTextStyles.statLabel.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            AppSpacing.verticalSpaceXS,
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (trend != null) ...[
            AppSpacing.verticalSpaceXS,
            _buildTrendIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    IconData trendIcon;
    if (trend!.startsWith('+')) {
      trendIcon = Icons.trending_up;
    } else if (trend!.startsWith('-')) {
      trendIcon = Icons.trending_down;
    } else {
      trendIcon = Icons.trending_flat;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(trendIcon, size: 12, color: trendColor),
        AppSpacing.horizontalSpaceXS,
        Text(
          trend!,
          style: AppTextStyles.caption.copyWith(
            color: trendColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final String? subtitle;
  final Widget? legend;
  final Widget? filters;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.legend,
    this.filters,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: title,
      subtitle: subtitle,
      isLoading: isLoading,
      trailing: onRefresh != null
          ? IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: onRefresh,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filters != null) ...[filters!, AppSpacing.verticalSpaceMedium],
          chart,
          if (legend != null) ...[AppSpacing.verticalSpaceMedium, legend!],
        ],
      ),
    );
  }
}

class FilterCard extends StatelessWidget {
  final String title;
  final List<Widget> filters;
  final VoidCallback? onReset;
  final bool hasActiveFilters;

  const FilterCard({
    super.key,
    required this.title,
    required this.filters,
    this.onReset,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: title,
      trailing: hasActiveFilters && onReset != null
          ? TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            )
          : null,
      child: Wrap(
        spacing: AppSpacing.small,
        runSpacing: AppSpacing.small,
        children: filters,
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final double progress; // 0.0 to 1.0
  final String progressText;
  final String? subtitle;
  final Color? progressColor;
  final Widget? details;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.progressText,
    this.subtitle,
    this.progressColor,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = progressColor ?? theme.primaryColor;

    return DashboardCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          // Circular Progress
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: theme.dividerColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      progressText,
                      style: AppTextStyles.statValue.copyWith(
                        fontSize: 24,
                        color: color,
                      ),
                    ),
                    Text(
                      'Complete',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (details != null) ...[AppSpacing.verticalSpaceMedium, details!],
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? action;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.color,
    this.onTap,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.primaryColor;

    return DashboardCard(
      onTap: onTap,
      decoration: AppDecorations.card.copyWith(
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: AppSpacing.paddingSmall,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: AppBorders.medium,
              ),
              child: Icon(icon, color: cardColor, size: 24),
            ),
            AppSpacing.horizontalSpaceMedium,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cardColor,
                  ),
                ),
                AppSpacing.verticalSpaceXS,
                Text(
                  message,
                  style: AppTextStyles.body2.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[AppSpacing.horizontalSpaceMedium, action!],
        ],
      ),
    );
  }
}
