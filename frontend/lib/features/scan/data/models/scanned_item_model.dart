import '../../domain/entities/scanned_item_entity.dart';

class ScannedItemModel extends ScannedItemEntity {
  const ScannedItemModel({
    required super.assetNo,
    super.description,
    super.serialNo,
    super.inventoryNo,
    super.quantity,
    super.unitName,
    super.createdByName,
    super.createdAt,
    required super.status,
    super.isUnknown,

    super.plantCode,
    super.locationCode,
    super.locationName,

    super.deptCode,
    super.deptDescription,
    super.plantDescription,
    super.lastScanAt,
    super.lastScannedBy,
    super.totalScans,
  });

  factory ScannedItemModel.fromJson(Map<String, dynamic> json) {
    return ScannedItemModel(
      assetNo: json['asset_no'] ?? '',
      description: json['description'],
      serialNo: json['serial_no'],
      inventoryNo: json['inventory_no'],
      quantity: _parseQuantity(json['quantity']),
      unitName: json['unit_name'],
      createdByName: json['created_by_name'] ?? 'Unknown User',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      status: json['status'] ?? 'A',

      plantCode: json['plant_code'],
      locationCode: json['location_code'],
      locationName: json['location_description'],

      deptCode: json['dept_code'],
      deptDescription: json['dept_description'],
      plantDescription: json['plant_description'],
      lastScanAt: json['last_scan_at'] != null
          ? DateTime.tryParse(json['last_scan_at'])
          : null,
      lastScannedBy: json['last_scanned_by'],
      totalScans: json['total_scans'] != null
          ? int.tryParse(json['total_scans'].toString())
          : null,
    );
  }

  factory ScannedItemModel.unknown(String assetNo, {String? locationName}) {
    return ScannedItemModel(
      assetNo: assetNo,
      description: 'Unknown Item',
      status: 'Unknown',
      isUnknown: true,
      locationName: locationName,
    );
  }

  static double? _parseQuantity(dynamic quantity) {
    if (quantity == null) return null;
    if (quantity is double) return quantity;
    if (quantity is int) return quantity.toDouble();
    if (quantity is String) return double.tryParse(quantity);
    return null;
  }

  Map<String, dynamic> toJson() {
    final json = {
      'asset_no': assetNo,
      'description': description,
      'serial_no': serialNo,
      'inventory_no': inventoryNo,
      'quantity': quantity,
      'unit_name': unitName,
      'created_by_name': createdByName,
      'created_at': createdAt?.toIso8601String(),
      'status': status,
    };

    if (plantCode != null) json['plant_code'] = plantCode;
    if (locationCode != null) json['location_code'] = locationCode;
    if (locationName != null) json['location_name'] = locationName;

    if (deptCode != null) json['dept_code'] = deptCode;
    if (deptDescription != null) json['dept_description'] = deptDescription;
    if (plantDescription != null) json['plant_description'] = plantDescription;
    if (lastScanAt != null)
      json['last_scan_at'] = lastScanAt!.toIso8601String();
    if (lastScannedBy != null) json['last_scanned_by'] = lastScannedBy;
    if (totalScans != null) json['total_scans'] = totalScans;

    return json;
  }
}
