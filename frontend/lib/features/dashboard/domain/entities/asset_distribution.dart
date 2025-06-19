// Path: frontend/lib/features/dashboard/domain/entities/asset_distribution.dart
import 'package:equatable/equatable.dart';

class AssetDistribution extends Equatable {
  final List<PieChartData> pieChartData;
  final DistributionSummary summary;
  final FilterInfo filterInfo;

  const AssetDistribution({
    required this.pieChartData,
    required this.summary,
    required this.filterInfo,
  });

  // Helper methods
  List<PieChartData> get sortedByValue =>
      [...pieChartData]..sort((a, b) => b.value.compareTo(a.value));

  List<PieChartData> get sortedByPercentage =>
      [...pieChartData]..sort((a, b) => b.percentage.compareTo(a.percentage));

  PieChartData? get largestDepartment =>
      pieChartData.isNotEmpty ? sortedByValue.first : null;

  PieChartData? get smallestDepartment =>
      pieChartData.isNotEmpty ? sortedByValue.last : null;

  bool get hasData => pieChartData.isNotEmpty && summary.totalAssets > 0;

  @override
  List<Object> get props => [pieChartData, summary, filterInfo];
}

class PieChartData extends Equatable {
  final String name;
  final int value;
  final double percentage;
  final String deptCode;
  final String plantCode;
  final String plantDescription;

  const PieChartData({
    required this.name,
    required this.value,
    required this.percentage,
    required this.deptCode,
    required this.plantCode,
    required this.plantDescription,
  });

  // Helper methods
  bool get hasAssets => value > 0;
  String get displayName => name.isNotEmpty ? name : deptCode;
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

  @override
  List<Object> get props => [
    name,
    value,
    percentage,
    deptCode,
    plantCode,
    plantDescription,
  ];
}

class DistributionSummary extends Equatable {
  final int totalAssets;
  final int totalDepartments;
  final String plantFilter;

  const DistributionSummary({
    required this.totalAssets,
    required this.totalDepartments,
    required this.plantFilter,
  });

  bool get isFiltered => plantFilter != 'all';
  double get averageAssetsPerDepartment =>
      totalDepartments > 0 ? totalAssets / totalDepartments : 0;

  @override
  List<Object> get props => [totalAssets, totalDepartments, plantFilter];
}

class FilterInfo extends Equatable {
  final AppliedFilters appliedFilters;

  const FilterInfo({required this.appliedFilters});

  bool get hasActiveFilters => appliedFilters.hasActiveFilters;

  @override
  List<Object> get props => [appliedFilters];
}

class AppliedFilters extends Equatable {
  final String? plantCode;

  const AppliedFilters({this.plantCode});

  bool get hasActiveFilters => plantCode != null && plantCode!.isNotEmpty;
  bool get isPlantFiltered => plantCode != null && plantCode != 'all';

  @override
  List<Object?> get props => [plantCode];
}
