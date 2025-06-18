// Path: frontend/lib/features/dashboard/presentation/widgets/location_analytics_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/entities/location_analytics.dart';
import 'chart_card_wrapper.dart';
import 'line_chart_component.dart';

class LocationAnalyticsCard extends StatefulWidget {
  const LocationAnalyticsCard({super.key});

  @override
  State<LocationAnalyticsCard> createState() => _LocationAnalyticsCardState();
}

class _LocationAnalyticsCardState extends State<LocationAnalyticsCard> {
  String _selectedLocationCode = 'Curing Oven Area';
  String _selectedPeriod = 'Q2';
  int _selectedYear = DateTime.now().year;

  final List<String> _locationOptions = [
    'Curing Oven Area',
    'E-Coat Line 1',
    'Maintenance Workshop',
    'Phosphating Line 1',
    'Pre-Treatment Section',
    'Paint Spray Booth 1',
    'Quality Control Lab',
    'Wastewater Treatment',
  ];

  final List<String> _periodOptions = ['Q1', 'Q2', 'Q3', 'Q4', '1Y'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return ChartCardWrapper(
          title: '🏭 การเติบโตของสินทรัพย์แต่ละพื้นที่ปฏิบัติการ',
          dropdownLabel: 'พื้นที่:',
          dropdownValue: _selectedLocationCode,
          dropdownItems: _locationOptions,
          onDropdownChanged: _onLocationChanged,
          additionalControls: _buildAdditionalControls(),
          child: _buildContent(state),
        );
      },
    );
  }

  Widget _buildAdditionalControls() {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(width: 16),
        Text(
          'ช่วงเวลา:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              items: _periodOptions.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(_getPeriodLabel(period)),
                );
              }).toList(),
              onChanged: _onPeriodChanged,
              style: theme.textTheme.bodySmall,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'ปี:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              items: _getYearOptions().map((year) {
                return DropdownMenuItem(value: year, child: Text('$year'));
              }).toList(),
              onChanged: _onYearChanged,
              style: theme.textTheme.bodySmall,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(DashboardState state) {
    if (state is DashboardLoading) {
      return _buildLoadingContent();
    } else if (state is LocationAnalyticsLoaded) {
      return _buildAnalyticsContent(state.analytics);
    } else if (state is DashboardError) {
      return _buildErrorContent(state.message);
    } else {
      return _buildEmptyContent();
    }
  }

  Widget _buildAnalyticsContent(Map<String, dynamic> analytics) {
    // Parse the analytics data
    final locationAnalyticsList =
        analytics['location_analytics'] as List<dynamic>? ?? [];
    final analyticsSummary =
        analytics['analytics_summary'] as Map<String, dynamic>? ?? {};
    final growthTrends = analytics['growth_trends'] as Map<String, dynamic>?;

    // Find the selected location data
    final selectedLocationData = locationAnalyticsList.firstWhere(
      (location) => location['location_description'] == _selectedLocationCode,
      orElse: () => null,
    );

    // Get growth trends for the selected location
    List<dynamic> locationTrends = [];
    if (growthTrends != null) {
      locationTrends = growthTrends['location_trends'] as List<dynamic>? ?? [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line Chart
        SizedBox(
          height: 200,
          child: locationTrends.isNotEmpty
              ? LineChartComponent(
                  data: locationTrends
                      .map(
                        (trend) => LineChartData(
                          x: _getXValue(trend['month_year'] ?? ''),
                          y: (trend['asset_count'] ?? 0).toDouble(),
                          label: trend['month_year'] ?? '',
                          growthPercentage: trend['growth_percentage'] ?? 0,
                        ),
                      )
                      .toList(),
                  xAxisLabels: _getXAxisLabels(locationTrends),
                  title: 'จำนวนสินทรัพย์',
                  color: Colors.purple,
                )
              : _buildNoTrendsChart(),
        ),
        const SizedBox(height: 16),

        // Location Summary
        if (selectedLocationData != null)
          _buildLocationSummary(selectedLocationData),
        const SizedBox(height: 12),

        // Insights
        _buildLocationInsights(
          selectedLocationData,
          locationTrends,
          analyticsSummary,
        ),
      ],
    );
  }

  Widget _buildLocationSummary(Map<String, dynamic> locationData) {
    final theme = Theme.of(context);
    final totalAssets = locationData['total_assets'] ?? 0;
    final utilizationRate = locationData['utilization_rate'] ?? 0;
    final totalScans = locationData['total_scans'] ?? 0;
    final daysSinceLastScan = locationData['days_since_last_scan'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            '$totalAssets',
            'สินทรัพย์ทั้งหมด',
            Icons.inventory_2,
            Colors.blue,
          ),
          _buildStatDivider(),
          _buildSummaryItem(
            '$utilizationRate%',
            'อัตราการใช้งาน',
            Icons.speed,
            _getUtilizationColor(utilizationRate),
          ),
          _buildStatDivider(),
          _buildSummaryItem(
            '$totalScans',
            'การสแกนทั้งหมด',
            Icons.qr_code_scanner,
            Colors.green,
          ),
          _buildStatDivider(),
          _buildSummaryItem(
            '$daysSinceLastScan',
            'วันที่ผ่านมา',
            Icons.schedule,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade300);
  }

  Widget _buildLocationInsights(
    Map<String, dynamic>? locationData,
    List<dynamic> trends,
    Map<String, dynamic> summary,
  ) {
    if (locationData == null) {
      return const Text('• ไม่มีข้อมูลสำหรับพื้นที่ที่เลือก');
    }

    final utilizationRate = locationData['utilization_rate'] ?? 0;
    final latestGrowth = trends.isNotEmpty
        ? trends.last['growth_percentage'] ?? 0
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• พื้นที่ $_selectedLocationCode มีการเติบโต $latestGrowth% ในช่วง${_getPeriodLabel(_selectedPeriod)}',
          style: const TextStyle(fontSize: 13),
        ),
        Text(
          '• อัตราการใช้งาน $utilizationRate% ${_getUtilizationDescription(utilizationRate)}',
          style: const TextStyle(fontSize: 13),
        ),
        Text(
          '→ ${_getRecommendation(utilizationRate, latestGrowth)}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoTrendsChart() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูลแนวโน้มสำหรับพื้นที่นี้',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังโหลดข้อมูลพื้นที่ปฏิบัติการ...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'ไม่สามารถโหลดข้อมูลพื้นที่ปฏิบัติการได้',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _reloadData,
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return const SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูลพื้นที่ปฏิบัติการ',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'กรุณาเพิ่มข้อมูลพื้นที่และสินทรัพย์',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _onLocationChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedLocationCode = value;
      });
      _reloadData();
    }
  }

  void _onPeriodChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedPeriod = value;
      });
      _reloadData();
    }
  }

  void _onYearChanged(int? value) {
    if (value != null) {
      setState(() {
        _selectedYear = value;
      });
      _reloadData();
    }
  }

  void _reloadData() {
    // Convert location description to location code (simplified)
    final locationCode = _getLocationCode(_selectedLocationCode);

    context.read<DashboardBloc>().add(
      LoadLocationAnalytics(
        locationCode: locationCode,
        period: _selectedPeriod,
        year: _selectedYear,
        includeTrends: true,
        forceRefresh: true,
      ),
    );
  }

  // Helper methods
  List<int> _getYearOptions() {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - index);
  }

  String _getPeriodLabel(String period) {
    const periodLabels = {
      'Q1': 'ไตรมาส 1',
      'Q2': 'ไตรมาส 2',
      'Q3': 'ไตรมาส 3',
      'Q4': 'ไตรมาส 4',
      '1Y': 'ทั้งปี',
    };
    return periodLabels[period] ?? period;
  }

  String _getLocationCode(String description) {
    // Simplified mapping - in real app, this would come from API
    const locationMap = {
      'Curing Oven Area': 'L001',
      'E-Coat Line 1': 'L002',
      'Maintenance Workshop': 'L003',
      'Phosphating Line 1': 'L004',
      'Pre-Treatment Section': 'L005',
      'Paint Spray Booth 1': 'L006',
      'Quality Control Lab': 'L007',
      'Wastewater Treatment': 'L008',
    };
    return locationMap[description] ?? 'L001';
  }

  double _getXValue(String monthYear) {
    try {
      final parts = monthYear.split('-');
      if (parts.length == 2) {
        final month = int.parse(parts[1]);
        return month.toDouble() - 1;
      }
    } catch (e) {
      // Fallback
    }
    return 0;
  }

  List<String> _getXAxisLabels(List<dynamic> trends) {
    return trends.map((trend) {
      try {
        final monthYear = trend['month_year'] ?? '';
        final parts = monthYear.split('-');
        if (parts.length == 2) {
          final month = int.parse(parts[1]);
          const months = [
            'ม.ค.',
            'ก.พ.',
            'มี.ค.',
            'เม.ย.',
            'พ.ค.',
            'มิ.ย.',
            'ก.ค.',
            'ส.ค.',
            'ก.ย.',
            'ต.ค.',
            'พ.ย.',
            'ธ.ค.',
          ];
          return months[month - 1];
        }
      } catch (e) {
        // Fallback
      }
      return trend['month_year'] ?? '';
    }).toList();
  }

  Color _getUtilizationColor(int utilizationRate) {
    if (utilizationRate >= 80) return Colors.green;
    if (utilizationRate >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getUtilizationDescription(int utilizationRate) {
    if (utilizationRate >= 80) return '→ ใช้งานได้ดี';
    if (utilizationRate >= 60) return '→ ใช้งานปานกลาง';
    return '→ ใช้งานน้อย';
  }

  String _getRecommendation(int utilizationRate, int latestGrowth) {
    if (utilizationRate >= 80 && latestGrowth > 0) {
      return 'เป้าหมายเพิ่มเครื่องจักรใหม่ 2 ชุดภายในไตรมาส 4';
    } else if (utilizationRate < 60) {
      return 'ควรปรับปรุงประสิทธิภาพการใช้งานพื้นที่';
    } else if (latestGrowth < 0) {
      return 'ตรวจสอบสาเหตุการลดลงของสินทรัพย์';
    } else {
      return 'รักษาระดับการใช้งานปัจจุบัน';
    }
  }
}
