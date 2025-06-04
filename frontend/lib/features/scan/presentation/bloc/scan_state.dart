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

  const ScanSuccess({required this.scannedItems});

  @override
  List<Object?> get props => [scannedItems];

  @override
  String toString() {
    return 'ScanSuccess(items: ${scannedItems.length})';
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
