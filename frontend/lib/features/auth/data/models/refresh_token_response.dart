class RefreshTokenResponse {
  final String token;
  final String refreshToken;

  RefreshTokenResponse({
    required this.token,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
    };
  }

  @override
  String toString() {
    return 'RefreshTokenResponse(token: ${token.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefreshTokenResponse &&
        other.token == token &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => token.hashCode ^ refreshToken.hashCode;
}