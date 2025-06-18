// Path: frontend/lib/features/dashboard/presentation/widgets/growth_trends_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../dashboard/domain/entities/growth_trends.dart';
import 'chart_card_wrapper.dart';
import 'line_chart_component.dart';

class GrowthTrendsCard extends StatefulWidget {
  const GrowthTrendsCard({super.key});

  @override
  State<GrowthTrendsCard> createState() => _GrowthTrendsCardState();
}

class _GrowthTrendsCardState extends State<GrowthTrendsCard> {
  String _selectedDeptCode = 'IT';
  String _selectedPeriod = 'Q2';
  int _selectedYear = DateTime.now().year;

  final List<String> _departmentOptions = [
    'IT',
    'PROD',
    'MAINT',
    'QC',
    'LOG',
    'HR',
    'FIN',
    'ADMIN',
  ];

  final List<String> _periodOptions = ['Q1', 'Q2', 'Q3', 'Q4', '1Y'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return ChartCardWrapper(
          title: '📈 การเติบโตของสินทรัพย์แต่ละแผนก',
          dropdownLabel: 'แผนก:',
          dropdownValue: _selectedDeptCode,
          dropdownItems: _departmentOptions,
          onDropdownChanged: _onDepartmentChanged,
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
    } else if (state is GrowthTrendsLoaded) {
      return _buildTrendsContent(state.trends);
    } else if (state is DashboardError) {
      return _buildErrorContent(state.message);
    } else {
      return _buildEmptyContent();
    }
  }

  Widget _buildTrendsContent(GrowthTrends trends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line Chart
        SizedBox(
          height: 200,
          child: LineChartComponent(
            data: trends.trends
                .map(
                  (trend) => CustomLineChartData(
                    x: _getXValue(trend.monthYear),
                    y: trend.assetCount.toDouble(),
                    label: trend.monthYear,
                    growthPercentage: trend.growthPercentage,
                  ),
                )
                .toList(),
            xAxisLabels: _getXAxisLabels(trends.trends),
            title: 'จำนวนสินทรัพย์',
            color: _getDepartmentColor(_selectedDeptCode),
          ),
        ),
        const SizedBox(height: 16),

        // Growth Summary
        _buildGrowthSummary(trends),
        const SizedBox(height: 12),

        // Insights
        _buildTrendsInsights(trends),
      ],
    );
  }

  Widget _buildGrowthSummary(GrowthTrends trends) {
    final theme = Theme.of(context);
    final totalGrowth = trends.periodInfo.totalGrowth;
    final averageGrowth = trends.averageGrowthRate;
    final highestGrowth = trends.highestGrowthPeriod;

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
          _buildGrowthItem(
            '$totalGrowth',
            'รวมทั้งหมด',
            Icons.inventory_2,
            Colors.blue,
          ),
          _buildStatDivider(),
          _buildGrowthItem(
            '${averageGrowth.toStringAsFixed(1)}%',
            'เติบโตเฉลี่ย',
            Icons.trending_up,
            averageGrowth >= 0 ? Colors.green : Colors.red,
          ),
          _buildStatDivider(),
          _buildGrowthItem(
            highestGrowth != null ? '${highestGrowth.growthPercentage}%' : '0%',
            'สูงสุด',
            Icons.north,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(
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

  Widget _buildTrendsInsights(GrowthTrends trends) {
    final deptName = _getDepartmentName(_selectedDeptCode);
    final averageGrowth = trends.averageGrowthRate;
    final trendAnalysis = trends.trendAnalysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• แผนก $deptName มีการเติบโต ${averageGrowth.toStringAsFixed(1)}% ในช่วง${_getPeriodLabel(_selectedPeriod)}',
          style: const TextStyle(fontSize: 13),
        ),
        Text('• $trendAnalysis', style: const TextStyle(fontSize: 13)),
        Text(
          '→ คาดการณ์เติบโต ${(averageGrowth * 2).toStringAsFixed(1)}% ภายในสิ้นปี',
          style: TextStyle(
            fontSize: 13,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังโหลดข้อมูลการเติบโต...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'ไม่สามารถโหลดข้อมูลการเติบโตได้',
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
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูลการเติบโต',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'กรุณาเพิ่มข้อมูลสินทรัพย์เพื่อดูแนวโน้ม',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _onDepartmentChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedDeptCode = value;
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
    context.read<DashboardBloc>().add(
      LoadGrowthTrends(
        deptCode: _selectedDeptCode,
        period: _selectedPeriod,
        year: _selectedYear,
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

  String _getDepartmentName(String deptCode) {
    const deptNames = {
      'IT': 'ไอที',
      'PROD': 'โรงงาน',
      'MAINT': 'บำรุงรักษา',
      'QC': 'ควบคุมคุณภาพ',
      'LOG': 'โลจิสติกส์',
      'HR': 'ทรัพยากรบุคคล',
      'FIN': 'การเงิน',
      'ADMIN': 'บริหาร',
    };
    return deptNames[deptCode] ?? deptCode;
  }

  Color _getDepartmentColor(String deptCode) {
    const departmentColors = {
      'IT': Color(0xFF2196F3),
      'PROD': Color(0xFF4CAF50),
      'MAINT': Color(0xFFFF9800),
      'QC': Color(0xFF9C27B0),
      'LOG': Color(0xFFF44336),
      'HR': Color(0xFF00BCD4),
      'FIN': Color(0xFF795548),
      'ADMIN': Color(0xFF607D8B),
    };
    return departmentColors[deptCode] ?? Colors.blue;
  }

  double _getXValue(String monthYear) {
    // Convert "2024-01" to index for chart
    try {
      final parts = monthYear.split('-');
      if (parts.length == 2) {
        final month = int.parse(parts[1]);
        return month.toDouble() - 1; // 0-based index
      }
    } catch (e) {
      // Fallback
    }
    return 0;
  }

  List<String> _getXAxisLabels(List<TrendDataPoint> trends) {
    return trends.map((trend) {
      try {
        final parts = trend.monthYear.split('-');
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
      return trend.monthYear;
    }).toList();
  }
}
