import 'dart:async';

import 'package:cinetrack/data/models/actor_models.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/actor_service.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:flutter/material.dart';

enum SearchTab { all, movies, actors }

class SearchViewModel extends ChangeNotifier {
  final MovieService _movieService;
  final ActorService _actorService;

  SearchViewModel(this._movieService, this._actorService) {
    loadInitialData();
  }

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  SearchTab _selectedTab = SearchTab.all;
  int _searchRequestId = 0;
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;
  List<TrendingMovie> _trendingMovies = [];
  List<TrendingMovie> _discoverMovies = [];
  List<TrendingMovie> _movieResults = [];
  List<SearchPerson> _actorResults = [];

  SearchTab get selectedTab => _selectedTab;
  String get query => searchController.text.trim();
  bool get hasQuery => query.isNotEmpty;
  bool get isLoading => _isLoading || _isSearching;
  String? get errorMessage => _errorMessage;
  List<SearchPerson> get actorResults => _actorResults;

  List<TrendingMovie> get movieResults {
    if (hasQuery) return _movieResults;

    final seenIds = <int>{};
    return [
      ..._trendingMovies,
      ..._discoverMovies,
    ].where((movie) => seenIds.add(movie.id)).toList();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _movieService.getTrending(timeWindow: 'day'),
        _movieService.getDiscover(page: 1),
      ]);

      _trendingMovies = results[0];
      _discoverMovies = results[1];
    } catch (_) {
      _errorMessage = 'Arama verileri yüklenemedi.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final currentQuery = query;
    final currentTab = _selectedTab;
    final requestId = ++_searchRequestId;

    if (currentQuery.isEmpty) {
      _movieResults = [];
      _actorResults = [];
      _isSearching = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final movieFuture = currentTab == SearchTab.actors
          ? Future.value(<TrendingMovie>[])
          : _movieService.searchMovies(query: currentQuery);
      final actorFuture = currentTab == SearchTab.movies
          ? Future.value(<SearchPerson>[])
          : _actorService.searchActors(query: currentQuery);

      final results = await Future.wait<Object>([movieFuture, actorFuture]);

      if (requestId != _searchRequestId) return;

      _movieResults = results[0] as List<TrendingMovie>;
      _actorResults = results[1] as List<SearchPerson>;
    } catch (_) {
      if (requestId != _searchRequestId) return;

      _movieResults = [];
      _actorResults = [];
      _errorMessage = 'Arama sonuçları getirilemedi.';
    }

    if (requestId != _searchRequestId) return;

    _isSearching = false;
    notifyListeners();
  }

  void selectTab(SearchTab tab) {
    if (_selectedTab == tab) return;

    _selectedTab = tab;

    if (hasQuery) {
      _performSearch();
      return;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
