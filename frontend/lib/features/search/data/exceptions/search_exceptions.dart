// Path: frontend/lib/features/search/data/exceptions/search_exceptions.dart
import '../../../../core/errors/exceptions.dart';

/// Search-specific exceptions
class SearchException extends AppException {
  SearchException(String message, {String? code}) : super(message, code: code);
}

/// Query validation exceptions
class SearchQueryException extends SearchException {
  SearchQueryException(String message) : super(message, code: 'INVALID_QUERY');
}

class SearchQueryTooShortException extends SearchQueryException {
  SearchQueryTooShortException({int minLength = 1})
    : super('Search query must be at least $minLength characters');
}

class SearchQueryTooLongException extends SearchQueryException {
  SearchQueryTooLongException({int maxLength = 200})
    : super('Search query must not exceed $maxLength characters');
}

class SearchQueryInvalidCharactersException extends SearchQueryException {
  SearchQueryInvalidCharactersException()
    : super('Search query contains invalid characters');
}

/// Search operation exceptions
class SearchTimeoutException extends SearchException {
  SearchTimeoutException()
    : super('Search request timeout', code: 'SEARCH_TIMEOUT');
}

class SearchResultsLimitExceededException extends SearchException {
  SearchResultsLimitExceededException({int maxLimit = 100})
    : super(
        'Search results limit exceeded. Maximum $maxLimit results allowed',
        code: 'LIMIT_EXCEEDED',
      );
}

class SearchFilterException extends SearchException {
  SearchFilterException(String message)
    : super(message, code: 'INVALID_FILTER');
}

class SearchNoResultsException extends SearchException {
  SearchNoResultsException()
    : super('No search results found', code: 'NO_RESULTS');
}

/// Cache-related exceptions
class SearchCacheException extends SearchException {
  SearchCacheException(String message) : super(message, code: 'CACHE_ERROR');
}

class SearchCacheExpiredException extends SearchCacheException {
  SearchCacheExpiredException() : super('Search cache has expired');
}

class SearchCacheCorruptedException extends SearchCacheException {
  SearchCacheCorruptedException() : super('Search cache data is corrupted');
}

/// Remote API exceptions
class SearchApiException extends SearchException {
  final int statusCode;

  SearchApiException(String message, this.statusCode, {String? code})
    : super(message, code: code);
}

class SearchRateLimitException extends SearchApiException {
  SearchRateLimitException()
    : super('Search rate limit exceeded', 429, code: 'RATE_LIMIT');
}

class SearchServiceUnavailableException extends SearchApiException {
  SearchServiceUnavailableException()
    : super(
        'Search service temporarily unavailable',
        503,
        code: 'SERVICE_UNAVAILABLE',
      );
}

/// Entity-specific exceptions
class SearchEntityException extends SearchException {
  final String entityType;

  SearchEntityException(this.entityType, String message)
    : super('$entityType search error: $message', code: 'ENTITY_ERROR');
}

class SearchAssetException extends SearchEntityException {
  SearchAssetException(String message) : super('Asset', message);
}

class SearchPlantException extends SearchEntityException {
  SearchPlantException(String message) : super('Plant', message);
}

class SearchLocationException extends SearchEntityException {
  SearchLocationException(String message) : super('Location', message);
}

class SearchUserException extends SearchEntityException {
  SearchUserException(String message) : super('User', message);
}

/// Helper function to create exceptions from error responses
SearchException createSearchExceptionFromError(dynamic error) {
  if (error is ApiException) {
    switch (error.statusCode) {
      case 400:
        return SearchQueryException(error.message);
      case 429:
        return SearchRateLimitException();
      case 503:
        return SearchServiceUnavailableException();
      default:
        return SearchApiException(error.message, error.statusCode);
    }
  } else if (error is NetworkException) {
    if (error.message.contains('timeout')) {
      return SearchTimeoutException();
    }
    return SearchException(
      'Network error: ${error.message}',
      code: 'NETWORK_ERROR',
    );
  } else if (error is StorageException) {
    return SearchCacheException('Cache error: ${error.message}');
  }

  return SearchException(
    'Unknown search error: ${error.toString()}',
    code: 'UNKNOWN_ERROR',
  );
}
