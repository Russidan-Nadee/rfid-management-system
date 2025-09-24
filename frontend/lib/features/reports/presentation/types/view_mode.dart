enum ViewMode {
  card,
  table
}

extension ViewModeExtension on ViewMode {
  String get displayName {
    switch (this) {
      case ViewMode.card:
        return 'Card View';
      case ViewMode.table:
        return 'Table View';
    }
  }

  bool get isCard => this == ViewMode.card;
  bool get isTable => this == ViewMode.table;
}