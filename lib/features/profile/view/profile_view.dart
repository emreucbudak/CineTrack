import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinetrack/core/services/storage_service.dart';
import 'package:cinetrack/core/theme/app_colors.dart';
import 'package:cinetrack/core/services/library_sync_service.dart';
import 'package:cinetrack/data/models/actor_models.dart';
import 'package:cinetrack/data/models/movie_models.dart';
import 'package:cinetrack/data/services/actor_service.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:cinetrack/features/actor/view/actor_detail_view.dart';
import 'package:cinetrack/features/auth/view/login_view.dart';
import 'package:cinetrack/features/movie/view/movie_detail_view.dart';
import 'package:cinetrack/features/profile/view/premium_frontend_sheet.dart';
import 'package:cinetrack/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(
      context.read<StorageService>(),
      context.read<LibrarySyncService>(),
      context.read<AuthService>(),
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

  Future<void> _handleLogout() async {
    await _viewModel.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  void _openFavoriteMovies() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FavoriteMoviesPage(movies: _viewModel.favoriteMovies),
      ),
    );
  }

  void _openFollowedActors() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FollowedActorsPage(actors: _viewModel.followedActors),
      ),
    );
  }

  Future<void> _showAccountSheet() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumSpotlightCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumSpotlightCard() {
    final isPremium = _viewModel.hasPremiumSubscription;
    final accentColor = isPremium
        ? const Color(0xFFE7B44C)
        : const Color(0xFF8C6B2D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF191214), Color(0xFF25181C), Color(0xFF342326)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: isPremium ? 0.38 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isPremium ? 0.16 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Abonelik Y\u00f6netimi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPremium
                          ? 'Premium plan\u0131n\u0131z aktif. Ayr\u0131cal\u0131klar\u0131n\u0131z kesintisiz devam ediyor.'
                          : 'Daha iyi bir deneyim i\u00e7in Premium plana y\u00fckseltebilirsiniz.',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isPremium ? 0.14 : 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  _viewModel.subscriptionPlanLabel,
                  style: TextStyle(
                    color: isPremium ? accentColor : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSubscriptionInfoTile(
                  label: 'Plan',
                  value: _viewModel.subscriptionPlanLabel,
                  icon: Icons.layers_outlined,
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSubscriptionInfoTile(
                  label: 'Biti\u015f Tarihi',
                  value: _viewModel.subscriptionEndsAtLabel,
                  icon: Icons.event_outlined,
                  accentColor: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openPremiumFrontendSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? accentColor : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Plan\u0131 Y\u00fckseltin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPremiumFrontendSheet() async {
    if (!mounted) return;

    Navigator.pop(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PremiumFrontendSheet(
        initialEmail: _viewModel.userEmail,
        initialName: _viewModel.userName,
      ),
    );
  }

  Widget _buildSubscriptionInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF120D0F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _viewModel.loadProfile,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileSection(),
                            const SizedBox(height: 24),
                            _buildMenuSection(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Center(
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              'Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 4,
              ),
              color: AppColors.surfaceDark,
            ),
            child: const ClipOval(
              child: Icon(Icons.person, color: Colors.grey, size: 48),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _viewModel.userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _viewModel.userEmail,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat(
              '${_viewModel.favoritesCount}',
              'Favoriler',
              onTap: _openFavoriteMovies,
            ),
            const SizedBox(width: 32),
            _buildStat(
              '${_viewModel.followedActorsCount}',
              'Takip',
              onTap: _openFollowedActors,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'HESAP K\u00dcT\u00dcPHANES\u0130',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.favorite,
          label: 'Favori Filmler',
          subtitle: '${_viewModel.favoritesCount} kay\u0131t',
          onTap: _openFavoriteMovies,
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.people_alt_outlined,
          label: 'Takip Edilen Ki\u015filer',
          subtitle: '${_viewModel.followedActorsCount} kay\u0131t',
          onTap: _openFollowedActors,
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.badge_outlined,
          label: 'Hesap Bilgileri',
          subtitle:
              'Kullan\u0131c\u0131 bilgileri ve h\u0131zl\u0131 i\u015flemler',
          onTap: () => _showAccountSheet(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          child: Divider(color: AppColors.borderDark, height: 1),
        ),
        _buildLogoutItem(),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.inputBackgroundDark,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _handleLogout,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.red.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout, color: Colors.red.shade400, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '\u00c7\u0131k\u0131\u015f Yap',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteMoviesPage extends StatelessWidget {
  final List<FavoriteMovie> movies;

  const _FavoriteMoviesPage({required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        title: const Text('Favori Filmler'),
      ),
      body: movies.isEmpty
          ? const _ProfileEmptyState(
              icon: Icons.favorite_border,
              message: 'Hen\u00fcz favori filminiz yok.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: movies.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return _ProfileListCard(
                  title: movie.title,
                  trailingText: 'Detay',
                  icon: Icons.movie_outlined,
                  imageUrl: movie.posterUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailView(tmdbId: movie.tmdbId),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _FollowedActorsPage extends StatelessWidget {
  final List<FollowedActor> actors;

  const _FollowedActorsPage({required this.actors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        title: const Text('Takip Edilen Ki\u015filer'),
      ),
      body: actors.isEmpty
          ? const _ProfileEmptyState(
              icon: Icons.people_outline,
              message: 'Hen\u00fcz takip etti\u011finiz ki\u015fi yok.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: actors.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final actor = actors[index];
                return _ProfileListCard(
                  title: actor.name,
                  trailingText: 'Detay',
                  icon: Icons.person_outline,
                  imageUrl: actor.profileUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActorDetailView(personId: actor.tmdbId),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ProfileListCard extends StatelessWidget {
  final String title;
  final String trailingText;
  final IconData icon;
  final String imageUrl;
  final VoidCallback onTap;

  const _ProfileListCard({
    required this.title,
    required this.trailingText,
    required this.icon,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _ProfileArtwork(imageUrl: imageUrl, icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileArtwork extends StatelessWidget {
  final String imageUrl;
  final IconData icon;

  const _ProfileArtwork({required this.imageUrl, required this.icon});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildFallback(),
              errorWidget: (context, url, error) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(child: Icon(icon, color: AppColors.primary));
  }
}

class _ProfileEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _ProfileEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
