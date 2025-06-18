// Path: frontend/lib/features/dashboard/presentation/widgets/summary_cards_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';

class SummaryCardsWidget extends StatelessWidget {
  const SummaryCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return _buildLoadingCards();
        } else if (state is QuickStatsLoaded) {
          return _buildStatsCards(state.quickStats);
        } else if (state is DashboardStatsLoaded) {
          return _buildStatsFromDashboard(state.stats.overview);
        } else if (state is DashboardError) {
          return _buildErrorCards(state.message);
        } else {
          return _buildEmptyCards();
        }
      },
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> quickStats) {
    final assets = quickStats['assets'] as Map<String, dynamic>? ?? {};
    final scans = quickStats['scans'] as Map<String, dynamic>? ?? {};
    final exports = quickStats['exports'] as Map<String, dynamic>? ?? {};
    final users = quickStats['users'] as Map<String, dynamic>? ?? {};

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          icon: LucideIcons.boxes,
          label: 'สินทรัพย์ทั้งหมด',
          value: '${assets['total'] ?? 0}',
          subtext: '${assets['active'] ?? 0} รายการใช้งาน',
          valueColor: Colors.blue,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.badgeCheck,
          label: 'ใช้งานอยู่',
          value: '${assets['active'] ?? 0}',
          subtext: _calculatePercentage(
            assets['active'] ?? 0,
            assets['total'] ?? 0,
          ),
          valueColor: Colors.green,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.badgeX,
          label: 'ไม่ใช้งาน',
          value: '${assets['inactive'] ?? 0}',
          subtext: _calculatePercentage(
            assets['inactive'] ?? 0,
            assets['total'] ?? 0,
          ),
          valueColor: Colors.red,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.packagePlus,
          label: 'สินทรัพย์ใหม่',
          value: '${assets['created'] ?? 0}',
          subtext: 'ในช่วงเวลาที่เลือก',
          valueColor: Colors.orange,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.scan,
          label: 'การสแกนล่าสุด',
          value: '${scans['period_count'] ?? 0}',
          subtext: 'ในช่วง ${scans['period'] ?? 'today'}',
          valueColor: Colors.purple,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.fileCheck,
          label: 'Export สำเร็จ',
          value: '${exports['completed'] ?? 0}',
          subtext: '${exports['total'] ?? 0} รายการทั้งหมด',
          valueColor: Colors.green,
          changePercent: null,
          trend: null,
        ),
      ],
    );
  }

  Widget _buildStatsFromDashboard(dynamic overview) {
    // Handle both entity and map structure
    final totalAssets = _getValue(overview, 'totalAssets', 'total_assets');
    final activeAssets = _getValue(overview, 'activeAssets', 'active_assets');
    final inactiveAssets = _getValue(
      overview,
      'inactiveAssets',
      'inactive_assets',
    );
    final createdAssets = _getValue(
      overview,
      'createdAssets',
      'created_assets',
    );
    final todayScans = _getValue(overview, 'todayScans', 'scans');
    final exportSuccess = _getValue(
      overview,
      'exportSuccess7d',
      'export_success',
    );

    // Get trend data if available
    final scansChangePercent = _getChangePercent(
      overview,
      'scansChangePercent',
      'scans',
    );
    final scansTrend = _getTrend(overview, 'scansTrend', 'scans');
    final exportChangePercent = _getChangePercent(
      overview,
      'exportSuccessChangePercent',
      'export_success',
    );
    final exportTrend = _getTrend(
      overview,
      'exportSuccessTrend',
      'export_success',
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          icon: LucideIcons.boxes,
          label: 'สินทรัพย์ทั้งหมด',
          value: '$totalAssets',
          subtext: '$activeAssets รายการใช้งาน',
          valueColor: Colors.blue,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.badgeCheck,
          label: 'ใช้งานอยู่',
          value: '$activeAssets',
          subtext: _calculatePercentage(activeAssets, totalAssets),
          valueColor: Colors.green,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.badgeX,
          label: 'ไม่ใช้งาน',
          value: '$inactiveAssets',
          subtext: _calculatePercentage(inactiveAssets, totalAssets),
          valueColor: Colors.red,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.packagePlus,
          label: 'สินทรัพย์ใหม่',
          value: '$createdAssets',
          subtext: 'รายการที่เพิ่งสร้าง',
          valueColor: Colors.orange,
          changePercent: null,
          trend: null,
        ),
        _SummaryCard(
          icon: LucideIcons.scan,
          label: 'การสแกนวันนี้',
          value: '$todayScans',
          subtext: _buildTrendText(scansChangePercent, scansTrend),
          valueColor: Colors.purple,
          changePercent: scansChangePercent,
          trend: scansTrend,
        ),
        _SummaryCard(
          icon: LucideIcons.fileCheck,
          label: 'Export สำเร็จ',
          value: '$exportSuccess',
          subtext: _buildTrendText(exportChangePercent, exportTrend),
          valueColor: Colors.green,
          changePercent: exportChangePercent,
          trend: exportTrend,
        ),
      ],
    );
  }

  Widget _buildLoadingCards() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(6, (index) => _buildLoadingCard()),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 160,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCards(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 32),
          const SizedBox(height: 8),
          Text(
            'Failed to load summary cards',
            style: TextStyle(
              color: Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCards() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          icon: LucideIcons.boxes,
          label: 'สินทรัพย์ทั้งหมด',
          value: '0',
          subtext: 'ไม่มีข้อมูล',
          valueColor: Colors.grey,
          changePercent: null,
          trend: null,
        ),
      ],
    );
  }

  // Helper methods
  dynamic _getValue(dynamic overview, String entityKey, String mapKey) {
    if (overview == null) return 0;

    // Try entity property first
    try {
      return overview.runtimeType.toString().contains('Overview')
          ? _getEntityValue(overview, entityKey)
          : (overview[mapKey] ?? overview[entityKey] ?? 0);
    } catch (e) {
      return overview[mapKey] ?? overview[entityKey] ?? 0;
    }
  }

  dynamic _getEntityValue(dynamic entity, String key) {
    switch (key) {
      case 'totalAssets':
        return entity.totalAssets ?? 0;
      case 'activeAssets':
        return entity.activeAssets ?? 0;
      case 'inactiveAssets':
        return entity.inactiveAssets ?? 0;
      case 'createdAssets':
        return entity.createdAssets ?? 0;
      case 'todayScans':
        return entity.todayScans ?? 0;
      case 'exportSuccess7d':
        return entity.exportSuccess7d ?? 0;
      default:
        return 0;
    }
  }

  int? _getChangePercent(dynamic overview, String entityKey, String section) {
    if (overview == null) return null;

    try {
      if (overview.runtimeType.toString().contains('Overview')) {
        switch (entityKey) {
          case 'scansChangePercent':
            return overview.scansChangePercent;
          case 'exportSuccessChangePercent':
            return overview.exportSuccessChangePercent;
          default:
            return null;
        }
      } else {
        final sectionData = overview[section] as Map<String, dynamic>?;
        return sectionData?['change_percent'];
      }
    } catch (e) {
      return null;
    }
  }

  String? _getTrend(dynamic overview, String entityKey, String section) {
    if (overview == null) return null;

    try {
      if (overview.runtimeType.toString().contains('Overview')) {
        switch (entityKey) {
          case 'scansTrend':
            return overview.scansTrend;
          case 'exportSuccessTrend':
            return overview.exportSuccessTrend;
          default:
            return null;
        }
      } else {
        final sectionData = overview[section] as Map<String, dynamic>?;
        return sectionData?['trend'];
      }
    } catch (e) {
      return null;
    }
  }

  String _calculatePercentage(int value, int total) {
    if (total == 0) return '0%';
    final percentage = (value / total * 100).round();
    return '$percentage%';
  }

  String _buildTrendText(int? changePercent, String? trend) {
    if (changePercent == null || trend == null) return 'ไม่มีข้อมูลเปรียบเทียบ';

    final sign = changePercent >= 0 ? '+' : '';
    final arrow = trend == 'up'
        ? '↗️'
        : trend == 'down'
        ? '↘️'
        : '→';

    return '$arrow $sign$changePercent%';
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtext;
  final Color valueColor;
  final int? changePercent;
  final String? trend;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtext,
    required this.valueColor,
    this.changePercent,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: valueColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getSubtextColor(),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getSubtextColor() {
    if (trend == null) return Colors.grey.shade600;

    switch (trend) {
      case 'up':
        return Colors.green.shade600;
      case 'down':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
