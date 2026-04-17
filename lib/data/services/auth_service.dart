import 'package:dio/dio.dart';
import 'package:cinetrack/core/constants/api_constants.dart';
import 'package:cinetrack/core/network/dio_client.dart';
import 'package:cinetrack/core/services/storage_service.dart';
import 'package:cinetrack/data/models/auth_models.dart';

class AuthService {
  final DioClient _client;
  final StorageService _storage;

  AuthService(this._client, this._storage);

  Future<({bool success, String? error})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final token = AuthTokenResponse.fromJson(response.data['data']);
        await _storage.saveToken(token.token);
        await _storage.saveRefreshToken(token.refreshToken);

        // Decode basic user info from JWT payload
        final parts = token.token.split('.');
        if (parts.length == 3) {
          final payload = _decodeJwtPayload(parts[1]);
          if (payload != null) {
            await _storage.saveUserInfo(
              userId: payload['sub'] ?? '',
              username: payload['username'] ?? '',
              email: payload['email'] ?? '',
            );
          }
        }
        return (success: true, error: null);
      }
      return (
        success: false,
        error: (response.data['errorMessage'] as String?) ?? 'Giriş başarısız.',
      );
    } on DioException catch (e) {
      return (
        success: false,
        error: (e.response?.data?['errorMessage'] as String?) ?? 'Bağlantı hatası.',
      );
    }
  }

  Future<({bool success, String? error})> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return (success: true, error: null);
      }
      return (
        success: false,
        error: (response.data['errorMessage'] as String?) ?? 'Kayıt işlemi başarısız.',
      );
    } on DioException catch (e) {
      return (
        success: false,
        error: (e.response?.data?['errorMessage'] as String?) ?? 'Bağlantı hatası.',
      );
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _client.dio.post(
          ApiConstants.revokeToken,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Ignore revoke errors
    } finally {
      await _storage.clearAll();
    }
  }

  Map<String, dynamic>? _decodeJwtPayload(String base64Payload) {
    try {
      String normalized = base64Payload.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      final bytes = _base64Decode(normalized);
      final jsonStr = String.fromCharCodes(bytes);
      return _parseSimpleJson(jsonStr);
    } catch (_) {
      return null;
    }
  }

  List<int> _base64Decode(String input) {
    // Use dart:convert indirectly through Uri
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final output = <int>[];
    var buffer = 0;
    var bits = 0;
    for (final char in input.codeUnits) {
      if (char == 61) break; // '='
      final val = chars.indexOf(String.fromCharCode(char));
      if (val == -1) continue;
      buffer = (buffer << 6) | val;
      bits += 6;
      if (bits >= 8) {
        bits -= 8;
        output.add((buffer >> bits) & 0xFF);
      }
    }
    return output;
  }

  Map<String, dynamic>? _parseSimpleJson(String json) {
    try {
      // Use RegExp to extract key-value pairs
      final map = <String, dynamic>{};
      final regex = RegExp(r'"(\w+)"\s*:\s*"([^"]*)"');
      for (final match in regex.allMatches(json)) {
        map[match.group(1)!] = match.group(2)!;
      }
      return map;
    } catch (_) {
      return null;
    }
  }
}
