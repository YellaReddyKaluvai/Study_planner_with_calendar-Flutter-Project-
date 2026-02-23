# Architecture Documentation

## Overview
The application follows **Clean Architecture** principles enforced with **Riverpod** for state management and **GoRouter** for navigation. The structure allows for scalability, testability, and separation of concerns.

## Folder Structure
```
lib/
├── core/                  # Core functionality shared across features
│   ├── theme/             # AppTheme, ColorPalette, ThemeProvider
│   ├── router/            # AppRouter (GoRouter config)
│   └── utils/             # Utility classes
├── features/              # Feature-based modules
│   ├── auth/              # Authentication Feature
│   │   ├── data/          # Repositories implementations, Data Sources
│   │   ├── domain/        # Entities, Repository Interfaces (Pure Dart)
│   │   └── presentation/  # UI (Pages, Widgets), Riverpod Notifiers
│   ├── profile/           # Profile Feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── ... (legacy features migrating to this structure)
└── presentation/          # Legacy UI code (Providers pattern) - being phased out
```

## State Management
We use **Riverpod 2.0** (`flutter_riverpod`).
- **Providers**: Used for dependency injection (e.g., `authRepositoryProvider`).
- **StateNotifier** / **Notifier**: Used for logic and state holding (e.g., `AuthNotifier`, `ProfileNotifier`).
- **StreamProvider**: Used for real-time data from Firestore (e.g., `userProfileStreamProvider`).

## Navigation
**GoRouter** handles routing.
- `AppRouter` listens to `authStateChanges` stream.
- Automatically redirects to `/login` if not authenticated.
- Automatically redirects to `/` if authenticated and on login page.

## Database (Firestore)
- **Users Collection**: `users/{uid}`
  - Stores user profile data.
  - Secured via Firestore Rules to ensure only owners can write.

## Legacy Code Interop
The app currently runs in a hybrid mode:
- New features (Auth, Profile) use **Riverpod**.
- Legacy features (Tasks, Calendar) use **Provider**.
- `MultiProvider` in `main.dart` wraps the app to keep legacy providers alive until migration is complete.
