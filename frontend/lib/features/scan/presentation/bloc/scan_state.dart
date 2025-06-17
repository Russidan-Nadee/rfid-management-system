// Path: frontend/lib/features/scan/presentation/bloc/scan_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/scanned_item_entity.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {
  const ScanInitial();
}

class ScanLoading extends ScanState {
  const ScanLoading();
}

class ScanSuccess extends ScanState {
  final List<ScannedItemEntity> scannedItems;
  final String selectedFilter;
  final String selectedLocation;

  const ScanSuccess({
    required this.scannedItems,
    this.selectedFilter = 'All',
    this.selectedLocation = 'All Locations',
  });

  @override
  List<Object?> get props => [scannedItems, selectedFilter, selectedLocation];

  @override
  String toString() {
    return 'ScanSuccess(items: ${scannedItems.length}, filter: $selectedFilter, location: $selectedLocation)';
  }

  // Get unique location names from scanned items
  List<String> get availableLocations {
    final locationNames = scannedItems
        .where((item) => item.locationName != null)
        .map((item) => item.locationName!)
        .toSet()
        .toList();

    locationNames.sort();
    return ['All Locations', ...locationNames];
  }

  // Get filtered items by location first, then by status
  List<ScannedItemEntity> get filteredItems {
    // First filter by location
    List<ScannedItemEntity> locationFiltered;
    if (selectedLocation == 'All Locations') {
      locationFiltered = scannedItems;
    } else {
      locationFiltered = scannedItems
          .where((item) => item.locationName == selectedLocation)
          .toList();
    }

    // Then filter by status
    if (selectedFilter == 'All') return locationFiltered;

    switch (selectedFilter.toLowerCase()) {
      case 'active':
        return locationFiltered
            .where((item) => item.status.toUpperCase() == 'A')
            .toList();
      case 'checked':
        return locationFiltered
            .where((item) => item.status.toUpperCase() == 'C')
            .toList();
      case 'inactive':
        return locationFiltered
            .where((item) => item.status.toUpperCase() == 'I')
            .toList();
      case 'unknown':
        return locationFiltered
            .where((item) => item.isUnknown == true)
            .toList();
      default:
        return locationFiltered;
    }
  }

  // Get status counts for current location
  Map<String, int> get statusCounts {
    final locationFiltered = selectedLocation == 'All Locations'
        ? scannedItems
        : scannedItems
              .where((item) => item.locationName == selectedLocation)
              .toList();

    return {
      'All': locationFiltered.length,
      'Active': locationFiltered
          .where((item) => item.status.toUpperCase() == 'A')
          .length,
      'Checked': locationFiltered
          .where((item) => item.status.toUpperCase() == 'C')
          .length,
      'Inactive': locationFiltered
          .where((item) => item.status.toUpperCase() == 'I')
          .length,
      'Unknown': locationFiltered
          .where((item) => item.isUnknown == true)
          .length,
    };
  }

  // Copy with method for state updates
  ScanSuccess copyWith({
    List<ScannedItemEntity>? scannedItems,
    String? selectedFilter,
    String? selectedLocation,
  }) {
    return ScanSuccess(
      scannedItems: scannedItems ?? this.scannedItems,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}

// เพิ่ม state ใหม่สำหรับ filter changes (ไม่ใช่ scan ใหม่)
class ScanSuccessFiltered extends ScanSuccess {
  const ScanSuccessFiltered({
    required super.scannedItems,
    super.selectedFilter = 'All',
    super.selectedLocation = 'All Locations',
  });

  @override
  String toString() {
    return 'ScanSuccessFiltered(items: ${scannedItems.length}, filter: $selectedFilter, location: $selectedLocation)';
  }
}

class ScanError extends ScanState {
  final String message;

  const ScanError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'ScanError(message: $message)';
  }
}

class AssetStatusUpdating extends ScanState {
  final String assetNo;

  const AssetStatusUpdating({required this.assetNo});

  @override
  List<Object?> get props => [assetNo];
}

class AssetStatusUpdated extends ScanState {
  final ScannedItemEntity updatedAsset;

  const AssetStatusUpdated({required this.updatedAsset});

  @override
  List<Object?> get props => [updatedAsset];
}

class AssetStatusUpdateError extends ScanState {
  final String message;

  const AssetStatusUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
