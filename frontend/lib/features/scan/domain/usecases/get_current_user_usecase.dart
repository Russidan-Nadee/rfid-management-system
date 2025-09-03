// Path: lib/features/auth/domain/usecases/get_current_user_usecase.dart
import 'package:tp_rfid/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<String> execute() async {
    final user = await repository.getCurrentUser();
    if (user != null) {
      return user.userId;
    }
    throw Exception('No authenticated user found');
  }
}
