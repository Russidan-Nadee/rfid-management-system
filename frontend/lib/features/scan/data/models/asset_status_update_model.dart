// Path: frontend/lib/features/scan/data/models/asset_status_update_model.dart
import '../../domain/entities/scanned_item_entity.dart';

/// Request model สำหรับ update asset status
class AssetStatusUpdateRequest {
  final String status;
  final String updatedBy;
  final String? remarks;

  const AssetStatusUpdateRequest({
    required this.status,
    required this.updatedBy,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'status': status, 'updated_by': updatedBy};

    if (remarks != null && remarks!.isNotEmpty) {
      json['remarks'] = remarks;
    }

    return json;
  }

  @override
  String toString() {
    return 'AssetStatusUpdateRequest(status: $status, updatedBy: $updatedBy, remarks: $remarks)';
  }
}

/// Response model สำหรับ update asset status
class AssetStatusUpdateResponse {
  final bool success;
  final String message;
  final ScannedItemEntity? updatedAsset;
  final DateTime timestamp;

  const AssetStatusUpdateResponse({
    required this.success,
    required this.message,
    this.updatedAsset,
    required this.timestamp,
  });

  factory AssetStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return AssetStatusUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      updatedAsset: json['data'] != null
          ? _parseAssetFromJson(json['data'])
          : null,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  static ScannedItemEntity _parseAssetFromJson(Map<String, dynamic> json) {
    return ScannedItemEntity(
      assetNo: json['asset_no'] ?? '',
      description: json['description'],
      serialNo: json['serial_no'],
      inventoryNo: json['inventory_no'],
      quantity: _parseQuantity(json['quantity']),
      unitName: json['unit_name'],
      createdByName: json['created_by_name'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      status: json['status'] ?? 'A',
    );
  }

  static double? _parseQuantity(dynamic quantity) {
    if (quantity == null) return null;
    if (quantity is double) return quantity;
    if (quantity is int) return quantity.toDouble();
    if (quantity is String) return double.tryParse(quantity);
    return null;
  }

  @override
  String toString() {
    return 'AssetStatusUpdateResponse(success: $success, message: $message, timestamp: $timestamp)';
  }
}

/// Factory สำหรับสร้าง request objects
class AssetStatusUpdateFactory {
  /// สร้าง request สำหรับเปลี่ยน Active -> Checked
  static AssetStatusUpdateRequest createCheckRequest(String updatedBy) {
    return AssetStatusUpdateRequest(
      status: 'C',
      updatedBy: updatedBy,
      remarks: 'Marked as checked via mobile app',
    );
  }

  /// สร้าง request สำหรับเปลี่ยน Active -> Inactive (สำหรับ manager/admin)
  static AssetStatusUpdateRequest createDeactivateRequest(
    String updatedBy,
    String? remarks,
  ) {
    return AssetStatusUpdateRequest(
      status: 'I',
      updatedBy: updatedBy,
      remarks: remarks ?? 'Deactivated via mobile app',
    );
  }

  /// สร้าง request สำหรับเปลี่ยน Checked -> Active
  static AssetStatusUpdateRequest createActivateRequest(String updatedBy) {
    return AssetStatusUpdateRequest(
      status: 'A',
      updatedBy: updatedBy,
      remarks: 'Reactivated via mobile app',
    );
  }
}
