// Path: frontend/lib/features/scan/presentation/widgets/scan_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/app/theme/app_spacing.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import 'package:frontend/app/theme/app_typography.dart';
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
      case 'Awaiting':
        return colorScheme.primary;
      case 'checked':
        return AppColors.assetActive;
      case 'inactive':
        return colorScheme.error;
      case 'unknown':
        return AppColors.warning; // เก็บไว้เพราะไม่มีใน Material theme
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    print('ScanListView: Building with ${widget.scannedItems.length} items');
    print('ScanListView: isLoading = ${widget.isLoading}');

    if (widget.isLoading) {
      print('ScanListView: Showing loading indicator');
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (widget.scannedItems.isEmpty) {
      print('ScanListView: Showing empty state');
      return _buildEmptyState(theme);
    }

    print(
      'ScanListView: Showing list with ${widget.scannedItems.length} items',
    );

    return BlocBuilder<ScanBloc, ScanState>(
      builder: (context, state) {
        if (state is! ScanSuccess) {
          return _buildEmptyState(theme);
        }

        final filteredItems = state.filteredItems;
        final selectedFilter = state.selectedFilter;
        final selectedLocation = state.selectedLocation;
        final availableLocations = state.availableLocations;
        final statusCounts = state.statusCounts;

        return RefreshIndicator(
          onRefresh: () async {
            print('ScanListView: Pull to refresh triggered');
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
                context,
              ),

              // Header with status filters
              _buildStatusFilter(theme, statusCounts, selectedFilter, context),

              // Filtered List with responsive 2-column on large screen
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLargeScreen = constraints.maxWidth >= 800;

                    if (filteredItems.isEmpty) {
                      return _buildEmptyFilterState(
                        theme,
                        selectedFilter,
                        selectedLocation,
                      );
                    }

                    if (!isLargeScreen) {
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          print(
                            'ScanListView: Building card $index for asset ${filteredItems[index].assetNo}',
                          );
                          return AssetCard(item: filteredItems[index]);
                        },
                      );
                    } else {
                      // Large screen: 2 columns via Rows inside Column
                      List<Widget> rows = [];
                      for (var i = 0; i < filteredItems.length; i += 2) {
                        final firstCard = AssetCard(item: filteredItems[i]);
                        final secondCard = (i + 1 < filteredItems.length)
                            ? AssetCard(item: filteredItems[i + 1])
                            : Expanded(child: Container());

                        rows.add(
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: firstCard),

                              Expanded(child: secondCard),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(children: rows),
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

  Widget _buildLocationFilter(
    ThemeData theme,
    List<String> availableLocations,
    String selectedLocation,
    BuildContext context,
  ) {
    // กรอง locations ตาม search query
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
            color: theme.colorScheme.outline.withOpacity(
              FilterTheme.borderOpacity,
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
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      AppSpacing.horizontalSpaceSM,
                      Text(
                        'Filter by Location',
                        style: AppTextStyles.filterLabel.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: TextField(
                    controller: _locationSearchController,
                    onChanged: (value) {
                      setState(() {
                        _locationSearchQuery = value;
                      });
                    },
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search locations...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      suffixIcon: _locationSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                size: 18,
                              ),
                              onPressed: () {
                                _locationSearchController.clear();
                                setState(() {
                                  _locationSearchQuery = '';
                                });
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
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
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
                      color: theme.colorScheme.primary,
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
                              'No locations found matching "${_locationSearchQuery}"',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
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

  Widget _buildStatusFilter(
    ThemeData theme,
    Map<String, int> statusCounts,
    String selectedFilter,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(
              FilterTheme.borderOpacity,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
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
                  Icon(Icons.filter_list, color: theme.colorScheme.primary),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    'Filter by Status',
                    style: AppTextStyles.filterLabel.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isStatusFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
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
                          'All',
                          statusCounts['All'] ?? 0,
                          selectedFilter,
                          context,
                        ),
                        if ((statusCounts['Active'] ?? 0) > 0)
                          _buildFilterChip(
                            theme,
                            'Awaiting',
                            statusCounts['Active'] ?? 0,
                            selectedFilter,
                            context,
                          ),
                        if ((statusCounts['Checked'] ?? 0) > 0)
                          _buildFilterChip(
                            theme,
                            'Checked',
                            statusCounts['Checked'] ?? 0,
                            selectedFilter,
                            context,
                          ),
                        if ((statusCounts['Inactive'] ?? 0) > 0)
                          _buildFilterChip(
                            theme,
                            'Inactive',
                            statusCounts['Inactive'] ?? 0,
                            selectedFilter,
                            context,
                          ),
                        if ((statusCounts['Unknown'] ?? 0) > 0)
                          _buildFilterChip(
                            theme,
                            'Unknown',
                            statusCounts['Unknown'] ?? 0,
                            selectedFilter,
                            context,
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

  Widget _buildLocationChip(
    BuildContext context,
    ThemeData theme,
    String location,
    String selectedLocation,
  ) {
    final isSelected = selectedLocation == location;
    final isAllLocations = location == 'All Locations';

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
          color: isSelected
              ? (isAllLocations
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary)
              : (isAllLocations
                    ? theme.colorScheme.primary.withOpacity(
                        FilterTheme.surfaceOpacity,
                      )
                    : theme.colorScheme.primary.withOpacity(
                        FilterTheme.surfaceOpacity,
                      )),
          borderRadius: AppBorders.lg,
          border: Border.all(
            color: isSelected
                ? (isAllLocations
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary)
                : (isAllLocations
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary),
            width: isSelected
                ? ScanListConstants.borderWidthSelected.toDouble()
                : ScanListConstants.borderWidthNormal.toDouble(),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAllLocations) ...[
              Icon(
                Icons.public,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
              ),
              AppSpacing.horizontalSpaceXS,
            ] else ...[
              Icon(
                Icons.location_on,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
              ),
              AppSpacing.horizontalSpaceXS,
            ],
            Text(
              _getDisplayText(location),
              style: AppTextStyles.filterLabel.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    String label,
    int count,
    String selectedFilter,
    BuildContext context,
  ) {
    final isSelected = selectedFilter == label;
    final color = theme.getFilterColor(label);

    return GestureDetector(
      onTap: () {
        context.read<ScanBloc>().add(FilterChanged(filter: label));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : color.withOpacity(FilterTheme.surfaceOpacity),
          borderRadius: AppBorders.lg,
          border: Border.all(
            color: color,
            width: isSelected
                ? ScanListConstants.borderWidthSelected.toDouble()
                : ScanListConstants.borderWidthNormal.toDouble(),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: AppTextStyles.filterLabel.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getDisplayText(String location) {
    // ถ้าชื่อยาวเกินไป ให้ตัดให้สั้น
    if (location.length > ScanListConstants.maxLocationDisplayLength) {
      return '${location.substring(0, ScanListConstants.trimLocationLength.toInt())}...';
    }
    return location;
  }

  Widget _buildEmptyFilterState(
    ThemeData theme,
    String filter,
    String location,
  ) {
    final isLocationFilter = location != 'All Locations';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ScanListConstants.iconContainerSize,
            height: ScanListConstants.iconContainerSize,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(
                FilterTheme.surfaceOpacity,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocationFilter ? Icons.location_off : Icons.filter_list_off,
              size: ScanListConstants.emptyStateIconSize,
              color: theme.colorScheme.primary.withOpacity(
                FilterTheme.textSecondaryOpacity,
              ),
            ),
          ),

          AppSpacing.verticalSpaceLG,

          Text(
            isLocationFilter ? 'No items in $location' : 'No $filter items',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(
                FilterTheme.textSecondaryOpacity,
              ),
            ),
          ),

          AppSpacing.verticalSpaceSM,

          Text(
            isLocationFilter
                ? 'Try selecting a different location or scan again'
                : 'Try selecting a different filter or scan again',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(
                FilterTheme.textTertiaryOpacity,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ScanListConstants.iconContainerSize,
            height: ScanListConstants.iconContainerSize,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(
                FilterTheme.surfaceOpacity,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: ScanListConstants.emptyStateIconSize,
              color: theme.colorScheme.primary.withOpacity(
                FilterTheme.textSecondaryOpacity,
              ),
            ),
          ),

          AppSpacing.verticalSpaceLG,

          Text(
            'No scanned items',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(
                FilterTheme.textSecondaryOpacity,
              ),
            ),
          ),

          AppSpacing.verticalSpaceSM,

          Text(
            'Tap the scan button to start scanning RFID tags',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(
                FilterTheme.textTertiaryOpacity,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
