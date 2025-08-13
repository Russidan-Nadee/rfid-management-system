import '../../domain/entities/asset_admin_entity.dart';

class AssetAdminModel extends AssetAdminEntity {
  const AssetAdminModel({
    required super.assetNo,
    required super.epcCode,
    required super.description,
    super.serialNo,
    super.inventoryNo,
    required super.plantCode,
    required super.locationCode,
    required super.unitCode,
    super.deptCode,
    super.categoryCode,
    super.brandCode,
    super.quantity,
    required super.status,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.plantDescription,
    super.locationDescription,
    super.deptDescription,
    super.unitName,
    super.brandName,
    super.categoryName,
    super.createdByName,
    super.lastScanAt,
    super.lastScannedBy,
    super.totalScans,
  });

  factory AssetAdminModel.fromJson(Map<String, dynamic> json) {
    return AssetAdminModel(
      assetNo: json['asset_no'] ?? '',
      epcCode: json['epc_code'] ?? '',
      description: json['description'] ?? '',
      serialNo: json['serial_no'],
      inventoryNo: json['inventory_no'],
      plantCode: json['plant_code'] ?? '',
      locationCode: json['location_code'] ?? '',
      unitCode: json['unit_code'] ?? '',
      deptCode: json['dept_code'],
      categoryCode: json['category_code'],
      brandCode: json['brand_code'],
      quantity: json['quantity'] != null ? double.tryParse(json['quantity'].toString()) : null,
      status: json['status'] ?? 'A',
      createdBy: json['created_by'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      plantDescription: json['plant_description'],
      locationDescription: json['location_description'],
      deptDescription: json['dept_description'],
      unitName: json['unit_name'],
      brandName: json['brand_name'],
      categoryName: json['category_name'],
      createdByName: json['created_by_name'],
      lastScanAt: json['last_scan_at'] != null 
          ? DateTime.parse(json['last_scan_at'])
          : null,
      lastScannedBy: json['last_scanned_by'],
      totalScans: json['total_scans'] != null ? int.tryParse(json['total_scans'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_no': assetNo,
      'epc_code': epcCode,
      'description': description,
      'serial_no': serialNo,
      'inventory_no': inventoryNo,
      'plant_code': plantCode,
      'location_code': locationCode,
      'unit_code': unitCode,
      'dept_code': deptCode,
      'category_code': categoryCode,
      'brand_code': brandCode,
      'quantity': quantity,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'plant_description': plantDescription,
      'location_description': locationDescription,
      'dept_description': deptDescription,
      'unit_name': unitName,
      'brand_name': brandName,
      'category_name': categoryName,
      'created_by_name': createdByName,
      'last_scan_at': lastScanAt?.toIso8601String(),
      'last_scanned_by': lastScannedBy,
      'total_scans': totalScans,
    };
  }

  factory AssetAdminModel.fromEntity(AssetAdminEntity entity) {
    return AssetAdminModel(
      assetNo: entity.assetNo,
      epcCode: entity.epcCode,
      description: entity.description,
      serialNo: entity.serialNo,
      inventoryNo: entity.inventoryNo,
      plantCode: entity.plantCode,
      locationCode: entity.locationCode,
      unitCode: entity.unitCode,
      deptCode: entity.deptCode,
      categoryCode: entity.categoryCode,
      brandCode: entity.brandCode,
      quantity: entity.quantity,
      status: entity.status,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      plantDescription: entity.plantDescription,
      locationDescription: entity.locationDescription,
      deptDescription: entity.deptDescription,
      unitName: entity.unitName,
      brandName: entity.brandName,
      categoryName: entity.categoryName,
      createdByName: entity.createdByName,
      lastScanAt: entity.lastScanAt,
      lastScannedBy: entity.lastScannedBy,
      totalScans: entity.totalScans,
    );
  }
}

class UpdateAssetRequestModel {
  final UpdateAssetRequest request;

  const UpdateAssetRequestModel(this.request);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (request.epcCode != null) json['epc_code'] = request.epcCode;
    if (request.description != null) json['description'] = request.description;
    if (request.serialNo != null) json['serial_no'] = request.serialNo;
    if (request.inventoryNo != null) json['inventory_no'] = request.inventoryNo;
    if (request.plantCode != null) json['plant_code'] = request.plantCode;
    if (request.locationCode != null) json['location_code'] = request.locationCode;
    if (request.unitCode != null) json['unit_code'] = request.unitCode;
    if (request.deptCode != null) json['dept_code'] = request.deptCode;
    if (request.categoryCode != null) json['category_code'] = request.categoryCode;
    if (request.brandCode != null) json['brand_code'] = request.brandCode;
    if (request.quantity != null) json['quantity'] = request.quantity;
    if (request.status != null) json['status'] = request.status;

    return json;
  }
}