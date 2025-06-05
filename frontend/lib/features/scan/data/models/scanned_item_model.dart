// Path: frontend/lib/features/scan/data/models/scanned_item_model.dart
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
    );
  }

  factory ScannedItemModel.unknown(String assetNo) {
    return ScannedItemModel(
      assetNo: assetNo,
      description: 'Unknown Item',
      status: 'Unknown',
      isUnknown: true,
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
    return {
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
  }
}
