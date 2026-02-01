import 'package:flutter/material.dart';
import 'package:movestreak/models/activity.dart';
import 'package:movestreak/models/streak_info.dart';
import 'package:movestreak/services/activity_service.dart';
import 'package:movestreak/services/streak_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService;
  final StreakService _streakService;

  List<Activity> _activities = [];
  StreakInfo _streakInfo = StreakInfo();
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  ActivityProvider({ActivityService? activityService})
      : _activityService = activityService ?? ActivityService(),
        _streakService = StreakService();

  List<Activity> get activities => _activities;
  StreakInfo get streakInfo => _streakInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  Future<void> loadActivitiesForDate({
    required String userId,
    required DateTime date,
  }) async {
    _isLoading = true;
    _error = null;
    _selectedDate = date;
    notifyListeners();

    try {
      _activities = await _activityService.getActivitiesForDate(
        userId: userId,
        date: date,
      );

      await _loadStreakInfo(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logActivity({
    required String userId,
    required String name,
    String? notes,
    int? durationMinutes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final activity = await _activityService.logActivity(
        userId: userId,
        name: name,
        notes: notes,
        durationMinutes: durationMinutes,
        activityDate: _selectedDate,
      );

      _activities.add(activity);
      await _loadStreakInfo(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteActivity({
    required String userId,
    required String activityId,
  }) async {
    try {
      await _activityService.deleteActivity(activityId);
      _activities.removeWhere((activity) => activity.id == activityId);

      await _loadStreakInfo(userId);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadStreakInfo(String userId) async {
    try {
      _streakInfo = await _streakService.calculateStreak(userId);
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> hasActivityOnDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      return await _activityService.hasActivityOnDate(
        userId: userId,
        date: date,
      );
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
