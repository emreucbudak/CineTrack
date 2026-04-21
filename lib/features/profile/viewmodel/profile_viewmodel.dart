import 'package:cinetrack/core/services/library_sync_service.dart';
import 'package:cinetrack/core/services/storage_service.dart';
import 'package:cinetrack/data/models/actor_models.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/actor_service.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final StorageService _storage;
  final LibrarySyncService _librarySyncService;
  final AuthService _authService;
  final MovieService _movieService;
  final ActorService _actorService;

  ProfileViewModel(
    this._storage,
    this._librarySyncService,
    this._authService,
    this._movieService,
    this._actorService,
  ) {
    _librarySyncService.addListener(_handleLibraryChanged);
    loadProfile();
  }

  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  int _favoritesCount = 0;
  int _followedActorsCount = 0;
  List<FavoriteMovie> _favoriteMovies = [];
  List<FollowedActor> _followedActors = [];

  // Frontend placeholder values until subscription endpoints are connected.
  bool _hasPremiumSubscription = false;
  DateTime? _subscriptionEndsAt;
  bool _isRefreshing = false;

  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get favoritesCount => _favoritesCount;
  int get followedActorsCount => _followedActorsCount;
  List<FavoriteMovie> get favoriteMovies => _favoriteMovies;
  List<FollowedActor> get followedActors => _followedActors;

  bool get hasPremiumSubscription => _hasPremiumSubscription;
  String get subscriptionPlanLabel =>
      _hasPremiumSubscription ? 'Premium' : 'Standart';
  String get subscriptionEndsAtLabel {
    if (!_hasPremiumSubscription || _subscriptionEndsAt == null) {
      return 'Süresiz';
    }

    final date = _subscriptionEndsAt!;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  Future<void> loadProfile() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _isLoading = true;
    notifyListeners();

    _userName = await _storage.getUsername() ?? 'Kullanıcı';
    _userEmail = await _storage.getEmail() ?? '';
    _hasPremiumSubscription = false;
    _subscriptionEndsAt = null;

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
    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _handleLibraryChanged() {
    loadProfile();
  }

  @override
  void dispose() {
    _librarySyncService.removeListener(_handleLibraryChanged);
    super.dispose();
  }
}
