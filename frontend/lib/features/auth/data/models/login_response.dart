// Path: frontend/lib/features/auth/data/models/login_response.dart
import 'user_model.dart';

class LoginResponse {
  final String token;
  final UserModel user;
  final String sessionId;

  LoginResponse({
    required this.token,
    required this.user,
    required this.sessionId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      sessionId: json['sessionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson(), 'sessionId': sessionId};
  }

  @override
  String toString() {
    return 'LoginResponse(token: ${token.substring(0, 10)}..., user: $user, sessionId: $sessionId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse &&
        other.token == token &&
        other.user == user &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode => token.hashCode ^ user.hashCode ^ sessionId.hashCode;
}
