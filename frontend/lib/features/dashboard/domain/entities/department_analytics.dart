// Path: frontend/lib/features/dashboard/domain/entities/department_analytics.dart

class DepartmentPieData {
  final String deptCode;
  final String deptDescription;
  final String? plantCode;
  final String? plantDescription;
  final int assetCount;
  final int percentage;
  final int activeAssets;
  final int inactiveAssets;
  final int createdAssets;

  const DepartmentPieData({
    required this.deptCode,
    required this.deptDescription,
    this.plantCode,
    this.plantDescription,
    required this.assetCount,
    required this.percentage,
    required this.activeAssets,
    required this.inactiveAssets,
    required this.createdAssets,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepartmentPieData &&
        other.deptCode == deptCode &&
        other.deptDescription == deptDescription &&
        other.plantCode == plantCode &&
        other.plantDescription == plantDescription &&
        other.assetCount == assetCount &&
        other.percentage == percentage &&
        other.activeAssets == activeAssets &&
        other.inactiveAssets == inactiveAssets &&
        other.createdAssets == createdAssets;
  }

  @override
  int get hashCode {
    return deptCode.hashCode ^
        deptDescription.hashCode ^
        plantCode.hashCode ^
        plantDescription.hashCode ^
        assetCount.hashCode ^
        percentage.hashCode ^
        activeAssets.hashCode ^
        inactiveAssets.hashCode ^
        createdAssets.hashCode;
  }

  @override
  String toString() {
    return 'DepartmentPieData(deptCode: $deptCode, deptDescription: $deptDescription, assetCount: $assetCount, percentage: $percentage)';
  }

  // Helper getters
  bool get hasAssets => assetCount > 0;

  double get activePercentage {
    if (assetCount == 0) return 0.0;
    return (activeAssets / assetCount) * 100;
  }
}

class DepartmentSummary {
  final int totalDepartments;
  final int totalAssets;
  final String plantFilter;
  final DepartmentPieData? largestDepartment;
  final DepartmentPieData? smallestDepartment;

  const DepartmentSummary({
    required this.totalDepartments,
    required this.totalAssets,
    required this.plantFilter,
    this.largestDepartment,
    this.smallestDepartment,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepartmentSummary &&
        other.totalDepartments == totalDepartments &&
        other.totalAssets == totalAssets &&
        other.plantFilter == plantFilter &&
        other.largestDepartment == largestDepartment &&
        other.smallestDepartment == smallestDepartment;
  }

  @override
  int get hashCode {
    return totalDepartments.hashCode ^
        totalAssets.hashCode ^
        plantFilter.hashCode ^
        largestDepartment.hashCode ^
        smallestDepartment.hashCode;
  }

  @override
  String toString() {
    return 'DepartmentSummary(totalDepartments: $totalDepartments, totalAssets: $totalAssets, plantFilter: $plantFilter)';
  }

  // Helper getters
  bool get hasData => totalAssets > 0 && totalDepartments > 0;
  bool get isFiltered => plantFilter != 'all';

  double get averageAssetsPerDepartment {
    if (totalDepartments == 0) return 0.0;
    return totalAssets / totalDepartments;
  }
}

class FilterInfo {
  final String? plantCode;
  final DateTime generatedAt;

  const FilterInfo({this.plantCode, required this.generatedAt});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterInfo &&
        other.plantCode == plantCode &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode {
    return plantCode.hashCode ^ generatedAt.hashCode;
  }

  @override
  String toString() {
    return 'FilterInfo(plantCode: $plantCode, generatedAt: $generatedAt)';
  }

  // Helper getters
  bool get hasPlantFilter => plantCode != null && plantCode!.isNotEmpty;

  String get filterDescription {
    return hasPlantFilter ? 'Plant: $plantCode' : 'All Plants';
  }
}

class DepartmentAnalytics {
  final List<DepartmentPieData> pieChartData;
  final DepartmentSummary summary;
  final FilterInfo filterInfo;

  const DepartmentAnalytics({
    required this.pieChartData,
    required this.summary,
    required this.filterInfo,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepartmentAnalytics &&
        other.pieChartData.length == pieChartData.length &&
        other.summary == summary &&
        other.filterInfo == filterInfo &&
        other.pieChartData.every((element) => pieChartData.contains(element));
  }

  @override
  int get hashCode {
    return pieChartData.hashCode ^ summary.hashCode ^ filterInfo.hashCode;
  }

  @override
  String toString() {
    return 'DepartmentAnalytics(pieChartData: ${pieChartData.length} items, summary: $summary)';
  }

  // Helper getters
  bool get hasData => pieChartData.isNotEmpty && summary.hasData;
  bool get hasMultipleDepartments => pieChartData.length > 1;

  List<DepartmentPieData> get topDepartments {
    final sorted = List<DepartmentPieData>.from(pieChartData);
    sorted.sort((a, b) => b.assetCount.compareTo(a.assetCount));
    return sorted.take(5).toList();
  }

  int get totalAssets =>
      pieChartData.fold(0, (sum, dept) => sum + dept.assetCount);

  double get largestDepartmentPercentage {
    if (pieChartData.isEmpty) return 0.0;
    return pieChartData
        .map((d) => d.percentage)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
  }
}
