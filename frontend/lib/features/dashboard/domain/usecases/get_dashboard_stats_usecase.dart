// Path: frontend/lib/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  /// Execute the use case to get dashboard statistics
  ///
  /// [params] contains the period for data retrieval
  /// Returns [DashboardStats] on success or [Failure] on error
  Future<Either<Failure, DashboardStats>> call(
    GetDashboardStatsParams params,
  ) async {
    // Validate period parameter
    if (!_isValidPeriod(params.period)) {
      return const Left(
        ValidationFailure(['Invalid period. Must be today, 7d, or 30d']),
      );
    }

    return await repository.getDashboardStats(params.period);
  }

  /// Validate if the period parameter is valid
  bool _isValidPeriod(String period) {
    const validPeriods = ['today', '7d', '30d'];
    return validPeriods.contains(period);
  }
}

class GetDashboardStatsParams {
  final String period;

  const GetDashboardStatsParams({required this.period});

  /// Factory constructor for today's stats
  factory GetDashboardStatsParams.today() {
    return const GetDashboardStatsParams(period: 'today');
  }

  /// Factory constructor for 7 days stats
  factory GetDashboardStatsParams.sevenDays() {
    return const GetDashboardStatsParams(period: '7d');
  }

  /// Factory constructor for 30 days stats
  factory GetDashboardStatsParams.thirtyDays() {
    return const GetDashboardStatsParams(period: '30d');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetDashboardStatsParams && other.period == period;
  }

  @override
  int get hashCode => period.hashCode;

  @override
  String toString() => 'GetDashboardStatsParams(period: $period)';
}
