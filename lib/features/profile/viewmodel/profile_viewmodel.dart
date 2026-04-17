import 'package:flutter/material.dart';
import 'package:cinetrack/core/services/storage_service.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:cinetrack/data/services/actor_service.dart';

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

  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get favoritesCount => _favoritesCount;
  int get followedActorsCount => _followedActorsCount;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    _userName = await _storage.getUsername() ?? 'Kullanıcı';
    _userEmail = await _storage.getEmail() ?? '';

    try {
      final favResult = await _movieService.getFavorites(page: 1, pageSize: 1);
      _favoritesCount = favResult.totalCount;
    } catch (_) {}

    try {
      final followResult = await _actorService.getFollowedActors(page: 1, pageSize: 1);
      _followedActorsCount = followResult.totalCount;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
