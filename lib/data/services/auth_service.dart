import 'dart:convert';

import 'package:cinetrack/core/constants/api_constants.dart';
import 'package:cinetrack/core/network/dio_client.dart';
import 'package:cinetrack/core/services/storage_service.dart';
import 'package:cinetrack/data/models/auth_models.dart';
import 'package:dio/dio.dart';

class AuthService {
  final DioClient _client;
  final StorageService _storage;

  AuthService(this._client, this._storage);

  Future<PendingAuthResult> login({
    required String email,
    required String password,
  }) async {
    return _submitPendingStep(
      endpoint: ApiConstants.login,
      payload: {'email': email, 'password': password},
      fallbackError: 'Giriş isteği başarısız.',
      fallbackPendingMessage: 'Doğrulama kodu gönderildi.',
    );
  }

  Future<TokenAuthResult> verifyLoginCode({
    required String temporaryToken,
    required String code,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.verifyLogin,
        data: {'temporaryToken': temporaryToken, 'code': code},
      );

      final body = _asMap(response.data);
      if (_isSuccess(body)) {
        final token = AuthTokenResponse.fromJson(_extractPayload(body));
        if (token.token.isEmpty) {
          return const AuthResult.failure(
            error: 'Sunucudan geçerli oturum bilgisi alınamadı.',
          );
        }

        await _persistAuthSession(token);

        return AuthResult.success(
          data: token,
          message: _extractMessage(body) ?? 'Giriş doğrulandı.',
        );
      }

      return AuthResult.failure(
        error: _extractError(body) ?? 'Giriş doğrulaması başarısız.',
        message: _extractMessage(body),
      );
    } on DioException catch (e) {
      return AuthResult.failure(
        error: _extractDioError(e, 'Giriş doğrulaması başarısız.'),
        message: _extractMessage(_asMap(e.response?.data)),
      );
    }
  }

  Future<PendingAuthResult> register({
    required String email,
    required String username,
    required String password,
  }) async {
    return _submitPendingStep(
      endpoint: ApiConstants.register,
      payload: {'email': email, 'username': username, 'password': password},
      fallbackError: 'Kayıt isteği başarısız.',
      fallbackPendingMessage: 'Kayıt doğrulama kodu gönderildi.',
    );
  }

  Future<MessageAuthResult> verifyRegisterCode({
    required String temporaryToken,
    required String code,
  }) async {
    return _submitMessageStep(
      endpoint: ApiConstants.verifyRegister,
      payload: {'temporaryToken': temporaryToken, 'code': code},
      fallbackError: 'Kayıt doğrulaması başarısız.',
      fallbackSuccessMessage: 'Kayıt doğrulandı.',
    );
  }

  Future<PendingAuthResult> requestPasswordReset({
    required String email,
    required String newPassword,
  }) async {
    return _submitPendingStep(
      endpoint: ApiConstants.forgotPassword,
      payload: {'email': email, 'newPassword': newPassword},
      fallbackError: 'Şifre sıfırlama isteği başarısız.',
      fallbackPendingMessage: 'Şifre sıfırlama kodu gönderildi.',
    );
  }

  Future<MessageAuthResult> verifyPasswordResetCode({
    required String temporaryToken,
    required String code,
  }) async {
    return _submitMessageStep(
      endpoint: ApiConstants.verifyForgotPassword,
      payload: {
        'temporaryToken': temporaryToken,
        'code': code,
      },
      fallbackError: 'Şifre sıfırlama doğrulaması başarısız.',
      fallbackSuccessMessage: 'Şifreniz başarıyla güncellendi.',
    );
  }

  Future<AuthResult<void>> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _client.dio.post(
            ApiConstants.revokeToken,
            data: {'refreshToken': refreshToken},
          );
        } on DioException {
          // Local sign-out should still succeed even if revoke fails.
        }
      }

      await _storage.clearAll();

      return const AuthResult.success(message: 'Oturum kapatıldı.');
    } catch (_) {
      return const AuthResult.failure(
        error: 'Oturum kapatılırken bir hata oluştu.',
      );
    }
  }

  Future<PendingAuthResult> _submitPendingStep({
    required String endpoint,
    required Map<String, dynamic> payload,
    required String fallbackError,
    required String fallbackPendingMessage,
  }) async {
    try {
      final response = await _client.dio.post(endpoint, data: payload);
      final body = _asMap(response.data);

      if (_isSuccess(body)) {
        final pending = PendingVerificationResponse.fromJson(
          _extractPayload(body),
        );

        if (pending.temporaryToken.isEmpty) {
          return const AuthResult.failure(
            error: 'Sunucudan geçerli doğrulama bilgisi alınamadı.',
          );
        }

        return AuthResult.pending(
          data: pending,
          message: _extractMessage(body) ?? fallbackPendingMessage,
        );
      }

      return AuthResult.failure(
        error: _extractError(body) ?? fallbackError,
        message: _extractMessage(body),
      );
    } on DioException catch (e) {
      return AuthResult.failure(
        error: _extractDioError(e, fallbackError),
        message: _extractMessage(_asMap(e.response?.data)),
      );
    }
  }

  Future<MessageAuthResult> _submitMessageStep({
    required String endpoint,
    required Map<String, dynamic> payload,
    required String fallbackError,
    required String fallbackSuccessMessage,
  }) async {
    try {
      final response = await _client.dio.post(endpoint, data: payload);
      final body = _asMap(response.data);

      if (_isSuccess(body)) {
        final payloadMap = _extractPayload(body);
        final messageResponse = payloadMap.isNotEmpty
            ? AuthMessageResponse.fromJson(payloadMap)
            : AuthMessageResponse(
                message: _extractMessage(body) ?? fallbackSuccessMessage,
              );
        final message = messageResponse.message.isNotEmpty
            ? messageResponse.message
            : _extractMessage(body) ?? fallbackSuccessMessage;

        return AuthResult.success(
          data: AuthMessageResponse(message: message),
          message: message,
        );
      }

      return AuthResult.failure(
        error: _extractError(body) ?? fallbackError,
        message: _extractMessage(body),
      );
    } on DioException catch (e) {
      return AuthResult.failure(
        error: _extractDioError(e, fallbackError),
        message: _extractMessage(_asMap(e.response?.data)),
      );
    }
  }

  Future<void> _persistAuthSession(AuthTokenResponse token) async {
    await _storage.saveToken(token.token);

    if (token.refreshToken.isNotEmpty) {
      await _storage.saveRefreshToken(token.refreshToken);
    } else {
      await _storage.deleteRefreshToken();
    }

    final parts = token.token.split('.');
    if (parts.length != 3) {
      return;
    }

    final payload = _decodeJwtPayload(parts[1]);
    if (payload == null) {
      return;
    }

    await _storage.saveUserInfo(
      userId:
          _firstNonBlank([payload['sub'], payload['nameid'], payload['id']]) ??
          '',
      username:
          _firstNonBlank([
            payload['username'],
            payload['unique_name'],
            payload['name'],
          ]) ??
          '',
      email: _firstNonBlank([payload['email']]) ?? '',
    );
  }

  bool _isSuccess(Map<String, dynamic> body) => body['success'] == true;

  Map<String, dynamic> _extractPayload(Map<String, dynamic> body) =>
      _asMap(body['data']);

  String? _extractMessage(Map<String, dynamic> body) {
    final data = body['data'];
    final payload = _asMap(data);

    return _firstNonBlank([
      body['message'],
      body['successMessage'],
      data is String ? data : null,
      payload['message'],
      payload['successMessage'],
    ]);
  }

  String? _extractError(Map<String, dynamic> body) {
    final payload = _asMap(body['data']);

    return _firstNonBlank([
      body['errorMessage'],
      body['message'],
      payload['errorMessage'],
      payload['message'],
    ]);
  }

  String _extractDioError(DioException error, String fallback) {
    final responseData = error.response?.data;
    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData.trim();
    }

    return _extractError(_asMap(responseData)) ?? fallback;
  }

  Map<String, dynamic>? _decodeJwtPayload(String base64Payload) {
    try {
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(base64Payload)),
      );
      return _asMap(jsonDecode(decoded));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    return <String, dynamic>{};
  }

  String? _firstNonBlank(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }
}
