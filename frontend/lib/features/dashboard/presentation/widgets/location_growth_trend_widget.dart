// Path: frontend/lib/features/dashboard/presentation/widgets/location_growth_trend_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../domain/entities/growth_trend.dart';
import 'common/dashboard_card.dart';
import 'common/empty_state.dart';
import 'common/loading_skeleton.dart';

class LocationGrowthTrendWidget extends StatefulWidget {
  final GrowthTrend growthTrend; // ใช้ GrowthTrend entity
  final bool isLoading;
  final String? selectedLocationCode;
  final List<Map<String, String>> availableLocations;
  final Function(String?) onLocationChanged;

  const LocationGrowthTrendWidget({
    super.key,
    required this.growthTrend,
    this.isLoading = false,
    this.selectedLocationCode,
    this.availableLocations = const [],
    required this.onLocationChanged,
  });

  @override
  State<LocationGrowthTrendWidget> createState() =>
      _LocationGrowthTrendWidgetState();
}

class _LocationGrowthTrendWidgetState extends State<LocationGrowthTrendWidget> {
  String? _currentSelectedLocation;

  @override
  void initState() {
    super.initState();
    _currentSelectedLocation = widget.selectedLocationCode;
  }

  @override
  void didUpdateWidget(LocationGrowthTrendWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLocationCode != oldWidget.selectedLocationCode) {
      setState(() {
        _currentSelectedLocation = widget.selectedLocationCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingWidget();
    }

    return ChartCard(
      title: 'Asset Growth Location',
      filters: _buildLocationFilter(),
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

  Widget _buildLocationFilter() {
    final Map<String, String> uniqueLocations = {};

    for (final location in widget.availableLocations) {
      uniqueLocations[location['code']!] = location['name']!;
    }

    // ตรวจสอบว่า currentSelectedLocation มีใน dropdown ไหม
    String? validSelectedLocation = _currentSelectedLocation;
    if (validSelectedLocation != null &&
        !uniqueLocations.containsKey(validSelectedLocation)) {
      print(
        '🚨 Location $validSelectedLocation not found in dropdown, resetting to null',
      );
      validSelectedLocation = null;
      _currentSelectedLocation = null;
    }

    return Container(
      padding: AppSpacing.paddingHorizontalMedium.add(
        AppSpacing.paddingVerticalSmall,
      ),
      decoration: AppDecorations.input,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: validSelectedLocation,
          hint: Text(
            'All Locations',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          isExpanded: true,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('All Locations', style: AppTextStyles.body2),
            ),
            ...uniqueLocations.entries.map(
              (entry) => DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(entry.value, style: AppTextStyles.body2),
              ),
            ),
          ],
          onChanged: (String? newValue) {
            print('🔥 Location filter changed to: $newValue');
            setState(() {
              _currentSelectedLocation = newValue;
            });
            widget.onLocationChanged(newValue);
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
            padding: AppSpacing.paddingHorizontalSmall.add(
              AppSpacing.paddingVerticalXS,
            ),
            decoration: AppDecorations.chip.copyWith(
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Text(
              'Current Year',
              style: AppTextStyles.overline.copyWith(
                color: Colors.orange,
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
                    padding: AppSpacing.paddingVerticalSmall,
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
            color: Colors.orange,
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
                  color: Colors.orange,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
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
            'Latest Year', // เปลี่ยนจาก 'Total Growth'
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
            Colors.orange,
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
      message: 'No location trend data available',
    );
  }

  Widget _buildLoadingWidget() {
    return DashboardCard(
      title: 'Asset Growth Location',
      isLoading: true,
      child: const SkeletonChart(height: 200, hasLegend: true),
    );
  }
}
