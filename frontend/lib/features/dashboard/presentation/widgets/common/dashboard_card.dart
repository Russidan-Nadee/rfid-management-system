// Path: frontend/lib/core/widgets/common/dashboard_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import 'package:frontend/app/theme/app_spacing.dart';
import 'package:frontend/app/theme/app_typography.dart';
import 'package:frontend/app/theme/app_colors.dart';

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
          decoration: decoration ?? _getDefaultCardDecoration(context),
          padding: padding ?? AppSpacing.cardPaddingAll,
          child: isLoading
              ? _buildLoadingContent(context)
              : _buildContent(theme),
        ),
      ),
    );
  }

  BoxDecoration _getDefaultCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (backgroundColor != null) {
      return BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorders.large,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : null,
        boxShadow: isDark ? null : AppShadows.small,
      );
    }

    return isDark
        ? BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppBorders.large,
            border: Border.all(
              color: AppColors.darkBorder.withValues(alpha: 0.3),
            ),
          )
        : AppDecorations.dashboardCard;
  }

  Widget _buildContent(ThemeData theme) {
    // ถ้าไม่มี title หรือ trailing ให้จัดกลางแกน Y
    if (title == null && trailing == null) {
      return Center(child: child);
    }

    // ถ้ามี title หรือ trailing ใช้ layout แบบเดิม
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_buildHeader(theme), AppSpacing.verticalSpaceMedium, child],
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  AppSpacing.verticalSpaceXS,
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: _getSecondaryTextColor(theme),
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

  Widget _buildLoadingContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.backgroundSecondary,
              borderRadius: AppBorders.small,
            ),
          ),
          AppSpacing.verticalSpaceMedium,
        ],
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.backgroundSecondary,
            borderRadius: AppBorders.small,
          ),
        ),
      ],
    );
  }

  Color _getSecondaryTextColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
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
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // คำนวณขนาดตัวเลขตามหน้าจอ
    double valueFontSize;
    double iconSize;

    if (screenWidth > 1440) {
      // Desktop large
      valueFontSize = 48;
      iconSize = 32;
    } else if (screenWidth > 1024) {
      // Desktop
      valueFontSize = 40;
      iconSize = 28;
    } else if (screenWidth > 600) {
      // Tablet
      valueFontSize = 36;
      iconSize = 24;
    } else {
      // Mobile
      valueFontSize = 32;
      iconSize = 24;
    }

    return DashboardCard(
      onTap: onTap,
      decoration: _getStatCardDecoration(context),
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color:
                    iconColor ??
                    (isDark
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.primary),
              ),
              AppSpacing.verticalSpaceSmall,
            ],
            Text(
              value,
              style: AppTextStyles.statValue.copyWith(
                color:
                    valueColor ??
                    (isDark
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.primary),
                fontSize: valueFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              title,
              style: AppTextStyles.statLabel.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.verticalSpaceXS,
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: _getSecondaryTextColor(theme),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (trend != null) ...[
              AppSpacing.verticalSpaceXS,
              Center(child: _buildTrendIndicator(context)),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _getStatCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return isDark
        ? BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.darkBorder.withValues(alpha: 0.3),
            ),
          )
        : BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTrendColor = trendColor ?? _getTrendColor(theme);

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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(trendIcon, size: 12, color: effectiveTrendColor),
        AppSpacing.horizontalSpaceXS,
        Text(
          trend!,
          style: AppTextStyles.caption.copyWith(
            color: effectiveTrendColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getTrendColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    if (trend!.startsWith('+')) {
      return isDark ? AppColors.success : AppColors.trendUp;
    } else if (trend!.startsWith('-')) {
      return isDark ? AppColors.error : AppColors.trendDown;
    } else {
      return isDark ? AppColors.darkTextSecondary : AppColors.trendStable;
    }
  }

  Color _getSecondaryTextColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
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
    final theme = Theme.of(context);

    return DashboardCard(
      title: title,
      subtitle: subtitle,
      isLoading: isLoading,
      decoration: _getChartCardDecoration(context),
      trailing: onRefresh != null
          ? IconButton(
              icon: Icon(
                Icons.refresh,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
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

  BoxDecoration _getChartCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return isDark
        ? BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppBorders.large,
            border: Border.all(
              color: AppColors.darkBorder.withValues(alpha: 0.3),
            ),
          )
        : AppDecorations.card;
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
    final theme = Theme.of(context);

    return DashboardCard(
      title: title,
      decoration: _getFilterCardDecoration(context),
      trailing: hasActiveFilters && onReset != null
          ? TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
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

  BoxDecoration _getFilterCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return isDark
        ? BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppBorders.large,
            border: Border.all(
              color: AppColors.darkBorder.withValues(alpha: 0.3),
            ),
          )
        : AppDecorations.card;
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
    final color = progressColor ?? theme.colorScheme.primary;

    return DashboardCard(
      title: title,
      subtitle: subtitle,
      decoration: _getProgressCardDecoration(context),
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
                    backgroundColor: _getProgressTrackColor(theme),
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
                        color: _getSecondaryTextColor(theme),
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

  BoxDecoration _getProgressCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return isDark
        ? BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppBorders.large,
            border: Border.all(
              color: AppColors.darkBorder.withValues(alpha: 0.3),
            ),
          )
        : AppDecorations.card;
  }

  Color _getProgressTrackColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? AppColors.darkBorder.withValues(alpha: 0.5)
        : theme.dividerColor.withValues(alpha: 0.2);
  }

  Color _getSecondaryTextColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
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
    final cardColor = color ?? theme.colorScheme.primary;

    return DashboardCard(
      onTap: onTap,
      decoration: _getInfoCardDecoration(context, cardColor),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: AppSpacing.paddingSmall,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.1),
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
                    color: theme.colorScheme.onSurface,
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

  BoxDecoration _getInfoCardDecoration(BuildContext context, Color cardColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return isDark
        ? BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppBorders.large,
            border: Border.all(color: cardColor.withValues(alpha: 0.3)),
          )
        : BoxDecoration(
            color: theme.cardColor,
            borderRadius: AppBorders.large,
            border: Border.all(color: cardColor.withValues(alpha: 0.3)),
            boxShadow: AppShadows.small,
          );
  }
}
