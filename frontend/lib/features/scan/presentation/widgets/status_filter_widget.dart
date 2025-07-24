// Path: frontend/lib/features/scan/presentation/widgets/status_filter_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

// Theme Extension สำหรับ Status Filter Colors
extension StatusFilterTheme on ThemeData {
  Color getFilterColor(String label) {
    switch (label.toLowerCase()) {
      case 'all':
        return colorScheme.primary;
      case 'awaiting':
        return colorScheme.primary;
      case 'checked':
        return AppColors.assetActive;
      case 'inactive':
        return colorScheme.error;
      case 'unknown':
        return AppColors.error.withValues(alpha: 0.7); // สีแดงสำหรับ Unknown
      default:
        return colorScheme.primary;
    }
  }

  // Standard opacity levels
  static const double surfaceOpacity = 0.1;
  static const double borderOpacity = 0.3;
}

class StatusFilterWidget extends StatefulWidget {
  final Map<String, int> statusCounts;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const StatusFilterWidget({
    super.key,
    required this.statusCounts,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<StatusFilterWidget> createState() => _StatusFilterWidgetState();
}

class _StatusFilterWidgetState extends State<StatusFilterWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(
              alpha: StatusFilterTheme.borderOpacity,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkText
                        : theme.colorScheme.primary,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    'Filter by Status',
                    style: AppTextStyles.filterLabel.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: _buildStatusFilters(),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _buildFilterChip('All', widget.statusCounts['All'] ?? 0),
        if ((widget.statusCounts['Active'] ?? 0) > 0)
          _buildFilterChip('Awaiting', widget.statusCounts['Active'] ?? 0),
        if ((widget.statusCounts['Checked'] ?? 0) > 0)
          _buildFilterChip('Checked', widget.statusCounts['Checked'] ?? 0),
        if ((widget.statusCounts['Inactive'] ?? 0) > 0)
          _buildFilterChip('Inactive', widget.statusCounts['Inactive'] ?? 0),
        if ((widget.statusCounts['Unknown'] ?? 0) > 0)
          _buildFilterChip('Unknown', widget.statusCounts['Unknown'] ?? 0),
      ],
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedFilter == label;
    final color = theme.getFilterColor(label);

    return GestureDetector(
      onTap: () => widget.onFilterChanged(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : color.withValues(alpha: StatusFilterTheme.surfaceOpacity),
          borderRadius: AppBorders.lg,
          border: Border.all(
            color: isSelected
                ? color
                : (label.toLowerCase() == 'unknown'
                      ? AppColors.error.withValues(
                          alpha: 0.7,
                        ) // Unknown: เก็บขอบสีแดง
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary.withValues(
                                alpha: 0.2,
                              ) // Dark Mode: เทาอ่อน
                            : color)), // Light Mode: สีตาม status เดิม
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: AppTextStyles.filterLabel.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : (label.toLowerCase() == 'unknown'
                      ? AppColors
                            .error // Unknown: text สีแดง
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors
                                  .darkText // Dark Mode: สีขาว
                            : color)), // Light Mode: สีตาม status
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
