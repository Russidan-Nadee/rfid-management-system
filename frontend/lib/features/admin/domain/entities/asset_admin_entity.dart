import 'package:equatable/equatable.dart';

class AssetAdminEntity extends Equatable {
  final String assetNo;
  final String epcCode;
  final String description;
  final String? serialNo;
  final String? inventoryNo;
  final String plantCode;
  final String locationCode;
  final String unitCode;
  final String? deptCode;
  final String? categoryCode;
  final String? brandCode;
  final double? quantity;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? plantDescription;
  final String? locationDescription;
  final String? deptDescription;
  final String? unitName;
  final String? brandName;
  final String? categoryName;
  final String? createdByName;
  final DateTime? lastScanAt;
  final String? lastScannedBy;
  final int? totalScans;

  const AssetAdminEntity({
    required this.assetNo,
    required this.epcCode,
    required this.description,
    this.serialNo,
    this.inventoryNo,
    required this.plantCode,
    required this.locationCode,
    required this.unitCode,
    this.deptCode,
    this.categoryCode,
    this.brandCode,
    this.quantity,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.plantDescription,
    this.locationDescription,
    this.deptDescription,
    this.unitName,
    this.brandName,
    this.categoryName,
    this.createdByName,
    this.lastScanAt,
    this.lastScannedBy,
    this.totalScans,
  });

  AssetAdminEntity copyWith({
    String? assetNo,
    String? epcCode,
    String? description,
    String? serialNo,
    String? inventoryNo,
    String? plantCode,
    String? locationCode,
    String? unitCode,
    String? deptCode,
    String? categoryCode,
    String? brandCode,
    double? quantity,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? plantDescription,
    String? locationDescription,
    String? deptDescription,
    String? unitName,
    String? brandName,
    String? categoryName,
    String? createdByName,
    DateTime? lastScanAt,
    String? lastScannedBy,
    int? totalScans,
  }) {
    return AssetAdminEntity(
      assetNo: assetNo ?? this.assetNo,
      epcCode: epcCode ?? this.epcCode,
      description: description ?? this.description,
      serialNo: serialNo ?? this.serialNo,
      inventoryNo: inventoryNo ?? this.inventoryNo,
      plantCode: plantCode ?? this.plantCode,
      locationCode: locationCode ?? this.locationCode,
      unitCode: unitCode ?? this.unitCode,
      deptCode: deptCode ?? this.deptCode,
      categoryCode: categoryCode ?? this.categoryCode,
      brandCode: brandCode ?? this.brandCode,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plantDescription: plantDescription ?? this.plantDescription,
      locationDescription: locationDescription ?? this.locationDescription,
      deptDescription: deptDescription ?? this.deptDescription,
      unitName: unitName ?? this.unitName,
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
      createdByName: createdByName ?? this.createdByName,
      lastScanAt: lastScanAt ?? this.lastScanAt,
      lastScannedBy: lastScannedBy ?? this.lastScannedBy,
      totalScans: totalScans ?? this.totalScans,
    );
  }

  @override
  List<Object?> get props => [
        assetNo,
        epcCode,
        description,
        serialNo,
        inventoryNo,
        plantCode,
        locationCode,
        unitCode,
        deptCode,
        categoryCode,
        brandCode,
        quantity,
        status,
        createdBy,
        createdAt,
        updatedAt,
        plantDescription,
        locationDescription,
        deptDescription,
        unitName,
        brandName,
        categoryName,
        createdByName,
        lastScanAt,
        lastScannedBy,
        totalScans,
      ];
}

class UpdateAssetRequest extends Equatable {
  final String assetNo;
  final String? epcCode;
  final String? description;
  final String? serialNo;
  final String? inventoryNo;
  final String? plantCode;
  final String? locationCode;
  final String? unitCode;
  final String? deptCode;
  final String? categoryCode;
  final String? brandCode;
  final double? quantity;
  final String? status;

  const UpdateAssetRequest({
    required this.assetNo,
    this.epcCode,
    this.description,
    this.serialNo,
    this.inventoryNo,
    this.plantCode,
    this.locationCode,
    this.unitCode,
    this.deptCode,
    this.categoryCode,
    this.brandCode,
    this.quantity,
    this.status,
  });

  @override
  List<Object?> get props => [
        assetNo,
        epcCode,
        description,
        serialNo,
        inventoryNo,
        plantCode,
        locationCode,
        unitCode,
        deptCode,
        categoryCode,
        brandCode,
        quantity,
        status,
      ];
}