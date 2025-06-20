// Path: frontend/lib/features/dashboard/domain/usecases/get_locations_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dashboard_repository.dart';

class GetLocationsUseCase {
  final DashboardRepository repository;

  GetLocationsUseCase(this.repository);

  /// Execute the use case to get locations list
  ///
  /// [params] contains optional plant filter
  /// Returns [List<Map<String, String>>] on success or [Failure] on error
  Future<Either<Failure, List<Map<String, String>>>> call(
    GetLocationsParams params,
  ) async {
    // Validate plant code if provided
    if (params.plantCode != null && !_isValidPlantCode(params.plantCode!)) {
      return Left(ValidationFailure(['Invalid plant code format']));
    }

    return await repository.getLocations(plantCode: params.plantCode);
  }

  /// Validate plant code format
  bool _isValidPlantCode(String plantCode) {
    // Plant code should be alphanumeric with hyphens and underscores
    final plantCodeRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    return plantCodeRegex.hasMatch(plantCode) && plantCode.length <= 50;
  }
}

class GetLocationsParams {
  final String? plantCode;

  const GetLocationsParams({this.plantCode});

  /// Factory constructor for all locations
  factory GetLocationsParams.all() {
    return const GetLocationsParams(plantCode: null);
  }

  /// Factory constructor for specific plant
  factory GetLocationsParams.forPlant(String plantCode) {
    return GetLocationsParams(plantCode: plantCode);
  }

  /// Check if filtering by specific plant
  bool get isFiltered => plantCode != null && plantCode!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetLocationsParams && other.plantCode == plantCode;
  }

  @override
  int get hashCode => plantCode.hashCode;

  @override
  String toString() => 'GetLocationsParams(plantCode: $plantCode)';
}
