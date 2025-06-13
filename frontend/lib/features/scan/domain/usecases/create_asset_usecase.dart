// Path: lib/features/scan/domain/usecases/create_asset_usecase.dart
import '../entities/master_data_entity.dart';
import '../entities/scanned_item_entity.dart';
import '../repositories/scan_repository.dart';

class CreateAssetUseCase {
  final ScanRepository repository;

  CreateAssetUseCase(this.repository);

  Future<ScannedItemEntity> execute(CreateAssetRequest request) async {
    return await repository.createAsset(request);
  }
}
