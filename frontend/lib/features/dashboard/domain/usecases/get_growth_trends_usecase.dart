// Path: frontend/lib/features/dashboard/domain/usecases/get_growth_trends_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/growth_trend.dart';
import '../repositories/dashboard_repository.dart';

class GetGrowthTrendsUseCase {
  final DashboardRepository repository;

  GetGrowthTrendsUseCase(this.repository);

  /// Execute the use case to get growth trends
  ///
  /// [params] contains filters and period settings
  /// Returns [GrowthTrend] on success or [Failure] on error
  Future<Either<Failure, GrowthTrend>> call(
    GetGrowthTrendsParams params,
  ) async {
    // Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(ValidationFailure([validation]));
    }

    return await repository.getGrowthTrends(
      deptCode: params.deptCode,
      period: params.period,
      year: params.year,
      startDate: params.startDate,
      endDate: params.endDate,
      groupBy: params.groupBy,
    );
  }

  /// Validate parameters
  String? _validateParams(GetGrowthTrendsParams params) {
    // Validate period
    if (!_isValidPeriod(params.period)) {
      return 'Invalid period. Must be Q1, Q2, Q3, Q4, 1Y, or custom';
    }

    // Validate department code if provided
    if (params.deptCode != null && !_isValidDeptCode(params.deptCode!)) {
      return 'Invalid department code format';
    }

    // Validate year if provided
    if (params.year != null && !_isValidYear(params.year!)) {
      return 'Invalid year. Must be between 2020 and ${DateTime.now().year + 1}';
    }

    // Validate custom period dates
    if (params.period == 'custom') {
      if (params.startDate == null || params.endDate == null) {
        return 'Start date and end date are required for custom period';
      }

      final startDate = DateTime.tryParse(params.startDate!);
      final endDate = DateTime.tryParse(params.endDate!);

      if (startDate == null || endDate == null) {
        return 'Invalid date format. Use YYYY-MM-DD';
      }

      if (endDate.isBefore(startDate)) {
        return 'End date must be after start date';
      }

      // Check if date range is not too long (max 2 years)
      if (endDate.difference(startDate).inDays > 730) {
        return 'Date range cannot exceed 2 years';
      }
    }

    return null;
  }

  /// Validate period
  bool _isValidPeriod(String period) {
    const validPeriods = ['Q1', 'Q2', 'Q3', 'Q4', '1Y', 'custom'];
    return validPeriods.contains(period);
  }

  /// Validate department code format
  bool _isValidDeptCode(String deptCode) {
    final deptCodeRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    return deptCodeRegex.hasMatch(deptCode) && deptCode.length <= 10;
  }

  /// Validate year
  bool _isValidYear(int year) {
    return year >= 2020 && year <= DateTime.now().year + 1;
  }
}

class GetGrowthTrendsParams {
  final String? deptCode;
  final String? locationCode;
  final String period;
  final int? year;
  final String? startDate;
  final String? endDate;
  final String groupBy;

  const GetGrowthTrendsParams({
    this.deptCode,
    this.locationCode,
    required this.period,
    this.year,
    this.startDate,
    this.endDate,
    this.groupBy = 'day',
  });

  /// Factory constructor for quarterly trends
  factory GetGrowthTrendsParams.quarterly({
    String? deptCode,
    required String quarter, // Q1, Q2, Q3, Q4
    int? year,
  }) {
    return GetGrowthTrendsParams(
      deptCode: deptCode,
      period: quarter,
      year: year ?? DateTime.now().year,
    );
  }

  /// Factory constructor for yearly trends
  factory GetGrowthTrendsParams.yearly({String? deptCode, int? year}) {
    return GetGrowthTrendsParams(
      deptCode: deptCode,
      period: '1Y',
      year: year ?? DateTime.now().year,
    );
  }

  /// Factory constructor for custom date range
  factory GetGrowthTrendsParams.custom({
    String? deptCode,
    required String startDate,
    required String endDate,
  }) {
    return GetGrowthTrendsParams(
      deptCode: deptCode,
      period: 'custom',
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Factory constructor for current quarter (Q2 by default)
  factory GetGrowthTrendsParams.currentQuarter({String? deptCode}) {
    return GetGrowthTrendsParams(
      deptCode: deptCode,
      period: 'Q2',
      year: DateTime.now().year,
    );
  }

  /// Check if filtering by specific department
  bool get isDepartmentFiltered => deptCode != null && deptCode!.isNotEmpty;

  /// Check if using custom date range
  bool get isCustomPeriod => period == 'custom';

  /// Check if quarterly period
  bool get isQuarterlyPeriod => ['Q1', 'Q2', 'Q3', 'Q4'].contains(period);

  /// Check if yearly period
  bool get isYearlyPeriod => period == '1Y';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetGrowthTrendsParams &&
        other.deptCode == deptCode &&
        other.period == period &&
        other.year == year &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.groupBy == groupBy;
  }

  @override
  int get hashCode =>
      Object.hash(deptCode, period, year, startDate, endDate, groupBy);

  @override
  String toString() =>
      'GetGrowthTrendsParams('
      'deptCode: $deptCode, '
      'period: $period, '
      'year: $year, '
      'startDate: $startDate, '
      'endDate: $endDate)';
}
