// Path: frontend/lib/features/dashboard/domain/entities/chart_data.dart
class ChartData {
  final String label;
  final double value;
  final String? color;
  final String? date;

  const ChartData({
    required this.label,
    required this.value,
    this.color,
    this.date,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartData &&
        other.label == label &&
        other.value == value &&
        other.color == color &&
        other.date == date;
  }

  @override
  int get hashCode {
    return label.hashCode ^ value.hashCode ^ color.hashCode ^ date.hashCode;
  }

  @override
  String toString() {
    return 'ChartData(label: $label, value: $value, color: $color, date: $date)';
  }
}
