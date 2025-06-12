// Path: frontend/lib/features/dashboard/data/models/alert_model.dart
import '../../domain/entities/alert.dart';

class AlertModel {
  final String id;
  final String type;
  final String message;
  final String severity;
  final int count;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.count,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'info',
      count: json['count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'severity': severity,
      'count': count,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Alert toEntity() {
    return Alert(
      id: id,
      type: type,
      message: message,
      severity: severity,
      count: count,
      createdAt: createdAt,
    );
  }

  // Helper methods for UI
  bool get isError => severity == 'error';
  bool get isWarning => severity == 'warning';
  bool get isInfo => severity == 'info';

  String get severityLabel {
    switch (severity) {
      case 'error':
        return 'Error';
      case 'warning':
        return 'Warning';
      case 'info':
        return 'Info';
      default:
        return 'Unknown';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'export':
        return 'Export';
      case 'asset':
        return 'Asset';
      case 'scan':
        return 'Scan';
      case 'data_quality':
        return 'Data Quality';
      case 'system':
        return 'System';
      default:
        return 'General';
    }
  }
}
