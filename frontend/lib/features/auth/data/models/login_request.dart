// Path: frontend/lib/features/auth/data/models/login_request.dart
class LoginRequest {
  final String ldapUsername;
  final String password;

  LoginRequest({required this.ldapUsername, required this.password});

  Map<String, dynamic> toJson() {
    return {'ldap_username': ldapUsername, 'password': password};
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      ldapUsername: json['ldap_username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  @override
  String toString() {
    return 'LoginRequest(ldapUsername: $ldapUsername, password: [HIDDEN])';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.ldapUsername == ldapUsername &&
        other.password == password;
  }

  @override
  int get hashCode => ldapUsername.hashCode ^ password.hashCode;
}
