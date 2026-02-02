import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movestreak/providers/auth_provider.dart';
import 'package:movestreak/providers/activity_provider.dart';
import 'package:movestreak/providers/quote_provider.dart';
import 'package:movestreak/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  String? _selectedActivity;

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

    // 1. Controller first
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 2. Progress animation second
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // 3. Pulse animation third (Essential order!)
    _pulseAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.1),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.1, end: 1.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
          ),
        );

    // 4. Data last
    _loadData(isInitial: true);
  }

  Future<void> _loadData({bool isInitial = false}) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      // Only load quote on initial startup to prevent layout shifts
      if (isInitial) context.read<QuoteProvider>().loadDailyQuote();

      await context.read<ActivityProvider>().loadActivitiesForDate(
        userId: authProvider.user!.id,
        date: DateTime.now(),
      );

      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020510),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MoveStreak',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 25,
            fontWeight: FontWeight.w900,

            letterSpacing: 2,
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 140),
                _buildAnimatedStreakCircle(),
                const SizedBox(height: 50),
                _buildQuoteSection(),
                const SizedBox(height: 50),
                _buildActivitySuggestions(),
                const SizedBox(height: 40),
                _buildLogButton(),
                const SizedBox(height: 60),
              ],
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
        final double targetProgress = (streak / 30).clamp(0.005, 1.0);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Animates the number from 0 to current streak
            final animatedNumber = (_progressAnimation.value * streak).floor();

            return ScaleTransition(
              scale: _pulseAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: StreakCirclePainter(
                          progress: _progressAnimation.value * targetProgress,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$animatedNumber',
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
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivitySuggestions() {
    return Column(
      children: [
        const Text(
          "TODAY'S MOVEMENT",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _activitySuggestions.map((suggestion) {
            final isSelected = _selectedActivity == suggestion;
            return GestureDetector(
              onTap: () => setState(() => _selectedActivity = suggestion),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8DA4EE)
                      : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  suggestion.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogButton() {
    return Consumer2<AuthProvider, ActivityProvider>(
      builder: (context, auth, activity, _) {
        bool isActive = _selectedActivity != null && !activity.isLoading;
        return GestureDetector(
          onTap: isActive
              ? () async {
                  await activity.logActivity(
                    userId: auth.user!.id,
                    name: _selectedActivity!,
                  );
                  setState(() => _selectedActivity = null);
                  _loadData(); // This refreshes streak and triggers pulse
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF8DA4EE), Color(0xFF6C7FD8)],
                    )
                  : null,
              color: isActive ? null : Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              activity.isLoading ? "LOGGING..." : "LOG ACTIVITY",
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuoteSection() {
    return Consumer<QuoteProvider>(
      builder: (context, provider, _) {
        return Text(
          provider.quote?.content ?? "Keep moving forward.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        );
      },
    );
  }
}

class StreakCirclePainter extends CustomPainter {
  final double progress;
  StreakCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF8DA4EE), Color(0xFFC0CEFA), Color(0xFF8DA4EE)],
        stops: [0.0, 0.5, 1.0],
        startAngle: -pi / 2,
        endAngle: pi * 1.5,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Outer Decoration dots
    final dotPaint = Paint()..color = Colors.white12;
    for (int i = 0; i < 60; i++) {
      double angle = (i * 6) * (pi / 180);
      double dx = center.dx + (radius + 20) * cos(angle);
      double dy = center.dy + (radius + 20) * sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.2, dotPaint);
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
  bool shouldRepaint(covariant StreakCirclePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
