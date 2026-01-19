# AI Copilot Instructions for New Life Church Mobile App

## Project Overview
This is a responsive Flutter mobile app for **New Life Community Church, Tonyrefail**. The app clones core website features and adds three new features: daily devotions, push notifications, and Bible search.

### Architecture Overview
- **Framework**: Flutter with Dart (null-safe)
- **State Management**: Provider pattern for dependency injection and state
- **Navigation**: GoRouter for type-safe routing
- **Backend**: Firebase for push notifications; local storage for devotions/favorites
- **Platforms**: iOS, Android, Web (responsive design for all screen sizes)

## Essential Workflows

### Development Commands
```bash
flutter pub get           # Install/update dependencies
flutter run              # Run app on connected device/emulator
flutter run -d chrome    # Run on web (if web platform enabled)
flutter build apk        # Build Android APK
flutter test            # Run unit/widget tests
flutter analyze         # Static analysis
dart format lib/       # Format Dart code
dart fix --apply       # Auto-fix linter issues
```

### Project Structure
- **lib/main.dart** - App entry point with Firebase initialization and Provider setup
- **lib/config/** - Firebase configuration (see Firebase setup notes below)
- **lib/theme/app_theme.dart** - Church branding colors (primary: deep teal, secondary: warm orange)
- **lib/routes/app_routes.dart** - GoRouter configuration with 7 main routes
- **lib/providers/** - State management (DevotionProvider, BibleProvider, NotificationProvider)
- **lib/services/** - Business logic (DevotionService, BibleService, NotificationService)
- **lib/screens/** - 7 screens: Home, About, Events, Devotion, Bible, Contact, Notifications
- **lib/widgets/** - Reusable UI components (AppBottomNav, etc.)
- **pubspec.yaml** - Dependencies including Firebase, Provider, GoRouter

## Code Patterns & Conventions

### App Architecture
- **Service Layer**: Three main services handle business logic
  - `DevotionService` - Manages daily devotions with local persistence (SharedPreferences)
  - `BibleService` - Bible API integration + favorite verses management
  - `NotificationService` - Firebase messaging + local notifications
- **State Management Pattern**: Each service has a corresponding Provider that wraps business logic
  - Providers inherit from `ChangeNotifier` and expose: loading state, error handling, data
  - Services are injected via `Provider` in `AppProviders.providers` list
  - See `lib/providers/` for pattern examples
- **Responsive Design**: All screens use `MediaQuery.of(context).size.width < 600` to detect mobile vs tablet
  - Mobile: single column layouts, smaller padding (16px)
  - Tablet: multi-column grids, larger padding (24px)

## Dart Code Style & Widget Patterns

### Dart Style
- **Naming**: camelCase for variables/methods, PascalCase for classes
- **Line length**: Max 80 characters
- **Imports**: Organize as dart: → package: → relative imports
- **Comments**: Use /// for public API docs, // for implementation

### Widget Patterns in This Project
- **Navigation**: All navigation uses `context.pushNamed('route-name')` via GoRouter (e.g., `context.pushNamed('devotion')`)
- **Forms**: Use `TextFormField` with `GlobalKey<FormState>()` for validation
- **Lists**: Use `ListView.builder()` for dynamic lists; `ExpansionTile` for collapsible sections
- **Cards**: Wrap content in `Card` with `Padding(all: 16)` for consistency
- **Buttons**: Use theme-defined `ElevatedButton` styles; see `lib/theme/app_theme.dart`
- **Responsive**: Check mobile width with `MediaQuery.of(context).size.width < 600`
  - Mobile: single column, smaller padding (16px)
  - Tablet: multi-column grids, larger padding (24px)

## Dependencies & Integration

### Core Dependencies (this project)
- **firebase_core** + **firebase_messaging** - Push notifications
- **provider** - State management via ChangeNotifier
- **go_router** - Type-safe routing with named routes
- **shared_preferences** - Local persistence (devotions, favorites)
- **dio** - HTTP client for Bible API calls
- **flutter_local_notifications** - Local notification display
- **intl** - Date formatting and i18n
- **connectivity_plus** - Network state detection

### Key Service-Provider Pattern
1. **DevotionService** (lib/services/devotion_service.dart)
   - Manages daily devotions with SharedPreferences persistence
   - Exposes: `getTodaysDevotion()`, `getAllDevotions()`, `addUserReflection(id, text)`
   - **Provider**: `DevotionProvider` wraps service and exposes `currentDevotion`, `allDevotions`

2. **BibleService** (lib/services/bible_service.dart)
   - Fetches verses from bible-api.com (free, no auth required)
   - Manages favorite verses with SharedPreferences
   - Exposes: `getVerse(reference)`, `toggleFavorite()`, `getFavorites()`
   - **Provider**: `BibleProvider` wraps service

3. **NotificationService** (lib/services/notification_service.dart)
   - Listens to Firebase messages and displays local notifications
   - Persists notification history with SharedPreferences
   - Exposes: `addNotification()`, `markAsRead()`, `getUnreadCount()`
   - **Provider**: `NotificationProvider` wraps service

### Firebase Setup (Required)
1. Create Firebase project at https://console.firebase.google.com
2. Run: `flutterfire configure` (auto-generates `lib/config/firebase_options.dart`)
3. Enable Cloud Messaging in Firebase Console
4. Replace placeholder API keys in `firebase_options.dart`

## Critical Development Rules

1. **After modifying pubspec.yaml: Always run `flutter pub get`**
   - Updates lock files and enables IDE autocomplete

2. **Null-safety is mandatory**
   - Nullable types: `String?`, Non-null assertions: `value!` only when certain
   - Use null coalescing: `value ?? defaultValue`

3. **Hot reload vs Hot restart**
   - Hot reload: Widget code changes (fastest, preserves state)
   - Hot restart: Global state, constants, service initialization (loses app state)
   - Provider state survives hot reload but not hot restart

4. **Service initialization pattern**
   - Services must call `await service.init()` before use
   - This is done in corresponding Provider constructor (see `lib/providers/`)
   - DevotionService loads from SharedPreferences on init
   - BibleService loads favorites on init
   - NotificationService initializes Firebase on init

5. **Error handling**
   - Catch exceptions at service boundaries (API calls, file I/O)
   - Providers expose `error` property for UI error display
   - Use `notifyListeners()` after state changes in providers

6. **Adding new routes**
   - Define route in `AppRoutes.router` (lib/routes/app_routes.dart)
   - Create screen widget in lib/screens/{feature}/{feature}_screen.dart
   - Add to bottom nav if primary feature; update `AppBottomNav` currentIndex
   - Use `context.pushNamed('route-name')` or `context.goNamed('route-name')`

7. **Responsive layout pattern**
   ```dart
   final isMobile = MediaQuery.of(context).size.width < 600;
   // Then conditionally apply: GridView.count(crossAxisCount: isMobile ? 2 : 3, ...)
   ```

## Code Review Checklist (for AI modifications)
- [ ] Follows Dart formatting (run `dart format lib/` before commit)
- [ ] No analysis warnings (`flutter analyze` shows green)
- [ ] Const constructors used for immutable widgets
- [ ] Null-safety: No unnecessary `!` operators
- [ ] Service changes include Provider pattern wrapper
- [ ] Uses provider notifyListeners() for state updates
- [ ] Responsive design implemented for mobile/tablet
- [ ] Comments explain "why", not "what" (code is self-documenting)
- [ ] New features tested with sample data

## Common Pitfalls to Avoid
- **Don't** call `notifyListeners()` in build() methods (infinite loops)
- **Don't** initialize services directly; use Provider injection pattern
- **Don't** hard-code strings/numbers; use constants in app_theme.dart
- **Don't** mix Stateful widget state with Provider state (pick one pattern)
- **Don't** use BuildContext after widget is disposed (save it beforehand)
- **Don't** ignore pubspec.lock changes in version control
- **Don't** fetch data in build(); use FutureBuilder or Provider computed properties

## Screen Overview
| Screen | File | Purpose | Special |
|--------|------|---------|---------|
| Home | home/home_screen.dart | App entry; quick access links | Shows daily devotion + verse preview |
| Devotion | devotion/devotion_screen.dart | Full devotion list; reflection editing | ExpansionTile for each devotion |
| Bible | bible/bible_screen.dart | Verse search + favorites | TabBar (Search/Favorites) |
| Events | events/events_screen.dart | Service times, meetings | Static content from church website |
| About | about/about_screen.dart | Church info, service times, social | Links to About section of website |
| Contact | contact/contact_screen.dart | Contact form + address | Form validation with GlobalKey |
| Notifications | notifications/notifications_screen.dart | All notifications, mark read | Timestamp formatting, batch actions |

## When in Doubt
1. Check existing screens for widget patterns (all follow same Card/Padding/ListView structure)
2. Look at DevotionProvider for state management pattern
3. Firebase setup: https://firebase.flutter.dev/docs/overview
4. Bible API: https://bible-api.com (free, no auth needed)
5. GoRouter docs: https://pub.dev/packages/go_router

---
*Last updated: January 5, 2026*
*Source: New Life Community Church, Tonyrefail (https://www.newlifetonyrefail.co.uk)*
