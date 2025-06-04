// Base Exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

// Network Exceptions
class NetworkException extends AppException {
  NetworkException(String message, {String? code}) : super(message, code: code);
}

class ConnectionTimeoutException extends NetworkException {
  ConnectionTimeoutException() : super('Connection timeout', code: 'TIMEOUT');
}

class NoInternetException extends NetworkException {
  NoInternetException() : super('No internet connection', code: 'NO_INTERNET');
}

// API Exceptions
class ApiException extends AppException {
  final int statusCode;

  ApiException(String message, this.statusCode, {String? code})
    : super(message, code: code);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException()
    : super('Unauthorized access', 401, code: 'UNAUTHORIZED');
}

class ForbiddenException extends ApiException {
  ForbiddenException() : super('Access forbidden', 403, code: 'FORBIDDEN');
}

class NotFoundException extends ApiException {
  NotFoundException(String resource)
    : super('$resource not found', 404, code: 'NOT_FOUND');
}

class ValidationException extends ApiException {
  final List<String> errors;

  ValidationException(this.errors)
    : super('Validation failed', 400, code: 'VALIDATION_ERROR');
}

class ServerException extends ApiException {
  ServerException() : super('Internal server error', 500, code: 'SERVER_ERROR');
}

// Authentication Exceptions
class AuthException extends AppException {
  AuthException(String message, {String? code}) : super(message, code: code);
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException()
    : super('Invalid username or password', code: 'INVALID_CREDENTIALS');
}

class TokenExpiredException extends AuthException {
  TokenExpiredException() : super('Session expired', code: 'TOKEN_EXPIRED');
}

class AccountLockedException extends AuthException {
  AccountLockedException()
    : super('Account temporarily locked', code: 'ACCOUNT_LOCKED');
}

// Storage Exceptions
class StorageException extends AppException {
  StorageException(String message, {String? code}) : super(message, code: code);
}

class CacheException extends StorageException {
  CacheException() : super('Cache operation failed', code: 'CACHE_ERROR');
}

// Utility function to convert HTTP status codes to exceptions
AppException createExceptionFromStatusCode(int statusCode, String message) {
  switch (statusCode) {
    case 400:
      return ValidationException([message]);
    case 401:
      return UnauthorizedException();
    case 403:
      return ForbiddenException();
    case 404:
      return NotFoundException(message);
    case 500:
    case 502:
    case 503:
    case 504:
      return ServerException();
    default:
      return ApiException(message, statusCode);
  }
}
