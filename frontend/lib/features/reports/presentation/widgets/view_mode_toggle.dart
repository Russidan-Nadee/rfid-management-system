import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../types/view_mode.dart';

class ViewModeToggle extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onModeChanged;

  const ViewModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
          ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
          : AppColors.primarySurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
            ? AppColors.darkBorder.withValues(alpha: 0.3)
            : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            icon: Icons.view_module,
            mode: ViewMode.card,
            tooltip: 'Card View',
          ),
          const SizedBox(width: 2),
          _buildToggleButton(
            context,
            icon: Icons.table_rows,
            mode: ViewMode.table,
            tooltip: 'Table View',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required IconData icon,
    required ViewMode mode,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = currentMode == mode;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
              ? (isDark ? AppColors.primary.withValues(alpha: 0.8) : AppColors.primary)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
              ? Colors.white
              : (isDark ? AppColors.darkText : AppColors.primary),
          ),
        ),
      ),
    );
  }
}