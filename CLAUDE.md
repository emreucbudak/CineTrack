# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter run                    # Run on connected device/emulator
flutter build apk              # Build Android APK
flutter build ios              # Build iOS (macOS only)
flutter analyze                # Run static analysis (uses flutter_lints)
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter pub get                # Install dependencies
```

## Architecture

MVVM pattern using Flutter's built-in `ChangeNotifier` — no third-party state management.

### Feature structure
Each feature lives in `lib/features/<feature>/` with two subdirectories:
- `view/` — StatefulWidget that creates and listens to its ViewModel
- `viewmodel/` — extends `ChangeNotifier`, holds UI state and data models

Data model classes (e.g. `HomeMovie`, `CastMember`, `ActorMovie`) are defined at the top of their respective viewmodel files, not in separate model files.

### ViewModel binding pattern
Every view follows the same lifecycle:
```dart
late final XViewModel _viewModel;
void initState() { _viewModel = XViewModel(); _viewModel.addListener(_onChanged); }
void _onChanged() => setState(() {});
void dispose() { _viewModel.removeListener(_onChanged); _viewModel.dispose(); }
```

### Navigation
- App entry: `LoginView` (no auth guard yet — login/register have TODO stubs for API calls)
- Post-login: `MainShellView` with `IndexedStack` bottom nav (Home, Search, Profile)
- Detail screens (MovieDetailView, ActorDetailView): pushed via `Navigator.push`
- No named routes or router package — uses imperative `MaterialPageRoute` navigation

### Theming
- Dark-only theme via `AppTheme.darkTheme` in `core/theme/app_theme.dart`
- All colors centralized in `AppColors` (`core/theme/app_colors.dart`) — primary is `#E60A15` (red)
- Typography: Google Fonts `Spline Sans` applied globally via `GoogleFonts.splineSansTextTheme`

### Current state
- All data is hardcoded placeholder content in ViewModels (no API integration, no local storage)
- Auth flows (login/register) have loading state but no backend calls (marked with `// TODO: API call`)
- Images use `CachedNetworkImage` with placeholder/error widgets throughout
- SDK constraint: `^3.11.0`
