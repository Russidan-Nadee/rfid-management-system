// Path: frontend/lib/features/dashboard/presentation/widgets/asset_distribution_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as charts;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../domain/entities/asset_distribution.dart';
import 'common/dashboard_card.dart';
import 'common/empty_state.dart';
import 'common/loading_skeleton.dart';

class AssetDistributionChartWidget extends StatelessWidget {
  final AssetDistribution distribution;
  final bool isLoading;

  const AssetDistributionChartWidget({
    super.key,
    required this.distribution,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    return ChartCard(
      title: 'Asset Distribution',
      chart: SizedBox(
        height: 200,
        child: distribution.hasData ? _buildPieChart() : _buildEmptyState(),
      ),
      legend: distribution.hasData ? _buildLegend(context) : null,
      filters: distribution.hasData ? _buildSummary(context) : null,
    );
  }

  Widget _buildPieChart() {
    return charts.PieChart(
      charts.PieChartData(
        sections: distribution.pieChartData.map((data) {
          return charts.PieChartSectionData(
            value: data.value.toDouble(),
            title: data.formattedPercentage,
            color: _getColorForIndex(distribution.pieChartData.indexOf(data)),
            radius: 60,
            titleStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 0,
        centerSpaceRadius: 30,
        pieTouchData: charts.PieTouchData(
          touchCallback:
              (
                charts.FlTouchEvent event,
                charts.PieTouchResponse? pieTouchResponse,
              ) {},
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.backgroundSecondary,
        borderRadius: AppBorders.medium,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : null,
      ),
      child: Wrap(
        spacing: AppSpacing.medium,
        runSpacing: AppSpacing.small,
        children: distribution.pieChartData.map((data) {
          final colorIndex = distribution.pieChartData.indexOf(data);
          return _buildLegendItem(
            context,
            color: _getColorForIndex(colorIndex),
            label: data.displayName,
            value: data.value.toString(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        AppSpacing.horizontalSpaceXS,
        Text(
          '$label ($value)',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.backgroundSecondary,
        borderRadius: AppBorders.medium,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            label: 'Total Assets',
            value: distribution.summary.totalAssets.toString(),
            icon: Icons.inventory,
          ),
          _buildDivider(context),
          _buildSummaryItem(
            context,
            label: 'Departments',
            value: distribution.summary.totalDepartments.toString(),
            icon: Icons.business,
          ),
          if (distribution.summary.isFiltered) ...[
            _buildDivider(context),
            _buildSummaryItem(
              context,
              label: 'Filter',
              value: distribution.summary.plantFilter,
              icon: Icons.filter_alt,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.darkText : theme.colorScheme.primary,
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.darkBorder : AppColors.divider,
    );
  }

  Widget _buildEmptyState() {
    return CompactEmptyState(
      icon: Icons.pie_chart_outline,
      message: 'No distribution data available',
    );
  }

  Widget _buildLoadingWidget() {
    return DashboardCard(
      title: 'Asset Distribution',
      isLoading: true,
      child: const SkeletonChart(height: 200, hasLegend: true),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.chartBlue,
      AppColors.chartOrange,
      AppColors.chartGreen,
      AppColors.chartPurple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
}

// Alternative implementation with more customization
class CustomAssetDistributionChart extends StatelessWidget {
  final AssetDistribution distribution;
  final bool isLoading;
  final double? height;
  final bool showLegend;
  final bool showSummary;
  final VoidCallback? onRefresh;

  const CustomAssetDistributionChart({
    super.key,
    required this.distribution,
    this.isLoading = false,
    this.height,
    this.showLegend = true,
    this.showSummary = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return DashboardCard(
        title: 'Asset Distribution',
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
        isLoading: true,
        child: SkeletonChart(height: height ?? 200, hasLegend: showLegend),
      );
    }

    return DashboardCard(
      title: 'Asset Distribution',
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
          // Chart
          SizedBox(
            height: height ?? 200,
            child: distribution.hasData
                ? _buildCustomPieChart()
                : _buildCustomEmptyState(),
          ),

          if (distribution.hasData && showLegend) ...[
            AppSpacing.verticalSpaceMedium,
            _buildCustomLegend(context),
          ],

          if (distribution.hasData && showSummary) ...[
            AppSpacing.verticalSpaceMedium,
            _buildCustomSummary(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomPieChart() {
    return charts.PieChart(
      charts.PieChartData(
        sections: distribution.pieChartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;

          return charts.PieChartSectionData(
            value: data.value.toDouble(),
            title: data.formattedPercentage,
            color: _getColorForIndex(index),
            radius: 60,
            titleStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: _buildBadge(data.value),
            badgePositionPercentageOffset: 1.3,
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 35,
        pieTouchData: charts.PieTouchData(
          touchCallback: (event, response) {
            // Handle touch events if needed
          },
        ),
      ),
    );
  }

  Widget? _buildBadge(int value) {
    if (value > 100) {
      return Container(
        padding: AppSpacing.paddingXS,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.small,
        ),
        child: Text(
          value.toString(),
          style: AppTextStyles.overline.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return null;
  }

  Widget _buildCustomLegend(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingSmall,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.backgroundSecondary,
        borderRadius: AppBorders.small,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : null,
      ),
      child: Wrap(
        spacing: AppSpacing.medium,
        runSpacing: AppSpacing.small,
        children: distribution.pieChartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;

          return Container(
            padding: AppSpacing.paddingXS,
            decoration: BoxDecoration(
              color: _getColorForIndex(index).withValues(alpha: 0.1),
              borderRadius: AppBorders.small,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getColorForIndex(index),
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.horizontalSpaceXS,
                Text(
                  '${data.displayName} (${data.value})',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.infoLight,
        borderRadius: AppBorders.medium,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.info,
            ),
          ),
          AppSpacing.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryChip(
                context,
                icon: Icons.inventory,
                label: 'Assets',
                value: distribution.summary.totalAssets.toString(),
              ),
              _buildSummaryChip(
                context,
                icon: Icons.business,
                label: 'Departments',
                value: distribution.summary.totalDepartments.toString(),
              ),
              if (distribution.summary.isFiltered)
                _buildSummaryChip(
                  context,
                  icon: Icons.filter_alt,
                  label: 'Filter',
                  value: distribution.summary.plantFilter,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingSmall,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppBorders.small,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.darkText : AppColors.info,
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.info,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.overline.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomEmptyState() {
    return EmptyStateCard(
      child: NoChartData(chartType: 'distribution', onRefresh: onRefresh),
    );
  }

  Color _getColorForIndex(int index) {
    return AppColors.chartPalette[index % AppColors.chartPalette.length];
  }
}
