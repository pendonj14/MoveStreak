# MoveStreak Architecture Guide

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP (Client)                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              UI Layer (Screens)                       │   │
│  │  ─────────────────────────────────────────────────   │   │
│  │  • HomeScreen (Dashboard)                             │   │
│  │  • SignInScreen                                       │   │
│  │  • SignUpScreen                                       │   │
│  │  • LogActivityScreen                                  │   │
│  │  • HistoryScreen                                      │   │
│  └────────────────┬─────────────────────────────────────┘   │
│                   │                                           │
│                   ▼                                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         State Management Layer (Providers)            │   │
│  │  ─────────────────────────────────────────────────   │   │
│  │  • AuthProvider (ChangeNotifier)                      │   │
│  │  • ActivityProvider (ChangeNotifier)                  │   │
│  │  • QuoteProvider (ChangeNotifier)                     │   │
│  └────────────────┬─────────────────────────────────────┘   │
│                   │                                           │
│                   ▼                                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │       Business Logic Layer (Services)                │   │
│  │  ─────────────────────────────────────────────────   │   │
│  │  • AuthService                                        │   │
│  │  • ActivityService                                    │   │
│  │  • StreakService                                      │   │
│  │  • QuoteService                                       │   │
│  └────────────────┬─────────────────────────────────────┘   │
│                   │                                           │
│                   ▼                                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          Data Layer (Models)                          │   │
│  │  ─────────────────────────────────────────────────   │   │
│  │  • User                                               │   │
│  │  • Activity                                           │   │
│  │  • Quote                                              │   │
│  │  • StreakInfo                                         │   │
│  └────────────────┬─────────────────────────────────────┘   │
│                   │                                           │
└───────────────────┼───────────────────────────────────────────┘
                    │
                    │ (HTTP/HTTPS)
                    ▼
┌─────────────────────────────────────────────────────────────┐
│              External Services                               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────┐         ┌─────────────────────┐    │
│  │  Supabase Cloud    │         │  Quotable API       │    │
│  │  ─────────────────  │         │  ─────────────────  │    │
│  │  • Auth (JWT)      │         │  • Quote endpoint   │    │
│  │  • PostgreSQL DB   │         │  • Caches locally   │    │
│  │  • Row Level Sec.  │         │  • Fallback support │    │
│  └────────────────────┘         └─────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer Descriptions

### 1. UI Layer (Screens)
**Location**: `lib/screens/`

Responsible for:
- Displaying data to users
- Capturing user input
- Triggering actions via providers
- Showing loading states and errors

**Files**:
- `home_screen.dart` - Main dashboard (streak, quote, activities)
- `sign_in_screen.dart` - User login
- `sign_up_screen.dart` - User registration
- `log_activity_screen.dart` - Activity logging form
- `history_screen.dart` - Calendar history view

### 2. State Management Layer (Providers)
**Location**: `lib/providers/`

Responsible for:
- Managing app state
- Bridging UI and business logic
- Notifying listeners of state changes
- Handling loading and error states

**Files**:
- `auth_provider.dart` - Authentication state
- `activity_provider.dart` - Activities and streak state
- `quote_provider.dart` - Daily quote state

**Pattern**: ChangeNotifier with Provider pattern

### 3. Business Logic Layer (Services)
**Location**: `lib/services/`

Responsible for:
- Core business logic
- API communication
- Data validation
- Complex calculations

**Files**:
- `auth_service.dart` - User authentication
- `activity_service.dart` - Activity CRUD operations
- `streak_service.dart` - Streak calculation
- `quote_service.dart` - Quote fetching and caching

### 4. Data Layer (Models)
**Location**: `lib/models/`

Responsible for:
- Data representation
- Type safety
- JSON serialization/deserialization
- Business object definitions

**Files**:
- `user.dart` - User profile data
- `activity.dart` - Activity data
- `quote.dart` - Quote data
- `streak_info.dart` - Streak information

---

## Data Flow Examples

### Example 1: User Login Flow

```
SignInScreen
    │
    ├─ User enters email & password
    ├─ Tap "Sign In"
    │
    ▼
AuthProvider.signIn()
    │
    ├─ Set isLoading = true
    │
    ▼
AuthService.signIn()
    │
    ├─ Call Supabase.auth.signInWithPassword()
    │
    ▼
Supabase (Cloud)
    │
    ├─ Validate credentials
    ├─ Generate JWT token
    ├─ Return user object
    │
    ▼
AuthService (returns User)
    │
    ├─ Fetch user profile from database
    ├─ Return User object
    │
    ▼
AuthProvider
    │
    ├─ Set _user = user
    ├─ Set isLoading = false
    ├─ notifyListeners()
    │
    ▼
HomeScreen (Consumer watches AuthProvider)
    │
    └─ Rebuilds when isLoggedIn = true
```

### Example 2: Activity Logging Flow

```
LogActivityScreen
    │
    ├─ User fills form
    ├─ Tap "Log Activity"
    │
    ▼
ActivityProvider.logActivity()
    │
    ├─ Set isLoading = true
    │
    ▼
ActivityService.logActivity()
    │
    ├─ Create activity object
    ├─ Insert into Supabase activities table
    ├─ Return created Activity
    │
    ▼
Supabase Database
    │
    ├─ RLS policy checks auth.uid() = user_id
    ├─ Insert activity
    ├─ Trigger updated_at update
    │
    ▼
ActivityService (returns Activity)
    │
    ├─ Add to local list
    │
    ▼
StreakService.calculateStreak()
    │
    ├─ Fetch activities for past 30 days
    ├─ Calculate current & longest streak
    ├─ Return StreakInfo
    │
    ▼
ActivityProvider
    │
    ├─ Update _activities list
    ├─ Update _streakInfo
    ├─ Set isLoading = false
    ├─ notifyListeners()
    │
    ▼
HomeScreen (rebuilds)
    │
    └─ Shows updated streak & today's activities
```

### Example 3: Daily Quote Flow

```
HomeScreen (initState)
    │
    ├─ Call QuoteProvider.loadDailyQuote()
    │
    ▼
QuoteProvider
    │
    ├─ Set isLoading = true
    │
    ▼
QuoteService.getDailyQuote()
    │
    ├─ Check SharedPreferences
    ├─ Is today's quote cached?
    │
    ├─ YES → Return cached quote
    │
    └─ NO → Fetch from API
         │
         ▼
    Quotable API
         │
         ├─ GET /random?tags=motivational
         ├─ Parse JSON response
         │
         ▼
    QuoteService
         │
         ├─ Cache quote with today's date
         ├─ Return Quote
    │
    ▼
QuoteProvider
    │
    ├─ Set _quote = quote
    ├─ Set isLoading = false
    ├─ notifyListeners()
    │
    ▼
HomeScreen (rebuilds)
    │
    └─ Displays quote with author
```

---

## State Management Pattern

### Provider Setup (main.dart)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ActivityProvider()),
    ChangeNotifierProvider(create: (_) => QuoteProvider()),
  ],
  child: MaterialApp(...),
)
```

### Using Providers in Widgets

```dart
// Read state (no rebuild)
final authProvider = context.read<AuthProvider>();

// Watch state (rebuilds when changes)
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text(authProvider.user?.email ?? 'Not logged in');
  },
)

// Multiple providers
Consumer2<AuthProvider, ActivityProvider>(
  builder: (context, authProvider, activityProvider, _) {
    // Use both
  },
)
```

---

## Database Schema Relationships

```
┌──────────────┐
│    users     │
├──────────────┤
│ id (PK)      │
│ email        │
│ display_name │
│ created_at   │
│ updated_at   │
└──────┬───────┘
       │
       │ (1 to Many)
       │
       ▼
┌──────────────────┐
│   activities     │
├──────────────────┤
│ id (PK)          │
│ user_id (FK)     │ ──→ users.id
│ name             │
│ notes            │
│ duration_minutes │
│ date             │
│ created_at       │
│ updated_at       │
└──────────────────┘
```

### Row Level Security (RLS)

```
Activities Table:
├─ SELECT policy: auth.uid() = user_id
├─ INSERT policy: auth.uid() = user_id
├─ UPDATE policy: auth.uid() = user_id
└─ DELETE policy: auth.uid() = user_id

Users Table:
├─ SELECT policy: auth.uid() = id (own profile only)
├─ UPDATE policy: auth.uid() = id
├─ INSERT policy: system only (via trigger)
└─ DELETE policy: cascade (auth deletion)
```

---

## Key Design Decisions

### 1. Provider Pattern (not setState)
**Why**: 
- Better state management for complex apps
- Cleaner separation of concerns
- Easier to test
- Better performance with Consumer rebuild scoping

### 2. Service Layer Abstraction
**Why**:
- Business logic separated from UI
- Easy to mock for testing
- Can swap implementations (local vs cloud)
- Testable without widgets

### 3. Separate Streak Service
**Why**:
- Complex calculation logic isolated
- Reusable across different parts of app
- Easy to unit test
- Handles edge cases (timezones, date boundaries)

### 4. Local Quote Caching
**Why**:
- Reduces API calls (one per day)
- Works offline
- Instant load on repeat visits
- Graceful fallback if API fails

### 5. Row Level Security (RLS)
**Why**:
- Database-level security
- User cannot access others' data even with JWT
- Better than app-level checks
- Industry standard practice

---

## API Integration Details

### Supabase Integration

```dart
// Initialization (main.dart)
await Supabase.initialize(
  url: SUPABASE_URL,
  anonKey: SUPABASE_ANON_KEY,
);

// Access in services
final client = Supabase.instance.client;

// Authenticated operations
client.from('activities')
  .insert({'user_id': uid, ...})
  .select()
  .single();
```

**Security**:
- JWT token stored in secure storage
- Tokens automatically refreshed
- RLS policies enforced on all queries
- No direct SQL access from client

### Quotable API Integration

```dart
// Public endpoint (no auth needed)
GET https://api.quotable.io/random?tags=motivational

// Response
{
  "content": "...",
  "author": "...",
  ...
}

// Local cache with date key
SharedPreferences.setString(
  'cached_quote_date', // key
  today, // value
)
```

---

## Error Handling Strategy

### Service Layer
```dart
// Services throw exceptions
throw Exception('Failed to load activities');

// Caught by providers
try {
  data = await service.fetch();
} catch (e) {
  _error = e.toString();
  notifyListeners();
}
```

### Provider Layer
```dart
// Providers maintain error state
String? _error;

// UI reads error state
if (provider.error != null) {
  ScaffoldMessenger.showSnackBar(
    SnackBar(content: Text(provider.error!)),
  );
}
```

### UI Layer
```dart
// Displays user-friendly error messages
if (provider.error != null) {
  Container(
    color: Colors.red[100],
    child: Text(provider.error!),
  )
}
```

---

## Performance Optimizations

### 1. Query Optimization
```sql
-- Indexes for common queries
CREATE INDEX idx_activities_user_id ON activities(user_id);
CREATE INDEX idx_activities_date ON activities(date);
CREATE INDEX idx_activities_user_date ON activities(user_id, date);
```

### 2. State Rebuild Scoping
```dart
// Only rebuild what changed
Consumer<ActivityProvider>(
  builder: (_, provider, __) {
    // Only rebuilds when ActivityProvider changes
  },
)
```

### 3. Lazy Loading
```dart
// Data loaded on demand, not upfront
FutureBuilder(
  future: provider.loadActivitiesForDate(...),
  builder: (context, snapshot) {
    // Load as needed
  },
)
```

### 4. Quote Caching
```dart
// One API call per day
if (cachedDate == today) {
  return cachedQuote; // No API call
}
```

---

## Testing Architecture

### Unit Tests (Can be added)
```dart
// Test services in isolation
test('StreakService calculates correct streak', () {
  final service = StreakService();
  final result = service.calculateStreak([date1, date2, date3]);
  expect(result.currentStreak, 3);
});
```

### Widget Tests (Can be added)
```dart
// Test screens with mocked providers
testWidgets('HomeScreen displays streak', (tester) async {
  await tester.pumpWidget(
    TestApp(
      authProvider: MockAuthProvider(),
      activityProvider: MockActivityProvider(),
    ),
  );
});
```

### Integration Tests (Can be added)
```dart
// Test full user flows
testWidgets('User can sign up, log activity, see streak', (...) async {
  // E2E testing
});
```

---

## Deployment Considerations

### Android
```bash
flutter build apk          # Debug APK
flutter build appbundle    # App Bundle for Play Store
```

### iOS
```bash
flutter build ios          # Debug build
flutter build ipa          # For App Store
```

### Configuration
- Update app name and version in pubspec.yaml
- Configure app icons in flutter app settings
- Update Supabase credentials for production
- Enable production JWT tokens

---

## Future Scaling

### Adding Notifications
```
NotificationService
    ├─ Firebase Cloud Messaging
    └─ Local notifications
```

### Adding Offline Sync
```
OfflineActivityService
    ├─ Hive local storage
    ├─ Queue for upload
    └─ Sync when online
```

### Adding Multiple Habits
```
HabitProvider (new)
    ├─ Create/edit habits
    ├─ Track multiple streaks
    └─ Habit grouping
```

---

## Summary

MoveStreak uses a **clean, scalable architecture** with:
- ✅ Clear separation of concerns
- ✅ Provider pattern for state management
- ✅ Service layer for business logic
- ✅ Type-safe models
- ✅ Secure cloud backend
- ✅ Efficient data querying
- ✅ Error handling throughout
- ✅ Optimized performance

This foundation allows for easy feature additions and maintains code quality as the app grows!
