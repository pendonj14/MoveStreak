# MoveStreak 🎯

A Flutter app that helps users build lasting physical activity habits through **streak tracking**, **daily logging**, and **motivational quotes**. The app emphasizes **consistency over intensity** and provides simple, frictionless habit formation.

## 🎯 Features

### Core Features (MVP)

#### 👤 User Authentication
- Email/password sign up and sign in
- Secure authentication via Supabase
- Individual user accounts and data isolation

#### 📝 Activity Logging
- Log physical activities with just a few taps
- Add optional duration and notes
- Pre-filled activity suggestions (Walk, Gym, Yoga, etc.)
- Log activities for today or past days

#### 🔥 Streak Tracking
- **Current streak**: Days in a row with at least one activity
- **Longest streak**: Best streak achieved
- Visual streak counter on home screen
- Streak resets if a day is missed
- Motivational messages based on streak status

#### 📅 Activity History
- Calendar view of past activities
- Visual indicators for days with activities
- Month navigation
- Click-to-view activity details
- See which days maintained your streak

#### ✨ Daily Motivational Quotes
- Random motivational quote fetched daily from Quotable API
- Cached to reduce API calls
- Fallback quote if API is unavailable
- Displayed on home screen

#### 🌐 Cloud Sync
- All data synced via Supabase
- Cross-device support
- Secure data storage

## 🛠️ Tech Stack

**Frontend:**
- Flutter 3.10.8+
- Dart 3.0+
- Material Design 3

**State Management:**
- Provider (state management)
- ChangeNotifier pattern

**Backend & Database:**
- Supabase (open-source Firebase alternative)
- PostgreSQL database
- Row Level Security (RLS)

**APIs:**
- Quotable API (motivational quotes)

**Local Storage:**
- SharedPreferences (caching)
- Hive (ready for offline support)

**Other Libraries:**
- http (API calls)
- intl (date formatting)
- json_annotation/json_serializable (JSON handling)

## 📦 Installation

### Prerequisites
- Flutter SDK 3.10.8+
- Dart SDK 3.0+
- Supabase account (free tier)

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd movestreak
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Create Supabase project**
   - Go to https://supabase.com
   - Create a new project
   - Copy your Project URL and Anon Key

4. **Configure credentials**
   - Open `lib/main.dart`
   - Replace `SUPABASE_URL` and `SUPABASE_ANON_KEY`

5. **Set up database**
   - In Supabase dashboard, go to SQL Editor
   - Create new query
   - Copy SQL from `supabase/migrations/01_create_schema.sql`
   - Run the query

6. **Run the app**
   ```bash
   flutter run
   ```

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup instructions.

## 📱 Screenshots & UX

### Sign In/Sign Up
- Clean email/password forms
- Form validation
- Error handling
- Link to switch between sign in and sign up

### Home Screen
- **Streak Card**: Large, prominent current streak display
- **Motivational Quote**: Inspirational quote with author
- **Today's Activities**: List of logged activities for today
- **Quick Actions**: 
  - Log Activity button
  - View History button

### Log Activity Screen
- Activity name field (required)
- Quick suggestions (Walk, Jog, Gym, etc.)
- Duration field (optional)
- Notes field (optional)
- Activity logging button

### History Screen
- Month calendar with visual indicators
- Green for days with activities
- Gray for empty days
- Orange border for today
- Click day to see details
- Month navigation arrows

## 🚀 Usage

### Logging an Activity
1. Tap "Log Activity" button
2. Select or enter activity name
3. (Optional) Add duration in minutes
4. (Optional) Add notes
5. Tap "Log Activity"
6. See your streak increase!

### Viewing History
1. Tap "View History" button
2. See calendar for current month
3. Use arrows to navigate months
4. Tap any day to see details
5. Green days = activities logged

### Building Your Streak
- Log at least one activity per day
- Avoid missing days to keep streak alive
- The app displays encouragement messages
- Come back daily to maintain momentum

## 🧪 Testing

### Test Credentials (After Setup)
```
Email: test@example.com
Password: testpassword123
```

### Testing Streaks
1. Log activities for multiple consecutive days
2. Skip a day to see streak reset
3. Start a new streak
4. View longest streak in history

## 📊 Project Structure

```
movestreak/
├── lib/
│   ├── main.dart                    # App entry, Supabase init
│   ├── models/
│   │   ├── activity.dart           # Activity data model
│   │   ├── user.dart               # User data model
│   │   ├── quote.dart              # Quote data model
│   │   └── streak_info.dart        # Streak calculation result
│   ├── services/
│   │   ├── auth_service.dart       # Auth operations
│   │   ├── activity_service.dart   # Activity CRUD
│   │   ├── streak_service.dart     # Streak calculation logic
│   │   └── quote_service.dart      # Quote fetching & caching
│   ├── providers/
│   │   ├── auth_provider.dart      # Auth state management
│   │   ├── activity_provider.dart  # Activity state management
│   │   └── quote_provider.dart     # Quote state management
│   └── screens/
│       ├── sign_in_screen.dart     # Login UI
│       ├── sign_up_screen.dart     # Registration UI
│       ├── home_screen.dart        # Main dashboard
│       ├── log_activity_screen.dart # Activity logging UI
│       └── history_screen.dart     # Calendar history view
├── supabase/
│   └── migrations/
│       └── 01_create_schema.sql    # Database schema
├── pubspec.yaml                     # Dependencies
├── SETUP_GUIDE.md                   # Setup instructions
└── README.md                        # This file
```

## 🔐 Security Features

- **Row Level Security (RLS)**: Users can only access their own data
- **Authentication**: Secure email/password via Supabase
- **Data Encryption**: Supabase handles encryption at rest
- **HTTPS**: All API calls use HTTPS

## 🌐 API Integration

### Quotable API
- **Endpoint**: `https://api.quotable.io/random?tags=motivational`
- **Cache**: One quote per day per user
- **Timeout**: 5 seconds
- **Fallback**: Generic motivational quote if API fails

## 📈 Streak Calculation Logic

1. Get all activities from past 30 days
2. Extract unique dates with activities
3. Count consecutive days backwards from today
4. If missed a day, check if it's today/yesterday (allow 1-day gap)
5. Calculate longest streak from all available data

## 🔄 State Management Flow

```
AuthProvider (User authentication)
    ↓
ActivityProvider (Activity management & streak calculation)
    ↓
QuoteProvider (Daily quote fetching)
    ↓
UI Screens (Display and interact with data)
```

## 📝 Offline Support (Ready for Implementation)

The app is structured to support offline-first functionality:
- Activities can be logged offline
- Hive package included for local database
- Sync when connection restored
- Implementation can be added in Phase 2

## 🐛 Known Limitations

- No social features (friends, challenges)
- No push notifications
- No wearable integration
- Single habit tracking only
- Mobile-only (web/desktop not tested)

## 🚦 Future Enhancements

- [ ] Push notifications for reminders
- [ ] Multiple habit tracking
- [ ] Social features (friends, leaderboards)
- [ ] Weekly/monthly reports and analytics
- [ ] Custom habit templates
- [ ] Dark mode
- [ ] Habit streak sharing
- [ ] Achievements/badges
- [ ] Cloud backup & restore
- [ ] Offline sync when online restored

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is provided as-is for educational and personal use.

## 📞 Support

For issues or questions:
1. Check the SETUP_GUIDE.md
2. Review the code comments
3. Check Supabase documentation
4. Check Flutter documentation

## 🎓 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Supabase Documentation](https://supabase.com/docs)
- [Provider Pattern](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io)

## 🎉 About MoveStreak

MoveStreak was created to solve a simple problem: **How do we help people build lasting physical activity habits?**

Instead of tracking performance metrics (calories, distance, speed), we focus on **consistency**. The philosophy is:
- **Show up consistently** = Win
- **Build streaks** = Get motivated
- **See progress visually** = Stay encouraged

One move at a time. One day at a time. One streak at a time. 🔥

---

Built with ❤️ for habit builders everywhere.
