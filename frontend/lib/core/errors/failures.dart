// Path: frontend/lib/core/errors/failures.dart
import 'package:tp_rfid/core/errors/exceptions.dart';

abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code})
    : super(message, code: code);
}

class ConnectionFailure extends NetworkFailure {
  const ConnectionFailure()
    : super('Connection failed', code: 'CONNECTION_ERROR');
}

class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure() : super('Request timeout', code: 'TIMEOUT');
}

class NoInternetFailure extends NetworkFailure {
  const NoInternetFailure()
    : super('No internet connection', code: 'NO_INTERNET');
}

// Server Failures
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code})
    : super(message, code: code);
}

class UnauthorizedFailure extends ServerFailure {
  const UnauthorizedFailure()
    : super('Unauthorized access', code: 'UNAUTHORIZED');
}

class ForbiddenFailure extends ServerFailure {
  const ForbiddenFailure() : super('Access forbidden', code: 'FORBIDDEN');
}

class NotFoundFailure extends ServerFailure {
  const NotFoundFailure(String resource)
    : super('$resource not found', code: 'NOT_FOUND');
}

class ValidationFailure extends ServerFailure {
  final List<String> errors;

  const ValidationFailure(this.errors)
    : super('Validation failed', code: 'VALIDATION_ERROR');
}

class InternalServerFailure extends ServerFailure {
  const InternalServerFailure()
    : super('Internal server error', code: 'SERVER_ERROR');
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code})
    : super(message, code: code);
}

class CacheReadFailure extends CacheFailure {
  const CacheReadFailure()
    : super('Failed to read from cache', code: 'CACHE_READ_ERROR');
}

class CacheWriteFailure extends CacheFailure {
  const CacheWriteFailure()
    : super('Failed to write to cache', code: 'CACHE_WRITE_ERROR');
}

class CacheExpiredFailure extends CacheFailure {
  const CacheExpiredFailure()
    : super('Cache data expired', code: 'CACHE_EXPIRED');
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code})
    : super(message, code: code);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
    : super('Invalid credentials', code: 'INVALID_CREDENTIALS');
}

class TokenExpiredFailure extends AuthFailure {
  const TokenExpiredFailure() : super('Token expired', code: 'TOKEN_EXPIRED');
}

class AccountLockedFailure extends AuthFailure {
  const AccountLockedFailure()
    : super('Account locked', code: 'ACCOUNT_LOCKED');
}

// Utility functions for converting exceptions to failures
Failure mapExceptionToFailure(dynamic exception) {
  if (exception is NetworkException) {
    return NetworkFailure(exception.message, code: exception.code);
  } else if (exception is ConnectionTimeoutException) {
    return const TimeoutFailure();
  } else if (exception is NoInternetException) {
    return const NoInternetFailure();
  } else if (exception is UnauthorizedException) {
    return const UnauthorizedFailure();
  } else if (exception is ForbiddenException) {
    return const ForbiddenFailure();
  } else if (exception is NotFoundException) {
    return NotFoundFailure(exception.message);
  } else if (exception is ValidationException) {
    return ValidationFailure(exception.errors);
  } else if (exception is ServerException) {
    return const InternalServerFailure();
  } else if (exception is CacheException) {
    return CacheFailure(exception.message, code: exception.code);
  } else if (exception is AuthException) {
    return AuthFailure(exception.message, code: exception.code);
  } else {
    return ServerFailure(
      'An unexpected error occurred: ${exception.toString()}',
    );
  }
}
