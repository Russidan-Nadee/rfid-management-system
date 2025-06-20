// Path: frontend/lib/features/dashboard/domain/usecases/get_location_analytics_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/location_analytics.dart';
import '../repositories/dashboard_repository.dart';

class GetLocationAnalyticsUseCase {
  final DashboardRepository repository;

  GetLocationAnalyticsUseCase(this.repository);

  /// Execute the use case to get location analytics and growth trends
  ///
  /// [params] contains filters and period settings for location data
  /// Returns [LocationAnalytics] on success or [Failure] on error
  Future<Either<Failure, LocationAnalytics>> call(
    GetLocationAnalyticsParams params,
  ) async {
    // Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(ValidationFailure([validation]));
    }

    return await repository.getLocationAnalytics(
      locationCode: params.locationCode,
      period: params.period,
      year: params.year,
      startDate: params.startDate,
      endDate: params.endDate,
      includeTrends: params.includeTrends,
    );
  }

  /// Validate parameters
  String? _validateParams(GetLocationAnalyticsParams params) {
    // Validate period
    if (!_isValidPeriod(params.period)) {
      return 'Invalid period. Must be Q1, Q2, Q3, Q4, 1Y, or custom';
    }

    // Validate location code if provided
    if (params.locationCode != null &&
        !_isValidLocationCode(params.locationCode!)) {
      return 'Invalid location code format';
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

  /// Validate location code format
  bool _isValidLocationCode(String locationCode) {
    final locationCodeRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    return locationCodeRegex.hasMatch(locationCode) &&
        locationCode.length <= 10;
  }

  /// Validate year
  bool _isValidYear(int year) {
    return year >= 2020 && year <= DateTime.now().year + 1;
  }
}

class GetLocationAnalyticsParams {
  final String? locationCode;
  final String period;
  final int? year;
  final String? startDate;
  final String? endDate;
  final bool includeTrends;

  const GetLocationAnalyticsParams({
    this.locationCode,
    required this.period,
    this.year,
    this.startDate,
    this.endDate,
    this.includeTrends = true,
  });

  /// Factory constructor for quarterly analytics
  factory GetLocationAnalyticsParams.quarterly({
    String? locationCode,
    required String quarter, // Q1, Q2, Q3, Q4
    int? year,
    bool includeTrends = true,
  }) {
    return GetLocationAnalyticsParams(
      locationCode: locationCode,
      period: quarter,
      year: year ?? DateTime.now().year,
      includeTrends: includeTrends,
    );
  }

  /// Factory constructor for yearly analytics
  factory GetLocationAnalyticsParams.yearly({
    String? locationCode,
    int? year,
    bool includeTrends = true,
  }) {
    return GetLocationAnalyticsParams(
      locationCode: locationCode,
      period: '1Y',
      year: year ?? DateTime.now().year,
      includeTrends: includeTrends,
    );
  }

  /// Factory constructor for custom date range
  factory GetLocationAnalyticsParams.custom({
    String? locationCode,
    required String startDate,
    required String endDate,
    bool includeTrends = true,
  }) {
    return GetLocationAnalyticsParams(
      locationCode: locationCode,
      period: 'custom',
      startDate: startDate,
      endDate: endDate,
      includeTrends: includeTrends,
    );
  }

  /// Factory constructor for current quarter (Q2 by default)
  factory GetLocationAnalyticsParams.currentQuarter({String? locationCode}) {
    return GetLocationAnalyticsParams(
      locationCode: locationCode,
      period: 'Q2',
      year: DateTime.now().year,
      includeTrends: false,
    );
  }

  /// Factory constructor for all locations analytics
  factory GetLocationAnalyticsParams.allLocations({
    String period = 'Q2',
    int? year,
  }) {
    return GetLocationAnalyticsParams(
      locationCode: null,
      period: period,
      year: year ?? DateTime.now().year,
      includeTrends: false,
    );
  }

  /// Factory constructor for specific location
  factory GetLocationAnalyticsParams.forLocation({
    required String locationCode,
    String period = 'Q2',
    int? year,
  }) {
    return GetLocationAnalyticsParams(
      locationCode: locationCode,
      period: period,
      year: year ?? DateTime.now().year,
      includeTrends: false,
    );
  }

  /// Check if filtering by specific location
  bool get isLocationFiltered =>
      locationCode != null && locationCode!.isNotEmpty;

  /// Check if using custom date range
  bool get isCustomPeriod => period == 'custom';

  /// Check if quarterly period
  bool get isQuarterlyPeriod => ['Q1', 'Q2', 'Q3', 'Q4'].contains(period);

  /// Check if yearly period
  bool get isYearlyPeriod => period == '1Y';

  /// Check if requesting trend data
  bool get requestsTrends => includeTrends;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetLocationAnalyticsParams &&
        other.locationCode == locationCode &&
        other.period == period &&
        other.year == year &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.includeTrends == includeTrends;
  }

  @override
  int get hashCode => Object.hash(
    locationCode,
    period,
    year,
    startDate,
    endDate,
    includeTrends,
  );

  @override
  String toString() =>
      'GetLocationAnalyticsParams('
      'locationCode: $locationCode, '
      'period: $period, '
      'year: $year, '
      'startDate: $startDate, '
      'endDate: $endDate, '
      'includeTrends: $includeTrends)';
}
