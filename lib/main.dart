import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movestreak/providers/auth_provider.dart';
import 'package:movestreak/providers/activity_provider.dart';
import 'package:movestreak/providers/quote_provider.dart';
import 'package:movestreak/screens/sign_in_screen.dart';
import 'package:movestreak/screens/home_screen.dart';

const String SUPABASE_URL = 'https://dvzjuttdxywkujczrneb.supabase.co';
const String SUPABASE_ANON_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2emp1dHRkeHl3a3VqY3pybmViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5MTkyNjgsImV4cCI6MjA4NTQ5NTI2OH0.CigoBXjvxRjIxAJ_mqPZ0jsRN84X8PnU2HOXqZTm908';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(url: SUPABASE_URL, anonKey: SUPABASE_ANON_KEY);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
      ],
      child: MaterialApp(
        title: 'MoveStreak',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          appBarTheme: AppBarTheme(elevation: 0),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isLoggedIn ? HomeScreen() : SignInScreen();
          },
        ),
      ),
    );
  }
}
