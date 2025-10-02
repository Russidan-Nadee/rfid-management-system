import '../../domain/entities/assets_by_plant.dart';

class AssetsByPlantModel {
  final List<PlantAssetDataModel> plants;
  final PlantSummaryModel summary;

  const AssetsByPlantModel({
    required this.plants,
    required this.summary,
  });

  factory AssetsByPlantModel.fromJson(Map<String, dynamic> json) {
    return AssetsByPlantModel(
      plants: (json['plants'] as List<dynamic>?)
              ?.map((e) => PlantAssetDataModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: PlantSummaryModel.fromJson(json['summary'] ?? {}),
    );
  }

  AssetsByPlant toEntity() {
    return AssetsByPlant(
      plants: plants.map((p) => p.toEntity()).toList(),
      summary: summary.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plants': plants.map((p) => p.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}

class PlantAssetDataModel {
  final String plantCode;
  final String plantName;
  final int assetCount;

  const PlantAssetDataModel({
    required this.plantCode,
    required this.plantName,
    required this.assetCount,
  });

  factory PlantAssetDataModel.fromJson(Map<String, dynamic> json) {
    return PlantAssetDataModel(
      plantCode: json['plant_code'] ?? '',
      plantName: json['plant_name'] ?? '',
      assetCount: json['asset_count'] ?? 0,
    );
  }

  PlantAssetData toEntity() {
    return PlantAssetData(
      plantCode: plantCode,
      plantName: plantName,
      assetCount: assetCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plant_code': plantCode,
      'plant_name': plantName,
      'asset_count': assetCount,
    };
  }
}

class PlantSummaryModel {
  final int totalAssets;
  final int totalPlants;
  final LargestPlantModel? largestPlant;

  const PlantSummaryModel({
    required this.totalAssets,
    required this.totalPlants,
    this.largestPlant,
  });

  factory PlantSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlantSummaryModel(
      totalAssets: json['total_assets'] ?? 0,
      totalPlants: json['total_plants'] ?? 0,
      largestPlant: json['largest_plant'] != null
          ? LargestPlantModel.fromJson(json['largest_plant'])
          : null,
    );
  }

  PlantSummary toEntity() {
    return PlantSummary(
      totalAssets: totalAssets,
      totalPlants: totalPlants,
      largestPlant: largestPlant?.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_assets': totalAssets,
      'total_plants': totalPlants,
      'largest_plant': largestPlant?.toJson(),
    };
  }
}

class LargestPlantModel {
  final String plantCode;
  final String plantName;
  final int assetCount;

  const LargestPlantModel({
    required this.plantCode,
    required this.plantName,
    required this.assetCount,
  });

  factory LargestPlantModel.fromJson(Map<String, dynamic> json) {
    return LargestPlantModel(
      plantCode: json['plant_code'] ?? '',
      plantName: json['plant_name'] ?? '',
      assetCount: json['asset_count'] ?? 0,
    );
  }

  LargestPlant toEntity() {
    return LargestPlant(
      plantCode: plantCode,
      plantName: plantName,
      assetCount: assetCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plant_code': plantCode,
      'plant_name': plantName,
      'asset_count': assetCount,
    };
  }
}
