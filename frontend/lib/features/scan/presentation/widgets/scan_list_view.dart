// Path: frontend/lib/features/scan/presentation/widgets/scan_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import 'asset_card.dart';

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

              // Filtered List
              Expanded(
                child: filteredItems.isEmpty
                    ? _buildEmptyFilterState(
                        theme,
                        selectedFilter,
                        selectedLocation,
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          print(
                            'ScanListView: Building card $index for asset ${filteredItems[index].assetNo}',
                          );
                          return AssetCard(item: filteredItems[index]);
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
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(
              () => _isLocationFilterExpanded = !_isLocationFilterExpanded,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter by Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isLocationFilterExpanded ? 0.5 : 0,
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
            height: _isLocationFilterExpanded ? null : 0,
            child: _isLocationFilterExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: availableLocations.map((location) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
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
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                            'Active',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isAllLocations
                    ? AppColors.chartGreen
                    : theme.colorScheme.primary)
              : (isAllLocations
                    ? AppColors.chartGreen.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isAllLocations
                      ? AppColors.chartGreen
                      : theme.colorScheme.primary)
                : (isAllLocations
                      ? AppColors.chartGreen
                      : theme.colorScheme.primary),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAllLocations) ...[
              Icon(
                Icons.public,
                size: 16,
                color: isSelected ? Colors.white : AppColors.chartGreen,
              ),
              const SizedBox(width: 6),
            ] else ...[
              Icon(
                Icons.location_on,
                size: 16,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              _getDisplayText(location),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isAllLocations
                          ? AppColors.chartGreen
                          : theme.colorScheme.primary),
                fontSize: 14,
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
    final color = _getFilterColor(label, theme);

    return GestureDetector(
      onTap: () {
        context.read<ScanBloc>().add(FilterChanged(filter: label));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getDisplayText(String location) {
    // ถ้าชื่อยาวเกินไป ให้ตัดให้สั้น
    if (location.length > 20) {
      return '${location.substring(0, 17)}...';
    }
    return location;
  }

  Color _getFilterColor(String label, ThemeData theme) {
    switch (label.toLowerCase()) {
      case 'all':
        return AppColors.chartGreen;
      case 'active':
        return theme.colorScheme.primary;
      case 'checked':
        return Colors.deepPurple;
      case 'inactive':
        return AppColors.getStatusColor('I');
      case 'unknown':
        return AppColors.error;
      default:
        return theme.colorScheme.primary;
    }
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocationFilter ? Icons.location_off : Icons.filter_list_off,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            isLocationFilter ? 'No items in $location' : 'No $filter items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isLocationFilter
                ? 'Try selecting a different location or scan again'
                : 'Try selecting a different filter or scan again',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No scanned items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tap the scan button to start scanning RFID tags',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
