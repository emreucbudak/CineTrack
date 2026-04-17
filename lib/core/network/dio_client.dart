import 'package:dio/dio.dart';
import 'package:cinetrack/core/constants/api_constants.dart';
import 'package:cinetrack/core/services/storage_service.dart';

class DioClient {
  late final Dio _dio;
  final StorageService _storage;

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request
        final opts = error.requestOptions;
        final token = await _storage.getToken();
        opts.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }
    handler.next(error);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final token = await _storage.getToken();
      final refreshToken = await _storage.getRefreshToken();
      if (token == null || refreshToken == null) return false;

      final response = await Dio(
        BaseOptions(baseUrl: ApiConstants.baseUrl),
      ).post(
        ApiConstants.refreshToken,
        data: {
          'token': token,
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _storage.saveToken(data['token']);
        await _storage.saveRefreshToken(data['refreshToken']);
        return true;
      }
    } catch (_) {
      // Refresh failed, user needs to re-login
    }
    await _storage.clearAll();
    return false;
  }
}
