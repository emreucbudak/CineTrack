enum AuthOperationStatus { success, pending, failure }

class AuthResult<T> {
  final AuthOperationStatus status;
  final T? data;
  final String? message;
  final String? error;

  const AuthResult._({
    required this.status,
    this.data,
    this.message,
    this.error,
  });

  const AuthResult.success({T? data, String? message})
    : this._(status: AuthOperationStatus.success, data: data, message: message);

  const AuthResult.pending({T? data, String? message})
    : this._(status: AuthOperationStatus.pending, data: data, message: message);

  const AuthResult.failure({String? error, String? message})
    : this._(
        status: AuthOperationStatus.failure,
        error: error,
        message: message,
      );

  bool get success => status == AuthOperationStatus.success;
  bool get isPending => status == AuthOperationStatus.pending;
  bool get failed => status == AuthOperationStatus.failure;
}

typedef PendingAuthResult = AuthResult<PendingVerificationResponse>;
typedef TokenAuthResult = AuthResult<AuthTokenResponse>;
typedef MessageAuthResult = AuthResult<AuthMessageResponse>;

class PendingVerificationResponse {
  final String temporaryToken;
  final String expiresAt;
  final String email;

  const PendingVerificationResponse({
    required this.temporaryToken,
    required this.expiresAt,
    required this.email,
  });

  DateTime? get expiryDateTime => DateTime.tryParse(expiresAt);

  factory PendingVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PendingVerificationResponse(
      temporaryToken: _readString(json['temporaryToken']),
      expiresAt: _readString(json['expiresAt']),
      email: _readString(json['email']),
    );
  }
}

class AuthTokenResponse {
  final String token;
  final String expiresAt;
  final String refreshToken;
  final String refreshTokenExpiresAt;

  const AuthTokenResponse({
    required this.token,
    required this.expiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  DateTime? get tokenExpiryDateTime => DateTime.tryParse(expiresAt);
  DateTime? get refreshTokenExpiryDateTime =>
      DateTime.tryParse(refreshTokenExpiresAt);

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      token: _readString(json['token']),
      expiresAt: _readString(json['expiresAt']),
      refreshToken: _readString(json['refreshToken']),
      refreshTokenExpiresAt: _readString(json['refreshTokenExpiresAt']),
    );
  }
}

class AuthMessageResponse {
  final String message;

  const AuthMessageResponse({required this.message});

  factory AuthMessageResponse.fromJson(Map<String, dynamic> json) {
    return AuthMessageResponse(
      message: _readString(json['message']).isNotEmpty
          ? _readString(json['message'])
          : _readString(json['successMessage']),
    );
  }
}

class UserResponse {
  final String id;
  final String email;
  final String username;
  final String createdAt;

  const UserResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: _readString(json['id']),
      email: _readString(json['email']),
      username: _readString(json['username']),
      createdAt: _readString(json['createdAt']),
    );
  }
}

String _readString(dynamic value) => value?.toString() ?? '';
