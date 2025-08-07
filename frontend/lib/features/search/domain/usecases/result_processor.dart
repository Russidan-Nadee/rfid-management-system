// Path: frontend/lib/features/search/domain/usecases/result_processor.dart
import '../entities/search_result_entity.dart';

/// Processes and formats search results for optimal display
/// Handles highlighting, grouping, aggregation, and export formatting
class ResultProcessor {
  final Map<String, String> _highlightCache = {};

  /// Process search results with highlighting and formatting
  List<SearchResultEntity> processResults(
    List<SearchResultEntity> results,
    String query, {
    bool enableHighlighting = true,
    bool enableGrouping = false,
    String? groupBy,
    int? maxResults,
  }) {
    var processedResults = results;

    // Apply result limit
    if (maxResults != null && maxResults > 0) {
      processedResults = processedResults.take(maxResults).toList();
    }

    // Apply highlighting
    if (enableHighlighting && query.isNotEmpty) {
      processedResults = _applyHighlighting(processedResults, query);
    }

    // Apply grouping if requested
    if (enableGrouping && groupBy != null) {
      processedResults = _applyGrouping(processedResults, groupBy);
    }

    // Sort by display priority
    processedResults.sort(
      (a, b) => b.displayPriority.compareTo(a.displayPriority),
    );

    return processedResults;
  }

  /// Apply search term highlighting to results
  List<SearchResultEntity> _applyHighlighting(
    List<SearchResultEntity> results,
    String query,
  ) {
    final queryTerms = _extractQueryTerms(query);

    return results.map((result) {
      final highlights = <String, dynamic>{};

      // Highlight title
      highlights['title'] = _highlightText(result.title, queryTerms);

      // Highlight subtitle
      highlights['subtitle'] = _highlightText(result.subtitle, queryTerms);

      // Highlight specific fields based on entity type
      switch (result.entityType) {
        case 'assets':
          if (result.assetNo != null) {
            highlights['asset_no'] = _highlightText(
              result.assetNo!,
              queryTerms,
            );
          }
          if (result.serialNo != null) {
            highlights['serial_no'] = _highlightText(
              result.serialNo!,
              queryTerms,
            );
          }
          if (result.description != null) {
            highlights['description'] = _highlightText(
              result.description!,
              queryTerms,
            );
          }
          break;

        case 'users':
          if (result.employeeId != null) {
            highlights['employee_id'] = _highlightText(
              result.employeeId!,
              queryTerms,
            );
          }
          if (result.fullName != null) {
            highlights['full_name'] = _highlightText(
              result.fullName!,
              queryTerms,
            );
          }
          break;

        case 'plants':
        case 'locations':
          if (result.plantCode != null) {
            highlights['plant_code'] = _highlightText(
              result.plantCode!,
              queryTerms,
            );
          }
          if (result.locationCode != null) {
            highlights['location_code'] = _highlightText(
              result.locationCode!,
              queryTerms,
            );
          }
          break;
      }

      return result.withHighlights(highlights);
    }).toList();
  }

  /// Extract individual terms from search query
  List<String> _extractQueryTerms(String query) {
    return query
        .trim()
        .split(RegExp(r'\s+'))
        .where((term) => term.length >= 2)
        .map((term) => term.toLowerCase())
        .toList();
  }

  /// Highlight matching terms in text
  String _highlightText(String text, List<String> queryTerms) {
    final cacheKey = '${text}_${queryTerms.join('_')}';

    if (_highlightCache.containsKey(cacheKey)) {
      return _highlightCache[cacheKey]!;
    }

    var highlightedText = text;

    for (final term in queryTerms) {
      final regex = RegExp(RegExp.escape(term), caseSensitive: false);

      highlightedText = highlightedText.replaceAllMapped(regex, (match) {
        return '<mark>${match.group(0)}</mark>';
      });
    }

    _highlightCache[cacheKey] = highlightedText;
    return highlightedText;
  }

  /// Group results by specified field
  List<SearchResultEntity> _applyGrouping(
    List<SearchResultEntity> results,
    String groupBy,
  ) {
    final groups = <String, List<SearchResultEntity>>{};

    // Group results
    for (final result in results) {
      final groupKey = _getGroupKey(result, groupBy);
      groups[groupKey] = groups[groupKey] ?? [];
      groups[groupKey]!.add(result);
    }

    // Flatten groups back to list with group headers
    final groupedResults = <SearchResultEntity>[];

    for (final entry in groups.entries) {
      // Add group header (could be special result entity)
      if (entry.value.isNotEmpty) {
        groupedResults.addAll(entry.value);
      }
    }

    return groupedResults;
  }

  /// Get group key for result
  String _getGroupKey(SearchResultEntity result, String groupBy) {
    switch (groupBy.toLowerCase()) {
      case 'entity_type':
        return result.entityType;
      case 'plant':
      case 'plant_code':
        return result.plantCode ?? 'No Plant';
      case 'location':
      case 'location_code':
        return result.locationCode ?? 'No Location';
      case 'status':
        return result.statusLabel;
      default:
        return 'Other';
    }
  }

  /// Format results for different output types
  Map<String, dynamic> formatForDisplay(
    List<SearchResultEntity> results, {
    String format = 'list',
    bool includeMetadata = true,
  }) {
    switch (format.toLowerCase()) {
      case 'table':
        return _formatAsTable(results, includeMetadata);
      case 'grid':
        return _formatAsGrid(results, includeMetadata);
      case 'summary':
        return _formatAsSummary(results, includeMetadata);
      default:
        return _formatAsList(results, includeMetadata);
    }
  }

  /// Format results as list view
  Map<String, dynamic> _formatAsList(
    List<SearchResultEntity> results,
    bool includeMetadata,
  ) {
    final formattedResults = results
        .map(
          (result) => {
            'id': result.id,
            'title': result.title,
            'subtitle': result.subtitle,
            'entity_type': result.entityType,
            'icon': result.entityIcon,
            'status': result.statusLabel,
            'status_color': result.statusColor,
            'highlights': result.highlights,
            if (includeMetadata) 'metadata': _extractMetadata(result),
          },
        )
        .toList();

    return {
      'format': 'list',
      'results': formattedResults,
      'total_count': results.length,
      'by_entity': _groupByEntityType(results),
    };
  }

  /// Format results as table view
  Map<String, dynamic> _formatAsTable(
    List<SearchResultEntity> results,
    bool includeMetadata,
  ) {
    final columns = _generateTableColumns(results);
    final rows = results
        .map((result) => _generateTableRow(result, columns))
        .toList();

    return {
      'format': 'table',
      'columns': columns,
      'rows': rows,
      'total_count': results.length,
    };
  }

  /// Format results as grid view
  Map<String, dynamic> _formatAsGrid(
    List<SearchResultEntity> results,
    bool includeMetadata,
  ) {
    final gridItems = results
        .map(
          (result) => {
            'id': result.id,
            'title': result.title,
            'subtitle': result.subtitle,
            'entity_type': result.entityType,
            'icon': result.entityIcon,
            'color': result.entityColor,
            'status': result.statusLabel,
            'image_url': _getEntityImage(result),
            'quick_actions': _getQuickActions(result),
          },
        )
        .toList();

    return {
      'format': 'grid',
      'items': gridItems,
      'total_count': results.length,
      'grid_size': _calculateOptimalGridSize(results.length),
    };
  }

  /// Format results as summary view
  Map<String, dynamic> _formatAsSummary(
    List<SearchResultEntity> results,
    bool includeMetadata,
  ) {
    final summary = _generateResultsSummary(results);

    return {
      'format': 'summary',
      'summary': summary,
      'total_count': results.length,
      'top_results': results
          .take(5)
          .map(
            (result) => {
              'id': result.id,
              'title': result.title,
              'entity_type': result.entityType,
              'relevance_score': result.relevanceScore,
            },
          )
          .toList(),
    };
  }

  /// Generate table columns based on results
  List<Map<String, dynamic>> _generateTableColumns(
    List<SearchResultEntity> results,
  ) {
    final columns = <Map<String, dynamic>>[
      {'key': 'title', 'label': 'Title', 'sortable': true},
      {'key': 'entity_type', 'label': 'Type', 'sortable': true},
      {'key': 'status', 'label': 'Status', 'sortable': true},
    ];

    // Add entity-specific columns
    final hasAssets = results.any((r) => r.entityType == 'assets');
    final hasUsers = results.any((r) => r.entityType == 'users');
    final hasPlants = results.any((r) => r.entityType == 'plants');

    if (hasAssets) {
      columns.addAll([
        {'key': 'asset_no', 'label': 'Asset No', 'sortable': true},
        {'key': 'serial_no', 'label': 'Serial No', 'sortable': true},
        {'key': 'plant_code', 'label': 'Plant', 'sortable': true},
        {'key': 'location_code', 'label': 'Location', 'sortable': true},
      ]);
    }

    if (hasUsers) {
      columns.addAll([
        {'key': 'username', 'label': 'Username', 'sortable': true},
        {'key': 'role', 'label': 'Role', 'sortable': true},
      ]);
    }

    if (hasPlants) {
      columns.add({
        'key': 'description',
        'label': 'Description',
        'sortable': false,
      });
    }

    return columns;
  }

  /// Generate table row for result
  Map<String, dynamic> _generateTableRow(
    SearchResultEntity result,
    List<Map<String, dynamic>> columns,
  ) {
    final row = <String, dynamic>{};

    for (final column in columns) {
      final key = column['key'] as String;

      switch (key) {
        case 'title':
          row[key] = result.title;
          break;
        case 'entity_type':
          row[key] = result.entityType;
          break;
        case 'status':
          row[key] = result.statusLabel;
          break;
        case 'asset_no':
          row[key] = result.assetNo ?? '';
          break;
        case 'serial_no':
          row[key] = result.serialNo ?? '';
          break;
        case 'plant_code':
          row[key] = result.plantCode ?? '';
          break;
        case 'location_code':
          row[key] = result.locationCode ?? '';
          break;
        case 'employee_id':
          row[key] = result.employeeId ?? '';
          break;
        case 'role':
          row[key] = result.role ?? '';
          break;
        case 'description':
          row[key] = result.description ?? '';
          break;
        default:
          row[key] = result.data[key]?.toString() ?? '';
      }
    }

    return row;
  }

  /// Extract metadata from result
  Map<String, dynamic> _extractMetadata(SearchResultEntity result) {
    return {
      'relevance_score': result.relevanceScore,
      'last_modified': result.lastModified?.toIso8601String(),
      'data_source': result.entityType,
      'has_highlights': result.hasHighlights,
      'field_count': result.data.length,
    };
  }

  /// Group results by entity type
  Map<String, int> _groupByEntityType(List<SearchResultEntity> results) {
    final groups = <String, int>{};

    for (final result in results) {
      groups[result.entityType] = (groups[result.entityType] ?? 0) + 1;
    }

    return groups;
  }

  /// Get entity image URL/path
  String? _getEntityImage(SearchResultEntity result) {
    switch (result.entityType) {
      case 'assets':
        return '/images/entities/asset.png';
      case 'plants':
        return '/images/entities/plant.png';
      case 'locations':
        return '/images/entities/location.png';
      case 'users':
        return '/images/entities/user.png';
      default:
        return '/images/entities/default.png';
    }
  }

  /// Get quick actions for result
  List<Map<String, dynamic>> _getQuickActions(SearchResultEntity result) {
    final actions = <Map<String, dynamic>>[
      {'label': 'View', 'action': 'view', 'icon': 'eye'},
    ];

    switch (result.entityType) {
      case 'assets':
        actions.addAll([
          {'label': 'Edit', 'action': 'edit', 'icon': 'edit'},
          {'label': 'History', 'action': 'history', 'icon': 'history'},
        ]);
        break;
      case 'users':
        actions.add({'label': 'Profile', 'action': 'profile', 'icon': 'user'});
        break;
    }

    return actions;
  }

  /// Calculate optimal grid size
  Map<String, int> _calculateOptimalGridSize(int itemCount) {
    if (itemCount <= 4) return {'columns': 2, 'rows': 2};
    if (itemCount <= 9) return {'columns': 3, 'rows': 3};
    if (itemCount <= 16) return {'columns': 4, 'rows': 4};
    return {'columns': 5, 'rows': (itemCount / 5).ceil()};
  }

  /// Generate results summary
  Map<String, dynamic> _generateResultsSummary(
    List<SearchResultEntity> results,
  ) {
    final byEntity = _groupByEntityType(results);
    final avgScore =
        results
            .where((r) => r.relevanceScore != null)
            .map((r) => r.relevanceScore!)
            .fold(0.0, (sum, score) => sum + score) /
        results.where((r) => r.relevanceScore != null).length;

    return {
      'total_results': results.length,
      'by_entity_type': byEntity,
      'average_relevance': avgScore.isFinite ? avgScore : 0.0,
      'has_highlights': results.any((r) => r.hasHighlights),
      'top_entity_type': byEntity.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key,
    };
  }

  /// Export results to different formats
  Future<String> exportResults(
    List<SearchResultEntity> results,
    String format, {
    bool includeMetadata = false,
  }) async {
    switch (format.toLowerCase()) {
      case 'csv':
        return _exportToCsv(results, includeMetadata);
      case 'json':
        return _exportToJson(results, includeMetadata);
      case 'xlsx':
        return _exportToExcel(results, includeMetadata);
      default:
        throw ArgumentError('Unsupported export format: $format');
    }
  }

  /// Export to CSV format
  String _exportToCsv(List<SearchResultEntity> results, bool includeMetadata) {
    if (results.isEmpty) return '';

    final headers = _getCsvHeaders(results, includeMetadata);
    final rows = results.map((result) => _getCsvRow(result, headers)).toList();

    return [headers.join(','), ...rows.map((row) => row.join(','))].join('\n');
  }

  /// Export to JSON format
  String _exportToJson(List<SearchResultEntity> results, bool includeMetadata) {
    final data = results
        .map(
          (result) => {
            'id': result.id,
            'title': result.title,
            'subtitle': result.subtitle,
            'entity_type': result.entityType,
            'data': result.data,
            if (includeMetadata) 'metadata': _extractMetadata(result),
          },
        )
        .toList();

    return data.toString(); // In real implementation, use json.encode()
  }

  /// Export to Excel format (placeholder)
  String _exportToExcel(
    List<SearchResultEntity> results,
    bool includeMetadata,
  ) {
    // In real implementation, would use excel package
    return 'Excel export not implemented';
  }

  /// Get CSV headers
  List<String> _getCsvHeaders(
    List<SearchResultEntity> results,
    bool includeMetadata,
  ) {
    final headers = ['ID', 'Title', 'Subtitle', 'Entity Type', 'Status'];

    if (results.any((r) => r.entityType == 'assets')) {
      headers.addAll(['Asset No', 'Serial No', 'Plant Code', 'Location Code']);
    }

    if (includeMetadata) {
      headers.add('Relevance Score');
    }

    return headers;
  }

  /// Get CSV row for result
  List<String> _getCsvRow(SearchResultEntity result, List<String> headers) {
    final row = <String>[];

    for (final header in headers) {
      switch (header) {
        case 'ID':
          row.add(result.id);
          break;
        case 'Title':
          row.add('"${result.title}"');
          break;
        case 'Subtitle':
          row.add('"${result.subtitle}"');
          break;
        case 'Entity Type':
          row.add(result.entityType);
          break;
        case 'Status':
          row.add(result.statusLabel);
          break;
        case 'Asset No':
          row.add(result.assetNo ?? '');
          break;
        case 'Serial No':
          row.add(result.serialNo ?? '');
          break;
        case 'Plant Code':
          row.add(result.plantCode ?? '');
          break;
        case 'Location Code':
          row.add(result.locationCode ?? '');
          break;
        case 'Relevance Score':
          row.add(result.relevanceScore?.toString() ?? '');
          break;
        default:
          row.add('');
      }
    }

    return row;
  }

  /// Clear highlight cache
  void clearCache() {
    _highlightCache.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'highlight_cache_size': _highlightCache.length,
      'cache_memory_estimate_kb': _highlightCache.length * 50, // Rough estimate
    };
  }

  /// Dispose resources
  void dispose() {
    _highlightCache.clear();
  }
}
