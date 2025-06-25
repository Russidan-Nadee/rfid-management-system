// Path: frontend/lib/features/dashboard/presentation/widgets/audit_progress_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_decorations.dart';
import 'common/dashboard_card.dart';
import '../../domain/entities/audit_progress.dart';
import 'common/loading_skeleton.dart';

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

    return ProgressCard(
      title: _getCardTitle(),
      progress: _getProgressValue(),
      progressText: _getProgressText(),
      subtitle: _getSubtitle(),
      progressColor: _getProgressColor(),
      details: Column(
        children: [
          _buildDepartmentFilter(),
          AppSpacing.verticalSpaceLarge,
          _buildProgressDetails(),
          if (widget.auditProgress.hasRecommendations) ...[
            AppSpacing.verticalSpaceMedium,
            _buildRecommendations(),
          ],
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

  double _getProgressValue() {
    final overallProgress = widget.auditProgress.overallProgress;
    final completionPercentage =
        overallProgress?.completionPercentage ??
        widget.auditProgress.averageCompletionPercentage;
    return completionPercentage / 100;
  }

  String _getProgressText() {
    final overallProgress = widget.auditProgress.overallProgress;
    final completionPercentage =
        overallProgress?.completionPercentage ??
        widget.auditProgress.averageCompletionPercentage;
    return '${completionPercentage.toStringAsFixed(0)}%';
  }

  String? _getSubtitle() {
    return _currentSelectedDept == null ? 'Overall Progress' : null;
  }

  Color _getProgressColor() {
    final completionPercentage = _getProgressValue() * 100;
    if (completionPercentage >= 80) return AppColors.success;
    if (completionPercentage >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildDepartmentFilter() {
    final Map<String, String> uniqueDepts = {};

    for (final dept in widget.availableDepartments) {
      uniqueDepts[dept['code']!] = dept['name']!;
    }

    return Container(
      padding: AppSpacing.paddingHorizontalMedium.add(
        AppSpacing.paddingVerticalSmall,
      ),
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
              AppColors.success,
            ),
            _buildDivider(),
            _buildProgressStat(
              'Pending',
              selectedDeptProgress.pendingAudit.toString(),
              AppColors.warning,
            ),
            _buildDivider(),
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
            AppColors.success,
          ),
          _buildDivider(),
          _buildProgressStat(
            'Pending',
            overallProgress.pendingAudit.toString(),
            AppColors.warning,
          ),
          _buildDivider(),
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
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.verticalSpaceSmall,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProgressStat(
              'Completed',
              widget.auditProgress.completedDepartments.length.toString(),
              AppColors.success,
            ),
            _buildDivider(),
            _buildProgressStat(
              'Critical',
              widget.auditProgress.criticalDepartments.length.toString(),
              AppColors.error,
            ),
            _buildDivider(),
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
          style: AppTextStyles.statValue.copyWith(fontSize: 18, color: color),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppColors.divider);
  }

  Widget _buildRecommendations() {
    final criticalRecs = widget.auditProgress.criticalRecommendations;
    final warningRecs = widget.auditProgress.warningRecommendations;

    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: AppDecorations.chip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: AppColors.warning),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Recommendations',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSmall,
          if (criticalRecs.isNotEmpty) ...[
            ...criticalRecs.take(2).map((rec) => _buildRecommendationItem(rec)),
          ],
          if (warningRecs.isNotEmpty) ...[
            ...warningRecs.take(1).map((rec) => _buildRecommendationItem(rec)),
          ],
          if (widget.auditProgress.recommendations.length > 3)
            Text(
              '+ ${widget.auditProgress.recommendations.length - 3} more recommendations',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(Recommendation recommendation) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getRecommendationIcon(recommendation.type),
            size: 12,
            color: _getRecommendationColor(recommendation.type),
          ),
          AppSpacing.horizontalSpaceXS,
          Expanded(
            child: Text(
              recommendation.message,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return DashboardCard(
      title: 'Audit Progress',
      isLoading: true,
      child: const SkeletonChart(height: 200),
    );
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
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }
}
