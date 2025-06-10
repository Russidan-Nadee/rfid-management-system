// Path: frontend/lib/features/search/domain/entities/search_filter_entity.dart
import 'package:equatable/equatable.dart';

/// Search filter entity for advanced search options
class SearchFilterEntity extends Equatable {
  final List<String>? plantCodes;
  final List<String>? locationCodes;
  final List<String>? unitCodes;
  final List<String>? status;
  final List<String>? roles;
  final DateRangeFilterEntity? dateRange;
  final List<String>? createdBy;
  final Map<String, dynamic>? customFilters;

  const SearchFilterEntity({
    this.plantCodes,
    this.locationCodes,
    this.unitCodes,
    this.status,
    this.roles,
    this.dateRange,
    this.createdBy,
    this.customFilters,
  });

  /// Factory constructors for common filter scenarios
  factory SearchFilterEntity.empty() {
    return const SearchFilterEntity();
  }

  factory SearchFilterEntity.forAssets({
    List<String>? plantCodes,
    List<String>? locationCodes,
    List<String>? status,
    DateRangeFilterEntity? dateRange,
  }) {
    return SearchFilterEntity(
      plantCodes: plantCodes,
      locationCodes: locationCodes,
      status: status,
      dateRange: dateRange,
    );
  }

  factory SearchFilterEntity.forUsers({
    List<String>? roles,
    DateRangeFilterEntity? dateRange,
  }) {
    return SearchFilterEntity(roles: roles, dateRange: dateRange);
  }

  factory SearchFilterEntity.byPlant(String plantCode) {
    return SearchFilterEntity(plantCodes: [plantCode]);
  }

  factory SearchFilterEntity.byLocation(String locationCode) {
    return SearchFilterEntity(locationCodes: [locationCode]);
  }

  factory SearchFilterEntity.byStatus(List<String> status) {
    return SearchFilterEntity(status: status);
  }

  /// Business logic methods

  /// Check if any filters are applied
  bool get hasFilters {
    return (plantCodes?.isNotEmpty ?? false) ||
        (locationCodes?.isNotEmpty ?? false) ||
        (unitCodes?.isNotEmpty ?? false) ||
        (status?.isNotEmpty ?? false) ||
        (roles?.isNotEmpty ?? false) ||
        dateRange != null ||
        (createdBy?.isNotEmpty ?? false) ||
        (customFilters?.isNotEmpty ?? false);
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (plantCodes?.isNotEmpty ?? false) count++;
    if (locationCodes?.isNotEmpty ?? false) count++;
    if (unitCodes?.isNotEmpty ?? false) count++;
    if (status?.isNotEmpty ?? false) count++;
    if (roles?.isNotEmpty ?? false) count++;
    if (dateRange != null) count++;
    if (createdBy?.isNotEmpty ?? false) count++;
    if (customFilters?.isNotEmpty ?? false) count += customFilters!.length;
    return count;
  }

  /// Check if filter is applicable to specific entity type
  bool isApplicableToEntity(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'assets':
        return plantCodes != null ||
            locationCodes != null ||
            unitCodes != null ||
            status != null ||
            dateRange != null ||
            createdBy != null;
      case 'plants':
        return dateRange != null;
      case 'locations':
        return plantCodes != null || dateRange != null;
      case 'users':
        return roles != null || dateRange != null || createdBy != null;
      default:
        return hasFilters;
    }
  }

  /// Get filter summary text
  String get filterSummary {
    if (!hasFilters) return 'No filters applied';

    final filters = <String>[];

    if (plantCodes?.isNotEmpty ?? false) {
      filters.add(
        '${plantCodes!.length} plant${plantCodes!.length > 1 ? 's' : ''}',
      );
    }

    if (locationCodes?.isNotEmpty ?? false) {
      filters.add(
        '${locationCodes!.length} location${locationCodes!.length > 1 ? 's' : ''}',
      );
    }

    if (status?.isNotEmpty ?? false) {
      filters.add('${status!.length} status');
    }

    if (roles?.isNotEmpty ?? false) {
      filters.add('${roles!.length} role${roles!.length > 1 ? 's' : ''}');
    }

    if (dateRange != null) {
      filters.add('date range');
    }

    if (createdBy?.isNotEmpty ?? false) {
      filters.add(
        '${createdBy!.length} creator${createdBy!.length > 1 ? 's' : ''}',
      );
    }

    if (customFilters?.isNotEmpty ?? false) {
      filters.add(
        '${customFilters!.length} custom filter${customFilters!.length > 1 ? 's' : ''}',
      );
    }

    if (filters.isEmpty) return 'No filters applied';
    if (filters.length == 1) return filters.first;
    if (filters.length == 2) return '${filters[0]} and ${filters[1]}';

    return '${filters.take(filters.length - 1).join(', ')}, and ${filters.last}';
  }

  /// Get active filter labels for display
  List<FilterLabel> get activeFilterLabels {
    final labels = <FilterLabel>[];

    if (plantCodes?.isNotEmpty ?? false) {
      for (final code in plantCodes!) {
        labels.add(
          FilterLabel(
            key: 'plant',
            value: code,
            label: 'Plant: $code',
            removable: true,
          ),
        );
      }
    }

    if (locationCodes?.isNotEmpty ?? false) {
      for (final code in locationCodes!) {
        labels.add(
          FilterLabel(
            key: 'location',
            value: code,
            label: 'Location: $code',
            removable: true,
          ),
        );
      }
    }

    if (status?.isNotEmpty ?? false) {
      for (final statusValue in status!) {
        labels.add(
          FilterLabel(
            key: 'status',
            value: statusValue,
            label: 'Status: ${_getStatusLabel(statusValue)}',
            removable: true,
          ),
        );
      }
    }

    if (roles?.isNotEmpty ?? false) {
      for (final role in roles!) {
        labels.add(
          FilterLabel(
            key: 'role',
            value: role,
            label: 'Role: ${_getRoleLabel(role)}',
            removable: true,
          ),
        );
      }
    }

    if (dateRange != null) {
      labels.add(
        FilterLabel(
          key: 'dateRange',
          value: 'dateRange',
          label: 'Date: ${dateRange!.description}',
          removable: true,
        ),
      );
    }

    return labels;
  }

  /// Remove specific filter
  SearchFilterEntity removeFilter(String key, String? value) {
    switch (key.toLowerCase()) {
      case 'plant':
        final updatedPlants = List<String>.from(plantCodes ?? []);
        if (value != null) updatedPlants.remove(value);
        return copyWith(
          plantCodes: updatedPlants.isEmpty ? null : updatedPlants,
        );

      case 'location':
        final updatedLocations = List<String>.from(locationCodes ?? []);
        if (value != null) updatedLocations.remove(value);
        return copyWith(
          locationCodes: updatedLocations.isEmpty ? null : updatedLocations,
        );

      case 'status':
        final updatedStatus = List<String>.from(status ?? []);
        if (value != null) updatedStatus.remove(value);
        return copyWith(status: updatedStatus.isEmpty ? null : updatedStatus);

      case 'role':
        final updatedRoles = List<String>.from(roles ?? []);
        if (value != null) updatedRoles.remove(value);
        return copyWith(roles: updatedRoles.isEmpty ? null : updatedRoles);

      case 'daterange':
        return copyWith(dateRange: null);

      default:
        return this;
    }
  }

  /// Clear all filters
  SearchFilterEntity clearAll() {
    return const SearchFilterEntity();
  }

  /// Add filter value
  SearchFilterEntity addFilter(String key, String value) {
    switch (key.toLowerCase()) {
      case 'plant':
        final updatedPlants = List<String>.from(plantCodes ?? []);
        if (!updatedPlants.contains(value)) updatedPlants.add(value);
        return copyWith(plantCodes: updatedPlants);

      case 'location':
        final updatedLocations = List<String>.from(locationCodes ?? []);
        if (!updatedLocations.contains(value)) updatedLocations.add(value);
        return copyWith(locationCodes: updatedLocations);

      case 'status':
        final updatedStatus = List<String>.from(status ?? []);
        if (!updatedStatus.contains(value)) updatedStatus.add(value);
        return copyWith(status: updatedStatus);

      case 'role':
        final updatedRoles = List<String>.from(roles ?? []);
        if (!updatedRoles.contains(value)) updatedRoles.add(value);
        return copyWith(roles: updatedRoles);

      default:
        return this;
    }
  }

  /// Merge with another filter
  SearchFilterEntity merge(SearchFilterEntity other) {
    return SearchFilterEntity(
      plantCodes: _mergeStringLists(plantCodes, other.plantCodes),
      locationCodes: _mergeStringLists(locationCodes, other.locationCodes),
      unitCodes: _mergeStringLists(unitCodes, other.unitCodes),
      status: _mergeStringLists(status, other.status),
      roles: _mergeStringLists(roles, other.roles),
      dateRange: other.dateRange ?? dateRange,
      createdBy: _mergeStringLists(createdBy, other.createdBy),
      customFilters: _mergeMaps(customFilters, other.customFilters),
    );
  }

  /// Create copy with updated fields
  SearchFilterEntity copyWith({
    List<String>? plantCodes,
    List<String>? locationCodes,
    List<String>? unitCodes,
    List<String>? status,
    List<String>? roles,
    DateRangeFilterEntity? dateRange,
    List<String>? createdBy,
    Map<String, dynamic>? customFilters,
  }) {
    return SearchFilterEntity(
      plantCodes: plantCodes ?? this.plantCodes,
      locationCodes: locationCodes ?? this.locationCodes,
      unitCodes: unitCodes ?? this.unitCodes,
      status: status ?? this.status,
      roles: roles ?? this.roles,
      dateRange: dateRange ?? this.dateRange,
      createdBy: createdBy ?? this.createdBy,
      customFilters: customFilters ?? this.customFilters,
    );
  }

  /// Private helper methods
  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return 'Active';
      case 'C':
        return 'Created';
      case 'I':
        return 'Inactive';
      default:
        return status;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'user':
        return 'User';
      default:
        return role;
    }
  }

  List<String>? _mergeStringLists(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return null;
    final merged = <String>{};
    if (list1 != null) merged.addAll(list1);
    if (list2 != null) merged.addAll(list2);
    return merged.toList();
  }

  Map<String, dynamic>? _mergeMaps(
    Map<String, dynamic>? map1,
    Map<String, dynamic>? map2,
  ) {
    if (map1 == null && map2 == null) return null;
    final merged = <String, dynamic>{};
    if (map1 != null) merged.addAll(map1);
    if (map2 != null) merged.addAll(map2);
    return merged;
  }

  @override
  List<Object?> get props => [
    plantCodes,
    locationCodes,
    unitCodes,
    status,
    roles,
    dateRange,
    createdBy,
    customFilters,
  ];

  @override
  String toString() {
    return 'SearchFilterEntity(activeFilters: $activeFilterCount, hasFilters: $hasFilters)';
  }
}

/// Date range filter entity
class DateRangeFilterEntity extends Equatable {
  final DateTime? from;
  final DateTime? to;
  final String? preset;

  const DateRangeFilterEntity({this.from, this.to, this.preset});

  /// Factory constructors for common date ranges
  factory DateRangeFilterEntity.today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return DateRangeFilterEntity(
      from: startOfDay,
      to: endOfDay,
      preset: 'today',
    );
  }

  factory DateRangeFilterEntity.thisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return DateRangeFilterEntity(
      from: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      to: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
      preset: 'thisweek',
    );
  }

  factory DateRangeFilterEntity.thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return DateRangeFilterEntity(
      from: startOfMonth,
      to: endOfMonth,
      preset: 'thismonth',
    );
  }

  factory DateRangeFilterEntity.lastDays(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    return DateRangeFilterEntity(
      from: DateTime(startDate.year, startDate.month, startDate.day),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59),
      preset: 'last${days}days',
    );
  }

  factory DateRangeFilterEntity.custom({
    required DateTime from,
    required DateTime to,
  }) {
    return DateRangeFilterEntity(from: from, to: to, preset: 'custom');
  }

  /// Business logic methods
  bool get isValid {
    if (from == null && to == null) return false;
    if (from != null && to != null) {
      return from!.isBefore(to!) || from!.isAtSameMomentAs(to!);
    }
    return true;
  }

  bool get isToday {
    if (preset == 'today') return true;
    if (from == null || to == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return from!.isAtSameMomentAs(today) && to!.isBefore(tomorrow);
  }

  bool get isThisWeek => preset == 'thisweek';
  bool get isThisMonth => preset == 'thismonth';
  bool get isCustom =>
      preset == 'custom' || (preset == null && from != null && to != null);

  /// Get human readable description
  String get description {
    if (preset != null) {
      switch (preset!.toLowerCase()) {
        case 'today':
          return 'Today';
        case 'thisweek':
          return 'This Week';
        case 'thismonth':
          return 'This Month';
        case 'last7days':
          return 'Last 7 Days';
        case 'last30days':
          return 'Last 30 Days';
        default:
          if (preset!.startsWith('last') && preset!.endsWith('days')) {
            final days = preset!.replaceAll(RegExp(r'[^\d]'), '');
            return 'Last $days Days';
          }
          return preset!;
      }
    }

    if (from != null && to != null) {
      return '${_formatDate(from!)} - ${_formatDate(to!)}';
    } else if (from != null) {
      return 'From ${_formatDate(from!)}';
    } else if (to != null) {
      return 'Until ${_formatDate(to!)}';
    }

    return 'No date range';
  }

  /// Get short description for chips
  String get shortDescription {
    if (preset != null) {
      switch (preset!.toLowerCase()) {
        case 'today':
          return 'Today';
        case 'thisweek':
          return 'This week';
        case 'thismonth':
          return 'This month';
        case 'last7days':
          return '7 days';
        case 'last30days':
          return '30 days';
        default:
          return preset!;
      }
    }
    return description;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  List<Object?> get props => [from, to, preset];

  @override
  String toString() {
    return 'DateRangeFilterEntity($description)';
  }
}

/// Filter label for UI display
class FilterLabel extends Equatable {
  final String key;
  final String value;
  final String label;
  final bool removable;
  final String? color;

  const FilterLabel({
    required this.key,
    required this.value,
    required this.label,
    this.removable = true,
    this.color,
  });

  @override
  List<Object?> get props => [key, value, label, removable, color];

  @override
  String toString() {
    return 'FilterLabel(key: $key, label: $label)';
  }
}
