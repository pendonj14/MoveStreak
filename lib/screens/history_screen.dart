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
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity History'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Month Navigation
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(),

            // Calendar View
            Expanded(
              child: Consumer2<AuthProvider, ActivityProvider>(
                builder: (context, authProvider, activityProvider, _) {
                  if (authProvider.user == null) {
                    return Center(child: Text('Not logged in'));
                  }

                  return FutureBuilder(
                    future: activityProvider.loadActivitiesForDate(
                      userId: authProvider.user!.id,
                      date: _selectedMonth,
                    ),
                    builder: (context, snapshot) {
                      return _buildCalendarView(
                        context,
                        authProvider.user!.id,
                        activityProvider,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    String userId,
    ActivityProvider activityProvider,
  ) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weekday headers
            _buildWeekdayHeaders(),
            SizedBox(height: 8),

            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: firstWeekday - 1 + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) {
                  // Empty cells before month starts
                  return SizedBox.shrink();
                }

                final dayNumber = index - firstWeekday + 2;
                final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);

                return FutureBuilder<bool>(
                  future:
                      activityProvider.hasActivityOnDate(
                    userId: userId,
                    date: date,
                  ),
                  builder: (context, snapshot) {
                    final hasActivity = snapshot.data ?? false;
                    final isToday = DateTime.now().day == dayNumber &&
                        DateTime.now().month == _selectedMonth.month &&
                        DateTime.now().year == _selectedMonth.year;

                    return GestureDetector(
                      onTap: () {
                        activityProvider.loadActivitiesForDate(
                          userId: userId,
                          date: date,
                        );
                        _showDayDetails(context, date, hasActivity);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: hasActivity
                              ? Colors.green[600]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayNumber.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: hasActivity
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              if (hasActivity)
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            SizedBox(height: 32),

            // Legend
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legend:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Activity Logged'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('No Activity'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.orange,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Today'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            weekdays[index],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        );
      },
    );
  }

  void _showDayDetails(
    BuildContext context,
    DateTime date,
    bool hasActivity,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer2<AuthProvider, ActivityProvider>(
          builder: (context, authProvider, activityProvider, _) {
            return FutureBuilder(
              future: activityProvider.loadActivitiesForDate(
                userId: authProvider.user!.id,
                date: date,
              ),
              builder: (context, snapshot) {
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        Center(child: CircularProgressIndicator())
                      else if (activityProvider.activities.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('No activities on this day'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: activityProvider.activities.length,
                          itemBuilder: (context, index) {
                            final activity =
                                activityProvider.activities[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green[200]!,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (activity.notes != null &&
                                        activity.notes!.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(activity.notes!),
                                      ),
                                    if (activity.durationMinutes != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '${activity.durationMinutes} minutes',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
