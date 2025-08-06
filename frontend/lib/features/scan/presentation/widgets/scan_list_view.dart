// Path: frontend/lib/features/scan/presentation/widgets/scan_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/app/theme/app_spacing.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import 'package:frontend/app/theme/app_typography.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import 'asset_card.dart';

// Theme Extension สำหรับ Filter Colors
extension FilterTheme on ThemeData {
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
        return AppColors.error.withValues(alpha: 0.7);
      default:
        return colorScheme.primary;
    }
  }

  // Standard opacity levels
  static const double surfaceOpacity = 0.1;
  static const double borderOpacity = 0.3;
  static const double textSecondaryOpacity = 0.6;
  static const double textTertiaryOpacity = 0.5;
}

// UI Constants
class ScanListConstants {
  static const double maxLocationDisplayLength = 20.0;
  static const double trimLocationLength = 17.0;
  static const double iconContainerSize = 80.0;
  static const double emptyStateIconSize = 40.0;
  static const int borderWidthSelected = 2;
  static const int borderWidthNormal = 1;
}

class ScanListView extends StatefulWidget {
  final List<ScannedItemEntity> scannedItems;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const ScanListView({
    super.key,
    required this.scannedItems,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<ScanListView> createState() => _ScanListViewState();
}

class _ScanListViewState extends State<ScanListView> {
  bool _isLocationFilterExpanded = true;
  bool _isStatusFilterExpanded = true;
  late TextEditingController _locationSearchController;
  String _locationSearchQuery = '';
  
  // ✅ Store the last ScanSuccess to preserve UI state
  ScanSuccess? _lastValidScanSuccess;

  @override
  void initState() {
    super.initState();
    _locationSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _locationSearchController.dispose();
    super.dispose();
  }

  void _triggerLoadExpectedCounts(ScanSuccess state) {
    if (state.expectedCounts.isEmpty) {
      final locationCodes = state.scannedItems
          .where(
            (item) =>
                item.locationCode != null && item.locationCode!.isNotEmpty,
          )
          .map((item) => item.locationCode!)
          .toSet()
          .toList();

      if (locationCodes.isNotEmpty) {
        context.read<ScanBloc>().add(
          LoadExpectedCounts(locationCodes: locationCodes),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ScanLocalizations.of(context);

    if (widget.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (widget.scannedItems.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    // Get latest ScanSuccess state for filter info
    return BlocBuilder<ScanBloc, ScanState>(
      builder: (context, state) {
        // ✅ Always preserve the latest ScanSuccess state
        if (state is ScanSuccess) {
          _lastValidScanSuccess = state;
        }
        
        // ✅ Use current state if it's ScanSuccess, otherwise use preserved state
        ScanSuccess? currentScanState;
        if (state is ScanSuccess) {
          currentScanState = state;
        } else if (_lastValidScanSuccess != null) {
          currentScanState = _lastValidScanSuccess;
        }
        
        // ✅ Use the state's built-in filtering logic or fallback to widget items
        List<ScannedItemEntity> itemsToShow;
        String selectedFilter = 'All';
        String selectedLocation = 'All Locations';
        List<String> availableLocations = [];
        Map<String, int> statusCounts = {};
        
        if (currentScanState != null) {
          // ✅ Use the state's filteredItems (this handles all filtering logic)
          itemsToShow = currentScanState.filteredItems;
          selectedFilter = currentScanState.selectedFilter;
          selectedLocation = currentScanState.selectedLocation;
          availableLocations = currentScanState.availableLocations;
          statusCounts = currentScanState.statusCounts;
          
          // Trigger expected counts for current ScanSuccess state
          if (state is ScanSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _triggerLoadExpectedCounts(state);
            });
          }
        } else {
          // ✅ Fallback when no preserved state exists
          itemsToShow = widget.scannedItems;
          final uniqueLocations = widget.scannedItems
              .map((item) => item.locationName ?? 'Unknown')
              .toSet()
              .toList();
          uniqueLocations.sort();
          availableLocations = ['All Locations', ...uniqueLocations];
          
          statusCounts = {
            'All': widget.scannedItems.length,
            'Active': widget.scannedItems.where((item) => item.status.toUpperCase() == 'A').length,
            'Checked': widget.scannedItems.where((item) => item.status.toUpperCase() == 'C').length,
            'Inactive': widget.scannedItems.where((item) => item.status.toUpperCase() == 'I').length,
            'Unknown': widget.scannedItems.where((item) => item.isUnknown == true).length,
          };
        }

        return RefreshIndicator(
          onRefresh: () async {
            widget.onRefresh?.call();
          },
          color: theme.colorScheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Filter
              _buildLocationFilter(
                theme,
                availableLocations,
                selectedLocation,
                _lastValidScanSuccess,
                context,
                l10n,
              ),

              // Status Filter
              _buildStatusFilter(
                theme,
                statusCounts,
                selectedFilter,
                context,
                l10n,
              ),

              // Filtered List
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (itemsToShow.isEmpty) {
                      return _buildEmptyFilterState(
                        theme,
                        selectedFilter,
                        selectedLocation,
                        l10n,
                      );
                    }

                    // Responsive columns
                    if (constraints.maxWidth >= 1200) {
                      // 3 columns
                      return _buildGridView(itemsToShow, 3);
                    } else if (constraints.maxWidth >= 800) {
                      // 2 columns
                      return _buildGridView(itemsToShow, 2);
                    } else {
                      // 1 column
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: itemsToShow.length,
                        itemBuilder: (context, index) =>
                            AssetCard(item: itemsToShow[index]),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<ScannedItemEntity> items, int columns) {
    List<Widget> rows = [];
    for (var i = 0; i < items.length; i += columns) {
      List<Widget> rowChildren = [];
      for (var j = 0; j < columns; j++) {
        if (i + j < items.length) {
          rowChildren.add(Expanded(child: AssetCard(item: items[i + j])));
        } else {
          rowChildren.add(Expanded(child: Container()));
        }
      }
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(children: rows),
    );
  }

  Widget _buildLocationFilter(
    ThemeData theme,
    List<String> availableLocations,
    String selectedLocation,
    ScanSuccess? state,
    BuildContext context,
    ScanLocalizations l10n,
  ) {
    final filteredLocations = availableLocations.where((location) {
      return location.toLowerCase().contains(
        _locationSearchQuery.toLowerCase(),
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(
              alpha: FilterTheme.borderOpacity,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with Search
          Padding(
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => setState(
                    () =>
                        _isLocationFilterExpanded = !_isLocationFilterExpanded,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkText
                            : theme.colorScheme.primary,
                        size: 18,
                      ),
                      AppSpacing.horizontalSpaceSM,
                      Text(
                        l10n.filterByLocation,
                        style: AppTextStyles.filterLabel.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkText
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: TextField(
                    controller: _locationSearchController,
                    onChanged: (value) =>
                        setState(() => _locationSearchQuery = value),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.searchLocations,
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkText
                            : theme.colorScheme.primary,
                        size: 18,
                      ),
                      suffixIcon: _locationSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkText
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                size: 18,
                              ),
                              onPressed: () {
                                _locationSearchController.clear();
                                setState(() => _locationSearchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.2,
                                )
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.2,
                                )
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                ),
                AppSpacing.horizontalSpaceSM,
                InkWell(
                  onTap: () => setState(
                    () =>
                        _isLocationFilterExpanded = !_isLocationFilterExpanded,
                  ),
                  child: AnimatedRotation(
                    turns: _isLocationFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isLocationFilterExpanded ? null : 0,
            child: _isLocationFilterExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: filteredLocations.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              l10n.noLocationsFound(_locationSearchQuery),
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkText
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: filteredLocations.map((location) {
                                return Padding(
                                  padding: AppSpacing.only(
                                    right: AppSpacing.sm,
                                  ),
                                  child: _buildLocationChip(
                                    context,
                                    theme,
                                    location,
                                    selectedLocation,
                                    state,
                                    l10n,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(
    BuildContext context,
    ThemeData theme,
    String location,
    String selectedLocation,
    ScanSuccess? state,
    ScanLocalizations l10n,
  ) {
    final isSelected = selectedLocation == location;
    final isAllLocations = location == l10n.allLocations;
    final isCurrentLocation = state?.currentLocation == location;

    // Get comparison data
    int scannedCount = 0;
    int expectedCount = 0;

    if (!isAllLocations && state != null) {
      // Count items that belong to this location (based on their registered locationName)
      scannedCount = state.scannedItems
          .where((item) => item.locationName == location)
          .length;

      // Get the locationCode for this location to fetch expected count
      final locationCode = state.scannedItems
          .where((item) => item.locationName == location)
          .map((item) => item.locationCode)
          .where((code) => code != null)
          .firstOrNull;

      if (locationCode != null) {
        expectedCount = state.expectedCounts[locationCode] ?? 0;
      }

    }

    // Determine chip color
    Color chipColor;
    Color textColor;
    Color borderColor;

    if (isAllLocations) {
      chipColor = isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withValues(
              alpha: FilterTheme.surfaceOpacity,
            );
      textColor = isSelected
          ? theme.colorScheme.onPrimary
          : (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : theme.colorScheme.primary);
      borderColor = theme.colorScheme.primary;
    } else if (isCurrentLocation) {
      chipColor = isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withValues(
              alpha: FilterTheme.surfaceOpacity,
            );
      textColor = isSelected
          ? theme.colorScheme.onPrimary
          : theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary;
    } else if (scannedCount > 0) {
      chipColor = isSelected
          ? AppColors.warning
          : AppColors.warning.withValues(alpha: FilterTheme.surfaceOpacity);
      textColor = isSelected ? Colors.white : AppColors.warning;
      borderColor = AppColors.warning;
    } else {
      chipColor = isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withValues(
              alpha: FilterTheme.surfaceOpacity,
            );
      textColor = isSelected
          ? theme.colorScheme.onPrimary
          : (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : theme.colorScheme.primary);
      borderColor = Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkTextSecondary.withValues(alpha: 0.2)
          : theme.colorScheme.primary;
    }

    return GestureDetector(
      onTap: () => context.read<ScanBloc>().add(
        LocationFilterChanged(location: location),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: AppBorders.lg,
          border: Border.all(
            color: borderColor,
            width: isSelected
                ? ScanListConstants.borderWidthSelected.toDouble()
                : ScanListConstants.borderWidthNormal.toDouble(),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAllLocations ? Icons.public : Icons.location_on,
              size: 16,
              color: textColor,
            ),
            AppSpacing.horizontalSpaceXS,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDisplayText(location),
                  style: AppTextStyles.filterLabel.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (!isAllLocations && (scannedCount > 0 || expectedCount > 0))
                  Text(
                    isCurrentLocation && expectedCount > 0
                        ? '($scannedCount/$expectedCount)'
                        : '($scannedCount)',
                    style: AppTextStyles.caption.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            if (!isAllLocations &&
                isCurrentLocation &&
                expectedCount > 0 &&
                scannedCount < expectedCount) ...[
              AppSpacing.horizontalSpaceXS,
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(
    ThemeData theme,
    Map<String, int> statusCounts,
    String selectedFilter,
    BuildContext context,
    ScanLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(
              alpha: FilterTheme.borderOpacity,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _isStatusFilterExpanded = !_isStatusFilterExpanded,
            ),
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
                    l10n.filterByStatus,
                    style: AppTextStyles.filterLabel.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isStatusFilterExpanded ? 0.5 : 0,
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isStatusFilterExpanded ? null : 0,
            child: _isStatusFilterExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _buildFilterChip(
                          theme,
                          l10n.all,
                          statusCounts['All'] ?? 0,
                          selectedFilter,
                          context,
                          l10n,
                        ),
                        if ((statusCounts['Active'] ?? 0) > 0)
                          _buildFilterChip(
                            theme,
                            l10n.statusAwaiting,
                            statusCounts['Active'] ?? 0,
                            selectedFilter,
                            context,
                            l10n,
                          ),
                        if ((statusCounts['Checked'] ?? 0) > 0)
                          _buildFilterChip(
                            theme,
                            l10n.statusChecked,
                            statusCounts['Checked'] ?? 0,
                            selectedFilter,
                            context,
                            l10n,
                          ),
                        if ((statusCounts['Inactive'] ?? 0) > 0)
                          _buildFilterChip(
                            theme,
                            l10n.statusInactive,
                            statusCounts['Inactive'] ?? 0,
                            selectedFilter,
                            context,
                            l10n,
                          ),
                        if ((statusCounts['Unknown'] ?? 0) > 0)
                          _buildFilterChip(
                            theme,
                            l10n.statusUnknown,
                            statusCounts['Unknown'] ?? 0,
                            selectedFilter,
                            context,
                            l10n,
                          ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    String label,
    int count,
    String selectedFilter,
    BuildContext context,
    ScanLocalizations l10n,
  ) {
    // Map localized labels to internal filter values
    String filterValue = label;
    if (label == l10n.statusAwaiting) {
      filterValue = 'Awaiting';
    } else if (label == l10n.statusChecked) {
      filterValue = 'Checked';
    } else if (label == l10n.statusInactive) {
      filterValue = 'Inactive';
    } else if (label == l10n.statusUnknown) {
      filterValue = 'Unknown';
    } else if (label == l10n.all) {
      filterValue = 'All';
    }

    final isSelected = selectedFilter == filterValue;
    final color = theme.getFilterColor(filterValue);

    return GestureDetector(
      onTap: () =>
          context.read<ScanBloc>().add(FilterChanged(filter: filterValue)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : color.withValues(alpha: FilterTheme.surfaceOpacity),
          borderRadius: AppBorders.lg,
          border: Border.all(
            color: isSelected
                ? color
                : (filterValue.toLowerCase() == 'unknown'
                      ? AppColors.error.withValues(alpha: 0.7)
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.2)
                            : color)),
            width: isSelected
                ? ScanListConstants.borderWidthSelected.toDouble()
                : ScanListConstants.borderWidthNormal.toDouble(),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: AppTextStyles.filterLabel.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : (filterValue.toLowerCase() == 'unknown'
                      ? AppColors.error
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkText
                            : color)),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getDisplayText(String location) {
    if (location.length > ScanListConstants.maxLocationDisplayLength) {
      return '${location.substring(0, ScanListConstants.trimLocationLength.toInt())}...';
    }
    return location;
  }

  Widget _buildEmptyFilterState(
    ThemeData theme,
    String filter,
    String location,
    ScanLocalizations l10n,
  ) {
    final isLocationFilter = location != l10n.allLocations;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ScanListConstants.iconContainerSize,
            height: ScanListConstants.iconContainerSize,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: FilterTheme.surfaceOpacity,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocationFilter ? Icons.location_off : Icons.filter_list_off,
              size: ScanListConstants.emptyStateIconSize,
              color: theme.colorScheme.primary.withValues(
                alpha: FilterTheme.textSecondaryOpacity,
              ),
            ),
          ),
          AppSpacing.verticalSpaceLG,
          Text(
            isLocationFilter
                ? l10n.noItemsInLocation(location)
                : l10n.noFilteredItems(filter),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkText
                  : theme.colorScheme.onBackground.withValues(
                      alpha: FilterTheme.textSecondaryOpacity,
                    ),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            isLocationFilter
                ? l10n.tryDifferentLocationOrScan
                : l10n.tryDifferentFilterOrScan,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : theme.colorScheme.onBackground.withValues(
                      alpha: FilterTheme.textTertiaryOpacity,
                    ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ScanLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ScanListConstants.iconContainerSize,
            height: ScanListConstants.iconContainerSize,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: FilterTheme.surfaceOpacity,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: ScanListConstants.emptyStateIconSize,
              color: theme.colorScheme.primary.withValues(
                alpha: FilterTheme.textSecondaryOpacity,
              ),
            ),
          ),
          AppSpacing.verticalSpaceLG,
          Text(
            l10n.noScannedItems,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkText
                  : theme.colorScheme.onBackground.withValues(
                      alpha: FilterTheme.textSecondaryOpacity,
                    ),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            l10n.tapScanButtonToStart,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : theme.colorScheme.onBackground.withValues(
                      alpha: FilterTheme.textTertiaryOpacity,
                    ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
