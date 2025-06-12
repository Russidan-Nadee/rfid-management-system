// Path: frontend/lib/features/dashboard/domain/entities/charts.dart
import 'asset_status_pie.dart';
import 'scan_trend.dart';

class Charts {
  final AssetStatusPie assetStatusPie;
  final List<ScanTrend> scanTrend7d;

  const Charts({required this.assetStatusPie, required this.scanTrend7d});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Charts &&
        other.assetStatusPie == assetStatusPie &&
        other.scanTrend7d.length == scanTrend7d.length &&
        other.scanTrend7d.every((element) => scanTrend7d.contains(element));
  }

  @override
  int get hashCode {
    return assetStatusPie.hashCode ^ scanTrend7d.hashCode;
  }

  @override
  String toString() {
    return 'Charts(assetStatusPie: $assetStatusPie, scanTrend7d: $scanTrend7d)';
  }
}
