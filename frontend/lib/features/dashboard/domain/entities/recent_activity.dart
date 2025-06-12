// Path: frontend/lib/features/dashboard/domain/entities/recent_activity.dart
class RecentScan {
  final String id;
  final String assetNo;
  final String assetDescription;
  final DateTime scannedAt;
  final String scannedBy;
  final String location;
  final String plant;
  final String? ipAddress;
  final String formattedTime;

  const RecentScan({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentScan &&
        other.id == id &&
        other.assetNo == assetNo &&
        other.assetDescription == assetDescription &&
        other.scannedAt == scannedAt &&
        other.scannedBy == scannedBy &&
        other.location == location &&
        other.plant == plant &&
        other.ipAddress == ipAddress &&
        other.formattedTime == formattedTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        assetNo.hashCode ^
        assetDescription.hashCode ^
        scannedAt.hashCode ^
        scannedBy.hashCode ^
        location.hashCode ^
        plant.hashCode ^
        ipAddress.hashCode ^
        formattedTime.hashCode;
  }

  @override
  String toString() {
    return 'RecentScan(id: $id, assetNo: $assetNo, scannedAt: $scannedAt)';
  }
}

class RecentExport {
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

  const RecentExport({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentExport &&
        other.id == id &&
        other.type == type &&
        other.typeLabel == typeLabel &&
        other.status == status &&
        other.statusLabel == statusLabel &&
        other.totalRecords == totalRecords &&
        other.fileSize == fileSize &&
        other.createdAt == createdAt &&
        other.userName == userName &&
        other.formattedTime == formattedTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        typeLabel.hashCode ^
        status.hashCode ^
        statusLabel.hashCode ^
        totalRecords.hashCode ^
        fileSize.hashCode ^
        createdAt.hashCode ^
        userName.hashCode ^
        formattedTime.hashCode;
  }

  @override
  String toString() {
    return 'RecentExport(id: $id, type: $type, status: $status, createdAt: $createdAt)';
  }

  // Helper getters
  bool get isCompleted => status == 'C';
  bool get isPending => status == 'P';
  bool get isFailed => status == 'F';
}

class RecentActivity {
  final List<RecentScan> recentScans;
  final List<RecentExport> recentExports;
  final String period;
  final int totalScans;
  final int totalExports;

  const RecentActivity({
    required this.recentScans,
    required this.recentExports,
    required this.period,
    required this.totalScans,
    required this.totalExports,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentActivity &&
        other.recentScans.length == recentScans.length &&
        other.recentExports.length == recentExports.length &&
        other.period == period &&
        other.totalScans == totalScans &&
        other.totalExports == totalExports &&
        other.recentScans.every((element) => recentScans.contains(element)) &&
        other.recentExports.every((element) => recentExports.contains(element));
  }

  @override
  int get hashCode {
    return recentScans.hashCode ^
        recentExports.hashCode ^
        period.hashCode ^
        totalScans.hashCode ^
        totalExports.hashCode;
  }

  @override
  String toString() {
    return 'RecentActivity(period: $period, totalScans: $totalScans, totalExports: $totalExports)';
  }

  // Helper getters
  bool get hasScans => recentScans.isNotEmpty;
  bool get hasExports => recentExports.isNotEmpty;
  bool get hasActivity => hasScans || hasExports;

  int get completedExports => recentExports.where((e) => e.isCompleted).length;
  int get failedExports => recentExports.where((e) => e.isFailed).length;
  int get pendingExports => recentExports.where((e) => e.isPending).length;
}
