class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final bool isStreakActive;

  StreakInfo({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.isStreakActive = false,
  });

  StreakInfo copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    bool? isStreakActive,
  }) {
    return StreakInfo(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      isStreakActive: isStreakActive ?? this.isStreakActive,
    );
  }
}
