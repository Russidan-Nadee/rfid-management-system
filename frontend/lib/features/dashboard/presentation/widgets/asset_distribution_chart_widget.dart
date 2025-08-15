// Path: frontend/lib/features/dashboard/presentation/widgets/asset_distribution_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as charts;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../l10n/features/dashboard/dashboard_localizations.dart';
import '../../domain/entities/asset_distribution.dart';
import 'common/dashboard_card.dart';
import 'common/empty_state.dart';
import 'common/loading_skeleton.dart';

enum ChartType { pie, bar }

class AssetDistributionChartWidget extends StatefulWidget {
  final AssetDistribution distribution;
  final bool isLoading;

  const AssetDistributionChartWidget({
    super.key,
    required this.distribution,
    this.isLoading = false,
  });

  @override
  State<AssetDistributionChartWidget> createState() => _AssetDistributionChartWidgetState();
}

class _AssetDistributionChartWidgetState extends State<AssetDistributionChartWidget> {
  ChartType _selectedChartType = ChartType.bar;

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    if (widget.isLoading) {
      return _buildLoadingWidget(l10n);
    }

    return DashboardCard(
      title: l10n.assetDistribution,
      trailing: widget.distribution.hasData ? _buildChartTypeSelector(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.distribution.hasData) ...[
            _buildSummary(context),
            AppSpacing.verticalSpaceMedium,
          ],
          SizedBox(
            height: 200,
            child: widget.distribution.hasData
                ? _buildSelectedChart()
                : _buildEmptyState(context),
          ),
          if (widget.distribution.hasData) ...[
            AppSpacing.verticalSpaceMedium,
            _buildLegend(context),
          ],
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = DashboardLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChartType>(
          value: _selectedChartType,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.colorScheme.onSurface),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          items: [
            DropdownMenuItem(
              value: ChartType.pie,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pie_chart, size: 16, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(l10n.pieChart),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ChartType.bar,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart, size: 16, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(l10n.barChart),
                ],
              ),
            ),
          ],
          onChanged: (ChartType? newType) {
            if (newType != null) {
              setState(() {
                _selectedChartType = newType;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedChartType) {
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.bar:
        return _buildBarChart();
    }
  }

  Widget _buildPieChart() {
    return charts.PieChart(
      charts.PieChartData(
        sections: widget.distribution.pieChartData.map((data) {
          return charts.PieChartSectionData(
            value: data.value.toDouble(),
            title: data.formattedPercentage,
            color: _getColorForIndex(widget.distribution.pieChartData.indexOf(data)),
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

  Widget _buildBarChart() {
    final maxValue = widget.distribution.pieChartData
        .map((data) => data.value)
        .fold(0, (prev, current) => current > prev ? current : prev)
        .toDouble();

    return charts.BarChart(
      charts.BarChartData(
        alignment: charts.BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: charts.BarTouchData(
          touchTooltipData: charts.BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            tooltipBorder: BorderSide.none,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final data = widget.distribution.pieChartData[group.x.toInt()];
              return charts.BarTooltipItem(
                '${data.displayName}\n${data.value} (${data.formattedPercentage})',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: charts.FlTitlesData(
          show: true,
          rightTitles: const charts.AxisTitles(
            sideTitles: charts.SideTitles(showTitles: false),
          ),
          topTitles: const charts.AxisTitles(
            sideTitles: charts.SideTitles(showTitles: false),
          ),
          bottomTitles: charts.AxisTitles(
            sideTitles: charts.SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.distribution.pieChartData.length) {
                  final data = widget.distribution.pieChartData[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data.displayName.length > 8 
                          ? '${data.displayName.substring(0, 8)}...'
                          : data.displayName,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: charts.AxisTitles(
            sideTitles: charts.SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: charts.FlBorderData(show: false),
        barGroups: widget.distribution.pieChartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return charts.BarChartGroupData(
            x: index,
            barRods: [
              charts.BarChartRodData(
                toY: data.value.toDouble(),
                color: _getColorForIndex(index),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: const charts.FlGridData(show: false),
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
        children: widget.distribution.pieChartData.map((data) {
          final colorIndex = widget.distribution.pieChartData.indexOf(data);
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
    final l10n = DashboardLocalizations.of(context);

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
            label: l10n.totalAssets,
            value: widget.distribution.summary.totalAssets.toString(),
            icon: Icons.inventory,
          ),
          _buildDivider(context),
          _buildSummaryItem(
            context,
            label: l10n.departments,
            value: widget.distribution.summary.totalDepartments.toString(),
            icon: Icons.business,
          ),
          if (widget.distribution.summary.isFiltered) ...[
            _buildDivider(context),
            _buildSummaryItem(
              context,
              label: l10n.filter,
              value: widget.distribution.summary.plantFilter,
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

  Widget _buildEmptyState(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return CompactEmptyState(
      icon: Icons.pie_chart_outline,
      message: l10n.noDistributionDataAvailable,
    );
  }

  Widget _buildLoadingWidget(DashboardLocalizations l10n) {
    return DashboardCard(
      title: l10n.assetDistribution,
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
    final l10n = DashboardLocalizations.of(context);

    if (isLoading) {
      return DashboardCard(
        title: l10n.assetDistribution,
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
      title: l10n.assetDistribution,
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
    final l10n = DashboardLocalizations.of(context);

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
            l10n.summary,
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
                label: l10n.assets,
                value: distribution.summary.totalAssets.toString(),
              ),
              _buildSummaryChip(
                context,
                icon: Icons.business,
                label: l10n.departments,
                value: distribution.summary.totalDepartments.toString(),
              ),
              if (distribution.summary.isFiltered)
                _buildSummaryChip(
                  context,
                  icon: Icons.filter_alt,
                  label: l10n.filter,
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
