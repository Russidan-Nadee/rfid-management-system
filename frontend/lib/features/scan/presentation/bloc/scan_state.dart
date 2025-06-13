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

  const ScanSuccess({required this.scannedItems, this.selectedFilter = 'All'});

  @override
  List<Object?> get props => [scannedItems, selectedFilter];

  @override
  String toString() {
    return 'ScanSuccess(items: ${scannedItems.length}, filter: $selectedFilter)';
  }

  // เพิ่ม helper method สำหรับ filter
  List<ScannedItemEntity> get filteredItems {
    if (selectedFilter == 'All') return scannedItems;

    switch (selectedFilter.toLowerCase()) {
      case 'active':
        return scannedItems
            .where((item) => item.status.toUpperCase() == 'A')
            .toList();
      case 'checked':
        return scannedItems
            .where((item) => item.status.toUpperCase() == 'C')
            .toList();
      case 'inactive':
        return scannedItems
            .where((item) => item.status.toUpperCase() == 'I')
            .toList();
      case 'unknown':
        return scannedItems.where((item) => item.isUnknown == true).toList();
      default:
        return scannedItems;
    }
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
