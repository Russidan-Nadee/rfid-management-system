// Path: frontend/lib/features/dashboard/data/models/recent_activity_model.dart
import '../../domain/entities/recent_activity.dart';
import 'period_info_model.dart';

class RecentScanModel {
  final String id;
  final String assetNo;
  final String assetDescription;
  final DateTime scannedAt;
  final String scannedBy;
  final String location;
  final String plant;
  final String? ipAddress;
  final String formattedTime;

  RecentScanModel({
    required this.id,
    required this.assetNo,
    required this.assetDescription,
    required this.scannedAt,
    required this.scannedBy,
    required this.location,
    required this.plant,
    this.ipAddress,
    required this.formattedTime,
  });

  factory RecentScanModel.fromJson(Map<String, dynamic> json) {
    return RecentScanModel(
      id: json['id']?.toString() ?? '',
      assetNo: json['asset_no'] ?? '',
      assetDescription: json['asset_description'] ?? '',
      scannedAt: DateTime.tryParse(json['scanned_at'] ?? '') ?? DateTime.now(),
      scannedBy: json['scanned_by'] ?? '',
      location: json['location'] ?? '',
      plant: json['plant'] ?? '',
      ipAddress: json['ip_address'],
      formattedTime: json['formatted_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_no': assetNo,
      'asset_description': assetDescription,
      'scanned_at': scannedAt.toIso8601String(),
      'scanned_by': scannedBy,
      'location': location,
      'plant': plant,
      'ip_address': ipAddress,
      'formatted_time': formattedTime,
    };
  }

  RecentScan toEntity() {
    return RecentScan(
      id: id,
      assetNo: assetNo,
      assetDescription: assetDescription,
      scannedAt: scannedAt,
      scannedBy: scannedBy,
      location: location,
      plant: plant,
      ipAddress: ipAddress,
      formattedTime: formattedTime,
    );
  }
}

class RecentExportModel {
  final String id;
  final String type;
  final String typeLabel;
  final String status;
  final String statusLabel;
  final int totalRecords;
  final String? fileSize;
  final DateTime createdAt;
  final String userName;
  final String formattedTime;

  RecentExportModel({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.statusLabel,
    required this.totalRecords,
    this.fileSize,
    required this.createdAt,
    required this.userName,
    required this.formattedTime,
  });

  factory RecentExportModel.fromJson(Map<String, dynamic> json) {
    return RecentExportModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      typeLabel: json['type_label'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      totalRecords: json['total_records'] ?? 0,
      fileSize: json['file_size'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      userName: json['user_name'] ?? '',
      formattedTime: json['formatted_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'type_label': typeLabel,
      'status': status,
      'status_label': statusLabel,
      'total_records': totalRecords,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'formatted_time': formattedTime,
    };
  }

  RecentExport toEntity() {
    return RecentExport(
      id: id,
      type: type,
      typeLabel: typeLabel,
      status: status,
      statusLabel: statusLabel,
      totalRecords: totalRecords,
      fileSize: fileSize,
      createdAt: createdAt,
      userName: userName,
      formattedTime: formattedTime,
    );
  }

  // Helper methods
  bool get isCompleted => status == 'C';
  bool get isPending => status == 'P';
  bool get isFailed => status == 'F';
}

class RecentActivityModel {
  final List<RecentScanModel> recentScans;
  final List<RecentExportModel> recentExports;
  final PeriodInfoModel periodInfo;

  RecentActivityModel({
    required this.recentScans,
    required this.recentExports,
    required this.periodInfo,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      recentScans:
          (json['recent_scans'] as List<dynamic>?)
              ?.map(
                (item) =>
                    RecentScanModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      recentExports:
          (json['recent_exports'] as List<dynamic>?)
              ?.map(
                (item) =>
                    RecentExportModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      periodInfo: PeriodInfoModel.fromJson(json['period_info'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recent_scans': recentScans.map((scan) => scan.toJson()).toList(),
      'recent_exports': recentExports.map((export) => export.toJson()).toList(),
      'period_info': periodInfo.toJson(),
    };
  }

  RecentActivity toEntity() {
    return RecentActivity(
      recentScans: recentScans.map((scan) => scan.toEntity()).toList(),
      recentExports: recentExports.map((export) => export.toEntity()).toList(),
      period: periodInfo.period,
      totalScans: recentScans.length,
      totalExports: recentExports.length,
    );
  }
}
