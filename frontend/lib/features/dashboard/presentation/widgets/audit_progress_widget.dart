// Path: frontend/lib/features/dashboard/presentation/widgets/audit_progress_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/audit_progress.dart';

class AuditProgressWidget extends StatelessWidget {
  final AuditProgress auditProgress;
  final bool includeDetails;
  final bool isLoading;
  final Function(bool) onToggleDetails;

  const AuditProgressWidget({
    super.key,
    required this.auditProgress,
    required this.includeDetails,
    this.isLoading = false,
    required this.onToggleDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    return _DashboardCard(
      title: 'Audit Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildProgressCircle(),
          const SizedBox(height: 20),
          _buildProgressDetails(),
          if (auditProgress.hasRecommendations) ...[
            const SizedBox(height: 16),
            _buildRecommendations(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    final overallProgress = auditProgress.overallProgress;
    final completionPercentage =
        overallProgress?.completionPercentage ??
        auditProgress.averageCompletionPercentage;

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
    final overallProgress = auditProgress.overallProgress;

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

    // If no overall progress, show department summary
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
              auditProgress.completedDepartments.length.toString(),
              Colors.green,
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildProgressStat(
              'Critical',
              auditProgress.criticalDepartments.length.toString(),
              Colors.red,
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildProgressStat(
              'Total Depts',
              auditProgress.auditProgress.length.toString(),
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
    final criticalRecs = auditProgress.criticalRecommendations;
    final warningRecs = auditProgress.warningRecommendations;

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
          if (auditProgress.recommendations.length > 3)
            Text(
              '+ ${auditProgress.recommendations.length - 3} more recommendations',
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
