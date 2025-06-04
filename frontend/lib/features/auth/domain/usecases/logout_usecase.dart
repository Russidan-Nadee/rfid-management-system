// Path: frontend/lib/features/auth/domain/usecases/logout_usecase.dart
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<LogoutResult> execute() async {
    try {
      // Check if user is logged in
      final isAuthenticated = await repository.isAuthenticated();
      if (!isAuthenticated) {
        return LogoutResult.success('Already logged out');
      }

      // Perform logout
      await repository.logout();

      return LogoutResult.success('Logout successful');
    } catch (e) {
      // Even if logout fails, we should clear local data
      try {
        await repository.clearAuthData();
      } catch (_) {
        // Ignore error in clearing local data
      }

      return LogoutResult.failure('Logout failed: ${e.toString()}');
    }
  }
}

class LogoutResult {
  final bool success;
  final String message;
  final String? errorMessage;

  LogoutResult({
    required this.success,
    required this.message,
    this.errorMessage,
  });

  factory LogoutResult.success(String message) {
    return LogoutResult(success: true, message: message);
  }

  factory LogoutResult.failure(String errorMessage) {
    return LogoutResult(
      success: false,
      message: 'Logout failed',
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'LogoutResult(success: $success, message: $message, errorMessage: $errorMessage)';
  }
}
