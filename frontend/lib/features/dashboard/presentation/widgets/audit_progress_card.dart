// Path: frontend/lib/features/dashboard/presentation/widgets/audit_progress_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'chart_card_wrapper.dart';
import 'progress_chart_component.dart';

class AuditProgressCard extends StatefulWidget {
  const AuditProgressCard({super.key});

  @override
  State<AuditProgressCard> createState() => _AuditProgressCardState();
}

class _AuditProgressCardState extends State<AuditProgressCard> {
  String _selectedDeptCode = 'ทั้งหมด';
  final List<String> _departmentOptions = [
    'ทั้งหมด',
    'IT',
    'PROD',
    'MAINT',
    'QC',
    'LOG',
    'HR',
    'FIN',
    'ADMIN',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return ChartCardWrapper(
          title: '📋 ความคืบหน้าการตรวจสอบประจำปี',
          dropdownLabel: 'แผนก:',
          dropdownValue: _selectedDeptCode,
          dropdownItems: _departmentOptions,
          onDropdownChanged: _onDepartmentChanged,
          child: _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(DashboardState state) {
    if (state is DashboardLoading) {
      return _buildLoadingContent();
    } else if (state is AuditProgressLoaded) {
      return _buildProgressContent(state.progress);
    } else if (state is DashboardError) {
      return _buildErrorContent(state.message);
    } else {
      return _buildEmptyContent();
    }
  }

  Widget _buildProgressContent(Map<String, dynamic> progress) {
    final auditProgress = progress['audit_progress'] as List<dynamic>? ?? [];
    final overallProgress =
        progress['overall_progress'] as Map<String, dynamic>?;
    final recommendations = progress['recommendations'] as List<dynamic>? ?? [];

    // Calculate overall completion percentage
    double completionPercentage = 0.0;
    int totalAssets = 0;
    int auditedAssets = 0;
    int pendingAssets = 0;

    if (overallProgress != null) {
      totalAssets = overallProgress['total_assets'] ?? 0;
      auditedAssets = overallProgress['audited_assets'] ?? 0;
      pendingAssets = overallProgress['pending_audit'] ?? 0;
      completionPercentage = (overallProgress['completion_percentage'] ?? 0.0)
          .toDouble();
    } else if (auditProgress.isNotEmpty) {
      // Calculate from department data
      for (final dept in auditProgress) {
        totalAssets += (dept['total_assets'] ?? 0) as int;
        auditedAssets += (dept['audited_assets'] ?? 0) as int;
        pendingAssets += (dept['pending_audit'] ?? 0) as int;
      }
      if (totalAssets > 0) {
        completionPercentage = (auditedAssets / totalAssets) * 100;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Circle
        Center(
          child: SizedBox(
            height: 140,
            child: ProgressChartComponent(
              percentage: completionPercentage,
              centerValue: '${completionPercentage.toInt()}%',
              centerLabel: 'เสร็จแล้ว',
              color: _getProgressColor(completionPercentage),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Progress Details
        _buildProgressDetails(totalAssets, auditedAssets, pendingAssets),
        const SizedBox(height: 16),

        // Department Progress (if multiple departments)
        if (auditProgress.isNotEmpty && _selectedDeptCode == 'ทั้งหมด')
          _buildDepartmentProgress(auditProgress),

        // Insights and Recommendations
        _buildProgressInsights(completionPercentage, recommendations),
      ],
    );
  }

  Widget _buildProgressDetails(
    int totalAssets,
    int auditedAssets,
    int pendingAssets,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProgressDetailItem(
            '$auditedAssets',
            'ตรวจแล้ว',
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatDivider(),
          _buildProgressDetailItem(
            '$pendingAssets',
            'รอตรวจ',
            Icons.schedule,
            Colors.orange,
          ),
          _buildStatDivider(),
          _buildProgressDetailItem(
            '$totalAssets',
            'ทั้งหมด',
            Icons.inventory_2,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetailItem(
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

  Widget _buildDepartmentProgress(List<dynamic> auditProgress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ความคืบหน้าแยกตามแผนก',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...auditProgress
            .take(5)
            .map((dept) => _buildDepartmentProgressItem(dept))
            .toList(),
        if (auditProgress.length > 5)
          Text(
            'และอีก ${auditProgress.length - 5} แผนก...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDepartmentProgressItem(dynamic dept) {
    final deptCode = dept['dept_code'] ?? '';
    final deptDescription = dept['dept_description'] ?? deptCode;
    final completionPercentage = (dept['completion_percentage'] ?? 0.0)
        .toDouble();
    final auditedAssets = dept['audited_assets'] ?? 0;
    final totalAssets = dept['total_assets'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              deptDescription,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(completionPercentage),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${completionPercentage.toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _getProgressColor(completionPercentage),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '$auditedAssets/$totalAssets',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInsights(
    double completionPercentage,
    List<dynamic> recommendations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ความคืบหน้าภาพรวม ${completionPercentage.toInt()}% ของการตรวจสอบประจำปี',
          style: const TextStyle(fontSize: 13),
        ),
        Text(
          '• เป้าหมายให้เสร็จสิ้นภายในไตรมาส 3',
          style: const TextStyle(fontSize: 13),
        ),
        if (completionPercentage < 50)
          Text(
            '→ ต้องเร่งความเร็วเพิ่มขึ้น ${(50 - completionPercentage).toInt()}% เพื่อทันเป้าหมาย',
            style: TextStyle(
              fontSize: 13,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          )
        else if (completionPercentage < 80)
          Text(
            '→ ความคืบหน้าดี แต่ยังต้องเร่งให้เสร็จ ${(100 - completionPercentage).toInt()}%',
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            '→ ความคืบหน้าดีมาก เหลืออีก ${(100 - completionPercentage).toInt()}% เท่านั้น',
            style: TextStyle(
              fontSize: 13,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),

        // Show critical recommendations
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...recommendations
              .take(2)
              .map((rec) => _buildRecommendationItem(rec))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildRecommendationItem(dynamic recommendation) {
    final type = recommendation['type'] ?? '';
    final message = recommendation['message'] ?? '';
    final action = recommendation['action'] ?? '';

    Color color = Colors.blue;
    IconData icon = Icons.info;

    switch (type) {
      case 'critical':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'warning':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'success':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'department_alert':
        color = Colors.purple;
        icon = Icons.business;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              action.isNotEmpty ? '$message → $action' : message,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ),
        ],
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
            Text('กำลังโหลดข้อมูลการตรวจสอบ...'),
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
              'ไม่สามารถโหลดข้อมูลการตรวจสอบได้',
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
            Icon(Icons.assignment_outlined, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูลการตรวจสอบ',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ยังไม่มีการตรวจสอบสินทรัพย์ในระบบ',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _onDepartmentChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedDeptCode = value;
      });
      _reloadData();
    }
  }

  void _reloadData() {
    context.read<DashboardBloc>().add(
      LoadAuditProgress(
        deptCode: _selectedDeptCode == 'ทั้งหมด' ? null : _selectedDeptCode,
        includeDetails: false,
        forceRefresh: true,
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}
