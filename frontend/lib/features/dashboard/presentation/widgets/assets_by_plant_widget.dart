import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../domain/entities/assets_by_plant.dart';
import 'common/dashboard_card.dart';
import 'common/empty_state.dart';
import 'common/loading_skeleton.dart';

class AssetsByPlantWidget extends StatelessWidget {
  final AssetsByPlant assetsByPlant;
  final bool isLoading;

  const AssetsByPlantWidget({
    super.key,
    required this.assetsByPlant,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    return DashboardCard(
      title: 'Assets by Plant',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: assetsByPlant.hasData
                ? _buildBarChart(context)
                : _buildEmptyState(context),
          ),
          if (assetsByPlant.hasData) ...[
            AppSpacing.verticalSpaceLarge,
            _buildSummary(context),
          ],
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxValue = assetsByPlant.plants
        .map((plant) => plant.assetCount)
        .fold(0, (prev, current) => current > prev ? current : prev)
        .toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            tooltipBorder: BorderSide.none,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final plant = assetsByPlant.plants[group.x.toInt()];
              return BarTooltipItem(
                '${plant.displayName}\n${plant.assetCount} assets',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < assetsByPlant.plants.length) {
                  final plant = assetsByPlant.plants[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      plant.plantCode,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.4)
                : AppColors.divider,
          ),
        ),
        barGroups: assetsByPlant.plants.asMap().entries.map((entry) {
          final index = entry.key;
          final plant = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: plant.assetCount.toDouble(),
                color: _getColorForIndex(index, isDark),
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.4)
                  : AppColors.divider,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingLarge,
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
        children: assetsByPlant.plants.asMap().entries.map((entry) {
          final index = entry.key;
          final plant = entry.value;
          final isLast = index == assetsByPlant.plants.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    label: plant.plantCode,
                    value: plant.assetCount.toString(),
                    icon: Icons.factory,
                    color: _getColorForIndex(index, isDark),
                  ),
                ),
                if (!isLast) _buildDivider(context),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        AppSpacing.verticalSpaceSM,
        Text(
          value,
          style: AppTextStyles.headline5.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
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
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? AppColors.darkBorder : AppColors.divider,
    );
  }

  Color _getColorForIndex(int index, bool isDark) {
    final colors = [
      AppColors.chartBlue,
      AppColors.chartOrange,
      AppColors.chartGreen,
      AppColors.chartPurple,
    ];
    final color = colors[index % colors.length];

    if (isDark) {
      return Color.lerp(color, Colors.black, 0.2)!;
    }
    return color;
  }

  Widget _buildEmptyState(BuildContext context) {
    return const CompactEmptyState(
      icon: Icons.factory_outlined,
      message: 'No plant data available',
    );
  }

  Widget _buildLoadingWidget() {
    return const DashboardCard(
      title: 'Assets by Plant',
      isLoading: true,
      child: SkeletonChart(height: 200, hasLegend: true),
    );
  }
}
