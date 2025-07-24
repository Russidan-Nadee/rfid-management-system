// Path: frontend/lib/features/scan/presentation/widgets/location_filter_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

class LocationFilterWidget extends StatefulWidget {
  final List<String> availableLocations;
  final String selectedLocation;
  final Function(String) onLocationChanged;

  const LocationFilterWidget({
    super.key,
    required this.availableLocations,
    required this.selectedLocation,
    required this.onLocationChanged,
  });

  @override
  State<LocationFilterWidget> createState() => _LocationFilterWidgetState();
}

class _LocationFilterWidgetState extends State<LocationFilterWidget> {
  bool _isExpanded = true;
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredLocations = _getFilteredLocations();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
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
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
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
                        'Filter by Location',
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
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search locations...',
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
                      suffixIcon: _searchQuery.isNotEmpty
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
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
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
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
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
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: filteredLocations.isEmpty
                        ? _buildNoResultsMessage()
                        : _buildLocationChips(filteredLocations),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  List<String> _getFilteredLocations() {
    return widget.availableLocations.where((location) {
      return location.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildNoResultsMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'No locations found matching "$_searchQuery"',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkText
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLocationChips(List<String> locations) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: locations.map((location) {
          return Padding(
            padding: AppSpacing.only(right: AppSpacing.sm),
            child: _buildLocationChip(location),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationChip(String location) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedLocation == location;
    final isAllLocations = location == 'All Locations';

    return GestureDetector(
      onTap: () => widget.onLocationChanged(location),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: AppBorders.lg,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.2)
                      : theme.colorScheme.primary),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAllLocations ? Icons.public : Icons.location_on,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkText
                        : theme.colorScheme.primary),
            ),
            AppSpacing.horizontalSpaceXS,
            Text(
              _getDisplayText(location),
              style: AppTextStyles.filterLabel.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.primary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayText(String location) {
    const maxLength = 20.0;
    const trimLength = 17.0;

    if (location.length > maxLength) {
      return '${location.substring(0, trimLength.toInt())}...';
    }
    return location;
  }
}
