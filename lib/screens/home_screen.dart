import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:movestreak/providers/auth_provider.dart';
import 'package:movestreak/providers/activity_provider.dart';
import 'package:movestreak/providers/quote_provider.dart';
import 'package:movestreak/screens/log_activity_screen.dart';
import 'package:movestreak/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;  String? _selectedActivity;
  final List<String> _activitySuggestions = [
    'Walk',
    'Jog',
    'Run',
    'Gym',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();

    // 1. Initialize the controller first
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 2. Initialize the animation variable second
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // 3. ONLY THEN call data loading/start animation
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<ActivityProvider>().loadActivitiesForDate(
        userId: authProvider.user!.id,
        date: DateTime.now(),
      );
    }
    context.read<QuoteProvider>().loadDailyQuote();
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020510), // Deep Dark Background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MoveStreak',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white54),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [Color(0xFF0F1730), Color(0xFF020510)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  const Text(
                    "Let's Get Started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // CIRCULAR STREAK TRACKER
                  _buildAnimatedStreakCircle(),

                  const SizedBox(height: 60),
                  _buildQuoteSection(),
                  const SizedBox(height: 40),
                  _buildActivitySuggestions(),
                  const SizedBox(height: 40),
                  _buildLogButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStreakCircle() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, _) {
        final streak = provider.streakInfo.currentStreak;
        // Logic: Streak as a percentage of the month (approx 30 days)
        final double progress = (streak / 30).clamp(0.0, 1.0);

        return AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 260,
                  child: CustomPaint(
                    painter: StreakCirclePainter(
                      progress: _progressAnimation.value * progress,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'DAY STREAK',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildQuoteSection() {
    return Consumer<QuoteProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const SizedBox.shrink();
        return FadeIn(
          duration: const Duration(seconds: 1),
          child: Text(
            provider.quote?.content ?? "Keep moving forward.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitySuggestions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _activitySuggestions
          .map(
            (suggestion) => ActionChip(
              label: Text(suggestion),
              onPressed: () {
                setState(() {
                  _selectedActivity = suggestion;
                });
              },
              backgroundColor: _selectedActivity == suggestion
                  ? Colors.green[600]
                  : Colors.green[100],
              labelStyle: TextStyle(
                color: _selectedActivity == suggestion
                    ? Colors.white
                    : Colors.green[800],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLogButton() {
    return Consumer2<AuthProvider, ActivityProvider>(
      builder: (context, authProvider, activityProvider, _) {
        return GestureDetector(
          onTap: _selectedActivity == null || activityProvider.isLoading
              ? null
              : () async {
                  if (authProvider.user != null) {
                    await activityProvider.logActivity(
                      userId: authProvider.user!.id,
                      name: _selectedActivity!,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$_selectedActivity logged! You showed up today! 🎉',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      setState(() {
                        _selectedActivity = null;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadData();
                      });
                    }
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _selectedActivity == null
                    ? Colors.white12
                    : Colors.white24,
              ),
              color: _selectedActivity == null
                  ? Colors.white.withOpacity(0.02)
                  : Colors.white.withOpacity(0.05),
            ),
            child: Text(
              activityProvider.isLoading ? "LOGGING..." : "LOG ACTIVITY",
              style: TextStyle(
                color: _selectedActivity == null
                    ? Colors.white38
                    : Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

// CUSTOM PAINTER FOR THE CIRCLE
class StreakCirclePainter extends CustomPainter {
  final double progress;
  StreakCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 25.0;

    // Background track (Darker circle)
    final bgPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Progress track (Glowing blue/white)
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF8DA4EE), Color(0xFFC0CEFA)],
        startAngle: -pi / 2,
        endAngle: pi * 1.5,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Outer dotted decoration (from your image)
    final dotPaint = Paint()..color = Colors.white24;
    for (int i = 0; i < 60; i++) {
      double angle = (i * 6) * (pi / 180);
      double dx = center.dx + (radius + 20) * cos(angle);
      double dy = center.dy + (radius + 20) * sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
    }

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// SIMPLE FADE ANIMATION WIDGET
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const FadeIn({required this.child, required this.duration, Key? key})
    : super(key: key);

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: widget.child);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
