import 'package:flutter/material.dart';
import 'package:cinetrack/core/services/library_sync_service.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/movie_service.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final MovieService _movieService;
  final LibrarySyncService _librarySyncService;
  final int tmdbId;

  MovieDetailViewModel(
    this._movieService,
    this._librarySyncService,
    this.tmdbId,
  ) {
    loadMovie();
  }

  bool _isLoading = true;
  String? _errorMessage;
  MovieDetail? _movie;
  bool _isFavorite = false;
  bool _favoriteLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MovieDetail? get movie => _movie;
  bool get isFavorite => _isFavorite;
  bool get favoriteLoading => _favoriteLoading;

  Future<void> loadMovie() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _movie = await _movieService.getMovieDetail(tmdbId);
    if (_movie == null) {
      _errorMessage = 'Film detayları yüklenemedi.';
    } else {
      // Check if movie is in favorites
      await _checkFavoriteStatus();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final favResult = await _movieService.getFavorites(
        page: 1,
        pageSize: 100,
      );
      _isFavorite = favResult.items.any((f) => f.tmdbId == tmdbId);
    } catch (_) {
      // Ignore - might not be logged in
    }
  }

  Future<void> toggleFavorite() async {
    if (_movie == null || _favoriteLoading) return;

    _favoriteLoading = true;
    notifyListeners();

    if (_isFavorite) {
      final result = await _movieService.removeFavorite(tmdbId);
      if (result.success) {
        _isFavorite = false;
        _librarySyncService.notifyLibraryChanged();
      }
    } else {
      final result = await _movieService.addFavorite(
        tmdbId: tmdbId,
        title: _movie!.title,
        posterPath: _movie!.posterPath,
      );
      if (result.success) {
        _isFavorite = true;
        _librarySyncService.notifyLibraryChanged();
      }
    }

    _favoriteLoading = false;
    notifyListeners();
  }
}
