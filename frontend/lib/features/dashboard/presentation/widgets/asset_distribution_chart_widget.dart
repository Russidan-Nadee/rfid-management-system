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
      legend: distribution.hasData ? _buildLegend() : null,
      filters: distribution.hasData ? _buildSummary() : null,
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

  Widget _buildLegend() {
    return Wrap(
      spacing: AppSpacing.medium,
      runSpacing: AppSpacing.small,
      children: distribution.pieChartData.map((data) {
        final colorIndex = distribution.pieChartData.indexOf(data);
        return _buildLegendItem(
          color: _getColorForIndex(colorIndex),
          label: data.displayName,
          value: data.value.toString(),
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        AppSpacing.horizontalSpaceXS,
        Text('$label ($value)', style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: AppDecorations.chip,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            label: 'Total Assets',
            value: distribution.summary.totalAssets.toString(),
            icon: Icons.inventory,
          ),
          _buildDivider(),
          _buildSummaryItem(
            label: 'Departments',
            value: distribution.summary.totalDepartments.toString(),
            icon: Icons.business,
          ),
          if (distribution.summary.isFiltered) ...[
            _buildDivider(),
            _buildSummaryItem(
              label: 'Filter',
              value: distribution.summary.plantFilter,
              icon: Icons.filter_alt,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        AppSpacing.verticalSpaceXS,
        Text(
          value,
          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: AppColors.divider);
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
    if (isLoading) {
      return DashboardCard(
        title: 'Asset Distribution',
        trailing: onRefresh != null
            ? IconButton(
                icon: const Icon(Icons.refresh, size: 20),
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
              icon: const Icon(Icons.refresh, size: 20),
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
            _buildCustomLegend(),
          ],

          if (distribution.hasData && showSummary) ...[
            AppSpacing.verticalSpaceMedium,
            _buildCustomSummary(),
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

  Widget _buildCustomLegend() {
    return Container(
      padding: AppSpacing.paddingSmall,
      decoration: AppDecorations.chip,
      child: Wrap(
        spacing: AppSpacing.medium,
        runSpacing: AppSpacing.small,
        children: distribution.pieChartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;

          return Container(
            padding: AppSpacing.paddingXS,
            decoration: BoxDecoration(
              color: _getColorForIndex(index).withOpacity(0.1),
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
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomSummary() {
    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: AppDecorations.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
          AppSpacing.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryChip(
                icon: Icons.inventory,
                label: 'Assets',
                value: distribution.summary.totalAssets.toString(),
              ),
              _buildSummaryChip(
                icon: Icons.business,
                label: 'Departments',
                value: distribution.summary.totalDepartments.toString(),
              ),
              if (distribution.summary.isFiltered)
                _buildSummaryChip(
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

  Widget _buildSummaryChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: AppSpacing.paddingSmall,
      decoration: AppDecorations.chip,
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.info),
          AppSpacing.verticalSpaceXS,
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondary,
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
