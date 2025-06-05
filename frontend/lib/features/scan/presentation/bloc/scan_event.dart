// Path: frontend/lib/features/scan/presentation/bloc/scan_event.dart
import 'package:equatable/equatable.dart';

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
