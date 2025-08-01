// Path: lib/features/scan/domain/usecases/get_master_data_usecase.dart
import '../entities/master_data_entity.dart';
import '../repositories/scan_repository.dart';

class GetMasterDataUseCase {
  final ScanRepository repository;

  GetMasterDataUseCase(this.repository);

  Future<List<PlantEntity>> getPlants() async {
    return await repository.getPlants();
  }

  Future<List<LocationEntity>> getLocationsByPlant(String plantCode) async {
    return await repository.getLocationsByPlant(plantCode);
  }

  Future<List<UnitEntity>> getUnits() async {
    return await repository.getUnits();
  }

  Future<List<DepartmentEntity>> getDepartments() async {
    return await repository.getDepartments();
  }
  Future<List<CategoryEntity>> getCategories() async {
    return await repository.getCategories();
  }

  Future<List<BrandEntity>> getBrands() async {
    return await repository.getBrands();
  }
}
