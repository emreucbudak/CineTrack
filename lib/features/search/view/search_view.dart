import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinetrack/core/theme/app_colors.dart';
import 'package:cinetrack/data/models/actor_models.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/actor_service.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:cinetrack/features/actor/view/actor_detail_view.dart';
import 'package:cinetrack/features/movie/view/movie_detail_view.dart';
import 'package:cinetrack/features/search/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final SearchViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SearchViewModel(
      context.read<MovieService>(),
      context.read<ActorService>(),
    );
    _viewModel.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _openMovieDetail(int tmdbId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailView(tmdbId: tmdbId)),
    );
  }

  void _openActorDetail(int personId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActorDetailView(personId: personId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDarkSolid, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildTopBar(), _buildSearchBar(), _buildTabs()],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () {},
              tooltip: 'Menü',
              icon: const Icon(Icons.menu, color: Colors.white),
            ),
          ),
          const Expanded(
            child: Text(
              'CineTrack',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () {},
              tooltip: 'Hesap',
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _viewModel.searchController,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Film, oyuncu veya yönetmen ara',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search, color: AppColors.textMuted, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        onChanged: (_) => _viewModel.onSearchChanged(),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabItem('Tümü', SearchTab.all),
        _tabItem('Filmler', SearchTab.movies),
        _tabItem('Kişiler', SearchTab.actors),
      ],
    );
  }

  Widget _tabItem(String label, SearchTab tab) {
    final isSelected = _viewModel.selectedTab == tab;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _viewModel.selectTab(tab),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_viewModel.errorMessage != null && !_viewModel.hasQuery) {
      return _buildMessage(_viewModel.errorMessage!);
    }

    final movies = _viewModel.movieResults;
    final actors = _viewModel.actorResults;

    if (_viewModel.hasQuery) {
      return switch (_viewModel.selectedTab) {
        SearchTab.movies =>
          movies.isEmpty
              ? _buildMessage('Film bulunamadı')
              : _buildScrollableMovieSection('Arama Sonuçları', movies),
        SearchTab.actors =>
          actors.isEmpty
              ? _buildMessage('Kişi bulunamadı')
              : _buildScrollableActorSection('Kişi Sonuçları', actors),
        SearchTab.all =>
          (movies.isEmpty && actors.isEmpty)
              ? _buildMessage('Sonuç bulunamadı')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (actors.isNotEmpty) ...[
                        _buildActorSection('Kişiler', actors),
                        const SizedBox(height: 24),
                      ],
                      if (movies.isNotEmpty)
                        _buildMovieSection('Filmler', movies),
                    ],
                  ),
                ),
      };
    }

    if (_viewModel.selectedTab == SearchTab.actors) {
      return _buildMessage('Kişi aramak için yukarıya bir isim yazın');
    }

    if (movies.isEmpty) {
      return _buildMessage('Gösterilecek film yok');
    }

    return _buildScrollableMovieSection('Trend Filmler', movies);
  }

  Widget _buildScrollableMovieSection(
    String title,
    List<TrendingMovie> movies,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildMovieSection(title, movies),
    );
  }

  Widget _buildScrollableActorSection(String title, List<SearchPerson> actors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildActorSection(title, actors),
    );
  }

  Widget _buildMovieSection(String title, List<TrendingMovie> movies) {
    return Column(
      children: [
        _sectionHeader(title),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length > 20 ? 20 : movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _movieCard(movie);
          },
        ),
      ],
    );
  }

  Widget _buildActorSection(String title, List<SearchPerson> actors) {
    return Column(
      children: [
        _sectionHeader(title),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actors.length > 20 ? 20 : actors.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final actor = actors[index];
            return _actorCard(actor);
          },
        ),
      ],
    );
  }

  Widget _movieCard(TrendingMovie movie) {
    return GestureDetector(
      onTap: () => _openMovieDetail(movie.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    errorWidget: (_, _, _) => const Center(
                      child: Icon(Icons.movie, color: Colors.grey, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            movie.ratingStr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  movie.year,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actorCard(SearchPerson actor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openActorDetail(actor.id),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDarkSolid),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: CachedNetworkImage(
                    imageUrl: actor.profileUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: AppColors.neutralMuted,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.neutralMuted,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      actor.knownForDepartment?.isNotEmpty == true
                          ? actor.knownForDepartment!
                          : 'Kişi',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
      ),
    );
  }
}
