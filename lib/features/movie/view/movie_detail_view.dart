import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinetrack/core/theme/app_colors.dart';
import 'package:cinetrack/core/services/library_sync_service.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:cinetrack/features/movie/viewmodel/movie_detail_viewmodel.dart';
import 'package:cinetrack/features/actor/view/actor_detail_view.dart';

class MovieDetailView extends StatefulWidget {
  final int tmdbId;

  const MovieDetailView({super.key, required this.tmdbId});

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  late final MovieDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MovieDetailViewModel(
      context.read<MovieService>(),
      context.read<LibrarySyncService>(),
      widget.tmdbId,
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

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.textMuted,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _viewModel.errorMessage!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _viewModel.loadMovie,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Tekrar Dene',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final movie = _viewModel.movie!;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeroSliver(movie),
              SliverToBoxAdapter(child: _buildContent(movie)),
            ],
          ),
          _buildHeaderOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeaderOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Geri',
                  onTap: () => Navigator.maybePop(context),
                ),
                Row(
                  children: [
                    _circleButton(
                      icon: Icons.share,
                      tooltip: 'Paylaş',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _circleButton(
                      icon: _viewModel.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      tooltip: 'Favori',
                      filled: true,
                      isPrimary: _viewModel.isFavorite,
                      onTap: _viewModel.toggleFavorite,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    String? tooltip,
    bool filled = false,
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: isPrimary
            ? AppColors.primary
            : Colors.black.withValues(alpha: 0.2),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeroSliver(MovieDetail movie) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: screenHeight * 0.55,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.posterUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: AppColors.surfaceDark,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              errorWidget: (_, _, _) => Container(
                color: AppColors.surfaceDark,
                child: const Icon(Icons.movie, color: Colors.grey, size: 64),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.backgroundDark.withValues(alpha: 0.4),
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              right: 24,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {},
                  child: const SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(MovieDetail movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(movie),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildGenres(movie),
          const SizedBox(height: 24),
          _buildOverview(movie),
          const SizedBox(height: 24),
          _buildCastSection(movie),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTitleSection(MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.primary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    movie.ratingStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _metaItem(Icons.calendar_today, movie.year),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.neutralMuted,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderDarkSolid),
              ),
              child: const Text(
                'HD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle, size: 22),
              label: const Text(
                'Şimdi İzle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 52,
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neutralMuted,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.add, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildGenres(MovieDetail movie) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: movie.genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neutralMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderDarkSolid),
          ),
          child: Text(
            genre.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade300,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverview(MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          movie.overview ?? 'Özet bilgisi bulunmuyor.',
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildCastSection(MovieDetail movie) {
    if (movie.cast.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Öne Çıkan Oyuncular',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movie.cast.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final member = movie.cast[index];
              return _castCard(member);
            },
          ),
        ),
      ],
    );
  }

  Widget _castCard(CastMemberDto member) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActorDetailView(personId: member.id),
          ),
        );
      },
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: member.profileUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppColors.surfaceDark,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surfaceDark,
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              member.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              member.character ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppColors.accentText),
            ),
          ],
        ),
      ),
    );
  }
}
