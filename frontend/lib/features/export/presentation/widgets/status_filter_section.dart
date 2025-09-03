import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
import 'package:tp_rfid/l10n/features/export/export_localizations.dart';
import 'status_filter_card.dart';

class StatusFilterSection extends StatelessWidget {
  final List<String> selectedStatuses;
  final Function(List<String>) onStatusesChanged;
  final bool? isLargeScreen;

  const StatusFilterSection({
    super.key,
    required this.selectedStatuses,
    required this.onStatusesChanged,
    this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ExportLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge =
        isLargeScreen ?? (screenWidth >= AppConstants.tabletBreakpoint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, theme, l10n),
        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xl,
          ),
        ),
        _buildStatusOptions(context, isLarge, l10n),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    ExportLocalizations l10n,
  ) {
    return Row(
      children: [
        const Icon(Icons.filter_list, color: AppColors.primary, size: 20),
        AppSpacing.horizontalSpaceSM,
        Flexible(
          child: Text(
            l10n.statusFilter.replaceAll(': ', ''),
            style: AppTextStyles.cardTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (selectedStatuses.isNotEmpty) ...[
          AppSpacing.horizontalSpaceSM,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${selectedStatuses.length}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusOptions(
    BuildContext context,
    bool isLarge,
    ExportLocalizations l10n,
  ) {
    final statusOptions = [
      {
        'code': 'A',
        'label': l10n.statusAwaitingLabel,
        'color': AppColors.vibrantOrange,
        'icon': Icons.schedule,
      },
      {
        'code': 'C',
        'label': l10n.statusCheckedLabel,
        'color': AppColors.success,
        'icon': Icons.check_circle,
      },
      {
        'code': 'I',
        'label': l10n.statusInactiveLabel,
        'color': AppColors.error,
        'icon': Icons.cancel,
      },
    ];

    if (isLarge) {
      return _buildLargeScreenLayout(context, statusOptions, l10n);
    } else {
      return _buildCompactLayout(context, statusOptions, l10n);
    }
  }

  Widget _buildLargeScreenLayout(
    BuildContext context,
    List<Map<String, dynamic>> statusOptions,
    ExportLocalizations l10n,
  ) {
    // Create all cards in a single row - All + A + C + I
    final allCards = [
      // All Status card
      {
        'code': '',
        'label': l10n.statusAllLabel,
        'subtitle': l10n.allStatusDescription,
        'icon': Icons.select_all,
        'color': AppColors.primary,
        'isAllCard': true,
      },
      // Individual status cards
      ...statusOptions.map(
        (status) => {
          ...status,
          'subtitle': _getStatusDescription(status['code'] as String, l10n),
          'isAllCard': false,
        },
      ),
    ];

    return Row(
      children: allCards.map((card) {
        final isLast = allCards.last == card;
        final isAllCard = card['isAllCard'] as bool;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.lg),
            child: StatusFilterCard(
              isSelected: isAllCard
                  ? selectedStatuses.isEmpty
                  : selectedStatuses.contains(card['code']),
              statusCode: card['code'] as String,
              title: card['label'] as String,
              subtitle: card['subtitle'] as String,
              icon: card['icon'] as IconData,
              color: card['color'] as Color,
              onTap: isAllCard ? (_) => onStatusesChanged([]) : _toggleStatus,
              isMultiSelect: !isAllCard,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    List<Map<String, dynamic>> statusOptions,
    ExportLocalizations l10n,
  ) {
    // Create all cards for mobile 2x2 grid
    final allCards = [
      // All Status card
      {
        'code': '',
        'label': l10n.statusAllLabel,
        'subtitle': l10n.allStatusDescription,
        'icon': Icons.select_all,
        'color': AppColors.primary,
        'isAllCard': true,
      },
      // Individual status cards
      ...statusOptions.map(
        (status) => {
          ...status,
          'subtitle': _getStatusDescription(status['code'] as String, l10n),
          'isAllCard': false,
        },
      ),
    ];

    return Column(
      children: [
        // First row: All + Awaiting
        Row(
          children: [
            Expanded(child: _buildStatusCard(allCards[0], l10n)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: _buildStatusCard(allCards[1], l10n)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Second row: Checked + Inactive
        Row(
          children: [
            Expanded(child: _buildStatusCard(allCards[2], l10n)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: _buildStatusCard(allCards[3], l10n)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> card, ExportLocalizations l10n) {
    final isAllCard = card['isAllCard'] as bool;

    return StatusFilterCard(
      isSelected: isAllCard
          ? selectedStatuses.isEmpty
          : selectedStatuses.contains(card['code']),
      statusCode: card['code'] as String,
      title: card['label'] as String,
      subtitle: card['subtitle'] as String,
      icon: card['icon'] as IconData,
      color: card['color'] as Color,
      onTap: isAllCard ? (_) => onStatusesChanged([]) : _toggleStatus,
      isMultiSelect: !isAllCard,
    );
  }

  void _toggleStatus(String statusCode) {
    final newStatuses = List<String>.from(selectedStatuses);
    if (newStatuses.contains(statusCode)) {
      newStatuses.remove(statusCode);
    } else {
      newStatuses.add(statusCode);
    }
    onStatusesChanged(newStatuses);
  }

  String _getStatusDescription(String statusCode, ExportLocalizations l10n) {
    switch (statusCode) {
      case 'A':
        return l10n.statusAwaitingDescription;
      case 'C':
        return l10n.statusCheckedDescription;
      case 'I':
        return l10n.statusInactiveDescription;
      default:
        return '';
    }
  }
}
