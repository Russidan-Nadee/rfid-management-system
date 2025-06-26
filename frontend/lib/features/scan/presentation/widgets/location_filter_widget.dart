// Path: frontend/lib/features/scan/presentation/widgets/location_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';

class LocationFilterWidget extends StatelessWidget {
  final List<String> availableLocations;
  final String selectedLocation;

  const LocationFilterWidget({
    super.key,
    required this.availableLocations,
    required this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ],
          ),

          const SizedBox(height: 8),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableLocations.map((location) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildLocationChip(theme, location),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(ThemeData theme, String location) {
    final isSelected = selectedLocation == location;
    final isAllLocations = location == 'All Locations';

    return GestureDetector(
      onTap: () => _onLocationTap(location),
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

  String _getDisplayText(String location) {
    // ถ้าชื่อยาวเกินไป ให้ตัดให้สั้น
    if (location.length > 20) {
      return '${location.substring(0, 17)}...';
    }
    return location;
  }

  void _onLocationTap(String location) {
    // Find the BuildContext from the widget tree
    final context = _findContext();
    if (context != null) {
      context.read<ScanBloc>().add(LocationFilterChanged(location: location));
    }
  }

  BuildContext? _findContext() {
    // This is a helper method to get context
    // In practice, you might want to pass context as parameter
    // or use a different approach like Provider or GetIt
    return null;
  }
}

// Extension to add context parameter
extension LocationFilterWidgetExtension on LocationFilterWidget {
  Widget buildWithContext(BuildContext context) {
    return _LocationFilterWidgetWithContext(
      availableLocations: availableLocations,
      selectedLocation: selectedLocation,
    );
  }
}

class _LocationFilterWidgetWithContext extends StatelessWidget {
  final List<String> availableLocations;
  final String selectedLocation;

  const _LocationFilterWidgetWithContext({
    required this.availableLocations,
    required this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ],
          ),

          const SizedBox(height: 8),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableLocations.map((location) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildLocationChip(context, theme, location),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(
    BuildContext context,
    ThemeData theme,
    String location,
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

  String _getDisplayText(String location) {
    // ถ้าชื่อยาวเกินไป ให้ตัดให้สั้น
    if (location.length > 20) {
      return '${location.substring(0, 17)}...';
    }
    return location;
  }
}
