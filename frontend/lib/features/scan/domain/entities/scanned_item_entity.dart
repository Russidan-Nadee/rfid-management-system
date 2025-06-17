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
  // เพิ่ม location fields (optional เพื่อ backward compatibility)
  final String? plantCode;
  final String? locationCode;
  final String? locationName;

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
    // Location fields เป็น optional
    this.plantCode,
    this.locationCode,
    this.locationName,
  });

  factory ScannedItemEntity.unknown(String assetNo, {String? locationName}) {
    return ScannedItemEntity(
      assetNo: assetNo,
      description: 'Unknown Item',
      status: 'Unknown',
      isUnknown: true,
      locationName: locationName,
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
    plantCode,
    locationCode,
    locationName,
  ];
}
