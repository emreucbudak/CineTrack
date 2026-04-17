class ApiConstants {
  ApiConstants._();

  // CineTrack Backend API
  // Physical device default is the current LAN IP. Override with
  // --dart-define=API_BASE_URL=http://<host>:<port>/api/v1 when needed.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.115:5000/api/v1',
  );

  // TMDB Image Base URLs
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p';
  static const String posterW500 = '$tmdbImageBase/w500';
  static const String posterW342 = '$tmdbImageBase/w342';
  static const String posterW185 = '$tmdbImageBase/w185';
  static const String backdropW780 = '$tmdbImageBase/w780';
  static const String profileW185 = '$tmdbImageBase/w185';
  static const String profileW45 = '$tmdbImageBase/w45';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String revokeToken = '/auth/revoke';

  // Movie Endpoints
  static const String trending = '/movies/trending';
  static const String discover = '/movies/discover';
  static const String movieSearch = '/movies/search';
  static const String movieDetail = '/movies'; // /{tmdbId}
  static const String favorites = '/movies/favorites';

  // Actor Endpoints
  static const String actorDetail = '/actors'; // /{personId}
  static const String actorSearch = '/actors/search';
  static const String followedActors = '/actors/followed';

  /// Build full poster URL from TMDB relative path
  static String posterUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$posterW500$path';
  }

  /// Build full backdrop URL from TMDB relative path
  static String backdropUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$backdropW780$path';
  }

  /// Build full profile URL from TMDB relative path
  static String profileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$profileW185$path';
  }
}
