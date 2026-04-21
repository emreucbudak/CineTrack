import 'package:flutter/material.dart';
import 'package:cinetrack/core/services/library_sync_service.dart';
import 'package:cinetrack/data/models/actor_models.dart';
import 'package:cinetrack/data/services/actor_service.dart';

class ActorDetailViewModel extends ChangeNotifier {
  final ActorService _actorService;
  final LibrarySyncService _librarySyncService;
  final int personId;

  ActorDetailViewModel(
    this._actorService,
    this._librarySyncService,
    this.personId,
  ) {
    loadActor();
  }

  bool _isLoading = true;
  String? _errorMessage;
  PersonDetail? _actor;
  bool _isFollowing = false;
  bool _followLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PersonDetail? get actor => _actor;
  bool get isFollowing => _isFollowing;
  bool get followLoading => _followLoading;

  Future<void> loadActor() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _actor = await _actorService.getActorDetail(personId);
    if (_actor == null) {
      _errorMessage = 'Oyuncu detayları yüklenemedi.';
    } else {
      await _checkFollowStatus();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkFollowStatus() async {
    try {
      final result = await _actorService.getFollowedActors(
        page: 1,
        pageSize: 100,
      );
      _isFollowing = result.items.any((f) => f.tmdbId == personId);
    } catch (_) {
      // Ignore
    }
  }

  Future<void> toggleFollow() async {
    if (_actor == null || _followLoading) return;

    _followLoading = true;
    notifyListeners();

    if (_isFollowing) {
      final result = await _actorService.unfollowActor(personId);
      if (result.success) {
        _isFollowing = false;
        _librarySyncService.notifyLibraryChanged();
      }
    } else {
      final result = await _actorService.followActor(
        tmdbId: personId,
        name: _actor!.name,
        profilePath: _actor!.profilePath,
      );
      if (result.success) {
        _isFollowing = true;
        _librarySyncService.notifyLibraryChanged();
      }
    }

    _followLoading = false;
    notifyListeners();
  }
}
