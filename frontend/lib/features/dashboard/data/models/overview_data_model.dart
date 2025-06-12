// Path: frontend/lib/features/dashboard/data/models/overview_data_model.dart
import 'package:frontend/features/dashboard/data/models/charts_model.dart';

import '../../domain/entities/overview_data.dart';

class OverviewDataModel {
  final OverviewModel overview;
  final DateTime lastUpdated;

  OverviewDataModel({required this.overview, required this.lastUpdated});

  factory OverviewDataModel.fromJson(Map<String, dynamic> json) {
    return OverviewDataModel(
      overview: OverviewModel.fromJson(json['overview'] ?? {}),
      lastUpdated:
          DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overview': overview.toJson(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  OverviewData toEntity() {
    return OverviewData(
      overview: overview.toEntity(),
      lastUpdated: lastUpdated,
    );
  }
}
