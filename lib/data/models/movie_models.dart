import 'package:cinetrack/core/constants/api_constants.dart';

class TrendingMovie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;

  TrendingMovie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.releaseDate,
    required this.voteAverage,
  });

  String get posterUrl => ApiConstants.posterUrl(posterPath);
  String get year => releaseDate != null && releaseDate!.length >= 4
      ? releaseDate!.substring(0, 4)
      : '';
  String get ratingStr => voteAverage.toStringAsFixed(1);

  factory TrendingMovie.fromJson(Map<String, dynamic> json) {
    return TrendingMovie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'],
      posterPath: json['posterPath'],
      releaseDate: json['releaseDate'],
      voteAverage: (json['voteAverage'] ?? 0).toDouble(),
    );
  }
}

class MovieDetail {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<Genre> genres;
  final List<CastMemberDto> cast;

  MovieDetail({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genres,
    required this.cast,
  });

  String get posterUrl => ApiConstants.posterUrl(posterPath);
  String get backdropUrl => ApiConstants.backdropUrl(backdropPath);
  String get year => releaseDate != null && releaseDate!.length >= 4
      ? releaseDate!.substring(0, 4)
      : '';
  String get ratingStr => voteAverage.toStringAsFixed(1);

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'],
      posterPath: json['posterPath'],
      backdropPath: json['backdropPath'],
      releaseDate: json['releaseDate'],
      voteAverage: (json['voteAverage'] ?? 0).toDouble(),
      voteCount: json['voteCount'] ?? 0,
      genres: (json['genres'] as List?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cast: (json['cast'] as List?)
              ?.map((e) => CastMemberDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CastMemberDto {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int order;

  CastMemberDto({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    required this.order,
  });

  String get profileUrl => ApiConstants.profileUrl(profilePath);

  factory CastMemberDto.fromJson(Map<String, dynamic> json) {
    return CastMemberDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'],
      profilePath: json['profilePath'],
      order: json['order'] ?? 0,
    );
  }
}

class FavoriteMovie {
  final String id;
  final int tmdbId;
  final String title;
  final String? posterPath;
  final String addedAt;

  FavoriteMovie({
    required this.id,
    required this.tmdbId,
    required this.title,
    this.posterPath,
    required this.addedAt,
  });

  String get posterUrl => ApiConstants.posterUrl(posterPath);

  factory FavoriteMovie.fromJson(Map<String, dynamic> json) {
    return FavoriteMovie(
      id: json['id'] ?? '',
      tmdbId: json['tmdbId'] ?? 0,
      title: json['title'] ?? '',
      posterPath: json['posterPath'],
      addedAt: json['addedAt'] ?? '',
    );
  }
}
