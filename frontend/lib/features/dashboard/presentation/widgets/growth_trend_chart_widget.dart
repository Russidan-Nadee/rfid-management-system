// Path: frontend/lib/features/dashboard/presentation/widgets/growth_trend_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../domain/entities/growth_trend.dart';
import 'common/dashboard_card.dart';
import 'common/empty_state.dart';
import 'common/loading_skeleton.dart';

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

    return ChartCard(
      title: 'Asset Growth Department',
      filters: _buildDepartmentFilter(),
      chart: Column(
        children: [
          _buildPeriodInfo(),
          AppSpacing.verticalSpaceMedium,
          SizedBox(
            height: 200,
            child: widget.growthTrend.hasData
                ? _buildLineChart()
                : _buildEmptyState(),
          ),
        ],
      ),
      legend: widget.growthTrend.hasData ? _buildTrendSummary() : null,
    );
  }

  Widget _buildDepartmentFilter() {
    final Map<String, String> uniqueDepts = {};

    for (final dept in widget.availableDepartments) {
      uniqueDepts[dept['code']!] = dept['name']!;
    }

    return Container(
      padding: AppSpacing.paddingHorizontalLG.add(AppSpacing.paddingVerticalSM),
      decoration: AppDecorations.input,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _currentSelectedDept,
          hint: Text(
            'All Departments',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          isExpanded: true,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('All Departments', style: AppTextStyles.body2),
            ),
            ...uniqueDepts.entries.map(
              (entry) => DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(entry.value, style: AppTextStyles.body2),
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
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
        ),
        if (widget.growthTrend.periodInfo.isCurrentYear)
          Container(
            padding: AppSpacing.paddingHorizontalSM.add(
              AppSpacing.paddingVerticalXS,
            ),
            decoration: AppDecorations.chip.copyWith(
              color: AppColors.vibrantOrange.withOpacity(0.1),
              border: Border.all(
                color: AppColors.vibrantOrange.withOpacity(0.3),
              ),
            ),
            child: Text(
              'Current Year',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.vibrantGreen,
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
            return FlLine(color: AppColors.divider, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: AppColors.divider, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}', style: AppTextStyles.overline);
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
                    padding: AppSpacing.paddingVerticalSM,
                    child: Text(
                      widget.growthTrend.trends[index].period,
                      style: AppTextStyles.chartLabel.copyWith(
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
          border: Border.all(color: AppColors.divider),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.vibrantOrange,
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
                  color: AppColors.vibrantOrange,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.vibrantOrange.withOpacity(0.1),
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
                    AppTextStyles.caption.copyWith(
                      color: Colors.white,
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
      padding: AppSpacing.paddingMedium,
      decoration: AppDecorations.chip,
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
          _buildDivider(),
          _buildSummaryItem(
            'Average Growth',
            '${correctedAverageGrowth.toString()}%',
            Icons.analytics,
            AppColors.vibrantOrange,
          ),
          _buildDivider(),
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

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        AppSpacing.verticalSpaceXS,
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
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

  Widget _buildEmptyState() {
    return CompactEmptyState(
      icon: Icons.show_chart,
      message: 'No trend data available',
    );
  }

  Widget _buildLoadingWidget() {
    return DashboardCard(
      title: 'Asset Growth Department',
      isLoading: true,
      child: const SkeletonChart(height: 200, hasLegend: true),
    );
  }
}
