import 'package:equatable/equatable.dart';

class AssetsByPlant extends Equatable {
  final List<PlantAssetData> plants;
  final PlantSummary summary;

  const AssetsByPlant({
    required this.plants,
    required this.summary,
  });

  bool get hasData => plants.isNotEmpty && summary.totalAssets > 0;

  List<PlantAssetData> get sortedByAssetCount =>
      [...plants]..sort((a, b) => b.assetCount.compareTo(a.assetCount));

  PlantAssetData? get largestPlant =>
      plants.isNotEmpty ? sortedByAssetCount.first : null;

  PlantAssetData? get smallestPlant =>
      plants.isNotEmpty ? sortedByAssetCount.last : null;

  @override
  List<Object> get props => [plants, summary];
}

class PlantAssetData extends Equatable {
  final String plantCode;
  final String plantName;
  final int assetCount;

  const PlantAssetData({
    required this.plantCode,
    required this.plantName,
    required this.assetCount,
  });

  bool get hasAssets => assetCount > 0;
  String get displayName => plantName.isNotEmpty ? plantName : plantCode;

  @override
  List<Object> get props => [plantCode, plantName, assetCount];
}

class PlantSummary extends Equatable {
  final int totalAssets;
  final int totalPlants;
  final LargestPlant? largestPlant;

  const PlantSummary({
    required this.totalAssets,
    required this.totalPlants,
    this.largestPlant,
  });

  double get averageAssetsPerPlant =>
      totalPlants > 0 ? totalAssets / totalPlants : 0;

  @override
  List<Object?> get props => [totalAssets, totalPlants, largestPlant];
}

class LargestPlant extends Equatable {
  final String plantCode;
  final String plantName;
  final int assetCount;

  const LargestPlant({
    required this.plantCode,
    required this.plantName,
    required this.assetCount,
  });

  String get displayName => plantName.isNotEmpty ? plantName : plantCode;

  @override
  List<Object> get props => [plantCode, plantName, assetCount];
}
