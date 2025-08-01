// Path: lib/features/scan/domain/entities/master_data_entity.dart
import 'package:equatable/equatable.dart';

class PlantEntity extends Equatable {
  final String plantCode;
  final String description;

  const PlantEntity({required this.plantCode, required this.description});

  @override
  List<Object> get props => [plantCode, description];

  @override
  String toString() => '$plantCode - $description';
}

class LocationEntity extends Equatable {
  final String locationCode;
  final String description;
  final String plantCode;

  const LocationEntity({
    required this.locationCode,
    required this.description,
    required this.plantCode,
  });

  @override
  List<Object> get props => [locationCode, description, plantCode];

  @override
  String toString() => '$locationCode - $description';
}

class UnitEntity extends Equatable {
  final String unitCode;
  final String name;

  const UnitEntity({required this.unitCode, required this.name});

  @override
  List<Object> get props => [unitCode, name];

  @override
  String toString() => '$unitCode - $name';
}

class CategoryEntity extends Equatable {
  final String categoryCode;
  final String categoryName;
  final String? description;

  const CategoryEntity({
    required this.categoryCode,
    required this.categoryName,
    this.description,
  });

  @override
  List<Object?> get props => [categoryCode, categoryName, description];

  @override
  String toString() => '$categoryCode - $categoryName';
}

class BrandEntity extends Equatable {
  final String brandCode;
  final String brandName;
  final String? description;

  const BrandEntity({
    required this.brandCode,
    required this.brandName,
    this.description,
  });

  @override
  List<Object?> get props => [brandCode, brandName, description];

  @override
  String toString() => '$brandCode - $brandName';
}

class DepartmentEntity extends Equatable {
  final String deptCode;
  final String description;
  final String? plantCode;

  const DepartmentEntity({
    required this.deptCode,
    required this.description,
    this.plantCode,
  });

  @override
  List<Object?> get props => [deptCode, description, plantCode];

  @override
  String toString() => '$deptCode - $description';
}

class CreateAssetRequest extends Equatable {
  final String assetNo;
  final String epcCode;
  final String description;
  final String plantCode;
  final String locationCode;
  final String unitCode;
  final String? deptCode;
  final String? serialNo;
  final String? inventoryNo;
  final double? quantity;
  final String createdBy;
  final String categoryCode;
  final String brandCode;

  const CreateAssetRequest({
    required this.assetNo,
    required this.epcCode,
    required this.description,
    required this.plantCode,
    required this.locationCode,
    required this.unitCode,
    this.deptCode,
    this.serialNo,
    this.inventoryNo,
    this.quantity,
    required this.createdBy,
    required this.categoryCode,
    required this.brandCode,
  });

  @override
  List<Object?> get props => [
    assetNo,
    epcCode,
    description,
    plantCode,
    locationCode,
    unitCode,
    deptCode,
    serialNo,
    inventoryNo,
    quantity,
    createdBy,
    categoryCode,
    brandCode,
  ];
}
