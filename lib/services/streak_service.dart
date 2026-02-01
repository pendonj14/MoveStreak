import 'package:movestreak/models/streak_info.dart';
import 'package:movestreak/services/activity_service.dart';

class StreakService {
  final ActivityService _activityService;

  StreakService({ActivityService? activityService})
      : _activityService = activityService ?? ActivityService();

  Future<StreakInfo> calculateStreak(String userId) async {
    try {
      final today = DateTime.now();
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));

      final activities =
          await _activityService.getActivitiesForDateRange(
        userId: userId,
        startDate: thirtyDaysAgo,
        endDate: today,
      );

      // Get unique dates with activities
      final datesWithActivity = activities
          .map((activity) => activity.date)
          .toSet()
          .toList();

      datesWithActivity.sort();

      // Calculate current streak
      int currentStreak = 0;
      bool isStreakActive = false;
      DateTime? lastActivityDate;

      if (datesWithActivity.isNotEmpty) {
        lastActivityDate = datesWithActivity.last;

        // Check if activity was today or yesterday
        final daysSinceLastActivity = today.difference(lastActivityDate).inDays;

        if (daysSinceLastActivity == 0 || daysSinceLastActivity == 1) {
          // Calculate streak backwards from today
          DateTime checkDate = today;
          currentStreak = 0;

          // Allow 1 day gap (for timezone/time zone differences)
          while (checkDate.isAfter(
              thirtyDaysAgo.subtract(const Duration(days: 1)))) {
            final hasActivity =
                datesWithActivity.any((date) => _isSameDay(date, checkDate));

            if (hasActivity) {
              currentStreak++;
              checkDate = checkDate.subtract(const Duration(days: 1));
            } else if (checkDate.difference(today).inDays == 0 ||
                checkDate.difference(today).inDays == -1) {
              // Allow skipping today/yesterday
              checkDate = checkDate.subtract(const Duration(days: 1));
            } else {
              break;
            }
          }

          isStreakActive = daysSinceLastActivity <= 1;
        }
      }

      // Calculate longest streak from all available activities
      int longestStreak = _calculateLongestStreak(datesWithActivity);

      return StreakInfo(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastActivityDate: lastActivityDate,
        isStreakActive: isStreakActive,
      );
    } catch (e) {
      return StreakInfo();
    }
  }

  int _calculateLongestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    dates.sort();

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final dayDiff = dates[i].difference(dates[i - 1]).inDays;

      if (dayDiff == 1) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } else if (dayDiff > 1) {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
