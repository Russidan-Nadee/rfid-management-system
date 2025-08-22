// Path: frontend/lib/features/search/domain/entities/search_history_entity.dart
import 'package:equatable/equatable.dart';

/// Search history entity for tracking user search patterns
class SearchHistoryEntity extends Equatable {
  final String id;
  final String query;
  final String searchType;
  final List<String> entities;
  final int resultsCount;
  final DateTime timestamp;
  final String? userId;
  final bool wasSuccessful;
  final Map<String, dynamic>? filters;
  final int clickThroughCount;

  const SearchHistoryEntity({
    required this.id,
    required this.query,
    required this.searchType,
    required this.entities,
    required this.resultsCount,
    required this.timestamp,
    this.userId,
    this.wasSuccessful = true,
    this.filters,
    this.clickThroughCount = 0,
  });

  /// Factory constructors
  factory SearchHistoryEntity.create({
    required String query,
    required String searchType,
    required List<String> entities,
    required int resultsCount,
    String? userId,
    bool wasSuccessful = true,
    Map<String, dynamic>? filters,
  }) {
    return SearchHistoryEntity(
      id: _generateId(),
      query: query,
      searchType: searchType,
      entities: entities,
      resultsCount: resultsCount,
      timestamp: DateTime.now(),
      userId: userId,
      wasSuccessful: wasSuccessful,
      filters: filters,
    );
  }

  factory SearchHistoryEntity.fromQuery(String query, {String? userId}) {
    return SearchHistoryEntity(
      id: _generateId(),
      query: query,
      searchType: 'instant',
      entities: const ['assets'],
      resultsCount: 0,
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  /// Business logic methods

  /// Check if search was recent (within last hour)
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 1;

  /// Check if search was today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return timestamp.isAfter(today);
  }

  /// Check if search was this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    return timestamp.isAfter(weekStartDate);
  }

  /// Check if search had good results
  bool get hadGoodResults => wasSuccessful && resultsCount > 0;

  /// Check if search was clicked through
  bool get hasClickThroughs => clickThroughCount > 0;

  /// Get time ago description
  String get timeAgo {
    final duration = DateTime.now().difference(timestamp);

    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else if (duration.inDays < 7) {
      return '${duration.inDays}d ago';
    } else if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (duration.inDays / 30).floor();
      return '${months}mo ago';
    }
  }

  /// Get formatted timestamp
  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return 'Today ${_formatTime(timestamp)}';
    } else if (timestamp.isAfter(yesterday)) {
      return 'Yesterday ${_formatTime(timestamp)}';
    } else {
      return '${_formatDate(timestamp)} ${_formatTime(timestamp)}';
    }
  }

  /// Get search success description
  String get successDescription {
    if (!wasSuccessful) return 'Failed';
    if (resultsCount == 0) return 'No results';
    if (resultsCount == 1) return '1 result';
    return '$resultsCount results';
  }

  /// Get search type display name
  String get searchTypeDisplayName {
    switch (searchType.toLowerCase()) {
      case 'instant':
        return 'Quick Search';
      case 'global':
        return 'Global Search';
      case 'advanced':
        return 'Advanced Search';
      case 'suggestions':
        return 'Suggestions';
      default:
        return searchType
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get entities display text
  String get entitiesText {
    if (entities.isEmpty) return 'All';
    if (entities.length == 1) return entities.first;
    if (entities.length == 2) return '${entities[0]} & ${entities[1]}';
    return '${entities[0]} & ${entities.length - 1} more';
  }

  /// Check if has filters applied
  bool get hasFilters => filters != null && filters!.isNotEmpty;

  /// Get filter count
  int get filterCount => filters?.length ?? 0;

  /// Check if matches another query
  bool matchesQuery(String otherQuery) {
    return query.toLowerCase() == otherQuery.toLowerCase();
  }

  /// Create copy with updated click count
  SearchHistoryEntity withClickThrough() {
    return copyWith(clickThroughCount: clickThroughCount + 1);
  }

  /// Create copy with updated fields
  SearchHistoryEntity copyWith({
    String? id,
    String? query,
    String? searchType,
    List<String>? entities,
    int? resultsCount,
    DateTime? timestamp,
    String? userId,
    bool? wasSuccessful,
    Map<String, dynamic>? filters,
    int? clickThroughCount,
  }) {
    return SearchHistoryEntity(
      id: id ?? this.id,
      query: query ?? this.query,
      searchType: searchType ?? this.searchType,
      entities: entities ?? this.entities,
      resultsCount: resultsCount ?? this.resultsCount,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      filters: filters ?? this.filters,
      clickThroughCount: clickThroughCount ?? this.clickThroughCount,
    );
  }

  /// Private helper methods
  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  List<Object?> get props => [
    id,
    query,
    searchType,
    entities,
    resultsCount,
    timestamp,
    userId,
    wasSuccessful,
    filters,
    clickThroughCount,
  ];

  @override
  String toString() {
    return 'SearchHistoryEntity(query: "$query", type: $searchType, results: $resultsCount, time: $timeAgo)';
  }
}

/// Search history collection entity
class SearchHistoryCollectionEntity extends Equatable {
  final List<SearchHistoryEntity> items;
  final int totalCount;
  final DateTime? oldestEntry;
  final DateTime? newestEntry;

  const SearchHistoryCollectionEntity({
    required this.items,
    required this.totalCount,
    this.oldestEntry,
    this.newestEntry,
  });

  /// Factory constructors
  factory SearchHistoryCollectionEntity.fromList(
    List<SearchHistoryEntity> items,
  ) {
    final sortedItems = List<SearchHistoryEntity>.from(items)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SearchHistoryCollectionEntity(
      items: sortedItems,
      totalCount: items.length,
      oldestEntry: items.isNotEmpty
          ? items
                .map((e) => e.timestamp)
                .reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      newestEntry: items.isNotEmpty
          ? items.map((e) => e.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    );
  }

  factory SearchHistoryCollectionEntity.empty() {
    return const SearchHistoryCollectionEntity(items: [], totalCount: 0);
  }

  /// Business logic methods

  /// Check if collection is empty
  bool get isEmpty => items.isEmpty;

  /// Check if collection has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get recent items (last 24 hours)
  List<SearchHistoryEntity> get recentItems {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return items.where((item) => item.timestamp.isAfter(yesterday)).toList();
  }

  /// Get today's items
  List<SearchHistoryEntity> get todayItems {
    return items.where((item) => item.isToday).toList();
  }

  /// Get this week's items
  List<SearchHistoryEntity> get thisWeekItems {
    return items.where((item) => item.isThisWeek).toList();
  }

  /// Get unique queries
  List<String> get uniqueQueries {
    final queries = items.map((item) => item.query).toSet();
    return queries.toList();
  }

  /// Get most frequent queries
  List<FrequentQueryEntity> get frequentQueries {
    final queryCount = <String, int>{};
    final queryDetails = <String, SearchHistoryEntity>{};

    for (final item in items) {
      queryCount[item.query] = (queryCount[item.query] ?? 0) + 1;
      queryDetails[item.query] = item; // Keep latest occurrence
    }

    final frequencies = queryCount.entries.map((entry) {
      final query = entry.key;
      final count = entry.value;
      final detail = queryDetails[query]!;

      return FrequentQueryEntity(
        query: query,
        frequency: count,
        lastSearched: detail.timestamp,
        avgResults: _calculateAvgResults(query),
        searchTypes: _getSearchTypes(query),
      );
    }).toList();

    frequencies.sort((a, b) => b.frequency.compareTo(a.frequency));
    return frequencies;
  }

  /// Get search patterns by time of day
  Map<int, int> get searchPatternsByHour {
    final patterns = <int, int>{};

    for (final item in items) {
      final hour = item.timestamp.hour;
      patterns[hour] = (patterns[hour] ?? 0) + 1;
    }

    return patterns;
  }

  /// Get search patterns by day of week
  Map<int, int> get searchPatternsByWeekday {
    final patterns = <int, int>{};

    for (final item in items) {
      final weekday = item.timestamp.weekday;
      patterns[weekday] = (patterns[weekday] ?? 0) + 1;
    }

    return patterns;
  }

  /// Get success rate
  double get successRate {
    if (items.isEmpty) return 0.0;
    final successCount = items.where((item) => item.wasSuccessful).length;
    return successCount / items.length;
  }

  /// Get average results per search
  double get avgResultsPerSearch {
    if (items.isEmpty) return 0.0;
    final totalResults = items.fold(0, (sum, item) => sum + item.resultsCount);
    return totalResults / items.length;
  }

  /// Filter by date range
  SearchHistoryCollectionEntity filterByDateRange(DateTime from, DateTime to) {
    final filtered = items
        .where(
          (item) => item.timestamp.isAfter(from) && item.timestamp.isBefore(to),
        )
        .toList();

    return SearchHistoryCollectionEntity.fromList(filtered);
  }

  /// Filter by query pattern
  SearchHistoryCollectionEntity filterByQuery(String pattern) {
    final filtered = items
        .where(
          (item) => item.query.toLowerCase().contains(pattern.toLowerCase()),
        )
        .toList();

    return SearchHistoryCollectionEntity.fromList(filtered);
  }

  /// Get paginated items
  SearchHistoryCollectionEntity paginate(int page, int itemsPerPage) {
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, items.length);

    if (startIndex >= items.length) {
      return SearchHistoryCollectionEntity.empty();
    }

    final paginatedItems = items.sublist(startIndex, endIndex);
    return SearchHistoryCollectionEntity(
      items: paginatedItems,
      totalCount: totalCount,
      oldestEntry: oldestEntry,
      newestEntry: newestEntry,
    );
  }

  /// Remove items older than specified days
  SearchHistoryCollectionEntity removeOlderThan(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final filtered = items
        .where((item) => item.timestamp.isAfter(cutoffDate))
        .toList();

    return SearchHistoryCollectionEntity.fromList(filtered);
  }

  /// Private helper methods
  double _calculateAvgResults(String query) {
    final queryItems = items.where((item) => item.query == query);
    if (queryItems.isEmpty) return 0.0;

    final totalResults = queryItems.fold(
      0,
      (sum, item) => sum + item.resultsCount,
    );
    return totalResults / queryItems.length;
  }

  List<String> _getSearchTypes(String query) {
    final types = items
        .where((item) => item.query == query)
        .map((item) => item.searchType)
        .toSet();
    return types.toList();
  }

  @override
  List<Object?> get props => [items, totalCount, oldestEntry, newestEntry];

  @override
  String toString() {
    return 'SearchHistoryCollectionEntity(count: $totalCount, recent: ${recentItems.length})';
  }
}

/// Frequent query entity for history analytics
class FrequentQueryEntity extends Equatable {
  final String query;
  final int frequency;
  final DateTime lastSearched;
  final double avgResults;
  final List<String> searchTypes;

  const FrequentQueryEntity({
    required this.query,
    required this.frequency,
    required this.lastSearched,
    required this.avgResults,
    required this.searchTypes,
  });

  /// Business logic methods

  /// Check if query is very frequent
  bool get isVeryFrequent => frequency >= 10;

  /// Check if query is recent
  bool get isRecent => DateTime.now().difference(lastSearched).inDays <= 7;

  /// Get popularity description
  String get popularityDescription {
    if (frequency >= 20) return 'Very Popular';
    if (frequency >= 10) return 'Popular';
    if (frequency >= 5) return 'Common';
    return 'Occasional';
  }

  @override
  List<Object?> get props => [
    query,
    frequency,
    lastSearched,
    avgResults,
    searchTypes,
  ];

  @override
  String toString() {
    return 'FrequentQueryEntity(query: "$query", frequency: $frequency, popularity: $popularityDescription)';
  }
}
