// Path: frontend/lib/features/search/data/models/search_filter_model.dart
import 'package:equatable/equatable.dart';

/// Search filter model for advanced search options
class SearchFilterModel extends Equatable {
  final List<String>? plantCodes;
  final List<String>? locationCodes;
  final List<String>? unitCodes;
  final List<String>? status;
  final List<String>? roles;
  final DateRangeFilter? dateRange;
  final List<String>? createdBy;
  final Map<String, dynamic>? customFilters;

  const SearchFilterModel({
    this.plantCodes,
    this.locationCodes,
    this.unitCodes,
    this.status,
    this.roles,
    this.dateRange,
    this.createdBy,
    this.customFilters,
  });

  factory SearchFilterModel.fromJson(Map<String, dynamic> json) {
    return SearchFilterModel(
      plantCodes: json['plant_codes'] != null
          ? List<String>.from(json['plant_codes'])
          : null,
      locationCodes: json['location_codes'] != null
          ? List<String>.from(json['location_codes'])
          : null,
      unitCodes: json['unit_codes'] != null
          ? List<String>.from(json['unit_codes'])
          : null,
      status: json['status'] != null ? List<String>.from(json['status']) : null,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      dateRange: json['date_range'] != null
          ? DateRangeFilter.fromJson(json['date_range'])
          : null,
      createdBy: json['created_by'] != null
          ? List<String>.from(json['created_by'])
          : null,
      customFilters: json['custom_filters'] != null
          ? Map<String, dynamic>.from(json['custom_filters'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (plantCodes != null && plantCodes!.isNotEmpty) {
      data['plant_codes'] = plantCodes;
    }
    if (locationCodes != null && locationCodes!.isNotEmpty) {
      data['location_codes'] = locationCodes;
    }
    if (unitCodes != null && unitCodes!.isNotEmpty) {
      data['unit_codes'] = unitCodes;
    }
    if (status != null && status!.isNotEmpty) {
      data['status'] = status;
    }
    if (roles != null && roles!.isNotEmpty) {
      data['roles'] = roles;
    }
    if (dateRange != null) {
      data['date_range'] = dateRange!.toJson();
    }
    if (createdBy != null && createdBy!.isNotEmpty) {
      data['created_by'] = createdBy;
    }
    if (customFilters != null && customFilters!.isNotEmpty) {
      data['custom_filters'] = customFilters;
    }

    return data;
  }

  SearchFilterModel copyWith({
    List<String>? plantCodes,
    List<String>? locationCodes,
    List<String>? unitCodes,
    List<String>? status,
    List<String>? roles,
    DateRangeFilter? dateRange,
    List<String>? createdBy,
    Map<String, dynamic>? customFilters,
  }) {
    return SearchFilterModel(
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

  /// Clear all filters
  SearchFilterModel clearAll() {
    return const SearchFilterModel();
  }

  /// Clear specific filter
  SearchFilterModel clearFilter(String filterType) {
    switch (filterType.toLowerCase()) {
      case 'plant':
      case 'plants':
        return copyWith(plantCodes: []);
      case 'location':
      case 'locations':
        return copyWith(locationCodes: []);
      case 'unit':
      case 'units':
        return copyWith(unitCodes: []);
      case 'status':
        return copyWith(status: []);
      case 'role':
      case 'roles':
        return copyWith(roles: []);
      case 'date':
      case 'daterange':
        return copyWith(dateRange: null);
      case 'createdby':
        return copyWith(createdBy: []);
      default:
        return this;
    }
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
    return 'SearchFilterModel(activeFilters: $activeFilterCount, hasFilters: $hasFilters)';
  }
}

/// Date range filter for searching by date
class DateRangeFilter extends Equatable {
  final DateTime? from;
  final DateTime? to;
  final String? preset;

  const DateRangeFilter({this.from, this.to, this.preset});

  factory DateRangeFilter.fromJson(Map<String, dynamic> json) {
    return DateRangeFilter(
      from: json['from'] != null ? DateTime.tryParse(json['from']) : null,
      to: json['to'] != null ? DateTime.tryParse(json['to']) : null,
      preset: json['preset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (from != null) 'from': from!.toIso8601String(),
      if (to != null) 'to': to!.toIso8601String(),
      if (preset != null) 'preset': preset,
    };
  }

  DateRangeFilter copyWith({DateTime? from, DateTime? to, String? preset}) {
    return DateRangeFilter(
      from: from ?? this.from,
      to: to ?? this.to,
      preset: preset ?? this.preset,
    );
  }

  /// Create preset date ranges
  factory DateRangeFilter.today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return DateRangeFilter(from: startOfDay, to: endOfDay, preset: 'today');
  }

  factory DateRangeFilter.thisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return DateRangeFilter(
      from: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      to: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
      preset: 'thisweek',
    );
  }

  factory DateRangeFilter.thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return DateRangeFilter(
      from: startOfMonth,
      to: endOfMonth,
      preset: 'thismonth',
    );
  }

  factory DateRangeFilter.lastDays(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    return DateRangeFilter(
      from: DateTime(startDate.year, startDate.month, startDate.day),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59),
      preset: 'last${days}days',
    );
  }

  /// Check if date range is valid
  bool get isValid {
    if (from == null && to == null) return false;
    if (from != null && to != null) {
      return from!.isBefore(to!) || from!.isAtSameMomentAs(to!);
    }
    return true;
  }

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  List<Object?> get props => [from, to, preset];

  @override
  String toString() {
    return 'DateRangeFilter(${description})';
  }
}

/// Search sort options
class SearchSortModel extends Equatable {
  final String field;
  final String direction;
  final String? label;

  const SearchSortModel({
    required this.field,
    required this.direction,
    this.label,
  });

  factory SearchSortModel.fromJson(Map<String, dynamic> json) {
    return SearchSortModel(
      field: json['field'] ?? 'relevance',
      direction: json['direction'] ?? 'desc',
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'direction': direction,
      if (label != null) 'label': label,
    };
  }

  /// Predefined sort options
  static const SearchSortModel relevance = SearchSortModel(
    field: 'relevance',
    direction: 'desc',
    label: 'Most Relevant',
  );

  static const SearchSortModel newest = SearchSortModel(
    field: 'created_at',
    direction: 'desc',
    label: 'Newest First',
  );

  static const SearchSortModel oldest = SearchSortModel(
    field: 'created_at',
    direction: 'asc',
    label: 'Oldest First',
  );

  static const SearchSortModel alphabetical = SearchSortModel(
    field: 'title',
    direction: 'asc',
    label: 'A to Z',
  );

  static const SearchSortModel reverseAlphabetical = SearchSortModel(
    field: 'title',
    direction: 'desc',
    label: 'Z to A',
  );

  static const SearchSortModel recentlyUpdated = SearchSortModel(
    field: 'updated_at',
    direction: 'desc',
    label: 'Recently Updated',
  );

  /// Get all available sort options
  static List<SearchSortModel> get allOptions => [
    relevance,
    newest,
    oldest,
    alphabetical,
    reverseAlphabetical,
    recentlyUpdated,
  ];

  String get displayName => label ?? '$field ($direction)';

  @override
  List<Object?> get props => [field, direction, label];

  @override
  String toString() {
    return 'SearchSortModel($displayName)';
  }
}

/// Search options for combining filters, sorting, and pagination
class SearchOptionsModel extends Equatable {
  final SearchFilterModel? filters;
  final SearchSortModel? sort;
  final int page;
  final int limit;
  final bool exactMatch;
  final bool includeHighlights;
  final bool includeAnalytics;
  final List<String> entities;

  const SearchOptionsModel({
    this.filters,
    this.sort,
    this.page = 1,
    this.limit = 20,
    this.exactMatch = false,
    this.includeHighlights = true,
    this.includeAnalytics = false,
    this.entities = const ['assets'],
  });

  factory SearchOptionsModel.fromJson(Map<String, dynamic> json) {
    return SearchOptionsModel(
      filters: json['filters'] != null
          ? SearchFilterModel.fromJson(json['filters'])
          : null,
      sort: json['sort'] != null
          ? SearchSortModel.fromJson(json['sort'])
          : null,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      exactMatch: json['exact_match'] ?? false,
      includeHighlights: json['include_highlights'] ?? true,
      includeAnalytics: json['include_analytics'] ?? false,
      entities: json['entities'] != null
          ? List<String>.from(json['entities'])
          : ['assets'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (filters != null) 'filters': filters!.toJson(),
      if (sort != null) 'sort': sort!.toJson(),
      'page': page,
      'limit': limit,
      'exact_match': exactMatch,
      'include_highlights': includeHighlights,
      'include_analytics': includeAnalytics,
      'entities': entities,
    };
  }

  SearchOptionsModel copyWith({
    SearchFilterModel? filters,
    SearchSortModel? sort,
    int? page,
    int? limit,
    bool? exactMatch,
    bool? includeHighlights,
    bool? includeAnalytics,
    List<String>? entities,
  }) {
    return SearchOptionsModel(
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      exactMatch: exactMatch ?? this.exactMatch,
      includeHighlights: includeHighlights ?? this.includeHighlights,
      includeAnalytics: includeAnalytics ?? this.includeAnalytics,
      entities: entities ?? this.entities,
    );
  }

  /// Reset to first page (useful after changing filters)
  SearchOptionsModel resetPage() {
    return copyWith(page: 1);
  }

  /// Go to next page
  SearchOptionsModel nextPage() {
    return copyWith(page: page + 1);
  }

  /// Go to previous page
  SearchOptionsModel previousPage() {
    return copyWith(page: page > 1 ? page - 1 : 1);
  }

  @override
  List<Object?> get props => [
    filters,
    sort,
    page,
    limit,
    exactMatch,
    includeHighlights,
    includeAnalytics,
    entities,
  ];

  @override
  String toString() {
    return 'SearchOptionsModel(page: $page, limit: $limit, entities: $entities, hasFilters: ${filters?.hasFilters ?? false})';
  }
}
