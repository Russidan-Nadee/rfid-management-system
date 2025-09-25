import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

class CompactFilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isDark;

  const CompactFilterDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value != null
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3)),
          width: value != null ? 2 : 1,
        ),
      ),
      child: DropdownButton<String>(
        hint: Text(
          hint,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        value: value,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'All ${hint}s',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          ...items.map((String itemValue) {
            return DropdownMenuItem<String>(
              value: itemValue,
              child: Text(
                _formatFilterDisplayText(itemValue),
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            );
          }),
        ],
        onChanged: onChanged,
        underline: const SizedBox(),
        isDense: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? AppColors.darkText : AppColors.primary,
          size: 20,
        ),
        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
        style: AppTextStyles.caption.copyWith(
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
        ),
      ),
    );
  }

  String _formatFilterDisplayText(String value) {
    return value.replaceAll('_', ' ').toUpperCase();
  }
}