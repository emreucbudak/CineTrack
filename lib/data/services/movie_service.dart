import 'package:dio/dio.dart';
import 'package:cinetrack/core/constants/api_constants.dart';
import 'package:cinetrack/core/network/dio_client.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/models/api_response.dart';

class MovieService {
  final DioClient _client;

  MovieService(this._client);

  Future<List<TrendingMovie>> getTrending({String timeWindow = 'day'}) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.trending,
        queryParameters: {'timeWindow': timeWindow},
      );

      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list
            .map((e) => TrendingMovie.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (_) {
      // Fall through to return empty
    }
    return [];
  }

  Future<List<TrendingMovie>> getDiscover({int page = 1}) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.discover,
        queryParameters: {'page': page},
      );

      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list
            .map((e) => TrendingMovie.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (_) {
      // Fall through
    }
    return [];
  }

  Future<List<TrendingMovie>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.movieSearch,
        queryParameters: {'query': query, 'page': page},
      );

      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list
            .map((e) => TrendingMovie.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (_) {
      // Fall through
    }
    return [];
  }

  Future<MovieDetail?> getMovieDetail(int tmdbId) async {
    try {
      final response = await _client.dio.get(
        '${ApiConstants.movieDetail}/$tmdbId',
      );

      if (response.data['success'] == true) {
        return MovieDetail.fromJson(response.data['data']);
      }
    } on DioException catch (_) {
      // Fall through
    }
    return null;
  }

  Future<PaginatedResult<FavoriteMovie>> getFavorites({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.favorites,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.data['success'] == true) {
        return PaginatedResult.fromJson(
          response.data['data'],
          FavoriteMovie.fromJson,
        );
      }
    } on DioException catch (_) {
      // Fall through
    }
    return PaginatedResult(
      items: [],
      page: page,
      pageSize: pageSize,
      totalCount: 0,
      totalPages: 0,
    );
  }

  Future<({bool success, String? error})> addFavorite({
    required int tmdbId,
    required String title,
    String? posterPath,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.favorites,
        data: {'tmdbId': tmdbId, 'title': title, 'posterPath': posterPath},
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return (success: true, error: null);
      }
      return (
        success: false,
        error:
            (response.data['errorMessage'] as String?) ?? 'Favori eklenemedi.',
      );
    } on DioException catch (e) {
      return (
        success: false,
        error:
            (e.response?.data?['errorMessage'] as String?) ??
            'Bağlantı hatası.',
      );
    }
  }

  Future<({bool success, String? error})> removeFavorite(int tmdbId) async {
    try {
      final response = await _client.dio.delete(
        '${ApiConstants.favorites}/$tmdbId',
      );

      if (response.statusCode == 204) {
        return (success: true, error: null);
      }
      return (success: false, error: 'Favori kaldırılamadı.');
    } on DioException catch (e) {
      return (
        success: false,
        error:
            (e.response?.data?['errorMessage'] as String?) ??
            'Bağlantı hatası.',
      );
    }
  }
}
