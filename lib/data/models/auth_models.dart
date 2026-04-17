class AuthTokenResponse {
  final String token;
  final String expiresAt;
  final String refreshToken;
  final String refreshTokenExpiresAt;

  AuthTokenResponse({
    required this.token,
    required this.expiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      token: json['token'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] ?? '',
    );
  }
}

class UserResponse {
  final String id;
  final String email;
  final String username;
  final String createdAt;

  UserResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
