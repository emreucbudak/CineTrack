import 'package:cinetrack/core/services/storage_service.dart';
import 'package:cinetrack/data/models/actor_models.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/actor_service.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final StorageService _storage;
  final AuthService _authService;
  final MovieService _movieService;
  final ActorService _actorService;

  ProfileViewModel(
    this._storage,
    this._authService,
    this._movieService,
    this._actorService,
  ) {
    loadProfile();
  }

  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  int _favoritesCount = 0;
  int _followedActorsCount = 0;
  List<FavoriteMovie> _favoriteMovies = [];
  List<FollowedActor> _followedActors = [];

  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get favoritesCount => _favoritesCount;
  int get followedActorsCount => _followedActorsCount;
  List<FavoriteMovie> get favoriteMovies => _favoriteMovies;
  List<FollowedActor> get followedActors => _followedActors;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    _userName = await _storage.getUsername() ?? 'Kullanıcı';
    _userEmail = await _storage.getEmail() ?? '';

    try {
      final favoriteResult = await _movieService.getFavorites(
        page: 1,
        pageSize: 100,
      );
      _favoriteMovies = favoriteResult.items;
      _favoritesCount = favoriteResult.totalCount;
    } catch (_) {
      _favoriteMovies = [];
      _favoritesCount = 0;
    }

    try {
      final followedResult = await _actorService.getFollowedActors(
        page: 1,
        pageSize: 100,
      );
      _followedActors = followedResult.items;
      _followedActorsCount = followedResult.totalCount;
    } catch (_) {
      _followedActors = [];
      _followedActorsCount = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
