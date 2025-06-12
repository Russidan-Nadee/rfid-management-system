// Path: frontend/lib/features/dashboard/domain/entities/asset_status_pie.dart
class AssetStatusPie {
  final int active;
  final int inactive;
  final int created;
  final int total;

  const AssetStatusPie({
    required this.active,
    required this.inactive,
    required this.created,
    required this.total,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssetStatusPie &&
        other.active == active &&
        other.inactive == inactive &&
        other.created == created &&
        other.total == total;
  }

  @override
  int get hashCode {
    return active.hashCode ^
        inactive.hashCode ^
        created.hashCode ^
        total.hashCode;
  }

  @override
  String toString() {
    return 'AssetStatusPie(active: $active, inactive: $inactive, created: $created, total: $total)';
  }
}
