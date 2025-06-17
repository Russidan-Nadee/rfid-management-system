// Path: frontend/lib/features/dashboard/data/models/department_analytics_model.dart
import '../../domain/entities/department_analytics.dart';

class DepartmentPieDataModel {
  final String deptCode;
  final String deptDescription;
  final String? plantCode;
  final String? plantDescription;
  final int assetCount;
  final int percentage;
  final int activeAssets;
  final int inactiveAssets;
  final int createdAssets;

  DepartmentPieDataModel({
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

  factory DepartmentPieDataModel.fromJson(Map<String, dynamic> json) {
    return DepartmentPieDataModel(
      deptCode: json['dept_code'] ?? '',
      deptDescription: json['dept_description'] ?? '',
      plantCode: json['plant_code'],
      plantDescription: json['plant_description'],
      assetCount: json['asset_count'] ?? 0,
      percentage: json['percentage'] ?? 0,
      activeAssets: json['active_assets'] ?? 0,
      inactiveAssets: json['inactive_assets'] ?? 0,
      createdAssets: json['created_assets'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dept_code': deptCode,
      'dept_description': deptDescription,
      'plant_code': plantCode,
      'plant_description': plantDescription,
      'asset_count': assetCount,
      'percentage': percentage,
      'active_assets': activeAssets,
      'inactive_assets': inactiveAssets,
      'created_assets': createdAssets,
    };
  }

  DepartmentPieData toEntity() {
    return DepartmentPieData(
      deptCode: deptCode,
      deptDescription: deptDescription,
      plantCode: plantCode,
      plantDescription: plantDescription,
      assetCount: assetCount,
      percentage: percentage,
      activeAssets: activeAssets,
      inactiveAssets: inactiveAssets,
      createdAssets: createdAssets,
    );
  }

  // Helper methods for UI
  bool get hasAssets => assetCount > 0;

  double get activePercentage {
    if (assetCount == 0) return 0.0;
    return (activeAssets / assetCount) * 100;
  }

  String get displayLabel => '$deptDescription ($percentage%)';

  String get shortLabel => deptCode;
}

class DepartmentSummaryModel {
  final int totalDepartments;
  final int totalAssets;
  final String plantFilter;
  final DepartmentPieDataModel? largestDepartment;
  final DepartmentPieDataModel? smallestDepartment;

  DepartmentSummaryModel({
    required this.totalDepartments,
    required this.totalAssets,
    required this.plantFilter,
    this.largestDepartment,
    this.smallestDepartment,
  });

  factory DepartmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return DepartmentSummaryModel(
      totalDepartments: json['total_departments'] ?? 0,
      totalAssets: json['total_assets'] ?? 0,
      plantFilter: json['plant_filter'] ?? 'all',
      largestDepartment: json['largest_department'] != null
          ? DepartmentPieDataModel.fromJson(
              json['largest_department'] as Map<String, dynamic>,
            )
          : null,
      smallestDepartment: json['smallest_department'] != null
          ? DepartmentPieDataModel.fromJson(
              json['smallest_department'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_departments': totalDepartments,
      'total_assets': totalAssets,
      'plant_filter': plantFilter,
      'largest_department': largestDepartment?.toJson(),
      'smallest_department': smallestDepartment?.toJson(),
    };
  }

  DepartmentSummary toEntity() {
    return DepartmentSummary(
      totalDepartments: totalDepartments,
      totalAssets: totalAssets,
      plantFilter: plantFilter,
      largestDepartment: largestDepartment?.toEntity(),
      smallestDepartment: smallestDepartment?.toEntity(),
    );
  }

  // Helper methods
  bool get hasData => totalAssets > 0 && totalDepartments > 0;
  bool get isFiltered => plantFilter != 'all';

  double get averageAssetsPerDepartment {
    if (totalDepartments == 0) return 0.0;
    return totalAssets / totalDepartments;
  }
}

class FilterInfoModel {
  final String? plantCode;
  final DateTime generatedAt;

  FilterInfoModel({this.plantCode, required this.generatedAt});

  factory FilterInfoModel.fromJson(Map<String, dynamic> json) {
    return FilterInfoModel(
      plantCode: json['plant_code'],
      generatedAt:
          DateTime.tryParse(json['generated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plant_code': plantCode,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  FilterInfo toEntity() {
    return FilterInfo(plantCode: plantCode, generatedAt: generatedAt);
  }

  // Helper methods
  bool get hasPlantFilter => plantCode != null && plantCode!.isNotEmpty;

  String get filterDescription {
    return hasPlantFilter ? 'Plant: $plantCode' : 'All Plants';
  }
}

class DepartmentAnalyticsModel {
  final List<DepartmentPieDataModel> pieChartData;
  final DepartmentSummaryModel summary;
  final FilterInfoModel filterInfo;

  DepartmentAnalyticsModel({
    required this.pieChartData,
    required this.summary,
    required this.filterInfo,
  });

  factory DepartmentAnalyticsModel.fromJson(Map<String, dynamic> json) {
    try {
      final pieData = json['pie_chart_data'] as List<dynamic>? ?? [];
      final summaryData = json['summary'] as Map<String, dynamic>? ?? {};
      final filterData = json['filter_info'] as Map<String, dynamic>? ?? {};

      return DepartmentAnalyticsModel(
        pieChartData: pieData
            .map(
              (item) =>
                  DepartmentPieDataModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        summary: DepartmentSummaryModel.fromJson(summaryData),
        filterInfo: FilterInfoModel.fromJson(filterData),
      );
    } catch (e) {
      print('Department analytics parsing error: $e');
      return DepartmentAnalyticsModel(
        pieChartData: [],
        summary: DepartmentSummaryModel(
          totalDepartments: 0,
          totalAssets: 0,
          plantFilter: 'all',
        ),
        filterInfo: FilterInfoModel(generatedAt: DateTime.now()),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'pie_chart_data': pieChartData.map((item) => item.toJson()).toList(),
      'summary': summary.toJson(),
      'filter_info': filterInfo.toJson(),
    };
  }

  DepartmentAnalytics toEntity() {
    return DepartmentAnalytics(
      pieChartData: pieChartData.map((item) => item.toEntity()).toList(),
      summary: summary.toEntity(),
      filterInfo: filterInfo.toEntity(),
    );
  }

  // Helper methods
  bool get hasData => pieChartData.isNotEmpty && summary.hasData;

  bool get hasMultipleDepartments => pieChartData.length > 1;

  List<DepartmentPieDataModel> get topDepartments {
    final sorted = List<DepartmentPieDataModel>.from(pieChartData);
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

  // Chart colors for pie chart
  static const List<String> chartColors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#795548', // Brown
    '#607D8B', // Blue Grey
    '#E91E63', // Pink
    '#3F51B5', // Indigo
  ];

  String getColorForIndex(int index) {
    return chartColors[index % chartColors.length];
  }
}
