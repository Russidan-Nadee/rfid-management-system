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

// แก้ไข AssetCreatedFromUnknown event ให้ครบ
class AssetCreatedFromUnknown extends ScanEvent {
  final ScannedItemEntity createdAsset;

  const AssetCreatedFromUnknown({required this.createdAsset});

  @override
  List<Object?> get props => [createdAsset];
}

// เพิ่ม FilterChanged event
class FilterChanged extends ScanEvent {
  final String filter;

  const FilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}
