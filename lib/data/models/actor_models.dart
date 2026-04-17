import 'package:cinetrack/core/constants/api_constants.dart';

class PersonDetail {
  final int id;
  final String name;
  final String? biography;
  final String? profilePath;
  final String? birthday;
  final String? placeOfBirth;
  final String? knownForDepartment;
  final List<MovieCredit> movieCredits;

  PersonDetail({
    required this.id,
    required this.name,
    this.biography,
    this.profilePath,
    this.birthday,
    this.placeOfBirth,
    this.knownForDepartment,
    required this.movieCredits,
  });

  String get profileUrl => ApiConstants.profileUrl(profilePath);

  factory PersonDetail.fromJson(Map<String, dynamic> json) {
    return PersonDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      biography: json['biography'],
      profilePath: json['profilePath'],
      birthday: json['birthday'],
      placeOfBirth: json['placeOfBirth'],
      knownForDepartment: json['knownForDepartment'],
      movieCredits:
          (json['movieCredits'] as List?)
              ?.map((e) => MovieCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MovieCredit {
  final int id;
  final String title;
  final String? character;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;

  MovieCredit({
    required this.id,
    required this.title,
    this.character,
    this.posterPath,
    this.releaseDate,
    required this.voteAverage,
  });

  String get posterUrl => ApiConstants.posterUrl(posterPath);
  String get year => releaseDate != null && releaseDate!.length >= 4
      ? releaseDate!.substring(0, 4)
      : '';
  String get ratingStr => voteAverage.toStringAsFixed(1);

  factory MovieCredit.fromJson(Map<String, dynamic> json) {
    return MovieCredit(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      character: json['character'],
      posterPath: json['posterPath'],
      releaseDate: json['releaseDate'],
      voteAverage: (json['voteAverage'] ?? 0).toDouble(),
    );
  }
}

class FollowedActor {
  final String id;
  final int tmdbId;
  final String name;
  final String? profilePath;
  final String followedAt;

  FollowedActor({
    required this.id,
    required this.tmdbId,
    required this.name,
    this.profilePath,
    required this.followedAt,
  });

  String get profileUrl => ApiConstants.profileUrl(profilePath);

  factory FollowedActor.fromJson(Map<String, dynamic> json) {
    return FollowedActor(
      id: json['id'] ?? '',
      tmdbId: json['tmdbId'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profilePath'],
      followedAt: json['followedAt'] ?? '',
    );
  }
}

class SearchPerson {
  final int id;
  final String name;
  final String? profilePath;
  final String? knownForDepartment;

  SearchPerson({
    required this.id,
    required this.name,
    this.profilePath,
    this.knownForDepartment,
  });

  String get profileUrl => ApiConstants.profileUrl(profilePath);

  factory SearchPerson.fromJson(Map<String, dynamic> json) {
    return SearchPerson(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profilePath'],
      knownForDepartment: json['knownForDepartment'],
    );
  }
}
