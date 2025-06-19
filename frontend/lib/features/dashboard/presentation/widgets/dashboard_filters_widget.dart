// Path: frontend/lib/features/dashboard/presentation/widgets/dashboard_filters_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardFiltersWidget extends StatelessWidget {
  final String currentPeriod;
  final String? currentPlantFilter;
  final String? currentDeptFilter;
  final Function(String) onPeriodChanged;
  final Function(String?) onPlantChanged;
  final Function(String?) onDeptChanged;
  final VoidCallback onResetFilters;

  const DashboardFiltersWidget({
    super.key,
    required this.currentPeriod,
    this.currentPlantFilter,
    this.currentDeptFilter,
    required this.onPeriodChanged,
    required this.onPlantChanged,
    required this.onDeptChanged,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        // Period Filter
        _FilterDropdown<String>(
          label: 'Period',
          value: currentPeriod,
          icon: Icons.calendar_today,
          items: const [
            _DropdownItem('today', 'Today'),
            _DropdownItem('7d', '7 Days'),
            _DropdownItem('30d', '30 Days'),
          ],
          onChanged: onPeriodChanged,
        ),

        const SizedBox(width: 12),

        // Plant Filter
        _FilterDropdown<String?>(
          label: 'Plant',
          value: currentPlantFilter,
          icon: Icons.factory,
          items: const [
            _DropdownItem(null, 'All Plants'),
            _DropdownItem('P001', 'Plant A'),
            _DropdownItem('P002', 'Plant B'),
            _DropdownItem('P003', 'Plant C'),
          ],
          onChanged: onPlantChanged,
        ),

        const SizedBox(width: 12),

        // Department Filter
        _FilterDropdown<String?>(
          label: 'Dept',
          value: currentDeptFilter,
          icon: Icons.business,
          items: const [
            _DropdownItem(null, 'All Depts'),
            _DropdownItem('IT', 'IT'),
            _DropdownItem('GA', 'GA'),
            _DropdownItem('HR', 'HR'),
            _DropdownItem('ACC', 'ACC'),
          ],
          onChanged: onDeptChanged,
        ),

        const SizedBox(width: 8),

        // Reset Filters Button
        if (_hasActiveFilters()) ...[
          const SizedBox(width: 4),
          _ResetFiltersButton(onPressed: onResetFilters),
        ],
      ],
    );
  }

  bool _hasActiveFilters() {
    return currentPlantFilter != null ||
        currentDeptFilter != null ||
        currentPeriod != 'today';
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final IconData icon;
  final List<_DropdownItem<T>> items;
  final Function(T) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(item.label, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownItem<T> {
  final T value;
  final String label;

  const _DropdownItem(this.value, this.label);
}

class _ResetFiltersButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ResetFiltersButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.clear, size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced version with more features
class DashboardFiltersExpanded extends StatefulWidget {
  final String currentPeriod;
  final String? currentPlantFilter;
  final String? currentDeptFilter;
  final Function(String) onPeriodChanged;
  final Function(String?) onPlantChanged;
  final Function(String?) onDeptChanged;
  final VoidCallback onResetFilters;

  const DashboardFiltersExpanded({
    super.key,
    required this.currentPeriod,
    this.currentPlantFilter,
    this.currentDeptFilter,
    required this.onPeriodChanged,
    required this.onPlantChanged,
    required this.onDeptChanged,
    required this.onResetFilters,
  });

  @override
  State<DashboardFiltersExpanded> createState() =>
      _DashboardFiltersExpandedState();
}

class _DashboardFiltersExpandedState extends State<DashboardFiltersExpanded> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Compact filter row
        Row(
          children: [
            // Quick period buttons
            _QuickPeriodButtons(
              currentPeriod: widget.currentPeriod,
              onPeriodChanged: widget.onPeriodChanged,
            ),

            const SizedBox(width: 8),

            // Active filters indicator
            if (_hasActiveFilters())
              _ActiveFiltersIndicator(
                plantFilter: widget.currentPlantFilter,
                deptFilter: widget.currentDeptFilter,
              ),

            const SizedBox(width: 8),

            // Expand/Collapse button
            _ExpandButton(
              isExpanded: _isExpanded,
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ],
        ),

        // Expanded filter options
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          _ExpandedFilters(
            currentPlantFilter: widget.currentPlantFilter,
            currentDeptFilter: widget.currentDeptFilter,
            onPlantChanged: widget.onPlantChanged,
            onDeptChanged: widget.onDeptChanged,
            onResetFilters: widget.onResetFilters,
          ),
        ],
      ],
    );
  }

  bool _hasActiveFilters() {
    return widget.currentPlantFilter != null ||
        widget.currentDeptFilter != null;
  }
}

class _QuickPeriodButtons extends StatelessWidget {
  final String currentPeriod;
  final Function(String) onPeriodChanged;

  const _QuickPeriodButtons({
    required this.currentPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      _PeriodButton('today', 'Today'),
      _PeriodButton('7d', '7D'),
      _PeriodButton('30d', '30D'),
    ];

    return Row(
      children: periods.map((period) {
        final isSelected = currentPeriod == period.value;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _PeriodChip(
            label: period.label,
            isSelected: isSelected,
            onPressed: () => onPeriodChanged(period.value),
          ),
        );
      }).toList(),
    );
  }
}

class _PeriodButton {
  final String value;
  final String label;

  const _PeriodButton(this.value, this.label);
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveFiltersIndicator extends StatelessWidget {
  final String? plantFilter;
  final String? deptFilter;

  const _ActiveFiltersIndicator({this.plantFilter, this.deptFilter});

  @override
  Widget build(BuildContext context) {
    final activeFilters = <String>[];
    if (plantFilter != null) activeFilters.add('Plant: $plantFilter');
    if (deptFilter != null) activeFilters.add('Dept: $deptFilter');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_alt, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '${activeFilters.length} filter${activeFilters.length == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;

  const _ExpandButton({required this.isExpanded, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _ExpandedFilters extends StatelessWidget {
  final String? currentPlantFilter;
  final String? currentDeptFilter;
  final Function(String?) onPlantChanged;
  final Function(String?) onDeptChanged;
  final VoidCallback onResetFilters;

  const _ExpandedFilters({
    this.currentPlantFilter,
    this.currentDeptFilter,
    required this.onPlantChanged,
    required this.onDeptChanged,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Advanced Filters',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FilterDropdown<String?>(
                  label: 'Plant',
                  value: currentPlantFilter,
                  icon: Icons.factory,
                  items: const [
                    _DropdownItem(null, 'All Plants'),
                    _DropdownItem('P001', 'Plant A'),
                    _DropdownItem('P002', 'Plant B'),
                    _DropdownItem('P003', 'Plant C'),
                  ],
                  onChanged: onPlantChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterDropdown<String?>(
                  label: 'Department',
                  value: currentDeptFilter,
                  icon: Icons.business,
                  items: const [
                    _DropdownItem(null, 'All Departments'),
                    _DropdownItem('IT', 'Information Technology'),
                    _DropdownItem('GA', 'General Affairs'),
                    _DropdownItem('HR', 'Human Resources'),
                    _DropdownItem('ACC', 'Accounting'),
                  ],
                  onChanged: onDeptChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onResetFilters,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Reset All Filters'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
