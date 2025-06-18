// Path: frontend/lib/features/dashboard/domain/usecases/get_location_analytics_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/location_analytics.dart';
import '../repositories/dashboard_repository.dart';

class GetLocationAnalyticsParams {
  final String? locationCode;
  final String period;
  final int? year;
  final String? startDate;
  final String? endDate;
  final bool includeTrends;
  final bool forceRefresh;

  const GetLocationAnalyticsParams({
    this.locationCode,
    this.period = 'Q2',
    this.year,
    this.startDate,
    this.endDate,
    this.includeTrends = true,
    this.forceRefresh = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetLocationAnalyticsParams &&
        other.locationCode == locationCode &&
        other.period == period &&
        other.year == year &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.includeTrends == includeTrends &&
        other.forceRefresh == forceRefresh;
  }

  @override
  int get hashCode {
    return locationCode.hashCode ^
        period.hashCode ^
        year.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        includeTrends.hashCode ^
        forceRefresh.hashCode;
  }

  @override
  String toString() {
    return 'GetLocationAnalyticsParams(locationCode: $locationCode, period: $period, year: $year, includeTrends: $includeTrends)';
  }

  bool get isCustomPeriod => period == 'custom';
  bool get hasValidCustomDates => startDate != null && endDate != null;
  bool get isValidForCustomPeriod => !isCustomPeriod || hasValidCustomDates;

  static GetLocationAnalyticsParams quarterly({
    String? locationCode,
    String period = 'Q2',
    int? year,
    bool includeTrends = true,
    bool forceRefresh = false,
  }) {
    return GetLocationAnalyticsParams(
      locationCode: locationCode,
      period: period,
      year: year,
      includeTrends: includeTrends,
      forceRefresh: forceRefresh,
    );
  }

  static GetLocationAnalyticsParams custom({
    String? locationCode,
    required String startDate,
    required String endDate,
    bool includeTrends = true,
    bool forceRefresh = false,
  }) {
    return GetLocationAnalyticsParams(
      locationCode: locationCode,
      period: 'custom',
      startDate: startDate,
      endDate: endDate,
      includeTrends: includeTrends,
      forceRefresh: forceRefresh,
    );
  }

  static GetLocationAnalyticsParams yearly({
    String? locationCode,
    int? year,
    bool includeTrends = true,
    bool forceRefresh = false,
  }) {
    return GetLocationAnalyticsParams(
      locationCode: locationCode,
      period: '1Y',
      year: year,
      includeTrends: includeTrends,
      forceRefresh: forceRefresh,
    );
  }
}

class GetLocationAnalyticsUseCase {
  final DashboardRepository repository;

  GetLocationAnalyticsUseCase(this.repository);

  Future<Either<Failure, LocationAnalytics>> call(
    GetLocationAnalyticsParams params,
  ) async {
    if (!params.isValidForCustomPeriod) {
      return Left(
        ValidationFailure(
          'Custom period requires both start_date and end_date',
        ),
      );
    }

    if (!_isValidPeriod(params.period)) {
      return Left(
        ValidationFailure('Invalid period. Use Q1, Q2, Q3, Q4, 1Y, or custom'),
      );
    }

    try {
      final result = await repository.getLocationAnalytics(
        locationCode: params.locationCode,
        period: params.period,
        year: params.year,
        startDate: params.startDate,
        endDate: params.endDate,
        includeTrends: params.includeTrends,
        forceRefresh: params.forceRefresh,
      );

      return result;
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  Future<Either<Failure, LocationAnalytics>> getAllLocations({
    String period = 'Q2',
    int? year,
    bool includeTrends = true,
    bool forceRefresh = false,
  }) async {
    return call(
      GetLocationAnalyticsParams.quarterly(
        period: period,
        year: year,
        includeTrends: includeTrends,
        forceRefresh: forceRefresh,
      ),
    );
  }

  Future<Either<Failure, LocationAnalytics>> getLocationByCode(
    String locationCode, {
    String period = 'Q2',
    int? year,
    bool includeTrends = true,
    bool forceRefresh = false,
  }) async {
    return call(
      GetLocationAnalyticsParams.quarterly(
        locationCode: locationCode,
        period: period,
        year: year,
        includeTrends: includeTrends,
        forceRefresh: forceRefresh,
      ),
    );
  }

  Future<Either<Failure, LocationAnalytics>> getCustomPeriod({
    String? locationCode,
    required String startDate,
    required String endDate,
    bool includeTrends = true,
    bool forceRefresh = false,
  }) async {
    return call(
      GetLocationAnalyticsParams.custom(
        locationCode: locationCode,
        startDate: startDate,
        endDate: endDate,
        includeTrends: includeTrends,
        forceRefresh: forceRefresh,
      ),
    );
  }

  bool _isValidPeriod(String period) {
    const validPeriods = ['Q1', 'Q2', 'Q3', 'Q4', '1Y', 'custom'];
    return validPeriods.contains(period);
  }
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
