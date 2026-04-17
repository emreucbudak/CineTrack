import 'package:flutter/material.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/movie_service.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieService _movieService;

  HomeViewModel(this._movieService) {
    loadData();
  }

  bool _isLoading = true;
  String? _errorMessage;
  List<TrendingMovie> _trendingMovies = [];
  List<TrendingMovie> _discoverMovies = [];
  List<TrendingMovie> _weeklyTrending = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TrendingMovie> get trendingMovies => _trendingMovies;
  List<TrendingMovie> get discoverMovies => _discoverMovies;
  List<TrendingMovie> get weeklyTrending => _weeklyTrending;

  // Hero movie = first trending movie
  TrendingMovie? get heroMovie =>
      _trendingMovies.isNotEmpty ? _trendingMovies.first : null;

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

      if (_trendingMovies.isEmpty &&
          _discoverMovies.isEmpty &&
          _weeklyTrending.isEmpty) {
        _errorMessage = 'Filmler yüklenemedi. Lütfen internet bağlantınızı kontrol edin.';
      }
    } catch (e) {
      _errorMessage = 'Veriler yüklenemedi.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
