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

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.categoryCode,
    required super.categoryName,
    super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryCode: json['category_code'] ?? '',
      categoryName: json['category_name'] ?? '',
      description: json['description'],
    );
  }
}

class BrandModel extends BrandEntity {
  const BrandModel({
    required super.brandCode,
    required super.brandName,
    super.description,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      brandCode: json['brand_code'] ?? '',
      brandName: json['brand_name'] ?? '',
      description: json['description'],
    );
  }
}

class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.deptCode,
    required super.description,
    super.plantCode,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      deptCode: json['dept_code'] ?? '',
      description: json['description'] ?? '',
      plantCode: json['plant_code'],
    );
  }
}

class CreateAssetRequestModel {
  final CreateAssetRequest request;

  const CreateAssetRequestModel(this.request);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'asset_no': request.assetNo,
      'epc_code': request.epcCode,
      'description': request.description,
      'plant_code': request.plantCode,
      'location_code': request.locationCode,
      'unit_code': request.unitCode,
      'created_by': request.createdBy,
      'category_code': request.categoryCode,
      'brand_code': request.brandCode,
    };

    if (request.deptCode != null) json['dept_code'] = request.deptCode;
    if (request.serialNo != null) json['serial_no'] = request.serialNo;
    if (request.inventoryNo != null) json['inventory_no'] = request.inventoryNo;
    if (request.quantity != null) json['quantity'] = request.quantity;

    return json;
  }
}
