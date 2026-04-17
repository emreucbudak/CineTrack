import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/movie_service.dart';

enum SearchTab { all, movies, actors }

class SearchViewModel extends ChangeNotifier {
  final MovieService _movieService;

  SearchViewModel(this._movieService) {
    loadInitialData();
  }

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  SearchTab _selectedTab = SearchTab.all;
  SearchTab get selectedTab => _selectedTab;

  String get query => searchController.text.trim();
  bool get hasQuery => query.isNotEmpty;

  bool _isLoading = true;
  List<TrendingMovie> _trendingMovies = [];
  List<TrendingMovie> _discoverMovies = [];

  bool get isLoading => _isLoading;
  List<TrendingMovie> get trendingMovies => _trendingMovies;
  List<TrendingMovie> get discoverMovies => _discoverMovies;

  // Filter movies based on search query
  List<TrendingMovie> get filteredMovies {
    final all = [..._trendingMovies, ..._discoverMovies];
    if (!hasQuery) return all;
    final q = query.toLowerCase();
    return all.where((m) => m.title.toLowerCase().contains(q)).toList();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _movieService.getTrending(timeWindow: 'day'),
      _movieService.getDiscover(page: 1),
    ]);

    _trendingMovies = results[0];
    _discoverMovies = results[1];

    _isLoading = false;
    notifyListeners();
  }

  void onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
  }

  void selectTab(SearchTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
