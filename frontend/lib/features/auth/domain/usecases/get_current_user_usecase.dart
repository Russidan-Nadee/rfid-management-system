// Path: frontend/lib/features/auth/domain/usecases/get_current_user_usecase.dart
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<String> execute() async {
    try {
      final userId = await repository.getCurrentUserId();

      if (userId != null && userId.isNotEmpty) {
        return userId;
      }

      // If no user is logged in, return system user
      return 'SYSTEM';
    } catch (e) {
      // If any error occurs, fallback to system user
      return 'SYSTEM';
    }
  }
}
