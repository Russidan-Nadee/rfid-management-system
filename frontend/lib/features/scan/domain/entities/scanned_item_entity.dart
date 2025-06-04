// Path: frontend/lib/features/scan/domain/entities/scanned_item_entity.dart
import 'package:equatable/equatable.dart';

class ScannedItemEntity extends Equatable {
  final String assetNo;
  final String? description;
  final String? serialNo;
  final String? inventoryNo;
  final double? quantity;
  final String? unitName;
  final String? createdByName;
  final DateTime? createdAt;
  final String status;
  final bool isUnknown;

  const ScannedItemEntity({
    required this.assetNo,
    this.description,
    this.serialNo,
    this.inventoryNo,
    this.quantity,
    this.unitName,
    this.createdByName,
    this.createdAt,
    required this.status,
    this.isUnknown = false,
  });

  factory ScannedItemEntity.unknown(String assetNo) {
    return ScannedItemEntity(
      assetNo: assetNo,
      description: 'Unknown Item',
      status: 'Unknown',
      isUnknown: true,
    );
  }

  String get displayName =>
      isUnknown ? 'Unknown Item' : (description ?? assetNo);

  @override
  List<Object?> get props => [
    assetNo,
    description,
    serialNo,
    inventoryNo,
    quantity,
    unitName,
    createdByName,
    createdAt,
    status,
    isUnknown,
  ];
}
