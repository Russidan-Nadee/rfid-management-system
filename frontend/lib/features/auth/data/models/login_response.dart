// Path: frontend/lib/features/auth/data/models/login_response.dart
import 'user_model.dart';

class LoginResponse {
  final String? token; // Optional for backward compatibility
  final String? refreshToken; // Optional for backward compatibility
  final UserModel user;
  final String sessionId;
  final String? expiresAt; // Session expiry time

  LoginResponse({
    this.token,
    this.refreshToken,
    required this.user,
    required this.sessionId,
    this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle both new session-based and old token-based responses
    final data = json['data'] ?? json;
    return LoginResponse(
      token: data['token'], // Optional - may be null in new system
      refreshToken: data['refreshToken'] ?? data['refresh_token'],
      user: UserModel.fromJson(data['user'] ?? {}),
      sessionId: data['sessionId'] ?? '',
      expiresAt: data['expiresAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'sessionId': sessionId,
      'expiresAt': expiresAt,
    };
  }

  @override
  String toString() {
    return 'LoginResponse(token: ${token?.substring(0, 10) ?? 'null'}..., refreshToken: ${refreshToken?.substring(0, 10) ?? 'null'}..., user: $user, sessionId: $sessionId, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse &&
        other.token == token &&
        other.refreshToken == refreshToken &&
        other.user == user &&
        other.sessionId == sessionId &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode => token.hashCode ^ refreshToken.hashCode ^ user.hashCode ^ sessionId.hashCode ^ expiresAt.hashCode;
}
