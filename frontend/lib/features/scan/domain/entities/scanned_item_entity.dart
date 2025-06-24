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
  final String? plantCode;
  final String? locationCode;
  final String? locationName;
  final String? deptCode;
  final String? deptDescription;
  final String? plantDescription;
  final DateTime? lastScanAt;
  final String? lastScannedBy;
  final int? totalScans;

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
    this.plantCode,
    this.locationCode,
    this.locationName,
    this.deptCode,
    this.deptDescription,
    this.plantDescription,
    this.lastScanAt,
    this.lastScannedBy,
    this.totalScans,
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
    deptCode,
    deptDescription,
    plantDescription,
    lastScanAt,
    lastScannedBy,
    totalScans,
  ];
}
