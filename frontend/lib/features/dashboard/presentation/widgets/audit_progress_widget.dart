// Path: frontend/lib/features/dashboard/presentation/widgets/audit_progress_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/audit_progress.dart';

class AuditProgressWidget extends StatefulWidget {
  final AuditProgress auditProgress;
  final bool includeDetails;
  final bool isLoading;
  final Function(bool) onToggleDetails;
  final String? selectedDeptCode;
  final List<Map<String, String>> availableDepartments;
  final Function(String?) onDeptChanged;

  const AuditProgressWidget({
    super.key,
    required this.auditProgress,
    required this.includeDetails,
    this.isLoading = false,
    required this.onToggleDetails,
    this.selectedDeptCode,
    this.availableDepartments = const [],
    required this.onDeptChanged,
  });

  @override
  State<AuditProgressWidget> createState() => _AuditProgressWidgetState();
}

class _AuditProgressWidgetState extends State<AuditProgressWidget> {
  String? _currentSelectedDept;

  @override
  void initState() {
    super.initState();
    _currentSelectedDept = widget.selectedDeptCode;
  }

  @override
  void didUpdateWidget(AuditProgressWidget oldWidget) {
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
      title: _getCardTitle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDepartmentFilter(),
          const SizedBox(height: 20),
          _buildProgressCircle(),
          const SizedBox(height: 20),
          _buildProgressDetails(),
          if (widget.auditProgress.hasRecommendations) ...[
            const SizedBox(height: 16),
            _buildRecommendations(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getCardTitle() {
    if (_currentSelectedDept == null) {
      return 'Audit Progress - All Departments';
    }

    final selectedDept = widget.availableDepartments.firstWhere(
      (dept) => dept['code'] == _currentSelectedDept,
      orElse: () => {'name': 'Unknown Department'},
    );

    return 'Audit Progress - ${selectedDept['name']}';
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

  Widget _buildProgressCircle() {
    final overallProgress = widget.auditProgress.overallProgress;
    final completionPercentage =
        overallProgress?.completionPercentage ??
        widget.auditProgress.averageCompletionPercentage;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: completionPercentage / 100,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(completionPercentage),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                '${completionPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(completionPercentage),
                ),
              ),
              const Text(
                'Checked',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetails() {
    // ถ้าเลือก Department เฉพาะ
    if (_currentSelectedDept != null) {
      // หา Department ที่เลือก
      final selectedDeptProgress = widget.auditProgress.auditProgress
          .where((dept) => dept.deptCode == _currentSelectedDept)
          .firstOrNull;

      if (selectedDeptProgress != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProgressStat(
              'Checked',
              selectedDeptProgress.auditedAssets.toString(),
              Colors.green,
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildProgressStat(
              'Pending',
              selectedDeptProgress.pendingAudit.toString(),
              Colors.orange,
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildProgressStat(
              'Total',
              selectedDeptProgress.totalAssets.toString(),
              AppColors.primary,
            ),
          ],
        );
      }
    }

    // ถ้าเลือก All Departments หรือมี overall progress
    final overallProgress = widget.auditProgress.overallProgress;
    if (overallProgress != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProgressStat(
            'Checked',
            overallProgress.auditedAssets.toString(),
            Colors.green,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildProgressStat(
            'Pending',
            overallProgress.pendingAudit.toString(),
            Colors.orange,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildProgressStat(
            'Total',
            overallProgress.totalAssets.toString(),
            AppColors.primary,
          ),
        ],
      );
    }

    // Fallback: แสดง Department Summary
    return Column(
      children: [
        Text(
          'Department Summary',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProgressStat(
              'Completed',
              widget.auditProgress.completedDepartments.length.toString(),
              Colors.green,
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildProgressStat(
              'Critical',
              widget.auditProgress.criticalDepartments.length.toString(),
              Colors.red,
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildProgressStat(
              'Total Depts',
              widget.auditProgress.auditProgress.length.toString(),
              AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecommendations() {
    final criticalRecs = widget.auditProgress.criticalRecommendations;
    final warningRecs = widget.auditProgress.warningRecommendations;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 6),
              const Text(
                'Recommendations',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (criticalRecs.isNotEmpty) ...[
            ...criticalRecs.take(2).map((rec) => _buildRecommendationItem(rec)),
          ],
          if (warningRecs.isNotEmpty) ...[
            ...warningRecs.take(1).map((rec) => _buildRecommendationItem(rec)),
          ],
          if (widget.auditProgress.recommendations.length > 3)
            Text(
              '+ ${widget.auditProgress.recommendations.length - 3} more recommendations',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(Recommendation recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getRecommendationIcon(recommendation.type),
            size: 12,
            color: _getRecommendationColor(recommendation.type),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              recommendation.message,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return _DashboardCard(
      title: 'Audit Progress',
      child: Container(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getRecommendationIcon(String type) {
    switch (type) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Color _getRecommendationColor(String type) {
    switch (type) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      default:
        return AppColors.primary;
    }
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
