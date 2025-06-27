// Path: frontend/lib/features/search/domain/usecases/query_validator.dart
import '../entities/search_filter_entity.dart';
import '../../data/exceptions/search_exceptions.dart';

/// Validates and sanitizes search queries for security and performance
/// Provides comprehensive input validation and XSS/injection protection
class QueryValidator {
  // Validation configuration
  static const int _minQueryLength = 1;
  static const int _maxQueryLength = 200;
  static const int _maxFilterValues = 20;
  static const List<String> _allowedEntities = [
    'assets',
    'plants',
    'locations',
    'users',
    'departments',
  ];

  // Dangerous patterns to block
  static final RegExp _sqlInjectionPattern = RegExp(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION)\b)|'
    r'(;|--|\|\||&&)',
    caseSensitive: false,
  );

  static final RegExp _xssPattern = RegExp(
    r'<[^>]*>|javascript:|data:|vbscript:|onload=|onerror=',
    caseSensitive: false,
  );

  static final RegExp _invalidCharsPattern = RegExp(r'[<>{}()\[\]\\\/]');

  static final RegExp _assetCodePattern = RegExp(r'^[A-Z0-9]{6,12}$');
  static final RegExp _plantCodePattern = RegExp(r'^[A-Z0-9]{2,8}$');
  static final RegExp _serialPattern = RegExp(r'^[A-Z0-9\-]{4,20}$');
  static final RegExp _deptCodePattern = RegExp(r'^[A-Z0-9]{2,6}$');

  /// Validate and sanitize search query
  ValidationResult<String> validateQuery(String query) {
    try {
      // Basic checks
      if (query.isEmpty) {
        return ValidationResult.error('Search query cannot be empty');
      }

      // Length validation
      if (query.length < _minQueryLength) {
        throw SearchQueryTooShortException(minLength: _minQueryLength);
      }

      if (query.length > _maxQueryLength) {
        throw SearchQueryTooLongException(maxLength: _maxQueryLength);
      }

      // Security validation
      if (_sqlInjectionPattern.hasMatch(query)) {
        throw SearchQueryInvalidCharactersException();
      }

      if (_xssPattern.hasMatch(query)) {
        throw SearchQueryInvalidCharactersException();
      }

      // Sanitize the query
      final sanitized = _sanitizeQuery(query);

      return ValidationResult.success(sanitized);
    } catch (e) {
      if (e is SearchException) {
        return ValidationResult.error(e.message);
      }
      return ValidationResult.error('Invalid search query: ${e.toString()}');
    }
  }

  /// Validate entity types
  ValidationResult<List<String>> validateEntities(List<String> entities) {
    if (entities.isEmpty) {
      return ValidationResult.error(
        'At least one entity type must be specified',
      );
    }

    final invalidEntities = entities
        .where((entity) => !_allowedEntities.contains(entity.toLowerCase()))
        .toList();

    if (invalidEntities.isNotEmpty) {
      return ValidationResult.error(
        'Invalid entity types: ${invalidEntities.join(', ')}',
      );
    }

    final normalizedEntities = entities
        .map((entity) => entity.toLowerCase())
        .toSet()
        .toList();

    return ValidationResult.success(normalizedEntities);
  }

  /// Validate search filters
  ValidationResult<SearchFilterEntity> validateFilters(
    SearchFilterEntity? filters,
  ) {
    if (filters == null || !filters.hasFilters) {
      return ValidationResult.success(filters ?? SearchFilterEntity.empty());
    }

    try {
      // Validate plant codes
      if (filters.plantCodes != null) {
        final result = _validateStringList(
          filters.plantCodes!,
          'Plant codes',
          _plantCodePattern,
        );
        if (!result.isValid) {
          return ValidationResult.error(result.error!);
        }
      }

      // Validate location codes
      if (filters.locationCodes != null) {
        final result = _validateStringList(
          filters.locationCodes!,
          'Location codes',
          _plantCodePattern, // Similar pattern to plant codes
        );
        if (!result.isValid) {
          return ValidationResult.error(result.error!);
        }
      }

      // Validate status values
      if (filters.status != null) {
        final validStatuses = ['A', 'C', 'I', 'ACTIVE', 'CREATED', 'INACTIVE'];
        final invalidStatuses = filters.status!
            .where((status) => !validStatuses.contains(status.toUpperCase()))
            .toList();

        if (invalidStatuses.isNotEmpty) {
          return ValidationResult.error(
            'Invalid status values: ${invalidStatuses.join(', ')}',
          );
        }
      }

      // Validate date range
      if (filters.dateRange != null && !filters.dateRange!.isValid) {
        return ValidationResult.error('Invalid date range');
      }

      // Validate custom filters
      if (filters.customFilters != null) {
        final result = _validateCustomFilters(filters.customFilters!);
        if (!result.isValid) {
          return ValidationResult.error(result.error!);
        }
      }

      return ValidationResult.success(filters);
    } catch (e) {
      return ValidationResult.error('Filter validation error: ${e.toString()}');
    }
  }

  /// Validate search options (limit, page, etc.)
  ValidationResult<Map<String, dynamic>> validateSearchOptions({
    int? limit,
    int? page,
    String? sort,
  }) {
    final options = <String, dynamic>{};

    // Validate limit
    if (limit != null) {
      if (limit < 1 || limit > 100) {
        return ValidationResult.error('Limit must be between 1 and 100');
      }
      options['limit'] = limit;
    }

    // Validate page
    if (page != null) {
      if (page < 1) {
        return ValidationResult.error('Page must be greater than 0');
      }
      options['page'] = page;
    }

    // Validate sort
    if (sort != null) {
      const validSorts = [
        'relevance',
        'date',
        'title',
        'created_at',
        'updated_at',
      ];
      if (!validSorts.contains(sort.toLowerCase())) {
        return ValidationResult.error('Invalid sort option: $sort');
      }
      options['sort'] = sort.toLowerCase();
    }

    return ValidationResult.success(options);
  }

  /// Detect and classify query type
  QueryType detectQueryType(String query) {
    final cleanQuery = query.trim().toUpperCase();

    // Asset code pattern
    if (_assetCodePattern.hasMatch(cleanQuery)) {
      return QueryType.assetCode;
    }

    // Serial number pattern
    if (_serialPattern.hasMatch(cleanQuery)) {
      return QueryType.serialNumber;
    }

    // Plant/Location code pattern
    if (_plantCodePattern.hasMatch(cleanQuery)) {
      return QueryType.plantOrLocationCode;
    }

    // Check for email pattern (user search)
    if (query.contains('@')) {
      return QueryType.email;
    }

    // Check for description-like queries
    if (query.length > 10 && query.split(' ').length > 1) {
      return QueryType.description;
    }

    return QueryType.general;
  }

  /// Suggest improvements for better search results
  List<String> suggestQueryImprovements(String query) {
    final suggestions = <String>[];
    final cleanQuery = query.trim();

    if (cleanQuery.length < 3) {
      suggestions.add('Try using at least 3 characters for better results');
    }

    if (cleanQuery.contains('*') || cleanQuery.contains('?')) {
      suggestions.add('Wildcard characters are not supported');
    }

    if (_invalidCharsPattern.hasMatch(cleanQuery)) {
      suggestions.add('Remove special characters like <, >, {, }, etc.');
    }

    final queryType = detectQueryType(cleanQuery);
    switch (queryType) {
      case QueryType.assetCode:
        suggestions.add('Searching by asset code - try exact match');
        break;
      case QueryType.description:
        suggestions.add('Use specific keywords for better description search');
        break;
      case QueryType.general:
        suggestions.add(
          'Try searching by asset code, serial number, or description',
        );
        break;
      default:
        break;
    }

    return suggestions;
  }

  /// Private helper methods

  String _sanitizeQuery(String query) {
    return query
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[^\w\s\-\.]'), '') // Remove dangerous chars
        .substring(0, query.length.clamp(0, _maxQueryLength));
  }

  ValidationResult<List<String>> _validateStringList(
    List<String> values,
    String fieldName,
    RegExp? pattern,
  ) {
    if (values.length > _maxFilterValues) {
      return ValidationResult.error(
        '$fieldName: Maximum $_maxFilterValues values allowed',
      );
    }

    if (pattern != null) {
      final invalidValues = values
          .where((value) => !pattern.hasMatch(value.toUpperCase()))
          .toList();

      if (invalidValues.isNotEmpty) {
        return ValidationResult.error(
          '$fieldName: Invalid format for ${invalidValues.join(', ')}',
        );
      }
    }

    return ValidationResult.success(values);
  }

  ValidationResult<Map<String, dynamic>> _validateCustomFilters(
    Map<String, dynamic> customFilters,
  ) {
    if (customFilters.length > 10) {
      return ValidationResult.error('Maximum 10 custom filters allowed');
    }

    for (final entry in customFilters.entries) {
      final key = entry.key;
      final value = entry.value;

      // Validate key
      if (key.isEmpty || key.length > 50) {
        return ValidationResult.error('Invalid filter key: $key');
      }

      // Validate value
      if (value == null) continue;

      if (value is String && value.length > 100) {
        return ValidationResult.error('Filter value too long for key: $key');
      }

      if (value is List && value.length > _maxFilterValues) {
        return ValidationResult.error('Too many values for filter: $key');
      }
    }

    return ValidationResult.success(customFilters);
  }
}

/// Validation result wrapper
class ValidationResult<T> {
  final bool isValid;
  final T? data;
  final String? error;

  const ValidationResult._(this.isValid, this.data, this.error);

  factory ValidationResult.success(T data) {
    return ValidationResult._(true, data, null);
  }

  factory ValidationResult.error(String error) {
    return ValidationResult._(false, null, error);
  }

  bool get hasError => !isValid && error != null;
}

/// Query type classification
enum QueryType {
  assetCode,
  serialNumber,
  plantOrLocationCode,
  email,
  description,
  general,
}
