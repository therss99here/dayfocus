# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dayfocus is a Flutter productivity app for timeboxing your day. All Flutter code lives in the `/app` directory. Requires Dart SDK ^3.9.2.

- **Bundle ID (iOS)**: `app.dayfocus.ios`
- **Minimum iOS**: 15.0

## Development Commands

All commands run from the `/app` directory:

```bash
flutter run                    # Run app (auto-detects device)
flutter run -d macos           # Run on macOS
flutter run -d ios             # Run on iOS

flutter analyze                # Lint/analyze code
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Single test file

# Code generation (required after changing @riverpod or Drift annotations)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs  # Watch mode
```

## Architecture

### Feature Module Pattern

Each feature in `lib/features/` follows a three-layer structure:
- `data/` - Repository implementations, data sources
- `domain/` - Entities, business logic
- `presentation/` - Widgets, screens, providers (Riverpod notifiers)

Shared infrastructure lives in `lib/core/` (database, theme, router, providers, notifications, widgets).

### State Management

Riverpod with code generation (`@riverpod` annotations). After modifying providers, regenerate `.g.dart` files with build_runner.

Notifiers use stream-based builds for reactive database updates:
```dart
@override
Stream<List<Entity>> build() async* {
  yield* repository.watchForDay(dayId);
}
```

Key providers:
- `appDatabaseProvider` - Singleton Drift database (keepAlive: true)
- `activeDayProvider` - Currently selected day
- `PrioritiesNotifier`, `TimelineNotifier` - Feature state managers

### Database

Drift (SQLite) with code generation. Schema in `lib/core/database/app_database.dart`. DAOs in `lib/core/database/daos/` wrap table operations; repositories in feature `data/` layers wrap DAOs.

Tables: `DayConfigs`, `Priorities`, `TimeBlocks`, `BrainDumpNotes`, `UserSettings`

### Configuration

Supabase is optional. Copy `env.example.json` to `env.json` with credentials to enable cloud sync/auth. The app works fully offline without it (`AppConfig.isConfigured` checks this).

### UI Patterns

- Responsive layout: two-panel on desktop/tablets (≥720pt + shortestSide ≥600), single column on mobile (see `BoardScreen`)
- Priorities can be dragged to the timeline to create linked time blocks
- Completing a priority marks its linked time block complete (and vice versa)
