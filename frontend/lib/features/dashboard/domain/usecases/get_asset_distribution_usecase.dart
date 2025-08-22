// Path: frontend/lib/features/dashboard/domain/usecases/get_asset_distribution_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/asset_distribution.dart';
import '../repositories/dashboard_repository.dart';

class GetAssetDistributionUseCase {
  final DashboardRepository repository;

  GetAssetDistributionUseCase(this.repository);

  /// Execute the use case to get asset distribution by department
  ///
  /// [params] contains optional plant filter
  /// Returns [AssetDistribution] on success or [Failure] on error
  Future<Either<Failure, AssetDistribution>> call(
    GetAssetDistributionParams params,
  ) async {
    // Validate plant code if provided
    if (params.plantCode != null && !_isValidPlantCode(params.plantCode!)) {
      return const Left(ValidationFailure(['Invalid plant code format']));
    }

    return await repository.getAssetDistribution(
      params.plantCode,
      params.deptCode,
    );
  }

  /// Validate plant code format
  bool _isValidPlantCode(String plantCode) {
    // Plant code should be alphanumeric with hyphens and underscores
    final plantCodeRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    return plantCodeRegex.hasMatch(plantCode) && plantCode.length <= 50;
  }
}

class GetAssetDistributionParams {
  final String? plantCode;
  final String? deptCode;

  const GetAssetDistributionParams({this.plantCode, this.deptCode});

  /// Factory constructor for all plants
  factory GetAssetDistributionParams.all() {
    return const GetAssetDistributionParams(plantCode: null);
  }

  /// Factory constructor for specific plant
  factory GetAssetDistributionParams.forPlant(String plantCode) {
    return GetAssetDistributionParams(plantCode: plantCode);
  }

  /// Check if filtering by specific plant
  bool get isFiltered => plantCode != null && plantCode!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetAssetDistributionParams && other.plantCode == plantCode;
  }

  @override
  int get hashCode => plantCode.hashCode;

  @override
  String toString() => 'GetAssetDistributionParams(plantCode: $plantCode)';
}
