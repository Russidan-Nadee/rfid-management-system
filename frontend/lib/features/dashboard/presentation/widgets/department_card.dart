// Path: frontend/lib/features/dashboard/presentation/widgets/department_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../dashboard/domain/entities/department_analytics.dart';
import 'chart_card_wrapper.dart';
import 'pie_chart_component.dart';

class DepartmentCard extends StatefulWidget {
  const DepartmentCard({super.key});

  @override
  State<DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<DepartmentCard> {
  String? _selectedPlantCode;
  final List<String> _plantOptions = ['ทั้งหมด', 'P001', 'P002', 'P003'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return ChartCardWrapper(
          title: '🏢 การกระจายสินทรัพย์ตามแผนก',
          dropdownLabel: 'โรงงาน:',
          dropdownValue: _selectedPlantCode ?? 'ทั้งหมด',
          dropdownItems: _plantOptions,
          onDropdownChanged: _onPlantChanged,
          child: _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(DashboardState state) {
    if (state is DashboardLoading) {
      return _buildLoadingContent();
    } else if (state is DepartmentAnalyticsLoaded) {
      return _buildAnalyticsContent(state.analytics);
    } else if (state is DashboardError) {
      return _buildErrorContent(state.message);
    } else {
      return _buildEmptyContent();
    }
  }

  Widget _buildAnalyticsContent(DepartmentAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie Chart
        SizedBox(
          height: 200,
          child: PieChartComponent(
            data: analytics.pieChartData
                .map(
                  (dept) => PieChartData(
                    label: dept.deptDescription,
                    value: dept.assetCount.toDouble(),
                    percentage: dept.percentage.toDouble(),
                    color: _getDepartmentColor(dept.deptCode),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Summary Information
        _buildSummaryStats(analytics),
        const SizedBox(height: 12),

        // Insights
        _buildInsights(analytics),
      ],
    );
  }

  Widget _buildSummaryStats(DepartmentAnalytics analytics) {
    final theme = Theme.of(context);

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
          _buildStatItem(
            '${analytics.summary.totalDepartments}',
            'แผนก',
            Icons.business,
            Colors.blue,
          ),
          _buildStatDivider(),
          _buildStatItem(
            '${analytics.summary.totalAssets}',
            'สินทรัพย์',
            Icons.inventory_2,
            Colors.green,
          ),
          _buildStatDivider(),
          _buildStatItem(
            '${analytics.summary.averageAssetsPerDepartment.toStringAsFixed(0)}',
            'เฉลี่ย/แผนก',
            Icons.analytics,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
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

  Widget _buildInsights(DepartmentAnalytics analytics) {
    if (analytics.pieChartData.isEmpty) {
      return const Text('• ไม่มีข้อมูลสำหรับการวิเคราะห์');
    }

    final topDepartments = analytics.topDepartments;
    final largestDept = topDepartments.isNotEmpty ? topDepartments.first : null;
    final secondLargest = topDepartments.length > 1 ? topDepartments[1] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (largestDept != null)
          Text(
            '• ${largestDept.deptDescription} ใช้งบลงทุนมากที่สุด (${largestDept.percentage}%)',
            style: const TextStyle(fontSize: 13),
          ),
        if (secondLargest != null)
          Text(
            '• ${secondLargest.deptDescription} รองลงมา (${secondLargest.percentage}%) → เน้น${_getDepartmentFocus(secondLargest.deptCode)}',
            style: const TextStyle(fontSize: 13),
          ),
        Text(
          '→ วิเคราะห์ ROI แยกแผนก เพื่อวางกลยุทธ์ปีถัดไป',
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
            Text('กำลังโหลดข้อมูลแผนก...'),
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
              'ไม่สามารถโหลดข้อมูลแผนกได้',
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
              onPressed: () {
                context.read<DashboardBloc>().add(
                  LoadDepartmentAnalytics(
                    plantCode: _selectedPlantCode == 'ทั้งหมด'
                        ? null
                        : _selectedPlantCode,
                    forceRefresh: true,
                  ),
                );
              },
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
            Icon(Icons.pie_chart_outline, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูลแผนก',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'กรุณาเพิ่มข้อมูลแผนกและสินทรัพย์',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _onPlantChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedPlantCode = value == 'ทั้งหมด' ? null : value;
      });

      // Reload data with new plant filter
      context.read<DashboardBloc>().add(
        LoadDepartmentAnalytics(
          plantCode: _selectedPlantCode,
          forceRefresh: true,
        ),
      );
    }
  }

  Color _getDepartmentColor(String deptCode) {
    // Static color mapping for consistency
    const departmentColors = {
      'IT': Color(0xFF2196F3), // Blue
      'PROD': Color(0xFF4CAF50), // Green
      'MAINT': Color(0xFFFF9800), // Orange
      'QC': Color(0xFF9C27B0), // Purple
      'LOG': Color(0xFFF44336), // Red
      'HR': Color(0xFF00BCD4), // Cyan
      'FIN': Color(0xFF795548), // Brown
      'ADMIN': Color(0xFF607D8B), // Blue Grey
    };

    return departmentColors[deptCode] ??
        Color((deptCode.hashCode & 0xFFFFFF) | 0xFF000000);
  }

  String _getDepartmentFocus(String deptCode) {
    const focusMap = {
      'IT': 'เทคโนโลยี',
      'PROD': 'การผลิต',
      'MAINT': 'การบำรุงรักษา',
      'QC': 'การควบคุมคุณภาพ',
      'LOG': 'โลจิสติกส์',
      'HR': 'ทรัพยากรบุคคล',
      'FIN': 'การเงิน',
      'ADMIN': 'การบริหาร',
    };

    return focusMap[deptCode] ?? 'งานประจำ';
  }
}
