import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinetrack/core/theme/app_theme.dart';
import 'package:cinetrack/core/services/storage_service.dart';
import 'package:cinetrack/core/network/dio_client.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:cinetrack/data/services/movie_service.dart';
import 'package:cinetrack/data/services/actor_service.dart';
import 'package:cinetrack/features/auth/view/login_view.dart';
import 'package:cinetrack/features/shell/view/main_shell_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final dioClient = DioClient(storageService);
  final authService = AuthService(dioClient, storageService);
  final movieService = MovieService(dioClient);
  final actorService = ActorService(dioClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storageService),
        Provider.value(value: dioClient),
        Provider.value(value: authService),
        Provider.value(value: movieService),
        Provider.value(value: actorService),
      ],
      child: const CineTrackApp(),
    ),
  );
}

class CineTrackApp extends StatefulWidget {
  const CineTrackApp({super.key});

  @override
  State<CineTrackApp> createState() => _CineTrackAppState();
}

class _CineTrackAppState extends State<CineTrackApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final storage = context.read<StorageService>();
    final loggedIn = await storage.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineTrack',
      theme: AppTheme.darkTheme,
      home: _isLoggedIn ? const MainShellView() : const LoginView(),
    );
  }
}
