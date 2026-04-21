import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinetrack/core/theme/app_colors.dart';
import 'package:cinetrack/core/services/library_sync_service.dart';
import 'package:cinetrack/data/models/actor_models.dart';
import 'package:cinetrack/data/services/actor_service.dart';
import 'package:cinetrack/features/actor/viewmodel/actor_detail_viewmodel.dart';
import 'package:cinetrack/features/movie/view/movie_detail_view.dart';

class ActorDetailView extends StatefulWidget {
  final int personId;

  const ActorDetailView({super.key, required this.personId});

  @override
  State<ActorDetailView> createState() => _ActorDetailViewState();
}

class _ActorDetailViewState extends State<ActorDetailView> {
  late final ActorDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ActorDetailViewModel(
      context.read<ActorService>(),
      context.read<LibrarySyncService>(),
      widget.personId,
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
                onPressed: _viewModel.loadActor,
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

    final actor = _viewModel.actor!;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(actor),
                  _buildBioSection(actor),
                  _buildInfoCards(actor),
                  _buildKnownForSection(actor),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.8),
        border: Border(bottom: BorderSide(color: AppColors.borderDark)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _headerButton(
                Icons.arrow_back,
                tooltip: 'Geri',
                onTap: () => Navigator.maybePop(context),
              ),
              const Expanded(
                child: Text(
                  'Oyuncu Profili',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              _headerButton(Icons.share, tooltip: 'Paylaş', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerButton(IconData icon, {String? tooltip, VoidCallback? onTap}) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(PersonDetail actor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 4,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: actor.profileUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: AppColors.surfaceDark,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.surfaceDark,
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundDark,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            actor.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            actor.knownForDepartment ?? 'Oyunculuk',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statChip(Icons.movie, '${actor.movieCredits.length} Film'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _viewModel.toggleFollow,
              icon: Icon(
                _viewModel.isFollowing ? Icons.check : Icons.person_add,
                size: 22,
              ),
              label: Text(
                _viewModel.isFollowing ? 'Takip Ediliyor' : 'Oyuncuyu Takip Et',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _viewModel.isFollowing
                    ? AppColors.surfaceDark
                    : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _viewModel.isFollowing
                      ? BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        )
                      : BorderSide.none,
                ),
                elevation: _viewModel.isFollowing ? 0 : 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.accentText),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.accentText),
        ),
      ],
    );
  }

  Widget _buildBioSection(PersonDetail actor) {
    if (actor.biography == null || actor.biography!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Biyografi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            actor.biography!,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(PersonDetail actor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: _infoCard('Doğum Tarihi', actor.birthday ?? 'Bilinmiyor'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _infoCard('Doğum Yeri', actor.placeOfBirth ?? 'Bilinmiyor'),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentText,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnownForSection(PersonDetail actor) {
    if (actor.movieCredits.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.theaters, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Bilinen Yapımları',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: actor.movieCredits.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final movie = actor.movieCredits[index];
                return _knownForCard(movie);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _knownForCard(MovieCredit movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailView(tmdbId: movie.id)),
        );
      },
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neutralMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _moviePlaceholder(),
                      errorWidget: (_, _, _) => _moviePlaceholder(),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movie.ratingStr,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${movie.year} • ${movie.character ?? ''}',
              style: const TextStyle(fontSize: 12, color: AppColors.accentText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moviePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.neutralMuted, Color(0xFF120809)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie,
          size: 40,
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
