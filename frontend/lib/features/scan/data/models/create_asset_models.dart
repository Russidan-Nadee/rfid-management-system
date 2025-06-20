// Path: lib/features/scan/data/models/create_asset_models.dart
import '../../domain/entities/master_data_entity.dart';

class PlantModel extends PlantEntity {
  const PlantModel({required super.plantCode, required super.description});

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      plantCode: json['plant_code'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.locationCode,
    required super.description,
    required super.plantCode,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      locationCode: json['location_code'] ?? '',
      description: json['description'] ?? '',
      plantCode: json['plant_code'] ?? '',
    );
  }
}

class UnitModel extends UnitEntity {
  const UnitModel({required super.unitCode, required super.name});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      unitCode: json['unit_code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CreateAssetRequestModel {
  final CreateAssetRequest request;

  const CreateAssetRequestModel(this.request);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'asset_no': request.assetNo,
      'description': request.description,
      'plant_code': request.plantCode,
      'location_code': request.locationCode,
      'unit_code': request.unitCode,
      'created_by': request.createdBy,
    };

    if (request.serialNo != null) json['serial_no'] = request.serialNo;
    if (request.inventoryNo != null) json['inventory_no'] = request.inventoryNo;
    if (request.quantity != null) json['quantity'] = request.quantity;

    return json;
  }
}
