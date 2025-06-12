// Path: frontend/lib/features/dashboard/presentation/widgets/period_selector.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final bool isLoading;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.isLoading = false,
  });

  static const List<PeriodOption> _periods = [
    PeriodOption(value: 'today', label: 'Today'),
    PeriodOption(value: '7d', label: '7 Days'),
    PeriodOption(value: '30d', label: '30 Days'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: isLoading ? _buildLoadingState() : _buildDropdown(),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Loading...',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedPeriod,
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        isDense: true,
        items: _periods.map((PeriodOption option) {
          return DropdownMenuItem<String>(
            value: option.value,
            child: Text(
              option.label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onBackground,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null && newValue != selectedPeriod) {
            onPeriodChanged(newValue);
          }
        },
      ),
    );
  }
}

class PeriodOption {
  final String value;
  final String label;

  const PeriodOption({required this.value, required this.label});
}

// Enhanced version with icons and descriptions
class PeriodSelectorEnhanced extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final bool isLoading;
  final bool showDescriptions;

  const PeriodSelectorEnhanced({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.isLoading = false,
    this.showDescriptions = false,
  });

  static const List<EnhancedPeriodOption> _enhancedPeriods = [
    EnhancedPeriodOption(
      value: 'today',
      label: 'Today',
      description: 'Current day',
      icon: Icons.today,
    ),
    EnhancedPeriodOption(
      value: '7d',
      label: '7 Days',
      description: 'Last week',
      icon: Icons.date_range,
    ),
    EnhancedPeriodOption(
      value: '30d',
      label: '30 Days',
      description: 'Last month',
      icon: Icons.calendar_month,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading ? _buildLoadingState() : _buildEnhancedDropdown(),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          'Loading...',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDropdown() {
    final selectedOption = _enhancedPeriods.firstWhere(
      (option) => option.value == selectedPeriod,
      orElse: () => _enhancedPeriods.first,
    );

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedPeriod,
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        isDense: true,
        selectedItemBuilder: (BuildContext context) {
          return _enhancedPeriods.map((option) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selectedOption.icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  selectedOption.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: _enhancedPeriods.map((EnhancedPeriodOption option) {
          return DropdownMenuItem<String>(
            value: option.value,
            child: showDescriptions
                ? _buildEnhancedItem(option)
                : _buildSimpleItem(option),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null && newValue != selectedPeriod) {
            onPeriodChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildSimpleItem(EnhancedPeriodOption option) {
    return Row(
      children: [
        Icon(option.icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          option.label,
          style: const TextStyle(fontSize: 14, color: AppColors.onBackground),
        ),
      ],
    );
  }

  Widget _buildEnhancedItem(EnhancedPeriodOption option) {
    return Row(
      children: [
        Icon(option.icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              option.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onBackground,
              ),
            ),
            Text(
              option.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EnhancedPeriodOption extends PeriodOption {
  final String description;
  final IconData icon;

  const EnhancedPeriodOption({
    required super.value,
    required super.label,
    required this.description,
    required this.icon,
  });
}

// Utility functions
class PeriodUtils {
  static String getPeriodLabel(String period) {
    switch (period) {
      case 'today':
        return 'Today';
      case '7d':
        return '7 Days';
      case '30d':
        return '30 Days';
      default:
        return period;
    }
  }

  static IconData getPeriodIcon(String period) {
    switch (period) {
      case 'today':
        return Icons.today;
      case '7d':
        return Icons.date_range;
      case '30d':
        return Icons.calendar_month;
      default:
        return Icons.calendar_today;
    }
  }

  static Duration getPeriodDuration(String period) {
    switch (period) {
      case 'today':
        return const Duration(days: 1);
      case '7d':
        return const Duration(days: 7);
      case '30d':
        return const Duration(days: 30);
      default:
        return const Duration(days: 1);
    }
  }

  static bool isValidPeriod(String period) {
    return ['today', '7d', '30d'].contains(period);
  }
}
