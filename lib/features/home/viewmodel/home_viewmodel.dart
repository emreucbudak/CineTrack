import 'dart:math';

import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieService _movieService;
  final Random _random = Random();

  HomeViewModel(this._movieService) {
    loadData();
  }

  bool _isLoading = true;
  String? _errorMessage;
  List<TrendingMovie> _trendingMovies = [];
  List<TrendingMovie> _discoverMovies = [];
  List<TrendingMovie> _weeklyTrending = [];
  TrendingMovie? _movieOfTheDay;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TrendingMovie> get trendingMovies => _trendingMovies;
  List<TrendingMovie> get discoverMovies => _discoverMovies;
  List<TrendingMovie> get weeklyTrending => _weeklyTrending;
  TrendingMovie? get movieOfTheDay => _movieOfTheDay;

  List<TrendingMovie> get _allMovies {
    final seenIds = <int>{};
    return [
      ..._trendingMovies,
      ..._discoverMovies,
      ..._weeklyTrending,
    ].where((movie) => seenIds.add(movie.id)).toList();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _movieService.getTrending(timeWindow: 'day'),
        _movieService.getDiscover(page: 1),
        _movieService.getTrending(timeWindow: 'week'),
      ]);

      _trendingMovies = results[0];
      _discoverMovies = results[1];
      _weeklyTrending = results[2];
      _selectMovieOfTheDay(notify: false);

      if (_allMovies.isEmpty) {
        _errorMessage =
            'Filmler yüklenemedi. Lütfen internet bağlantınızı kontrol edin.';
      }
    } catch (_) {
      _errorMessage = 'Veriler yüklenemedi.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void pickRandomMovie() {
    _selectMovieOfTheDay();
  }

  void _selectMovieOfTheDay({bool notify = true}) {
    final movies = _allMovies;

    if (movies.isEmpty) {
      _movieOfTheDay = null;
      if (notify) {
        notifyListeners();
      }
      return;
    }

    if (movies.length == 1) {
      _movieOfTheDay = movies.first;
      if (notify) {
        notifyListeners();
      }
      return;
    }

    TrendingMovie nextMovie = movies[_random.nextInt(movies.length)];
    while (nextMovie.id == _movieOfTheDay?.id) {
      nextMovie = movies[_random.nextInt(movies.length)];
    }

    _movieOfTheDay = nextMovie;

    if (notify) {
      notifyListeners();
    }
  }
}
