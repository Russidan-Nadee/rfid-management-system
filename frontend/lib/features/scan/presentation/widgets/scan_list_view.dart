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
      case 'awaiting':
        return colorScheme.primary;
      case 'checked':
        return AppColors.assetActive;
      case 'inactive':
        return colorScheme.error;
      case 'unknown':
        return AppColors.error.withValues(alpha: 0.7); // เปลี่ยนเป็นสีแดง
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

  // ⭐ เพิ่ม method สำหรับ trigger expected counts loading
  void _triggerLoadExpectedCounts(ScanSuccess state) {
    if (state.expectedCounts.isEmpty) {
      // ดึง unique location codes (ไม่ใช่ names)
      final locationCodes = state.scannedItems
          .where(
            (item) =>
                item.locationCode != null && item.locationCode!.isNotEmpty,
          )
          .map((item) => item.locationCode!)
          .toSet()
          .toList();

      if (locationCodes.isNotEmpty) {
        print(
          'ScanListView: Triggering load expected counts for: $locationCodes',
        );
        context.read<ScanBloc>().add(
          LoadExpectedCounts(locationCodes: locationCodes),
        );
      }
    }
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

        // ⭐ Trigger load expected counts เมื่อ state เป็น ScanSuccess
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _triggerLoadExpectedCounts(state);
        });

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
              // Location Filter ⭐ Enhanced
              _buildLocationFilter(
                theme,
                availableLocations,
                selectedLocation,
                state, // ส่ง state เพื่อดู expectedCounts
                context,
              ),

              // Header with status filters
              _buildStatusFilter(theme, statusCounts, selectedFilter, context),

              // Filtered List with responsive 3-column on large screen
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (filteredItems.isEmpty) {
                      return _buildEmptyFilterState(
                        theme,
                        selectedFilter,
                        selectedLocation,
                      );
                    }

                    // Responsive columns based on screen width
                    if (constraints.maxWidth >= 1200) {
                      // Very large screen: 3 columns
                      List<Widget> rows = [];
                      for (var i = 0; i < filteredItems.length; i += 3) {
                        final firstCard = AssetCard(item: filteredItems[i]);
                        final secondCard = (i + 1 < filteredItems.length)
                            ? AssetCard(item: filteredItems[i + 1])
                            : Expanded(child: Container());
                        final thirdCard = (i + 2 < filteredItems.length)
                            ? AssetCard(item: filteredItems[i + 2])
                            : Expanded(child: Container());

                        rows.add(
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: firstCard),
                              Expanded(child: secondCard),
                              Expanded(child: thirdCard),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(children: rows),
                      );
                    } else if (constraints.maxWidth >= 800) {
                      // Large screen: 2 columns
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
                    } else {
                      // Mobile: 1 column
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

  // ⭐ Enhanced Location Filter with Comparison Data
  Widget _buildLocationFilter(
    ThemeData theme,
    List<String> availableLocations,
    String selectedLocation,
    ScanSuccess state, // เพิ่ม parameter เพื่อดู expectedCounts
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
                            ? AppColors
                                  .darkText // Dark Mode: สีขาว
                            : theme
                                  .colorScheme
                                  .primary, // Light Mode: สีน้ำเงิน
                        size: 18,
                      ),
                      AppSpacing.horizontalSpaceSM,
                      Text(
                        'Filter by Location',
                        style: AppTextStyles.filterLabel.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors
                                    .darkText // Dark Mode: สีขาว
                              : theme
                                    .colorScheme
                                    .primary, // Light Mode: สีน้ำเงิน
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors
                                .darkText // Dark Mode: สีขาว
                          : theme.colorScheme.onSurface, // Light Mode: สีเข้ม
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search locations...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors
                                  .darkTextSecondary // Dark Mode: สีเทาอ่อนกว่า
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ), // Light Mode: สีเทา
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors
                                  .darkText // Dark Mode: สีขาว
                            : theme
                                  .colorScheme
                                  .primary, // Light Mode: สีน้ำเงิน
                        size: 18,
                      ),
                      suffixIcon: _locationSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors
                                          .darkText // Dark Mode: สีขาว
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ), // Light Mode: สีเทา
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.2,
                                ) // Dark Mode: เทาอ่อน ลด 30%
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ), // Light Mode: เดิม
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.2,
                                ) // Dark Mode: เทาอ่อน ลด 30%
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ), // Light Mode: เดิม
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
                          ? AppColors
                                .darkText // Dark Mode: สีขาว
                          : theme.colorScheme.primary, // Light Mode: สีน้ำเงิน
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
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors
                                          .darkText // Dark Mode: สีขาว
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ), // Light Mode: สีเทา
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
                                    state, // ⭐ ส่ง state เพื่อดู comparison data
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

  // ⭐ Enhanced Location Chip with Comparison Data
  Widget _buildLocationChip(
    BuildContext context,
    ThemeData theme,
    String location,
    String selectedLocation,
    ScanSuccess state, // เพิ่ม parameter
  ) {
    final isSelected = selectedLocation == location;
    final isAllLocations = location == 'All Locations';
    final isCurrentLocation = state.currentLocation == location;

    // Get comparison data
    int scannedCount = 0;
    int expectedCount = 0;

    if (!isAllLocations) {
      // นับ scanned items ใน location นี้
      scannedCount = state.scannedItems
          .where((item) => item.locationName == location)
          .length;

      // หา expected count จาก state.expectedCounts
      // ต้องหา locationCode ที่ตรงกับ locationName
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
      // All Locations - standard color
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
      // Current location - blue
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
      // Wrong location (has scanned items) - orange
      chipColor = isSelected
          ? AppColors.warning
          : AppColors.warning.withValues(alpha: FilterTheme.surfaceOpacity);
      textColor = isSelected ? Colors.white : AppColors.warning;
      borderColor = AppColors.warning;
    } else {
      // Empty location - muted
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
                // Location name
                Text(
                  _getDisplayText(location),
                  style: AppTextStyles.filterLabel.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                // ⭐ Count display
                if (!isAllLocations && (scannedCount > 0 || expectedCount > 0))
                  Text(
                    isCurrentLocation && expectedCount > 0
                        ? '($scannedCount/$expectedCount)' // Current location: show scanned/expected
                        : '($scannedCount)', // Other locations: show scanned only
                    style: AppTextStyles.caption.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            // Status indicator
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
              : color.withValues(alpha: FilterTheme.surfaceOpacity),
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
                              ) // Dark Mode: เทาอ่อน ลด 30%
                            : color)), // Light Mode: สีตาม status เดิม
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
            isLocationFilter ? 'No items in $location' : 'No $filter items',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors
                        .darkText // Dark Mode: สีขาว
                  : theme.colorScheme.onBackground.withValues(
                      alpha: FilterTheme.textSecondaryOpacity,
                    ), // Light Mode: สีเทา
            ),
          ),

          AppSpacing.verticalSpaceSM,

          Text(
            isLocationFilter
                ? 'Try selecting a different location or scan again'
                : 'Try selecting a different filter or scan again',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors
                        .darkTextSecondary // Dark Mode: สีเทาอ่อน
                  : theme.colorScheme.onBackground.withValues(
                      alpha: FilterTheme.textTertiaryOpacity,
                    ), // Light Mode: สีเทาอ่อน
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
            'No scanned items',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors
                        .darkText // Dark Mode: สีขาว
                  : theme.colorScheme.onBackground.withValues(
                      alpha: FilterTheme.textSecondaryOpacity,
                    ), // Light Mode: สีเทา
            ),
          ),

          AppSpacing.verticalSpaceSM,

          Text(
            'Tap the scan button to start scanning RFID tags',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors
                        .darkTextSecondary // Dark Mode: สีเทาอ่อน
                  : theme.colorScheme.onBackground.withValues(
                      alpha: FilterTheme.textTertiaryOpacity,
                    ), // Light Mode: สีเทาอ่อน
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
