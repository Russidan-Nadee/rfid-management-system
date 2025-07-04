// Path: frontend/lib/features/dashboard/presentation/widgets/audit_progress_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
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
  @override
  Widget build(BuildContext context) {
    print('🔥 Widget rebuild with props: ${widget.selectedDeptCode}');

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
    print(
      '🎯 Building title with selectedDeptCode: ${widget.selectedDeptCode}',
    );
    if (widget.selectedDeptCode == null) {
      return 'Audit Progress - All Departments';
    }

    final selectedDept = widget.availableDepartments.firstWhere(
      (dept) => dept['code'] == widget.selectedDeptCode,
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
    return widget.selectedDeptCode == null ? 'Overall Progress' : null;
  }

  Color _getProgressColor() {
    final completionPercentage = _getProgressValue() * 100;
    if (completionPercentage >= 80) return AppColors.success;
    if (completionPercentage >= 50) return AppColors.vibrantOrange;
    return AppColors.error;
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
          value: widget.selectedDeptCode,
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
            print('🎯 Dropdown changed to: $newValue');
            widget.onDeptChanged(newValue);
          },
        ),
      ),
    );
  }

  Widget _buildProgressDetails() {
    print(
      '🎯 Building progress with selectedDeptCode: ${widget.selectedDeptCode}',
    );
    print(
      '🎯 Has overall progress: ${widget.auditProgress.overallProgress != null}',
    );

    // 1. ตรวจสอบว่าเลือกแผนกเฉพาะเจาะจงหรือไม่
    if (widget.selectedDeptCode != null) {
      print('🎯 Showing specific department data');
      final selectedDeptProgress = widget.auditProgress.auditProgress
          .where((dept) => dept.deptCode == widget.selectedDeptCode)
          .firstOrNull; // Ensure firstOrNull is available (Dart 2.12+ or collection package)

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
              'Await',
              selectedDeptProgress.pendingAudit.toString(),
              AppColors.vibrantOrange,
            ),
            _buildDivider(),
            _buildProgressStat(
              'Total',
              selectedDeptProgress.totalAssets.toString(),
              AppColors.primary,
            ),
          ],
        );
      } else {
        // กรณีเลือกแผนกเฉพาะเจาะจง แต่ไม่พบข้อมูลของแผนกนั้น
        return Center(
          child: Text(
            'No data available for this department.',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        );
      }
    }

    // 2. ถ้าเลือก "All Departments" (selectedDeptCode เป็น null)
    // ให้พยายามแสดง Overall Progress เป็นอันดับแรก
    final overallProgress = widget.auditProgress.overallProgress;
    if (overallProgress != null) {
      print('🎯 Showing overall progress data');
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
            'Awaiting',
            overallProgress.pendingAudit.toString(),
            AppColors.vibrantOrange,
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

    // 3. Fallback: ถ้าไม่มีทั้ง Overall Progress และไม่ได้เลือกแผนกเฉพาะเจาะจง
    // ให้แสดง Department Summary (ซึ่งเป็นการสรุปแผนก ไม่ใช่สินทรัพย์รวม)
    print(
      '🎯 Falling back to Department Summary as no overall progress available',
    );
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
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.vibrantOrange,
              ),
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
        return AppColors.vibrantOrange;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }
}
