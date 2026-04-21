import 'package:dio/dio.dart';
import 'package:cinetrack/core/constants/api_constants.dart';
import 'package:cinetrack/core/network/dio_client.dart';
import 'package:cinetrack/data/models/actor_models.dart';
import 'package:cinetrack/data/models/api_response.dart';

class ActorService {
  final DioClient _client;

  ActorService(this._client);

  Future<List<SearchPerson>> searchActors({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.actorSearch,
        queryParameters: {'query': query, 'page': page},
      );

      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list
            .map((e) => SearchPerson.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (_) {
      // Fall through
    }
    return [];
  }

  Future<PersonDetail?> getActorDetail(int personId) async {
    try {
      final response = await _client.dio.get(
        '${ApiConstants.actorDetail}/$personId',
      );

      if (response.data['success'] == true) {
        return PersonDetail.fromJson(response.data['data']);
      }
    } on DioException catch (_) {
      // Fall through
    }
    return null;
  }

  Future<PaginatedResult<FollowedActor>> getFollowedActors({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.followedActors,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.data['success'] == true) {
        return PaginatedResult.fromJson(
          response.data['data'],
          FollowedActor.fromJson,
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

  Future<({bool success, String? error})> followActor({
    required int tmdbId,
    required String name,
    String? profilePath,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.followedActors,
        data: {'tmdbId': tmdbId, 'name': name, 'profilePath': profilePath},
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return (success: true, error: null);
      }
      return (
        success: false,
        error:
            (response.data['errorMessage'] as String?) ??
            'Oyuncu takip edilemedi.',
      );
    } on DioException catch (e) {
      return (
        success: false,
        error: _extractErrorMessage(e.response?.data) ?? 'Bağlantı hatası.',
      );
    }
  }

  Future<({bool success, String? error})> unfollowActor(int tmdbId) async {
    try {
      final response = await _client.dio.delete(
        '${ApiConstants.followedActors}/$tmdbId',
      );

      if (response.statusCode == 204) {
        return (success: true, error: null);
      }
      return (success: false, error: 'Oyuncu takibi kaldırılamadı.');
    } on DioException catch (e) {
      return (
        success: false,
        error: _extractErrorMessage(e.response?.data) ?? 'Bağlantı hatası.',
      );
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is String) {
      final text = data.trim();
      return text.isEmpty ? null : text;
    }

    if (data is Map<String, dynamic>) {
      final error =
          data['errorMessage'] ??
          data['message'] ??
          (data['data'] is Map<String, dynamic>
              ? (data['data'] as Map<String, dynamic>)['errorMessage'] ??
                    (data['data'] as Map<String, dynamic>)['message']
              : null);

      return error is String && error.trim().isNotEmpty ? error.trim() : null;
    }

    return null;
  }
}
