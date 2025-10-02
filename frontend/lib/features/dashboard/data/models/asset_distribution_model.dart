// Path: frontend/lib/features/dashboard/data/models/asset_distribution_model.dart
class AssetDistributionModel {
  final List<PieChartDataModel> pieChartData;
  final DistributionSummaryModel summary;
  final FilterInfoModel filterInfo;

  const AssetDistributionModel({
    required this.pieChartData,
    required this.summary,
    required this.filterInfo,
  });

  factory AssetDistributionModel.fromJson(Map<String, dynamic> json) {
    return AssetDistributionModel(
      pieChartData:
          (json['all_departments'] as List<dynamic>?)
              ?.map(
                (e) => PieChartDataModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      summary: DistributionSummaryModel.fromJson(json['summary'] ?? {}),
      filterInfo: FilterInfoModel.fromJson(json['filter_info'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pie_chart_data': pieChartData.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
      'filter_info': filterInfo.toJson(),
    };
  }
}

class PieChartDataModel {
  final String name;
  final int value;
  final double percentage;
  final String deptCode;
  final String plantCode;
  final String plantDescription;

  const PieChartDataModel({
    required this.name,
    required this.value,
    required this.percentage,
    required this.deptCode,
    required this.plantCode,
    required this.plantDescription,
  });

  factory PieChartDataModel.fromJson(Map<String, dynamic> json) {
    return PieChartDataModel(
      name: json['name'] ?? '',
      value: json['value'] ?? 0,
      percentage: double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0,
      deptCode: json['dept_code'] ?? '',
      plantCode: json['plant_code'] ?? '',
      plantDescription: json['plant_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'percentage': percentage,
      'dept_code': deptCode,
      'plant_code': plantCode,
      'plant_description': plantDescription,
    };
  }
}

class DistributionSummaryModel {
  final int totalAssets;
  final int assignedAssets;
  final int unassignedAssets;
  final int totalDepartments;
  final String plantFilter;

  const DistributionSummaryModel({
    required this.totalAssets,
    required this.assignedAssets,
    required this.unassignedAssets,
    required this.totalDepartments,
    required this.plantFilter,
  });

  factory DistributionSummaryModel.fromJson(Map<String, dynamic> json) {
    return DistributionSummaryModel(
      totalAssets: json['total_assets'] ?? 0,
      assignedAssets: json['assigned_assets'] ?? 0,
      unassignedAssets: json['unassigned_assets'] ?? 0,
      totalDepartments: json['total_departments'] ?? 0,
      plantFilter: json['plant_filter'] ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_assets': totalAssets,
      'assigned_assets': assignedAssets,
      'unassigned_assets': unassignedAssets,
      'total_departments': totalDepartments,
      'plant_filter': plantFilter,
    };
  }
}

class FilterInfoModel {
  final AppliedFiltersModel appliedFilters;

  const FilterInfoModel({required this.appliedFilters});

  factory FilterInfoModel.fromJson(Map<String, dynamic> json) {
    return FilterInfoModel(
      appliedFilters: AppliedFiltersModel.fromJson(
        json['applied_filters'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'applied_filters': appliedFilters.toJson()};
  }
}

class AppliedFiltersModel {
  final String? plantCode;

  const AppliedFiltersModel({this.plantCode});

  factory AppliedFiltersModel.fromJson(Map<String, dynamic> json) {
    return AppliedFiltersModel(plantCode: json['plant_code']);
  }

  Map<String, dynamic> toJson() {
    return {'plant_code': plantCode};
  }
}
