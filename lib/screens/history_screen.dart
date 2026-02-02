import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movestreak/providers/auth_provider.dart';
import 'package:movestreak/providers/activity_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // We'll show the last 6 months to better mimic the GitHub contribution view
  final DateTime _today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020510), // Matching Home theme
      appBar: AppBar(
        title: const Text(
          'ACTIVITY HISTORY',
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white54,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<AuthProvider, ActivityProvider>(
        builder: (context, authProvider, activityProvider, _) {
          if (authProvider.user == null) {
            return const Center(
              child: Text(
                'Please log in',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 150,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader("HISTORY"),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildContributionGrid(
                      authProvider.user!.id,
                      activityProvider,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildContributionGrid(String userId, ActivityProvider provider) {
    // Number of weeks to display
    final int weeksToShow = 20;
    // Calculate the start date (Oldest date on the far left)
    final DateTime startDate = _today.subtract(
      Duration(days: _today.weekday - 1 + (weeksToShow - 1) * 7),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Ensures oldest history starts on the left
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Aligns bubbles to the left
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(weeksToShow, (weekIndex) {
                return Column(
                  children: List.generate(7, (dayIndex) {
                    final date = startDate.add(
                      Duration(days: (weekIndex * 7) + dayIndex),
                    );

                    // Don't draw future dates
                    if (date.isAfter(_today)) {
                      return _buildSquare(null, Colors.transparent);
                    }

                    return FutureBuilder<bool>(
                      future: provider.hasActivityOnDate(
                        userId: userId,
                        date: date,
                      ),
                      builder: (context, snapshot) {
                        final hasActivity = snapshot.data ?? false;
                        final isToday =
                            date.day == _today.day &&
                            date.month == _today.month &&
                            date.year == _today.year;

                        return GestureDetector(
                          onTap: () =>
                              _showDayDetails(context, date, hasActivity),
                          child: _buildSquare(
                            date,
                            hasActivity
                                ? const Color(0xFF8DA4EE)
                                : Colors.white.withOpacity(0.05),
                            isToday: isToday,
                          ),
                        );
                      },
                    );
                  }),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Wrapped legend in a Row to center it horizontally under the grid
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildLegend()],
        ),
      ],
    );
  }

  Widget _buildSquare(DateTime? date, Color color, {bool isToday = false}) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: isToday ? Border.all(color: Colors.white70, width: 1) : null,
        boxShadow:
            (color != Colors.white.withOpacity(0.05) &&
                color != Colors.transparent)
            ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)]
            : null,
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min, // Keeps legend compact
      children: [
        const Text(
          "Less",
          style: TextStyle(color: Colors.white30, fontSize: 12),
        ),
        const SizedBox(width: 8),
        _buildSquare(null, Colors.white.withOpacity(0.05)),
        _buildSquare(null, const Color(0xFF8DA4EE).withOpacity(0.4)),
        _buildSquare(null, const Color(0xFF8DA4EE).withOpacity(0.7)),
        _buildSquare(null, const Color(0xFF8DA4EE)),
        const SizedBox(width: 8),
        const Text(
          "More",
          style: TextStyle(color: Colors.white30, fontSize: 12),
        ),
      ],
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, bool hasActivity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1730),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMM d').format(date).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (!hasActivity)
                const Text(
                  "No movement logged for this day.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: Color(0xFF8DA4EE)),
                      const SizedBox(width: 12),
                      const Text(
                        "Activity Completed",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
