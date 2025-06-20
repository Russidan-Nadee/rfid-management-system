import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as charts;
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/asset_distribution.dart';

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

    return _DashboardCard(
      title: 'Asset Distribution',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: distribution.hasData ? _buildPieChart() : _buildEmptyState(),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 12),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return charts.PieChart(
      charts.PieChartData(
        sections: distribution.pieChartData.map((data) {
          return charts.PieChartSectionData(
            value: data.value.toDouble(),
            title: '${data.formattedPercentage}',
            color: _getColorForIndex(distribution.pieChartData.indexOf(data)),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 0.8,
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
      spacing: 16,
      runSpacing: 8,
      children: distribution.pieChartData.map((data) {
        final colorIndex = distribution.pieChartData.indexOf(data);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColorForIndex(colorIndex),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${data.displayName} (${data.value})',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total Assets',
            distribution.summary.totalAssets.toString(),
            Icons.inventory,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildSummaryItem(
            'Departments',
            distribution.summary.totalDepartments.toString(),
            Icons.business,
          ),
          if (distribution.summary.isFiltered) ...[
            Container(width: 1, height: 30, color: Colors.grey.shade300),
            _buildSummaryItem(
              'Filter',
              distribution.summary.plantFilter,
              Icons.filter_alt,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No distribution data available',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return _DashboardCard(
      title: 'Asset Distribution',
      child: Container(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
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

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashboardCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
