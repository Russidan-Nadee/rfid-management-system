// Path: frontend/lib/features/dashboard/presentation/widgets/growth_trend_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/growth_trend.dart';

class GrowthTrendChartWidget extends StatefulWidget {
  final GrowthTrend growthTrend;
  final bool isLoading;
  final String? selectedDeptCode;
  final List<Map<String, String>> availableDepartments;
  final Function(String?) onDeptChanged;

  const GrowthTrendChartWidget({
    super.key,
    required this.growthTrend,
    this.isLoading = false,
    this.selectedDeptCode,
    this.availableDepartments = const [],
    required this.onDeptChanged,
  });

  @override
  State<GrowthTrendChartWidget> createState() => _GrowthTrendChartWidgetState();
}

class _GrowthTrendChartWidgetState extends State<GrowthTrendChartWidget> {
  String? _currentSelectedDept;

  @override
  void initState() {
    super.initState();
    _currentSelectedDept = widget.selectedDeptCode;
  }

  @override
  void didUpdateWidget(GrowthTrendChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDeptCode != oldWidget.selectedDeptCode) {
      setState(() {
        _currentSelectedDept = widget.selectedDeptCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingWidget();
    }

    return _DashboardCard(
      title: 'Asset Growth Department',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDepartmentFilter(),
          const SizedBox(height: 16),
          _buildPeriodInfo(),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: widget.growthTrend.hasData
                ? _buildLineChart()
                : _buildEmptyState(),
          ),
          const SizedBox(height: 16),
          _buildTrendSummary(),
        ],
      ),
    );
  }

  Widget _buildDepartmentFilter() {
    final Map<String, String> uniqueDepts = {};

    for (final dept in widget.availableDepartments) {
      uniqueDepts[dept['code']!] = dept['name']!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _currentSelectedDept,
          hint: const Text('All Departments'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Departments'),
            ),
            ...uniqueDepts.entries.map(
              (entry) => DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(entry.value),
              ),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _currentSelectedDept = newValue;
            });
            widget.onDeptChanged(newValue);
          },
        ),
      ),
    );
  }

  Widget _buildPeriodInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Period: ${widget.growthTrend.periodInfo.period}',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        if (widget.growthTrend.periodInfo.isCurrentYear)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Current Year',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLineChart() {
    final spots = widget.growthTrend.trends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.assetCount.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.growthTrend.trends.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.growthTrend.trends[index].period,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index < widget.growthTrend.trends.length) {
                  final trend = widget.growthTrend.trends[index];
                  return FlDotCirclePainter(
                    radius: 4,
                    color: trend.isPositiveGrowth
                        ? AppColors.trendUp
                        : trend.isNegativeGrowth
                        ? AppColors.trendDown
                        : AppColors.trendStable,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index < widget.growthTrend.trends.length) {
                  final trend = widget.growthTrend.trends[index];
                  return LineTooltipItem(
                    'Year ${trend.period}\n${trend.assetCount} assets\n${trend.formattedGrowthPercentage}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrendSummary() {
    int latestYearGrowth = _calculateLatestYearGrowth();
    int correctedAverageGrowth = _calculateAverageGrowth();

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
            'Latest Year',
            '${latestYearGrowth.toString()}%',
            Icons.trending_up,
            latestYearGrowth > 0
                ? AppColors.trendUp
                : latestYearGrowth < 0
                ? AppColors.trendDown
                : AppColors.trendStable,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildSummaryItem(
            'Average Growth',
            '${correctedAverageGrowth.toString()}%',
            Icons.analytics,
            AppColors.primary,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildSummaryItem(
            'Periods',
            widget.growthTrend.summary.totalPeriods.toString(),
            Icons.calendar_today,
            AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  int _calculateLatestYearGrowth() {
    if (widget.growthTrend.trends.length < 2) return 0;

    final latestYear = widget.growthTrend.trends.last;
    final previousYear =
        widget.growthTrend.trends[widget.growthTrend.trends.length - 2];

    if (previousYear.assetCount == 0) return 100; // หลีกเลี่ยงหารด้วย 0

    // คำนวณเปอร์เซ็นต์การเติบโต
    return (((latestYear.assetCount - previousYear.assetCount) /
                previousYear.assetCount) *
            100)
        .round();
  }

  int _calculateAverageGrowth() {
    if (widget.growthTrend.trends.length < 2) return 0;

    List<int> growthPercentages = [];

    for (int i = 1; i < widget.growthTrend.trends.length; i++) {
      final current = widget.growthTrend.trends[i];
      final previous = widget.growthTrend.trends[i - 1];

      if (previous.assetCount > 0) {
        final growth =
            (((current.assetCount - previous.assetCount) /
                        previous.assetCount) *
                    100)
                .round();
        growthPercentages.add(growth);
      }
    }

    if (growthPercentages.isEmpty) return 0;

    return (growthPercentages.reduce((a, b) => a + b) /
            growthPercentages.length)
        .round();
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
          Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No trend data available',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return _DashboardCard(
      title: 'Asset Growth Department',
      child: Container(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
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
