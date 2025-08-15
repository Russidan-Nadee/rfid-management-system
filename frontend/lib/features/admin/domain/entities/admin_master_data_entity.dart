import 'package:equatable/equatable.dart';

class AdminPlantEntity extends Equatable {
  final String plantCode;
  final String description;

  const AdminPlantEntity({
    required this.plantCode,
    required this.description,
  });

  @override
  List<Object> get props => [plantCode, description];

  @override
  String toString() => '$plantCode - $description';
}

class AdminLocationEntity extends Equatable {
  final String locationCode;
  final String description;
  final String plantCode;

  const AdminLocationEntity({
    required this.locationCode,
    required this.description,
    required this.plantCode,
  });

  @override
  List<Object> get props => [locationCode, description, plantCode];

  @override
  String toString() => '$locationCode - $description';
}

class AdminDepartmentEntity extends Equatable {
  final String deptCode;
  final String description;
  final String? plantCode;

  const AdminDepartmentEntity({
    required this.deptCode,
    required this.description,
    this.plantCode,
  });

  @override
  List<Object?> get props => [deptCode, description, plantCode];

  @override
  String toString() => '$deptCode - $description';
}