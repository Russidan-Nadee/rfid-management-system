import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../reports/presentation/types/view_mode.dart';
import '../../../reports/presentation/widgets/view_mode_toggle.dart';
import 'compact_filter_dropdown.dart';

class AllReportsFilterBar extends StatelessWidget implements PreferredSizeWidget {
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final VoidCallback onRefresh;

  // Filter values
  final String? selectedStatus;
  final String? selectedPriority;
  final String? selectedProblemType;
  final String? selectedPlantCode;
  final String? selectedLocationCode;

  // Filter callbacks
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPriorityChanged;
  final ValueChanged<String?> onProblemTypeChanged;
  final ValueChanged<String?> onPlantChanged;
  final ValueChanged<String?> onLocationChanged;
  final VoidCallback onClearFilters;

  // Master data
  final List<dynamic> plants;
  final List<dynamic> locations;
  final bool masterDataLoaded;

  const AllReportsFilterBar({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onRefresh,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.selectedProblemType,
    required this.selectedPlantCode,
    required this.selectedLocationCode,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onProblemTypeChanged,
    required this.onPlantChanged,
    required this.onLocationChanged,
    required this.onClearFilters,
    required this.plants,
    required this.locations,
    required this.masterDataLoaded,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: isDark ? AppColors.darkText : AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 1,
      flexibleSpace: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Active filter indicator
              if (_hasActiveFilters()) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getActiveFilterCount()} filters',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onClearFilters,
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              // Filters
              Expanded(
                child: _buildCompactFilters(isDark),
              ),
              const SizedBox(width: 16),
              // View toggle and refresh buttons
              ViewModeToggle(
                currentMode: viewMode,
                onModeChanged: onViewModeChanged,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRefresh,
                icon: Icon(
                  Icons.refresh,
                  color: isDark ? AppColors.darkText : AppColors.primary,
                ),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactFilters(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Status Filter
          CompactFilterDropdown(
            hint: 'Status',
            value: selectedStatus,
            items: const ['pending', 'acknowledged', 'in_progress', 'resolved', 'cancelled'],
            onChanged: onStatusChanged,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          // Priority Filter
          CompactFilterDropdown(
            hint: 'Priority',
            value: selectedPriority,
            items: const ['low', 'normal', 'high', 'critical'],
            onChanged: onPriorityChanged,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          // Problem Type Filter
          CompactFilterDropdown(
            hint: 'Problem',
            value: selectedProblemType,
            items: const ['asset_damage', 'asset_missing', 'location_issue', 'data_error', 'urgent_issue', 'other'],
            onChanged: onProblemTypeChanged,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          // Plant Filter
          _buildPlantFilterDropdown(isDark),
          const SizedBox(width: 12),
          // Location Filter
          _buildLocationFilterDropdown(isDark),
        ],
      ),
    );
  }

  Widget _buildPlantFilterDropdown(bool isDark) {
    if (!masterDataLoaded || plants.isEmpty) {
      return Container(
        height: 36,
        width: 100,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final plantItems = plants.map((plant) => plant['plant_code'] as String).toList();

    return CompactFilterDropdown(
      hint: 'Plant',
      value: selectedPlantCode,
      items: plantItems,
      onChanged: onPlantChanged,
      isDark: isDark,
    );
  }

  Widget _buildLocationFilterDropdown(bool isDark) {
    if (!masterDataLoaded || locations.isEmpty) {
      return Container(
        height: 36,
        width: 100,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Filter locations based on selected plant
    List<dynamic> filteredLocations = locations;
    if (selectedPlantCode != null) {
      filteredLocations = locations
          .where((location) => location['plant_code'] == selectedPlantCode)
          .toList();
    }

    final locationItems = filteredLocations.map((location) => location['location_code'] as String).toList();

    return CompactFilterDropdown(
      hint: 'Location',
      value: selectedLocationCode,
      items: locationItems,
      onChanged: onLocationChanged,
      isDark: isDark,
    );
  }

  bool _hasActiveFilters() {
    return selectedStatus != null ||
           selectedPriority != null ||
           selectedProblemType != null ||
           selectedPlantCode != null ||
           selectedLocationCode != null;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (selectedStatus != null) count++;
    if (selectedPriority != null) count++;
    if (selectedProblemType != null) count++;
    if (selectedPlantCode != null) count++;
    if (selectedLocationCode != null) count++;
    return count;
  }
}