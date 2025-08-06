// Path: frontend/lib/features/scan/presentation/bloc/scan_event.dart
import 'package:equatable/equatable.dart';
import 'package:frontend/features/scan/domain/entities/scanned_item_entity.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class StartScan extends ScanEvent {
  const StartScan();
}

class ClearScanResults extends ScanEvent {
  const ClearScanResults();
}

class RefreshScanResults extends ScanEvent {
  const RefreshScanResults();
}

//  event ใหม่สำหรับเลือก location
class LocationSelected extends ScanEvent {
  final String selectedLocation;

  const LocationSelected({required this.selectedLocation});

  @override
  List<Object?> get props => [selectedLocation];
}

class UpdateAssetStatus extends ScanEvent {
  final String assetNo;
  final String updatedBy;

  const UpdateAssetStatus({required this.assetNo, required this.updatedBy});

  @override
  List<Object?> get props => [assetNo, updatedBy];
}

class MarkAssetChecked extends ScanEvent {
  final String assetNo;

  const MarkAssetChecked({required this.assetNo});

  @override
  List<Object?> get props => [assetNo];
}

class LogAssetScanned extends ScanEvent {
  final String assetNo;
  final String scannedBy;

  const LogAssetScanned({required this.assetNo, required this.scannedBy});

  @override
  List<Object?> get props => [assetNo, scannedBy];
}

class AssetCreatedFromUnknown extends ScanEvent {
  final ScannedItemEntity createdAsset;
  final String originalEpcCode; // Add the original EPC code

  const AssetCreatedFromUnknown({
    required this.createdAsset,
    required this.originalEpcCode,
  });

  @override
  List<Object?> get props => [createdAsset, originalEpcCode];
}

class FilterChanged extends ScanEvent {
  final String filter;

  const FilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

// LocationFilterChanged event
class LocationFilterChanged extends ScanEvent {
  final String location;

  const LocationFilterChanged({required this.location});

  @override
  List<Object?> get props => [location];
}

class LoadExpectedCounts extends ScanEvent {
  final List<String> locationCodes;

  const LoadExpectedCounts({required this.locationCodes});

  @override
  List<Object?> get props => [locationCodes];
}

class LoadAssetImages extends ScanEvent {
  final String assetNo;

  const LoadAssetImages({required this.assetNo});

  @override
  List<Object?> get props => [assetNo];
}
