// Path: frontend/lib/features/scan/presentation/widgets/scan_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import 'asset_card.dart';

class ScanListView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    print('ScanListView: Building with ${scannedItems.length} items');
    print('ScanListView: isLoading = $isLoading');

    if (isLoading) {
      print('ScanListView: Showing loading indicator');
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (scannedItems.isEmpty) {
      print('ScanListView: Showing empty state');
      return _buildEmptyState(theme);
    }

    print('ScanListView: Showing list with ${scannedItems.length} items');

    return BlocBuilder<ScanBloc, ScanState>(
      builder: (context, state) {
        final filteredItems = state is ScanSuccess
            ? state.filteredItems
            : scannedItems;
        final selectedFilter = state is ScanSuccess
            ? state.selectedFilter
            : 'All';

        return RefreshIndicator(
          onRefresh: () async {
            print('ScanListView: Pull to refresh triggered');
            onRefresh?.call();
          },
          color: theme.colorScheme.primary,
          child: Column(
            children: [
              // Header with filters
              _buildHeader(theme, scannedItems, selectedFilter, context),

              // Filtered List
              Expanded(
                child: filteredItems.isEmpty
                    ? _buildEmptyFilterState(theme, selectedFilter)
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

  Widget _buildHeader(
    ThemeData theme,
    List<ScannedItemEntity> allItems,
    String selectedFilter,
    BuildContext context,
  ) {
    final totalItems = allItems.length;
    final activeItems = allItems
        .where((item) => item.status.toUpperCase() == 'A')
        .length;
    final checkedItems = allItems
        .where((item) => item.status.toUpperCase() == 'C')
        .length;
    final inactiveItems = allItems
        .where((item) => item.status.toUpperCase() == 'I')
        .length;
    final unknownItems = allItems
        .where((item) => item.isUnknown == true)
        .length;

    print(
      'ScanListView: Header stats - Total: $totalItems, Active: $activeItems, Checked: $checkedItems, Inactive: $inactiveItems, Unknown: $unknownItems',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'RFID Scan Results ($totalItems)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                theme,
                'All',
                totalItems,
                selectedFilter,
                context,
              ),
              if (activeItems > 0)
                _buildFilterChip(
                  theme,
                  'Active',
                  activeItems,
                  selectedFilter,
                  context,
                ),
              if (checkedItems > 0)
                _buildFilterChip(
                  theme,
                  'Checked',
                  checkedItems,
                  selectedFilter,
                  context,
                ),
              if (inactiveItems > 0)
                _buildFilterChip(
                  theme,
                  'Inactive',
                  inactiveItems,
                  selectedFilter,
                  context,
                ),
              if (unknownItems > 0)
                _buildFilterChip(
                  theme,
                  'Unknown',
                  unknownItems,
                  selectedFilter,
                  context,
                ),
            ],
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

  Color _getFilterColor(String label, ThemeData theme) {
    switch (label.toLowerCase()) {
      case 'all':
        return AppColors.chartGreen;
      case 'active':
        return theme.colorScheme.primary; // ใช้ AppColors
      case 'checked':
        return Colors.deepPurple; // ใช้ AppColors
      case 'inactive':
        return AppColors.getStatusColor('I'); // ใช้ AppColors
      case 'unknown':
        return AppColors.error; // ใช้ AppColors
      default:
        return theme.colorScheme.primary;
    }
  }

  Widget _buildEmptyFilterState(ThemeData theme, String filter) {
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
              Icons.filter_list_off,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No $filter items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Try selecting a different filter or scan again',
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
