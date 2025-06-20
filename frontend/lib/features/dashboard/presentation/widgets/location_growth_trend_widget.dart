// Path: frontend/lib/features/dashboard/presentation/widgets/location_growth_trend_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/location_analytics.dart';

class LocationGrowthTrendWidget extends StatefulWidget {
  final LocationAnalytics locationAnalytics;
  final bool isLoading;
  final String? selectedLocationCode;
  final List<Map<String, String>> availableLocations;
  final Function(String?) onLocationChanged;

  const LocationGrowthTrendWidget({
    super.key,
    required this.locationAnalytics,
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
    print('🎨 LocationGrowthTrendWidget build');
    print('🎨 Has data: ${widget.locationAnalytics.hasData}');
    print('🎨 Trends count: ${widget.locationAnalytics.locationTrends.length}');
    print('🎨 Available locations: ${widget.availableLocations.length}');

    if (widget.isLoading) {
      return _buildLoadingWidget();
    }

    return _DashboardCard(
      title: 'Asset Growth Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationFilter(),
          const SizedBox(height: 16),
          _buildPeriodInfo(),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: widget.locationAnalytics.hasData
                ? _buildLineChart()
                : _buildEmptyState(),
          ),
          const SizedBox(height: 16),
          _buildTrendSummary(),
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    final Map<String, String> uniqueLocations = {};

    for (final location in widget.availableLocations) {
      uniqueLocations[location['code']!] = location['name']!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _currentSelectedLocation,
          hint: const Text('All Locations'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Locations'),
            ),
            ...uniqueLocations.entries.map(
              (entry) => DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(entry.value),
              ),
            ),
          ],
          onChanged: (String? newValue) {
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
          'Period: ${widget.locationAnalytics.periodInfo.period}',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        if (widget.locationAnalytics.periodInfo.isCurrentYear)
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
    final spots = widget.locationAnalytics.locationTrends.asMap().entries.map((
      entry,
    ) {
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
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 &&
                    index < widget.locationAnalytics.locationTrends.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.locationAnalytics.locationTrends[index].monthYear,
                      style: const TextStyle(fontSize: 10),
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
            color: Colors.orange, // ใช้ Colors.orange แทน AppColors.secondary
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // เพิ่ม check index ก่อนใช้
                if (index < widget.locationAnalytics.locationTrends.length) {
                  final trend = widget.locationAnalytics.locationTrends[index];
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
                // fallback ถ้า index เกิน
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
              color: Colors.orange.withOpacity(0.1), // ใช้ Colors.orange
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index < widget.locationAnalytics.locationTrends.length) {
                  final trend = widget.locationAnalytics.locationTrends[index];
                  return LineTooltipItem(
                    '${trend.monthYear}\n${trend.assetCount} assets\n${trend.formattedGrowthPercentage}\nActive: ${trend.activeCount}',
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
            'Total Growth',
            widget.locationAnalytics.summary.totalGrowth.toString(),
            Icons.trending_up,
            widget.locationAnalytics.hasPositiveGrowth
                ? AppColors.trendUp
                : AppColors.trendDown,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildSummaryItem(
            'Average Growth',
            widget.locationAnalytics.summary.averageGrowth.toString(),
            Icons.analytics,
            Colors.orange, // ใช้ Colors.orange แทน AppColors.secondary
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildSummaryItem(
            'Periods',
            widget.locationAnalytics.summary.totalPeriods.toString(),
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
          Icon(
            Icons.location_on_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No location trend data available',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a location to view growth trends',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return _DashboardCard(
      title: 'Asset Growth Location',
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
